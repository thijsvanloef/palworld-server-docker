#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"
# shellcheck source=scripts/mods/mod_state.sh
source "/home/steam/server/mods/mod_state.sh"

#-------------------------------------------------
# Mods env vars
#-------------------------------------------------
MOD_ENABLED="${MOD_ENABLED:-true}"
MOD_URL_UE4SS="${MOD_URL_UE4SS:-https://github.com/Okaetsu/RE-UE4SS/releases/download/2281fa31/UE4SS-Palworld-g2281fa31.zip}"
MOD_ID_PALSCHEMA="${MOD_ID_PALSCHEMA:-3625280368}"
MOD_USE_PALDEFENDER="${MOD_USE_PALDEFENDER:-false}"
MOD_URL_PALDEFENDER="${MOD_URL_PALDEFENDER:-https://github.com/Ultimeit/PalDefender/releases/latest/download/PalDefender.zip}"

#-------------------------------------------------
# Mods internal vars
#-------------------------------------------------
image="thijsvanloef/palworld-server-docker:wine"
bin_dir="/palworld/Pal/Binaries/Win64"
native_mods_dir="/palworld/Mods/NativeMods"
native_staging_dir="/palworld/Mods/.tmp/native-mods"
workshop_staging_dir="/palworld/Mods/.workshop"
ue4ss_staging_dir="/palworld/Mods/.tmp/ue4ss-palworld"
ue4ss_mods_config_staging_file="/palworld/Mods/.tmp/ue4ss-mods.txt"
ue4ss_mods_dir="${bin_dir}/ue4ss/Mods"
workshop_app_id="1623730"
state_file="/palworld/Mods/.state.json"
state_backup_dir="/palworld/Mods/.state-backups"
state_journal_file="/palworld/Mods/.state-journal.json"
steamcmd_bin="${steamcmd_bin:-/home/steam/steamcmd/steamcmd.sh}"
steam_login_user_file="/palworld/.steam/.steam-login-user"
workshop_mods_file="${workshop_mods_file:-/palworld/Mods/workshop-mods.txt}"
previous_state='{}'
v="$(isTrue "${MOD_DEBUG:-false}" && echo "v")"
download_ue4ss=true
MOD_STATE_DEPLOYMENTS=()
MOD_STATE_PACKAGES='{}'
MOD_STATE_ORDER=0

#-------------------------------------------------
# helper functions
#-------------------------------------------------

# Trim leading and trailing whitespace from a string.
_trim() {
    local value="${1:-}"
    value="$(printf '%s' "${value}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf '%s' "${value}"
}

# Write a debug log message when mod debugging is enabled.
ModLog_debug() {
    local msg="${1:-(no message)}"
    isTrue "${MOD_DEBUG:-false}" && LogInfo "[MODS DEBUG] ${msg}"
}

# Append a value only once to the named tracking array.
ModTrack_addUnique() {
    local -n tracked_items="$1"
    local value="$2"
    local existing

    for existing in "${tracked_items[@]}"; do
        [ "${existing}" = "${value}" ] && return 0
    done
    tracked_items+=("${value}")
}

