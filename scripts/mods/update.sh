#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

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
workshop_staging_dir="/palworld/Mods/.workshop"
ue4ss_staging_dir="/palworld/Mods/.tmp/ue4ss-palworld"
ue4ss_mods_dir="${bin_dir}/ue4ss/Mods"
workshop_app_id="1623730"
state_file="/palworld/Mods/.state.json"
steamcmd_bin="${steamcmd_bin:-/home/steam/steamcmd/steamcmd.sh}"
steam_login_user_file="/palworld/.steam/.steam-login-user"
workshop_mods_file="${workshop_mods_file:-/palworld/Mods/workshop-mods.txt}"
previous_state='{}'
v="$(isTrue "${MOD_DEBUG:-false}" && echo "v")"
download_workshop=true
download_ue4ss=true

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
        if curl -sSfL -z "${zip_file}" -o "${tmp_file}" "${MOD_URL_UE4SS}" && [ -s "${tmp_file}" ]; then
            mv -f "${tmp_file}" "${zip_file}"
            should_extract=true
            LogInfo "Downloaded newer UE4SS Palworld package."
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
    local rel_path

    if ! UE4SS_isDownloaded "${source_dir}"; then
        return 0
    fi

    mkdir -p "${bin_dir}"
    cp -aur "${source_dir}/." "${bin_dir}/" > /dev/null 2>&1

    # Only the top-level entry names are tracked for later cleanup.
    while IFS= read -r rel_path; do
        ModTrack_addUnique DEPLOYED_UE4SS_FILES "${rel_path}"
    done < <(find "${source_dir}" -mindepth 1 -maxdepth 1 -printf '%f\n')
}

# Enable deployed Lua mods in the UE4SS mods configuration file.
UE4SS_updateModsTxt() {
    local mods_txt="${ue4ss_mods_dir}/mods.txt"
    [ -f "${mods_txt}" ] || return 0

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
}

#-------------------------------------------------
# ModState functions
#-------------------------------------------------