# Populate the named array with NativeMods directory names, without deploying anything.
NativeMods_listNames() {
    local -n out_names="$1"
    local mod_path
    while IFS= read -r -d '' mod_path; do
        out_names+=("$(basename "${mod_path}")")
    done < <(find "${native_mods_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | LC_ALL=C sort -z)
}

ModState_isSafeTargetPath() {
    local target_path="${1:-}"
    [[ -n "${target_path}" ]] || return 1
    [[ "${target_path}" == "/palworld"* ]] || return 1
    [[ "${target_path}" != *".."* ]] || return 1
    return 0
}

ModState_registerPackage() {
    local owner_key="$1"
    local kind="$2"
    local name="$3"
    local source_id="$4"
    local version="${5:-unknown}"

    MOD_STATE_PACKAGES="$(jq -c --arg owner "${owner_key}" --arg kind "${kind}" --arg name "${name}" --arg source_id "${source_id}" --arg version "${version}" '. + {($owner):{kind:$kind,name:$name,source_id:$source_id,version:$version}}' <<< "${MOD_STATE_PACKAGES}")"
}

ModState_recordTree() {
    local source_root="${1:-}"
    local target_root="${2:-}"
    local owner_key="${3:-}"
    local order="${4:-}"
    local source_file rel_path target_file

    [ -n "${source_root}" ] || return 0
    [ -n "${target_root}" ] || return 0
    [ -n "${owner_key}" ] || return 0

    # Collect desired files only; the reconciler applies them after all packages are staged.
    if [ -d "${source_root}" ]; then
        while IFS= read -r -d '' source_file; do
            rel_path="${source_file#"${source_root}"/}"
            target_file="${target_root%/}/${rel_path}"
            ModState_recordFileClaim "${owner_key}" "${source_file}" "${target_file}" "${order}"
        done < <(find "${source_root}" -type f -print0 2>/dev/null | LC_ALL=C sort -z)
    elif [ -f "${source_root}" ]; then
        ModState_recordFileClaim "${owner_key}" "${source_root}" "${target_root}" "${order}"
    fi
}

ModState_recordFileClaim() {
    local owner_key="$1"
    local source_file="$2"
    local target_file="$3"
    local order="${4:-}"
    local claim

    # Owner identity is independent of the package's display name.
    if ! ModStateV3_isSafeTargetPath "${target_file}" "/palworld"; then
        LogWarn "Skipping unsafe mod deployment target: ${target_file}"
        return 0
    fi
    if [ -z "${order}" ]; then
        MOD_STATE_ORDER=$((MOD_STATE_ORDER + 1))
        order="${MOD_STATE_ORDER}"
    fi
    claim="$(jq -nc --arg owner "${owner_key}" --arg source "${source_file}" --arg target "${target_file}" --argjson order "${order}" --arg sha256 "$(ModStateV3_hashFile "${source_file}")" '{owner:$owner,source:$source,target:$target,order:$order,sha256:$sha256}')"
    MOD_STATE_DEPLOYMENTS+=("${claim}")
}

# Given a source path and a target path, remove only the contents of the source from the target.
# $1: source_path
# $2: target_path
# $3: compare timestamp (true/false, default: true)
#     do not remove target files if they are newer than source files
Mod_removeSourceFromTarget() {
    local source_path="$1"
    local target_path="$2"
    local compare_timestamp="${3:-true}"

    if [ -d "${source_path}" ]; then
        ModLog_debug "Removing source directory from target: ${source_path} → ${target_path}"
        if [ ! -d "${target_path}" ]; then
            return 0
        fi

        local item
        for item in "${source_path}/"*; do
            [ -e "${item}" ] || continue
            local relative_item="${item#"${source_path}/"}"
            Mod_removeSourceFromTarget "${item}" "${target_path}/${relative_item}" "${compare_timestamp}"
        done

        if [ -d "${target_path}" ] && [ -z "$(ls -A "${target_path}")" ]; then
            ModLog_debug "Removing empty directory: ${target_path}"
            rmdir "${target_path}"
        fi
    elif [ -f "${source_path}" ]; then
        ModLog_debug "Removing source file from target: ${target_path}"
        if [ -f "${target_path}" ]; then
            if isTrue "${compare_timestamp}"; then
                local source_mtime target_mtime
                source_mtime="$(stat -c '%Y' "${source_path}" 2>/dev/null || echo 0)"
                target_mtime="$(stat -c '%Y' "${target_path}" 2>/dev/null || echo 0)"
                if [ "${target_mtime}" -le "${source_mtime}" ]; then
                    rm "-f${v}" "${target_path}"
                else
                    ModLog_debug "Kept user-modified file: ${target_path}"
                fi
            else
                rm "-f${v}" "${target_path}"
            fi
        fi
    fi
}

#-------------------------------------------------
# PalDefender functions
#-------------------------------------------------

# Download and deploy PalDefender, or remove it when disabled.
PalDefender_update() {
    local zip_file="/palworld/Mods/.cache/PalDefender.zip"
    local tmp_file="${zip_file}.tmp"
    local target_dir="$1"
    local should_extract=false

    if ! isTrue "${MOD_USE_PALDEFENDER}"; then
        if [ -f "${target_dir}/PalDefender.dll" ] || [ -f "${target_dir}/d3d9.dll" ]; then
            LogInfo "Removed PalDefender files from target: ${target_dir}"
            rm -f "${target_dir}/PalDefender.dll" "${target_dir}/d3d9.dll"
        fi
        return 0
    fi

    mkdir -p "$(dirname "${zip_file}")"
    mkdir -p "$(dirname "${target_dir}")"

    if [ -f "${zip_file}" ]; then
        if ! curl -sSfL -o "${tmp_file}" -z "${zip_file}" "${MOD_URL_PALDEFENDER}"; then
            LogWarn "Failed to download PalDefender package from ${MOD_URL_PALDEFENDER}."
            return 0
        fi
        if [ -s "${tmp_file}" ]; then
            mv -f "${tmp_file}" "${zip_file}"
            should_extract=true
            LogInfo "Downloaded newer PalDefender package."
        else
            rm -f "${tmp_file}"
            if [ ! -f "${target_dir}/PalDefender.dll" ] || [ ! -f "${target_dir}/d3d9.dll" ]; then
                should_extract=true
            fi
        fi
    else
        if ! curl -sSfL -o "${zip_file}" "${MOD_URL_PALDEFENDER}"; then
            LogWarn "Failed to download PalDefender package from ${MOD_URL_PALDEFENDER}."
            return 0
        fi
        should_extract=true
    fi
    if isTrue "${should_extract}"; then
        LogInfo "Deploying PalDefender package to target: ${target_dir}"
        unzip -o "${zip_file}" -d "${target_dir}"
    fi
}

#-------------------------------------------------
# UE4SS functions
#-------------------------------------------------

# Check whether a directory contains recognizable UE4SS artifacts.
UE4SS_isDownloaded() {
    local source_dir="$1"

    [ -d "${source_dir}/ue4ss" ] || \
    [ -f "${source_dir}/dwmapi.dll" ] || \
    [ -f "${source_dir}/UE4SS.dll" ] || \
    [ -f "${source_dir}/UE4SS-settings.ini" ] || \
    [ -f "${source_dir}/MemberVariableLayout.ini" ] || \
    [ -f "${source_dir}/Vindsent.dll" ]
}

# Report the cached UE4SS package's mtime as a version fingerprint, or "missing" if not cached yet.
UE4SS_zipMtime() {
    local zip_file="/palworld/Mods/.cache/UE4SS-Palworld.zip"
    if [ -f "${zip_file}" ]; then
        stat -c '%Y' "${zip_file}" 2>/dev/null || echo missing
    else
        echo missing
    fi
}

# Update the cached UE4SS package and extract it into the staging directory.
UE4SS_sync() {
    local zip_file="/palworld/Mods/.cache/UE4SS-Palworld.zip"
    local tmp_file="${zip_file}.tmp"
    local target_dir="$1"
    local should_extract=false

    if ! isTrue "${download_ue4ss}"; then
        if [ -d "${target_dir}" ]; then
            rm -rf "${target_dir}"
        fi
        return 0
    fi

    mkdir -p "$(dirname "${zip_file}")"
    mkdir -p "$(dirname "${target_dir}")"

    if [ -f "${zip_file}" ]; then
        if curl -sSfL -z "${zip_file}" -o "${tmp_file}" "${MOD_URL_UE4SS}"; then
            if [ -s "${tmp_file}" ]; then
                mv -f "${tmp_file}" "${zip_file}"
                should_extract=true
                LogInfo "Downloaded newer UE4SS Palworld package."
            else
                rm -f "${tmp_file}"
                if [ ! -d "${target_dir}" ]; then
                    should_extract=true
                fi
            fi
        else
            LogWarn "Failed to check UE4SS Palworld updates from ${MOD_URL_UE4SS}. Using local cache if available."
            rm -f "${tmp_file}"
            if [ ! -d "${target_dir}" ]; then
                should_extract=true
            fi
        fi
    else
        if ! curl -sSfL -o "${zip_file}" "${MOD_URL_UE4SS}"; then
            LogError "Failed to download UE4SS Palworld package from ${MOD_URL_UE4SS}."
            return 1
        fi
        LogInfo "Downloaded latest UE4SS Palworld package."
        should_extract=true
    fi

    if isTrue "${should_extract}"; then
        rm -rf "${target_dir}"
        mkdir -p "${target_dir}"

        if unzip -o "${zip_file}" -d "${target_dir}" >/dev/null; then
            ModLog_debug "Extracted UE4SS Palworld package to ${target_dir}"
        else
            LogWarn "Failed to extract UE4SS Palworld package."
            rm -rf "${target_dir}"
            return 1
        fi
    fi
    return 0
}

# Remove UE4SS artifacts recorded in the previous deployment state.
UE4SS_undeploy() {
    local state_json="$1"
    local tracked_path

    while IFS= read -r tracked_path; do
        [ -z "${tracked_path}" ] && continue
        Mod_removeSourceFromTarget "${ue4ss_staging_dir:?}/${tracked_path}" "${bin_dir:?}/${tracked_path}" true
    done < <(printf '%s' "${state_json}" | jq -r '.ue4ss.files[]? // empty' 2>/dev/null)
}

# Deploy UE4SS artifacts and record their top-level paths for later cleanup.
UE4SS_deploy() {
    local source_dir="$1"
    local owner_key="${2:-ue4ss}"
    local rel_path

    if ! UE4SS_isDownloaded "${source_dir}"; then
        return 0
    fi

    if [ "${owner_key}" = "ue4ss" ]; then
        ModState_registerPackage "ue4ss" "ue4ss" "UE4SS" "ue4ss" "$(UE4SS_zipMtime)"
    fi
    ModState_recordTree "${source_dir}" "${bin_dir}" "${owner_key}"

    # Only the top-level entry names are tracked for later cleanup.
    while IFS= read -r rel_path; do
        ModTrack_addUnique DEPLOYED_UE4SS_FILES "${rel_path}"
    done < <(find "${source_dir}" -mindepth 1 -maxdepth 1 -printf '%f\n')
}

# Enable deployed Lua mods in the UE4SS mods configuration file.
UE4SS_updateModsTxt() {
    local source_mods_txt mods_txt="${ue4ss_mods_config_staging_file}"
    source_mods_txt="$(find "${ue4ss_staging_dir}" -type f -path '*/Mods/mods.txt' -print -quit 2>/dev/null)"
    if [ -z "${source_mods_txt}" ] && [ -f "${ue4ss_mods_dir}/mods.txt" ]; then
        LogWarn "UE4SS staging mods.txt was not found. Falling back to the deployed file; removed MOD entries may remain enabled, so review and disable stale entries manually."
        source_mods_txt="${ue4ss_mods_dir}/mods.txt"
    fi
    [ -n "${source_mods_txt}" ] || return 0

    mkdir -p "$(dirname "${mods_txt}")"
    cp -p -- "${source_mods_txt}" "${mods_txt}"

    local lua_mod line already_in_file
    for lua_mod in "${DEPLOYED_LUA_MODS[@]}"; do
        already_in_file=false
        while IFS= read -r line || [ -n "${line:-}" ]; do
            if [[ "${line}" =~ ^[[:space:]]*${lua_mod}[[:space:]]*: ]]; then
                already_in_file=true
                break
            fi
        done < "${mods_txt}"
        if [ "${already_in_file}" = false ]; then
            printf '%s : 1\n' "${lua_mod}" >> "${mods_txt}"
            LogInfo "Enabled ${lua_mod} in mods.txt"
        fi
    done
    ModState_registerPackage "ue4ss" "ue4ss" "UE4SS" "ue4ss" "$(UE4SS_zipMtime)"
    ModState_recordFileClaim "ue4ss" "${mods_txt}" "${ue4ss_mods_dir}/mods.txt"
}

#-------------------------------------------------
# ModState functions
#-------------------------------------------------

ModState_cleanupEntry() {
    local record_json="${1:-}"
    local target_path source_mtime target_mtime source_path

    target_path="$(printf '%s' "${record_json}" | jq -r '.target_path // empty' 2>/dev/null || true)"
    source_path="$(printf '%s' "${record_json}" | jq -r '.source_path // empty' 2>/dev/null || true)"
    source_mtime="$(printf '%s' "${record_json}" | jq -r '.source_mtime // empty' 2>/dev/null || echo 0)"

    [ -n "${target_path}" ] || return 0
    if ! ModState_isSafeTargetPath "${target_path}"; then
        LogWarn "Ignoring unsafe deployment target while cleaning up previous state: ${target_path}"
        return 0
    fi

    if [ -n "${source_path}" ] && [ -f "${source_path}" ] && [ -z "${source_mtime}" ]; then
        source_mtime="$(stat -c '%Y' "${source_path}" 2>/dev/null || echo 0)"
    fi
    if ! [[ "${source_mtime}" =~ ^[0-9]+$ ]]; then
        source_mtime=0
    fi

    if [ -d "${target_path}" ]; then
        while IFS= read -r -d '' item; do
            if [ -f "${item}" ]; then
                target_mtime="$(stat -c '%Y' "${item}" 2>/dev/null || echo 0)"
                if [ "${target_mtime}" -le "${source_mtime}" ]; then
                    rm -f "${item}"
                fi
            elif [ -d "${item}" ]; then
                ModState_cleanupEntry "$(jq -nc --arg target_path "${item}" --arg source_mtime "${source_mtime}" '{target_path:$target_path,source_mtime:($source_mtime|tonumber)}')"
            fi
        done < <(find "${target_path}" -depth -mindepth 1 -print0 2>/dev/null)
        if [ -d "${target_path}" ] && [ -z "$(ls -A "${target_path}" 2>/dev/null)" ]; then
            rmdir "${target_path}" 2>/dev/null || true
        fi
        return 0
    fi

    if [ -f "${target_path}" ]; then
        target_mtime="$(stat -c '%Y' "${target_path}" 2>/dev/null || echo 0)"
        if [ "${target_mtime}" -le "${source_mtime}" ]; then
            rm -f "${target_path}"
        fi
    fi
}

# Remove artifacts that were deployed in the previous state.
ModState_cleanup() {
    local state_json="$1"
    local schema_version
    schema_version="$(printf '%s' "${state_json}" | jq -r '.schema_version // 1' 2>/dev/null || echo 1)"
    local item record

    if [ "${schema_version}" = "2" ] || [ -n "$(printf '%s' "${state_json}" | jq -r '.deployments[]? // empty' 2>/dev/null)" ]; then
        while IFS= read -r record; do
            [ -z "${record}" ] && continue
            ModState_cleanupEntry "${record}"
        done < <(printf '%s' "${state_json}" | jq -c '.deployments[]? // empty' 2>/dev/null)
        return 0
    fi

    while IFS= read -r item; do
        [ -z "${item}" ] && continue
        Mod_removeSourceFromTarget "/palworld/Mods/.workshop/${item}" "${ue4ss_mods_dir:?}/${item}" true
        Mod_removeSourceFromTarget "/palworld/Mods/NativeMods/${item}" "${ue4ss_mods_dir:?}/${item}" true
        ModLog_debug "Removed undeployed lua mod: ${item}"
    done < <(printf '%s' "${state_json}" | jq -r '.deployed_lua_mods[]? // empty' 2>/dev/null)

    while IFS= read -r item; do
        [ -z "${item}" ] && continue
        Mod_removeSourceFromTarget "/palworld/Mods/.workshop/${item}" "${ue4ss_mods_dir:?}/PalSchema/mods/${item}" true
        Mod_removeSourceFromTarget "/palworld/Mods/NativeMods/${item}" "${ue4ss_mods_dir:?}/PalSchema/mods/${item}" true
        ModLog_debug "Removed undeployed palschema mod: ${item}"
    done < <(printf '%s' "${state_json}" | jq -r '.deployed_palschema_mods[]? // empty' 2>/dev/null)

    while IFS= read -r item; do
        [ -z "${item}" ] && continue
        rm "-f${v}" "/palworld/Pal/Content/Paks/LogicMods/${item}"
        rm "-f${v}" "/palworld/Pal/Content/Paks/~mods/${item}"
        ModLog_debug "Cleaning up previous deployed pak: ${item}"
    done < <(printf '%s' "${state_json}" | jq -r '.deployed_paks[]? // empty' 2>/dev/null)

    UE4SS_undeploy "${state_json}"
}

ModState_cleanupStagingDirs() {
    rm -rf "${workshop_staging_dir}" "${ue4ss_staging_dir}"
}

# Build the JSON state describing currently discovered and deployed mods.
ModState_buildJson() {
    local workshop_json='{}'
    local native_json='{}'
    local claims_json='[]'
    local targets_json='{}'
    local ue4ss_files_json='[]'
    local deployed_paks_json='[]'
    local deployed_lua_json='[]'
    local deployed_palschema_json='[]'
    local mod_id source_dir version mod_name native_version tracked_file item

    ModLog_debug "Building state JSON for ${#WORKSHOP_IDS[@]} workshop mods, ${#NATIVE_MOD_NAMES[@]} native mods, ${#DEPLOYED_UE4SS_FILES[@]} UE4SS files, ${#DEPLOYED_PAKS[@]} deployed paks, ${#DEPLOYED_LUA_MODS[@]} deployed lua mods, ${#DEPLOYED_PALSCHEMA_MODS[@]} deployed palschema mods."
    for mod_id in "${WORKSHOP_IDS[@]}"; do
        source_dir="$(Workshop_findSourceDir "${mod_id}" || true)"
        if [ -n "${source_dir}" ] && [ -f "${source_dir}/Info.json" ]; then
            version="$(jq -r '.Version // "unknown"' "${source_dir}/Info.json" 2>/dev/null || echo unknown)"
        else
            version="missing"
        fi
        workshop_json="$(jq -c --arg key "${mod_id}" --arg value "${version}" '. + {($key): $value}' <<< "${workshop_json}")"
    done

    for mod_name in "${NATIVE_MOD_NAMES[@]}"; do
        source_dir="${native_mods_dir:?}/${mod_name}"
        native_version="$(find "${source_dir}" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n 1)"
        if [ -z "${native_version}" ]; then
            native_version="missing"
        fi
        native_json="$(jq -c --arg key "${mod_name}" --arg value "${native_version}" '. + {($key): $value}' <<< "${native_json}")"
    done

    for tracked_file in "${DEPLOYED_UE4SS_FILES[@]}"; do
        ue4ss_files_json="$(jq -c --arg value "${tracked_file}" '. + [$value]' <<< "${ue4ss_files_json}")"
    done

    for item in "${DEPLOYED_PAKS[@]}"; do
        deployed_paks_json="$(jq -c --arg value "${item}" '. + [$value]' <<< "${deployed_paks_json}")"
    done

    for item in "${DEPLOYED_LUA_MODS[@]}"; do
        deployed_lua_json="$(jq -c --arg value "${item}" '. + [$value]' <<< "${deployed_lua_json}")"
    done

    for item in "${DEPLOYED_PALSCHEMA_MODS[@]}"; do
        deployed_palschema_json="$(jq -c --arg value "${item}" '. + [$value]' <<< "${deployed_palschema_json}")"
    done

    if [ "${#MOD_STATE_DEPLOYMENTS[@]}" -gt 0 ]; then
        claims_json="$(printf '%s\n' "${MOD_STATE_DEPLOYMENTS[@]}" | jq -sc '.')"
        targets_json="$(jq -c 'sort_by(.target) | group_by(.target) | map({(.[0].target):{claims:map({owner,source,sha256,order})}}) | add // {}' <<< "${claims_json}")"
    fi

    printf '%s\n' \
        "${MOD_STATE_PACKAGES}" \
        "${targets_json}" \
        "${workshop_json}" \
        "${native_json}" \
        "${ue4ss_files_json}" \
        "${deployed_paks_json}" \
        "${deployed_lua_json}" \
        "${deployed_palschema_json}" |
        jq -cs \
        --arg ue4ss_source_version "$(UE4SS_zipMtime)" \
        '.[0] as $packages |
         .[1] as $targets |
         .[2] as $workshop |
         .[3] as $native |
         .[4] as $ue4ss_files |
         .[5] as $deployed_paks |
         .[6] as $deployed_lua_mods |
         .[7] as $deployed_palschema_mods |
         {
            schema_version: 3,
            packages: $packages,
            targets: $targets,
            workshop: $workshop,
            native: $native,
            ue4ss: {files: $ue4ss_files},
            ue4ss_source_version: $ue4ss_source_version,
            deployed_paks: $deployed_paks,
            deployed_lua_mods: $deployed_lua_mods,
            deployed_palschema_mods: $deployed_palschema_mods,
            staging_dirs: ["/palworld/Mods/.workshop","/palworld/Mods/.tmp/ue4ss-palworld","/palworld/Mods/.tmp/native-mods"]
        }'
}

# Build a lightweight {workshop, native, ue4ss_source_version} fingerprint without requiring deployment to have run.
ModState_buildSourceSnapshot() {
    local workshop_json='{}'
    local native_json='{}'
    local mod_id source_dir version mod_name native_version

    for mod_id in "${WORKSHOP_IDS[@]}"; do
        source_dir="$(Workshop_findSourceDir "${mod_id}" || true)"
        if [ -n "${source_dir}" ] && [ -f "${source_dir}/Info.json" ]; then
            version="$(jq -r '.Version // "unknown"' "${source_dir}/Info.json" 2>/dev/null || echo unknown)"
        else
            version="missing"
        fi
        workshop_json="$(jq -c --arg key "${mod_id}" --arg value "${version}" '. + {($key): $value}' <<< "${workshop_json}")"
    done

    for mod_name in "${NATIVE_MOD_NAMES[@]}"; do
        source_dir="${native_mods_dir:?}/${mod_name}"
        native_version="$(find "${source_dir}" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n 1)"
        if [ -z "${native_version}" ]; then
            native_version="missing"
        fi
        native_json="$(jq -c --arg key "${mod_name}" --arg value "${native_version}" '. + {($key): $value}' <<< "${native_json}")"
    done

    printf '%s\n' "${workshop_json}" "${native_json}" |
        jq -cs \
        --arg ue4ss_source_version "$(UE4SS_zipMtime)" \
        '.[0] as $workshop | .[1] as $native | {workshop: $workshop, native: $native, ue4ss_source_version: $ue4ss_source_version}'
}

# Print installed mod versions and deployed artifacts from the last recorded state.
ModInfo_print() {
    if [ ! -f "${state_file}" ]; then
        LogInfo "No mod state recorded yet. Run mods-update first."
        return 0
    fi
    local state_json wid version src_dir pkg_name name mtime mtime_h ue4ss_ver ue4ss_count
    state_json="$(jq -c . "${state_file}" 2>/dev/null || echo '{}')"

    echo "=== Workshop Mods ==="
    printf '%-14s %-30s %s\n' "Workshop ID" "Package" "Version"
    while IFS=$'\t' read -r wid version; do
        [ -z "${wid}" ] && continue
        src_dir="$(Workshop_findSourceDir "${wid}" || true)"
        pkg_name="-"
        [ -n "${src_dir}" ] && pkg_name="$(Mod_collectPackageName "${src_dir}" "${wid}")"
        printf '%-14s %-30s %s\n' "${wid}" "${pkg_name}" "${version}"
    done < <(printf '%s' "${state_json}" | jq -r '.workshop // {} | to_entries[] | "\(.key)\t\(.value)"')

    echo
    echo "=== Native Mods ==="
    printf '%-30s %s\n' "Name" "Last Modified"
    while IFS=$'\t' read -r name mtime; do
        [ -z "${name}" ] && continue
        mtime_h="${mtime}"
        [[ "${mtime}" =~ ^[0-9]+$ ]] && mtime_h="$(date -d "@${mtime}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "${mtime}")"
        printf '%-30s %s\n' "${name}" "${mtime_h}"
    done < <(printf '%s' "${state_json}" | jq -r '.native // {} | to_entries[] | "\(.key)\t\(.value)"')

    echo
    echo "=== UE4SS ==="
    ue4ss_ver="$(printf '%s' "${state_json}" | jq -r '.ue4ss_source_version // "unknown"')"
    ue4ss_count="$(printf '%s' "${state_json}" | jq -r '.ue4ss.files // [] | length')"
    echo "Cache version (mtime): ${ue4ss_ver} / Deployed entries: ${ue4ss_count}"

    echo
    echo "=== Deployed Artifacts ==="
    echo "Lua mods: $(printf '%s' "${state_json}" | jq -r '.deployed_lua_mods // [] | join(", ")')"
    echo "PalSchema mods: $(printf '%s' "${state_json}" | jq -r '.deployed_palschema_mods // [] | join(", ")')"
    echo "Logic paks: $(printf '%s' "${state_json}" | jq -r '.deployed_paks // [] | join(", ")')"
}

#-------------------------------------------------
# Locking functions
#-------------------------------------------------

# Acquire an exclusive lock so concurrent mods-update invocations don't race on shared caches/state.
ModLock_acquire() {
    local lock_dir="/palworld/Mods"
    mkdir -p "${lock_dir}"
    exec 9<"${lock_dir}"
    if ! command -v flock >/dev/null 2>&1; then
        LogWarn "flock command not found; concurrent mods-update runs are not protected against."
        return 0
    fi
    if ! flock -w "${MOD_UPDATE_LOCK_TIMEOUT:-300}" 9; then
        LogError "Another mods-update is already running and did not finish within ${MOD_UPDATE_LOCK_TIMEOUT:-300}s. Aborting."
        exit 1
    fi
}

# Release the lock acquired by ModLock_acquire.
ModLock_release() {
    exec 9>&- 2>/dev/null || true
}

#-------------------------------------------------
# Workshop functions
#-------------------------------------------------

# Validate and normalize a raw Workshop ID before adding it to the named array.
Workshop_appendId() {
    local target_array_name="$1"
    local ignored_id="$2"
    local raw_id
    raw_id="$(_trim "${3:-}")"
    [ -z "${raw_id}" ] && return 0

    if [ "${raw_id}" = "${ignored_id}" ]; then
        download_ue4ss=true
        LogWarn "UE4SS workshop mod ID ${ignored_id} is not supported. It has been ignored."
        return 0
    fi

    if [[ "${raw_id}" =~ ^[0-9]+$ ]]; then
        ModTrack_addUnique "${target_array_name}" "${raw_id}"
    else
        LogWarn "Invalid workshop mod ID: ${raw_id}"
    fi
}