# Remove artifacts that were deployed in the previous state.
ModState_cleanup() {
    local state_json="$1"
    local item

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

# Build the JSON state describing currently discovered and deployed mods.
ModState_buildJson() {
    local workshop_json='{}'
    local native_json='{}'
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
        workshop_json="$(jq -cn --argjson base "${workshop_json}" --arg key "${mod_id}" --arg value "${version}" '$base + {($key): $value}')"
    done

    for mod_name in "${NATIVE_MOD_NAMES[@]}"; do
        source_dir="${native_mods_dir:?}/${mod_name}"
        native_version="$(find "${source_dir}" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n 1)"
        if [ -z "${native_version}" ]; then
            native_version="missing"
        fi
        native_json="$(jq -cn --argjson base "${native_json}" --arg key "${mod_name}" --arg value "${native_version}" '$base + {($key): $value}')"
    done

    for tracked_file in "${DEPLOYED_UE4SS_FILES[@]}"; do
        ue4ss_files_json="$(jq -cn --argjson base "${ue4ss_files_json}" --arg value "${tracked_file}" '$base + [$value]')"
    done

    for item in "${DEPLOYED_PAKS[@]}"; do
        deployed_paks_json="$(jq -cn --argjson base "${deployed_paks_json}" --arg value "${item}" '$base + [$value]')"
    done

    for item in "${DEPLOYED_LUA_MODS[@]}"; do
        deployed_lua_json="$(jq -cn --argjson base "${deployed_lua_json}" --arg value "${item}" '$base + [$value]')"
    done

    for item in "${DEPLOYED_PALSCHEMA_MODS[@]}"; do
        deployed_palschema_json="$(jq -cn --argjson base "${deployed_palschema_json}" --arg value "${item}" '$base + [$value]')"
    done

    jq -cn \
        --argjson workshop "${workshop_json}" \
        --argjson native "${native_json}" \
        --argjson ue4ss_files "${ue4ss_files_json}" \
        --argjson deployed_paks "${deployed_paks_json}" \
        --argjson deployed_lua_mods "${deployed_lua_json}" \
        --argjson deployed_palschema_mods "${deployed_palschema_json}" \
        '{workshop: $workshop, native: $native, ue4ss: {files: $ue4ss_files}, deployed_paks: $deployed_paks, deployed_lua_mods: $deployed_lua_mods, deployed_palschema_mods: $deployed_palschema_mods}'
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
    local info_json="${dest_dir}/Info.json"
    local pak pak_name rules_json rule type target target_path dest

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
                    mkdir -p "${dest}"
                    cp "-aur${v}" "${target_path}" "${dest}"
                    ModTrack_addUnique DEPLOYED_LUA_MODS "${pkg_name}"
                    ;;
                Paks)
                    LogInfo "[Paks] ${pkg_name} → /palworld/Pal/Content/Paks/LogicMods/"
                    while IFS= read -r -d '' pak; do
                        pak_name="$(basename "${pak}")"
                        mkdir -p "/palworld/Pal/Content/Paks/LogicMods"
                        cp "-auf${v}" "${pak}" "/palworld/Pal/Content/Paks/LogicMods/"
                        ModTrack_addUnique DEPLOYED_PAKS "${pak_name}"
                    done < <(find "${target_path}" -type f -name '*.pak' -print0)
                    ;;
                PalSchema)
                    dest="${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}/"
                    LogInfo "[PalSchema] ${pkg_name} → ${dest}"
                    ModLog_debug "Syncing PalSchema mod from \"${target_path}\" to \"${dest}\""
                    mkdir -p "${dest}"
                    cp "-aur${v}" "${target_path}" "${dest}"
                    ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
                    ;;
                UE4SS)
                    LogInfo "[UE4SS] deploying framework from ${target_path}"
                    UE4SS_deploy "${target_path}"
                    ;;
            esac
        done < <(printf '%s' "${rule}" | jq -r '.Targets[]? // empty')
    done < <(printf '%s\n' "${rules_json}")
}