# Read and return unique workshop mod IDs from environment variables and a file.
Workshop_readIds() {
    local -a ids=()
    local -a raw_ids
    local line
    local -r ignore_ue4ss_id="3625223587"  # UE4SS workshop mod ID

    # Process MOD_ID_PALSCHEMA environment variable, if set.
    if [[ "${MOD_ID_PALSCHEMA}" =~ ^[0-9]+$ ]]; then
        ids+=("${MOD_ID_PALSCHEMA}")
    else
        LogInfo "Skipping PalSchema. (MOD_ID_PALSCHEMA=\"${MOD_ID_PALSCHEMA}\")"
    fi

    # Process MOD_IDS environment variable, if set.
    if [ -n "${MOD_IDS:-}" ]; then
        IFS=',' read -r -a raw_ids <<< "${MOD_IDS}"
        for line in "${raw_ids[@]}"; do
            Workshop_appendId ids "${ignore_ue4ss_id}" "${line}"
        done
    fi

    # Process workshop_mods_file, if it exists.
    if [ -f "${workshop_mods_file}" ]; then
        while IFS= read -r line || [ -n "${line:-}" ]; do
            Workshop_appendId ids "${ignore_ue4ss_id}" "${line%%#*}"
        done < "${workshop_mods_file}"
    fi

    printf '%s\n' "${ids[@]}"
}

# Locate a downloaded Workshop mod across supported Steam library paths.
Workshop_findSourceDir() {
    local mod_id="$1"
    local candidate

    for candidate in \
        "/palworld/.steam/steamapps/workshop/content/${workshop_app_id}/${mod_id}" \
        "/home/steam/Steam/steamapps/workshop/content/${workshop_app_id}/${mod_id}" \
        "/home/steam/.steam/steam/steamapps/workshop/content/${workshop_app_id}/${mod_id}" \
        "/home/steam/.local/share/Steam/steamapps/workshop/content/${workshop_app_id}/${mod_id}"; do
        if [ -d "${candidate}" ]; then
            printf '%s' "${candidate}"
            return 0
        fi
    done

    return 1
}

# Download the requested Workshop mods through SteamCMD.
Workshop_downloadMods() {
    local ids=("$@")
    local steamcmd_args=("+login")
    local login_user=""
    local login_source="anonymous"

    if [ -n "${STEAM_USERNAME:-}" ] && [ "${STEAM_USERNAME}" != "anonymous" ]; then
        login_user="$(_trim "${STEAM_USERNAME}")"
        login_source="STEAM_USERNAME"
    elif [ -s "${steam_login_user_file}" ]; then
        login_user="$(_trim "$(head -n1 "${steam_login_user_file}")")"
        login_source="${steam_login_user_file}"
    fi

    if [ -n "${login_user}" ]; then
        steamcmd_args+=("${login_user}")
    else
        steamcmd_args+=("anonymous")
    fi

    local mod_id
    for mod_id in "${ids[@]}"; do
        steamcmd_args+=("+workshop_download_item" "${workshop_app_id}" "${mod_id}")
    done
    steamcmd_args+=("+quit")

    if [ "${#ids[@]}" -eq 0 ]; then
        return 0
    fi

    LogInfo "Downloading ${#ids[@]} Steam Workshop mod(s)..."
    ModLog_debug "${steamcmd_bin} +login ${login_source} +workshop_download_item ... +quit"
    if ! "${steamcmd_bin}" "${steamcmd_args[@]}"; then
        LogError "SteamCMD reported an error while downloading workshop mods."
        return 1
    fi
    return 0
}

#-------------------------------------------------
# Mod deployment functions
#-------------------------------------------------