# Detect and deploy mod artifacts when no InstallRule is available.
Mod_deployAutoDiscover() {
    local dest_dir="$1"
    local pkg_name="$2"
    local check_dir d sub name dest found_flat pak_file pak_name target_paks_dir

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
            mkdir -p "$target_paks_dir"
            cp "-aur${v}" "$pak_file" "$target_paks_dir/"
            LogDebug "[Pak] Absolute destination: ${target_paks_dir}/${pak_name}"
            ModTrack_addUnique DEPLOYED_PAKS "${pak_name}"
        fi
    done < <(find "$dest_dir" -type f -iname "*.pak")

    # If this is a UE4SS mod with a Mods folder, copy its contents to Mods directory
    if [ -d "${dest_dir}/Mods" ]; then
        for d in "${dest_dir}/Mods"/*/; do
            [ -d "${d}" ] || continue
            name="$(basename "${d}")"
            cp "-aur${v}" "${d%/}" "${ue4ss_mods_dir}/"
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
    if [ -d "${dest_dir}/PalSchema/mods" ]; then
        mkdir -p "${ue4ss_mods_dir}/PalSchema/mods"
        for d in "${dest_dir}/PalSchema/mods"/*/; do
            [ -d "${d}" ] || continue
            cp "-aur${v}" "${d%/}" "${ue4ss_mods_dir}/PalSchema/mods/"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "$(basename "${d}")"
        done
    elif [ -d "${dest_dir}/PalSchema" ]; then
        # Check if it is the PalSchema framework itself
        if [ -f "${dest_dir}/PalSchema/scripts/main.lua" ] || [ -f "${dest_dir}/PalSchema/main.lua" ]; then
            LogInfo "Detected legacy PalSchema framework in ${dest_dir}/PalSchema ... Ignored."
        else
            # ${dest_dir}/PalSchema/* → /palworld/Pal/Binaries/Win64/ue4ss/Mods/PalSchema/mods/<pkg_name>/
            mkdir -p "${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}"
            cp "-aur${v}" "${dest_dir}/PalSchema/." "${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}/"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
        fi
    elif [ -d "${dest_dir}/mods" ]; then
        mkdir -p "${ue4ss_mods_dir}/PalSchema/mods"
        for d in "${dest_dir}/mods"/*/; do
            [ -d "${d}" ] || continue
            cp "-aur${v}" "${d%/}" "${ue4ss_mods_dir}/PalSchema/mods/"
            ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "$(basename "${d}")"
        done
    fi

    found_flat=false
    for check_dir in blueprints raw translations items; do
        if [ -d "${dest_dir}/${check_dir}" ]; then
            found_flat=true
            break
        fi
    done
    if [ "${found_flat}" = true ]; then
        dest="${ue4ss_mods_dir}/PalSchema/mods/${pkg_name}"
        mkdir -p "${dest}"
        cp "-aur${v}" "${dest_dir}/." "${dest}/"
        ModTrack_addUnique DEPLOYED_PALSCHEMA_MODS "${pkg_name}"
    fi
}

# Stage a mod and deploy it using explicit rules or automatic discovery.
Mod_deploy() {
    local source_dir="$1"
    local dest_dir="$2"
    local pkg_name="$3"
    local info_json

    mkdir -p "${dest_dir}"
    cp "-aur${v}" "${source_dir}/." "${dest_dir}/"
    info_json="${dest_dir}/Info.json"
    if [ -f "${info_json}" ] && jq -e '.InstallRule' "${info_json}" >/dev/null 2>&1; then
        Mod_deployViaRules "${dest_dir}" "${pkg_name}"
    else
        Mod_deployAutoDiscover "${dest_dir}" "${pkg_name}"
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
        local in_active_list=false
        while IFS= read -r line || [ -n "${line:-}" ]; do
            if [ "${line}" = "[ActiveModList]" ]; then
                in_active_list=true
                continue
            fi

            if [[ "${line}" =~ ^\[.*\]$ ]] && [ "${in_active_list}" = true ]; then
                in_active_list=false
            fi

            if [ "${in_active_list}" = true ]; then
                continue
            fi

            if [[ "${line}" =~ ^bGlobalEnableMod= ]]; then
                echo "bGlobalEnableMod=true" >> "${tmp_file}"
            else
                echo "${line}" >> "${tmp_file}"
            fi
        done < "${ini_file}"
    fi

    if [ ! -s "${tmp_file}" ]; then
        cat > "${tmp_file}" <<'EOF'
[Settings]
bGlobalEnableMod=true
EOF
    elif ! grep -q '^bGlobalEnableMod=true$' "${tmp_file}" 2>/dev/null; then
        if grep -q '^bGlobalEnableMod=' "${tmp_file}" 2>/dev/null; then
            sed -i 's/^bGlobalEnableMod=.*/bGlobalEnableMod=true/' "${tmp_file}"
        elif grep -q '^\[Settings\]$' "${tmp_file}" 2>/dev/null; then
            sed -i '/^\[Settings\]$/a bGlobalEnableMod=true' "${tmp_file}"
        else
            {
                echo '[Settings]'
                echo 'bGlobalEnableMod=true'
                echo
                cat "${tmp_file}"
            } > "${tmp_file}.new"
            mv "${tmp_file}.new" "${tmp_file}"
        fi
    fi

    {
        echo
        echo '[ActiveModList]'
        for package_name in "${ACTIVE_PACKAGES[@]}"; do
            echo "${package_name}=true"
        done
    } >> "${tmp_file}"

    mv -f "${tmp_file}" "${ini_file}"
    chmod 644 "${ini_file}"
}