# Read a mod package name from Info.json, falling back to a safe directory name.
Mod_collectPackageName() {
    local source_dir="$1"
    local fallback_name="$2"
    local info_json="${source_dir}/Info.json"
    local package_name=""

    if [ -f "${info_json}" ]; then
        package_name="$(jq -r '.PackageName // empty' "${info_json}" 2>/dev/null || true)"
    fi

    if [ -n "${package_name}" ] && [ "${package_name}" != "null" ]; then
        # Normalize package name as directory name
        package_name="$(sed -E -e 's/\//-/g' -e 's/^\.\./__/g' <<< "${package_name}")"
        printf '%s' "${package_name}"
    else
        printf '%s' "${fallback_name}"
    fi
}

# Deploy a mod according to the InstallRule entries in its Info.json.
Mod_deployViaRules() {
    local dest_dir="$1"
    local pkg_name="$2"
    local owner_key="$3"
    local info_json="${dest_dir}/Info.json"
    local pak pak_name rules_json rule type target target_path dest source_root

    ModLog_debug "Mod_deployViaRules: ${pkg_name}"

    if jq -e '.InstallRule[]? | select(.IsServer == true)' "${info_json}" >/dev/null 2>&1; then
        rules_json="$(jq -c '.InstallRule[]? | select(.IsServer == true)' "${info_json}" 2>/dev/null || true)"
    else
        rules_json="$(jq -c '.InstallRule[]?' "${info_json}" 2>/dev/null || true)"
    fi

    while IFS= read -r rule; do
        [ -z "${rule}" ] && continue
        type="$(printf '%s' "${rule}" | jq -r '.Type // empty')"

        while IFS= read -r target; do
            # traverse up directories and replace with __ to prevent directory traversal attacks
            target="$(sed -E -e 's/\.\./__/g' <<< "${target}")"
            target_path="${dest_dir%/}/${target}"

            if [ ! -e "${target_path}" ]; then
                LogWarn "Target path ${target_path} not found for type ${type}"
                continue
            fi

            case "${type}" in
                Lua)
                    dest="${ue4ss_mods_dir}/${pkg_name}/"
                    LogInfo "[Lua] ${pkg_name} → ${dest}"
                    ModLog_debug "Syncing Lua mod from \"${target_path}\" to \"${dest}\""
                    ModState_recordTree "${target_path}" "${dest}" "${owner_key}"
                    ModTrack_addUnique DEPLOYED_LUA_MODS "${pkg_name}"
                    ;;
                Paks)
                    LogInfo "[Paks] ${pkg_name} → /palworld/Pal/Content/Paks/LogicMods/"
                    while IFS= read -r -d '' pak; do
                        pak_name="$(basename "${pak}")"
                        ModState_recordTree "${pak}" "/palworld/Pal/Content/Paks/LogicMods/${pak_name}" "${owner_key}"
                        ModTrack_addUnique DEPLOYED_PAKS "${pak_name}"
                    done < <(find "${target_path}" -type f -name '*.pak' -print0 | LC_ALL=C sort -z)
                    ;;
                PalSchema)
                    dest="${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}/"
                    LogInfo "[PalSchema] ${pkg_name} → ${dest}"
                    ModLog_debug "Syncing PalSchema mod from \"${target_path}\" to \"${dest}\""
                    ModState_recordTree "${target_path}" "${dest}" "${owner_key}"
                    ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
                    ;;
                UE4SS)
                    LogInfo "[UE4SS] deploying framework from ${target_path}"
                    UE4SS_deploy "${target_path}" "${owner_key}"
                    ;;
            esac
        done < <(printf '%s' "${rule}" | jq -r '.Targets[]? // empty')
    done < <(printf '%s\n' "${rules_json}")
}

# Detect and deploy mod artifacts when no InstallRule is available.
Mod_deployAutoDiscover() {
    local staged_mod_dir="$1"
    local pkg_name="$2"
    local owner_key="$3"
    local check_dir d sub name dest found_flat pak_file pak_name target_paks_dir staged_ue4ss_mod_dir

    ModLog_debug "Mod_deployAutoDiscover: ${pkg_name}"

    # Logic Mods (.pak files)
    local default_paks_dir="/palworld/Pal/Content/Paks/LogicMods"
    local tilde_paks_dir="/palworld/Pal/Content/Paks/~mods"
    while read -r pak_file; do
        if [ -f "$pak_file" ]; then
            pak_name=$(basename "$pak_file")
            target_paks_dir="$default_paks_dir"

            # If the pak file is located inside a ~mods folder in the source package, route to ~mods
            if [[ "$pak_file" == *"~mods"* ]]; then
                target_paks_dir="$tilde_paks_dir"
            fi

            LogInfo "Found pak mod: $pak_name. Deploying to $(basename "$target_paks_dir")..."
            ModState_recordTree "$pak_file" "${target_paks_dir}/${pak_name}" "${owner_key}"
            LogDebug "[Pak] Absolute destination: ${target_paks_dir}/${pak_name}"
            ModTrack_addUnique DEPLOYED_PAKS "${pak_name}"
        fi
    done < <(find "$staged_mod_dir" -type f -iname "*.pak")

    # If this is a UE4SS mod with a Mods folder, copy its contents to Mods directory
    if [ -d "${staged_mod_dir}/Pal/Binaries/Win64/ue4ss/Mods" ]; then
        staged_ue4ss_mod_dir="${staged_mod_dir}/Pal/Binaries/Win64/ue4ss/Mods"
    else
        staged_ue4ss_mod_dir="${staged_mod_dir}/Mods"
    fi
    LogInfo "Checking for UE4SS Mods directory in ${staged_ue4ss_mod_dir}..."
    if [ -d "${staged_ue4ss_mod_dir}" ]; then
        for d in "${staged_ue4ss_mod_dir}"/*/; do
            [ -d "${d}" ] || continue
            name="$(basename "${d}")"
            ModState_recordTree "${d%/}" "${ue4ss_mods_dir}/${name}" "${owner_key}"
            if [ "${name}" = "PalSchema" ] && [ -d "${d}/mods" ]; then
                for sub in "${d}/mods"/*/; do
                    [ -d "${sub}" ] && ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "$(basename "${sub}")"
                done
            else
                ModTrack_addUnique DEPLOYED_LUA_MODS "${name}"
            fi
        done
    fi

    # PalSchema mods (either inside a 'PalSchema/mods' folder, a flat 'PalSchema' folder, or 'mods' folder)
    if [ -d "${staged_mod_dir}/PalSchema/mods" ]; then
        for d in "${staged_mod_dir}/PalSchema/mods"/*/; do
            [ -d "${d}" ] || continue
            ModState_recordTree "${d%/}" "${ue4ss_mods_dir}/PalSchema/mods/$(basename "${d}")" "${owner_key}"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "$(basename "${d}")"
        done
    elif [ -d "${staged_mod_dir}/PalSchema" ]; then
        # Check if it is the PalSchema framework itself
        if [ -f "${staged_mod_dir}/PalSchema/scripts/main.lua" ] || [ -f "${staged_mod_dir}/PalSchema/main.lua" ]; then
            LogInfo "Detected legacy PalSchema framework in ${staged_mod_dir}/PalSchema ... Ignored."
        else
            # ${staged_mod_dir}/PalSchema/* → /palworld/Pal/Binaries/Win64/ue4ss/Mods/PalSchema/mods/<pkg_name>/
            ModState_recordTree "${staged_mod_dir}/PalSchema" "${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}" "${owner_key}"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
        fi
    elif [ -d "${staged_mod_dir}/mods" ]; then
        for d in "${staged_mod_dir}/mods"/*/; do
            [ -d "${d}" ] || continue
            ModState_recordTree "${d%/}" "${ue4ss_mods_dir}/PalSchema/mods/$(basename "${d}")" "${owner_key}"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "$(basename "${d}")"
        done
    fi

    found_flat=false
    for check_dir in blueprints raw translations items; do
        if [ -d "${staged_mod_dir}/${check_dir}" ]; then
            found_flat=true
            break
        fi
    done
    if [ "${found_flat}" = true ]; then
        dest="${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}"
        ModState_recordTree "${staged_mod_dir}" "${dest}" "${owner_key}"
        ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
    fi
}

# Stage a mod and deploy it using explicit rules or automatic discovery.
Mod_deploy() {
    local source_dir="$1"
    local dest_dir="$2"
    local pkg_name="$3"
    local owner_key="$4"
    local info_json

    mkdir -p "${dest_dir}"
    cp "-aur${v}" "${source_dir}/." "${dest_dir}/"
    info_json="${dest_dir}/Info.json"
    if [ -f "${info_json}" ] && jq -e '.InstallRule' "${info_json}" >/dev/null 2>&1; then
        Mod_deployViaRules "${dest_dir}" "${pkg_name}" "${owner_key}"
    else
        Mod_deployAutoDiscover "${dest_dir}" "${pkg_name}" "${owner_key}"
    fi
}

#-------------------------------------------------
# Mod configuration functions
#-------------------------------------------------

# Rewrite PalModSettings.ini with the current active package list enabled.
ModConfig_ensurePalModSettings() {
    local ini_file="/palworld/Mods/PalModSettings.ini"
    local line package_name tmp_file
    tmp_file="$(mktemp)"

    mkdir -p "$(dirname "${ini_file}")"

    if [ -f "${ini_file}" ]; then
        # Remove existing [ActiveModList] section and its contents.
        # Remove existing [Settings] section and its contents.
        # Override bGlobalEnableMod=True within [PalModSettings] section.
        # Remove any other bGlobalEnableMod lines.
        local in_active_list=false in_setting_section=false in_palmod_settings_section=false
        while IFS= read -r line || [ -n "${line:-}" ]; do
            if [ "${in_active_list}" = true ]; then
                if [[ "${line}" =~ ^\[.*\]$ ]]; then
                    in_active_list=false
                else
                    continue
                fi
            fi
            if [ "${in_setting_section}" = true ]; then
                if [[ "${line}" =~ ^\[.*\]$ ]]; then
                    in_setting_section=false
                else
                    continue
                fi
            fi
            if [[ "${line}" =~ ^\[ActiveModList\] ]]; then
                in_active_list=true
                continue
            fi
            if [[ "${line}" =~ ^\[Settings\] ]]; then
                in_setting_section=true
                continue
            fi
            if [[ "${line}" =~ ^\[PalModSettings\] ]]; then
                in_palmod_settings_section=true
                echo "${line}" >> "${tmp_file}"
                continue
            fi

            if [[ "${line}" =~ ^bGlobalEnableMod= ]]; then
                if [ "${in_palmod_settings_section}" = true ]; then
                    echo "bGlobalEnableMod=True" >> "${tmp_file}"
                else
                    continue
                fi
            else
                echo "${line}" >> "${tmp_file}"
            fi
        done < "${ini_file}"
    fi

    if [ ! -s "${tmp_file}" ]; then
        cat > "${tmp_file}" <<'EOF'
[PalModSettings]
ConfigVersion=1.0
bGlobalEnableMod=True
EOF
    elif ! grep -q '^bGlobalEnableMod=True$' "${tmp_file}" 2>/dev/null; then
        if grep -q '^bGlobalEnableMod=' "${tmp_file}" 2>/dev/null; then
            sed -i 's/^bGlobalEnableMod=.*/bGlobalEnableMod=True/' "${tmp_file}"
        elif grep -q '^\[PalModSettings\]$' "${tmp_file}" 2>/dev/null; then
            sed -i '/^\[PalModSettings\]$/a bGlobalEnableMod=True' "${tmp_file}"
        else
            {
                echo '[PalModSettings]'
                echo 'ConfigVersion=1.0'
                echo 'bGlobalEnableMod=True'
                echo
                cat "${tmp_file}"
            } > "${tmp_file}.new"
            mv "${tmp_file}.new" "${tmp_file}"
        fi
    fi

    # Append the [ActiveModList] section at the end of the ini file.
    if [ -s "${tmp_file}" ] && [ "$(tail -c 1 "${tmp_file}")" != "" ]; then
        echo >> "${tmp_file}"
    fi
    {
        echo '[ActiveModList]'
        for package_name in "${ACTIVE_PACKAGES[@]}"; do
            echo "${package_name}=True"
        done
    } >> "${tmp_file}"

    mv -f "${tmp_file}" "${ini_file}"
    chmod 644 "${ini_file}"
}