#-------------------------------------------------
# Main flow
#-------------------------------------------------

ACTIVE_PACKAGES=()
NATIVE_MOD_NAMES=()
DEPLOYED_UE4SS_FILES=()
DEPLOYED_PAKS=()
DEPLOYED_LUA_MODS=()
DEPLOYED_PALSCHEMA_MODS=()

# Windows only
if [ "$(ServerPlatform)" != "windows" ]; then
    LogInfo "Mod support is enabled only for ${image}."
    exit 0
fi

# Load previous state if available
if [ -f "${state_file}" ]; then
    previous_state="$(jq -c . "${state_file}" 2>/dev/null || echo '{}')"
fi
ModState_cleanup "${previous_state}"

if isTrue "${MOD_ENABLED:-true}"; then
    LogInfo "Mod support is enabled."
else
    LogInfo "Mod support is disabled. Cleaning up mods and exiting."
    exit 0
fi

# Load workshop mod IDs
mapfile -t WORKSHOP_IDS < <(Workshop_readIds || true)

# Check if any workshop mods are missing and need to be downloaded
for mod_id in "${WORKSHOP_IDS[@]}"; do
    if ! Workshop_findSourceDir "${mod_id}" >/dev/null 2>&1; then
        download_workshop=true
        break
    fi
done

# Download Workshop mods
if isTrue "${download_workshop:-true}"; then
    LogInfo "Downloading Steam Workshop mods..."
    if ! Workshop_downloadMods "${WORKSHOP_IDS[@]}"; then
        LogError "Failed to download Steam Workshop mods."
        exit 1
    fi
else
    LogInfo "Skipping Steam Workshop mod downloads."
fi

# Sync UE4SS Palworld
LogInfo "Syncing UE4SS Palworld..."
UE4SS_sync "${ue4ss_staging_dir}"

# Deploy UE4SS Palworld artifacts
UE4SS_deploy "${ue4ss_staging_dir}"
ModLog_debug "UE4SS: ${#DEPLOYED_UE4SS_FILES[@]} files deployed."

# Deploy NativeMods/*
while IFS= read -r -d '' mod_path; do
    mod_name="$(basename "${mod_path}")"
    pkg_name="$(Mod_collectPackageName "${mod_path}" "${mod_name}")"
    dest_dir="${ue4ss_mods_dir}/${mod_name}"

    Mod_deploy "${mod_path}" "${dest_dir}" "${pkg_name}"
    ACTIVE_PACKAGES+=("${pkg_name}")
    NATIVE_MOD_NAMES+=("${mod_name}")
    LogInfo "Deployed NativeMods/${mod_name} (${pkg_name}) to ${dest_dir}"
done < <(find "${native_mods_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

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
    dest_dir="${workshop_staging_dir}/${pkg_name}"
    LogInfo "Deploy workshop mod ${mod_id} (${pkg_name}) to ${dest_dir}"
    Mod_deploy "${source_dir}" "${dest_dir}" "${pkg_name}"
    ACTIVE_PACKAGES+=("${pkg_name}")
done

UE4SS_updateModsTxt
ModConfig_ensurePalModSettings

PalDefender_update "${bin_dir}"

current_state="$(ModState_buildJson)"

printf '%s\n' "${current_state}" | jq '.' > "${state_file}"
chmod 644 "${state_file}"

ModLog_debug "previous state: ${previous_state}"
ModLog_debug "current state: ${current_state}"

if [ "${current_state}" = "${previous_state}" ]; then
    LogInfo "No mod changes detected."
    exit 0
fi

LogAction "Mod changes detected"

server_running=false
if pgrep -f "$(PalworldServerProcessMatch)" >/dev/null 2>&1; then
    server_running=true
fi

if [ "${server_running}" != true ]; then
    LogInfo "Server is not running yet, so no restart is required."
    exit 0
fi

exec /home/steam/server/auto_reboot.sh