#-------------------------------------------------
# Main flow
#-------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ACTIVE_PACKAGES=()
    NATIVE_MOD_NAMES=()
    DEPLOYED_UE4SS_FILES=()
    DEPLOYED_PAKS=()
    DEPLOYED_LUA_MODS=()
    DEPLOYED_PALSCHEMA_MODS=()
    MOD_STATE_DEPLOYMENTS=()
    MOD_STATE_PACKAGES='{}'
    MOD_STATE_ORDER=0

    # Windows only
    if [ "$(ServerPlatform)" != "windows" ]; then
        LogInfo "Mod support is enabled only for ${image}."
        exit 0
    fi

    # Load previous state if available
    if [ -f "${state_file}" ]; then
        previous_state="$(jq -c . "${state_file}" 2>/dev/null || echo '{}')"
    fi

    if [ "$1" = "info" ]; then
        ModInfo_print
        exit 0
    fi

    # Serialize clean/check/update against concurrent mods-update invocations sharing the same caches and state file.
    ModLock_acquire
    MOD_STATE_V3_RECOVERED=false
    export MOD_STATE_V3_RECOVERED
    if ! ModStateV3_recoverJournal "${state_journal_file}" "${state_file}" "/palworld" "${state_backup_dir}"; then
        LogError "Failed to recover the interrupted mod deployment transaction."
        exit 1
    fi
    if [ -f "${state_file}" ]; then
        previous_state="$(jq -c . "${state_file}" 2>/dev/null || echo '{}')"
    fi

    if [ "$1" = "clean" ]; then
        LogInfo "Cleaning up mods..."
        if [ "$(printf '%s' "${previous_state}" | jq -r '.schema_version // 1')" = "3" ]; then
            if ! ModStateV3_reconcile "${previous_state}" '{"schema_version":3,"packages":{},"targets":{}}' "${state_file}" "/palworld" "${state_backup_dir}" "${state_journal_file}"; then
                LogError "Failed to restore managed mod files while cleaning up."
                exit 1
            fi
        else
            ModState_cleanup "${previous_state}"
        fi
        ModState_cleanupStagingDirs
        rm -f "${state_file}"
        rm -rf "${native_staging_dir}" "${state_backup_dir}" "${state_journal_file}"
        exit 0
    fi

    if isTrue "${MOD_ENABLED:-true}"; then
        LogInfo "Mod support is enabled."
    else
        LogInfo "Mod support is disabled. Cleaning up mods and exiting."
        exit 0
    fi

    # Load workshop mod IDs
    mapfile -t WORKSHOP_IDS < <(Workshop_readIds || true)

    # SteamCMD/curl compare manifests internally, so syncing is always safe and cheap when nothing changed.
    # Both "check" and the full update share this same sync step before diverging below.
    LogInfo "Syncing Steam Workshop mods..."
    if ! Workshop_downloadMods "${WORKSHOP_IDS[@]}"; then
        LogError "Failed to sync Steam Workshop mods."
        exit 1
    fi

    LogInfo "Syncing UE4SS Palworld..."
    UE4SS_sync "${ue4ss_staging_dir}" || exit 1

    if [ "$1" = "check" ]; then
        rm -rf "${ue4ss_staging_dir}"
        NativeMods_listNames NATIVE_MOD_NAMES

        current_snapshot="$(ModState_buildSourceSnapshot)"
        previous_snapshot="$(printf '%s' "${previous_state}" | jq -c '{workshop:(.workshop//{}),native:(.native//{}),ue4ss_source_version:(.ue4ss_source_version//"missing")}' 2>/dev/null || echo '{}')"

        if [ "${current_snapshot}" = "${previous_snapshot}" ]; then
            LogInfo "All mods are up to date."
            exit 0
        fi

        LogInfo "Updates are available. Run mods-update to apply them."
        ModLog_debug "previous snapshot: ${previous_snapshot}"
        ModLog_debug "current snapshot: ${current_snapshot}"
        exit 2
    fi

    # Deploy UE4SS Palworld artifacts
    UE4SS_deploy "${ue4ss_staging_dir}"
    ModLog_debug "UE4SS: ${#DEPLOYED_UE4SS_FILES[@]} files deployed."

    # Deploy NativeMods/*
    rm -rf "${native_staging_dir}"
    mkdir -p "${native_staging_dir}"
    while IFS= read -r -d '' mod_path; do
        mod_name="$(basename "${mod_path}")"
        pkg_name="$(Mod_collectPackageName "${mod_path}" "${mod_name}")"
        owner_key="native:${mod_name}"
        dest_dir="${native_staging_dir}/${mod_name}"

        ModState_registerPackage "${owner_key}" "native" "${pkg_name}" "${mod_name}" "$(jq -r '.Version // "unknown"' "${mod_path}/Info.json" 2>/dev/null || echo unknown)"
        Mod_deploy "${mod_path}" "${dest_dir}" "${pkg_name}" "${owner_key}"
        ACTIVE_PACKAGES+=("${pkg_name}")
        NATIVE_MOD_NAMES+=("${mod_name}")
        LogInfo "Staged NativeMods/${mod_name} (${pkg_name}) for ${dest_dir}"
    done < <(find "${native_mods_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | LC_ALL=C sort -z)

    # Wipe Workshop staging so stale entries from prior naming don't accumulate
    rm -rf "${workshop_staging_dir}"
    mkdir -p "${workshop_staging_dir}"

    for mod_id in "${WORKSHOP_IDS[@]}"; do
        source_dir="$(Workshop_findSourceDir "${mod_id}" || true)"
        if [ -z "${source_dir}" ]; then
            LogWarn "Workshop mod ${mod_id} was not found after download."
            continue
        fi

        pkg_name="$(Mod_collectPackageName "${source_dir}" "${mod_id}")"
        owner_key="workshop:${mod_id}"
        dest_dir="${workshop_staging_dir}/${mod_id}"
        version="$(jq -r '.Version // "unknown"' "${source_dir}/Info.json" 2>/dev/null || echo unknown)"
        ModState_registerPackage "${owner_key}" "workshop" "${pkg_name}" "${mod_id}" "${version}"
        LogInfo "Deploy workshop mod ${mod_id} (${pkg_name}) to ${dest_dir}"
        Mod_deploy "${source_dir}" "${dest_dir}" "${pkg_name}" "${owner_key}"
        ACTIVE_PACKAGES+=("${pkg_name}")
    done

    UE4SS_updateModsTxt
    ModConfig_ensurePalModSettings

    PalDefender_update "${bin_dir}"

    current_state="$(ModState_buildJson)"

    if [ "$(printf '%s' "${previous_state}" | jq -r '.schema_version // 1')" = "2" ]; then
        LogWarn "Migrating mod state from schema version 2; managed deployment files will be rebuilt."
        # v2 owner IDs are ambiguous, so rebuild from current inputs instead of guessing package ownership.
        migration_state="$(printf '%s' "${previous_state}" | jq -c 'if .schema_version == 2 then .deployments |= map(select(.artifact != "staged")) else . end')"
        ModState_cleanup "${migration_state}"
        previous_state='{}'
    fi

    if ! ModStateV3_reconcile "${previous_state}" "${current_state}" "${state_file}" "/palworld" "${state_backup_dir}" "${state_journal_file}"; then
        LogError "Failed to reconcile mod deployments. The previous state was retained for recovery."
        exit 1
    fi

    if [ "${MOD_STATE_V3_CHANGED:-false}" != true ]; then
        LogInfo "No mod changes detected."
        ModState_cleanupStagingDirs
        rm -rf "${native_staging_dir}"
        exit 0
    fi

    ModState_cleanupStagingDirs
    rm -rf "${native_staging_dir}"

    ModLog_debug "previous state: ${previous_state}"
    ModLog_debug "current state: ${current_state}"

    LogAction "Mod changes detected"

    server_running=false
    if pgrep -f "$(PalworldServerProcessMatch)" >/dev/null 2>&1; then
        server_running=true
    fi

    if [ "${server_running}" != true ]; then
        LogInfo "Server is not running yet, so no restart is required."
        exit 0
    fi

    # Release the lock before exec, since auto_reboot.sh does not call mods-update itself.
    ModLock_release
    exec /home/steam/server/auto_reboot.sh
fi
