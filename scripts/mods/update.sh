#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

#-------------------------------------------------
# Mods env vars
#-------------------------------------------------
UE4SS_EXPERIMENTAL_INSTALL="${UE4SS_EXPERIMENTAL_INSTALL:-false}"
UE4SS_EXPERIMENTAL_URL="${UE4SS_EXPERIMENTAL_URL:-https://github.com/Okaetsu/RE-UE4SS/releases/download/experimental-palworld/UE4SS-Palworld.zip}"
UE4SS_CLEANUP_LEGACY="${UE4SS_CLEANUP_LEGACY:-true}"

#-------------------------------------------------
# Mods internal vars
#-------------------------------------------------
image="thijsvanloef/palworld-server-docker:windows"
platform="$(ServerPlatform)"
bin_dir="/palworld/Pal/Binaries/Win64"
src_dir="/palworld/Mods/NativeMods"
workshop_staging_dir="/palworld/Mods/.workshop"
mods_base_dir="${bin_dir}/ue4ss/Mods"
workshop_app_id="1623730"
state_file="/palworld/Mods/.state.json"
steamcmd_bin="${steamcmd_bin:-/home/steam/steamcmd/steamcmd.sh}"
steam_login_user_file="/palworld/.steam/.steam-login-user"
workshop_mods_file="${workshop_mods_file:-/palworld/workshop-mods.txt}"
previous_state='{}'

#-------------------------------------------------
# helper functions
#-------------------------------------------------
_trim() {
    local value="${1:-}"
    value="$(printf '%s' "${value}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf '%s' "${value}"
}

#-------------------------------------------------
# ue4ss functions
#-------------------------------------------------
ue4ss_source_is_available() {
    local source_dir="$1"

    [ -d "${source_dir}/ue4ss" ] || \
    [ -f "${source_dir}/dwmapi.dll" ] || \
    [ -f "${source_dir}/UE4SS.dll" ] || \
    [ -f "${source_dir}/UE4SS-settings.ini" ] || \
    [ -f "${source_dir}/MemberVariableLayout.ini" ] || \
    [ -f "${source_dir}/Vindsent.dll" ]
}

sync_ue4ss_experimental_source() {
    local zip_file="/palworld/Mods/.cache/UE4SS-Palworld.zip"
    local tmp_file="${zip_file}.tmp"
    local target_dir="$1"
    local should_extract=false

    if ! isTrue "${UE4SS_EXPERIMENTAL_INSTALL}"; then
        if [ -d "${target_dir}" ]; then
            rm -rf "${target_dir}"
        fi
        return 0
    fi

    mkdir -p "$(dirname "${zip_file}")"
    mkdir -p "$(dirname "${target_dir}")"

    if [ -f "${zip_file}" ]; then
        if curl -sSfL -z "${zip_file}" -o "${tmp_file}" "${UE4SS_EXPERIMENTAL_URL}"; then
            if [ -s "${tmp_file}" ]; then
                mv -f "${tmp_file}" "${zip_file}"
                should_extract=true
                LogInfo "Downloaded newer UE4SS experimental package."
            else
                rm -f "${tmp_file}"
                if [ ! -d "${target_dir}" ]; then
                    should_extract=true
                fi
            fi
        else
            LogWarn "Failed to check UE4SS experimental updates from ${UE4SS_EXPERIMENTAL_URL}. Using local cache if available."
            rm -f "${tmp_file}"
            if [ ! -f "${zip_file}" ]; then
                return 0
            fi
            if [ ! -d "${target_dir}" ]; then
                should_extract=true
            fi
        fi
    else
        if ! curl -sSfL -o "${zip_file}" "${UE4SS_EXPERIMENTAL_URL}"; then
            LogWarn "Failed to download UE4SS experimental package from ${UE4SS_EXPERIMENTAL_URL}."
            return 0
        fi
        should_extract=true
    fi

    if [ "${should_extract}" != true ]; then
        return 0
    fi

    rm -rf "${target_dir}"
    mkdir -p "${target_dir}"

    if unzip -o "${zip_file}" -d "${target_dir}" >/dev/null; then
        LogDebug "Extracted UE4SS experimental package to ${target_dir}"
    else
        LogWarn "Failed to extract UE4SS experimental package."
        rm -rf "${target_dir}"
    fi
}

cleanup_previous_ue4ss_state() {
    local state_json="$1"
    local tracked_path

    while IFS= read -r tracked_path; do
        [ -z "${tracked_path}" ] && continue
        rm -rf "${bin_dir:?}/${tracked_path}"
    done < <(printf '%s' "${state_json}" | jq -r '.ue4ss.files[]? // empty' 2>/dev/null)

    if isTrue "${UE4SS_CLEANUP_LEGACY}"; then
        rm -f "${bin_dir:?}/dwmapi.dll" "${bin_dir:?}/UE4SS.dll" "${bin_dir:?}/UE4SS-settings.ini" "${bin_dir:?}/MemberVariableLayout.ini" "${bin_dir:?}/Vindsent.dll"
    fi
}

add_deployed_ue4ss_file() {
    local path="$1"
    local current

    for current in "${DEPLOYED_UE4SS_FILES[@]}"; do
        if [ "${current}" = "${path}" ]; then
            return 0
        fi
    done

    DEPLOYED_UE4SS_FILES+=("${path}")
}

deploy_ue4ss_artifacts() {
    local source_dir="$1"

    if ! ue4ss_source_is_available "${source_dir}"; then
        return 0
    fi

    mkdir -p "${bin_dir}"

    if [ -d "${source_dir}/ue4ss" ]; then
        mkdir -p "${bin_dir}/ue4ss"
        cp -a "${source_dir}/ue4ss/." "${bin_dir}/ue4ss/"
        add_deployed_ue4ss_file "ue4ss"
    fi

    if [ -f "${source_dir}/dwmapi.dll" ]; then
        cp -f "${source_dir}/dwmapi.dll" "${bin_dir}/dwmapi.dll"
        add_deployed_ue4ss_file "dwmapi.dll"
    elif [ -f "${source_dir}/UE4SS.dll" ]; then
        cp -f "${source_dir}/UE4SS.dll" "${bin_dir}/UE4SS.dll"
        cp -f "${source_dir}/UE4SS.dll" "${bin_dir}/dwmapi.dll"
        add_deployed_ue4ss_file "UE4SS.dll"
        add_deployed_ue4ss_file "dwmapi.dll"
    fi

    for extra_file in "UE4SS-settings.ini" "MemberVariableLayout.ini" "Vindsent.dll"; do
        if [ -f "${source_dir}/${extra_file}" ]; then
            cp -f "${source_dir}/${extra_file}" "${bin_dir}/${extra_file}"
            add_deployed_ue4ss_file "${extra_file}"
        fi
    done

    if [ -d "${source_dir}/Mods" ]; then
        mkdir -p "${mods_base_dir}"
        cp -a "${source_dir}/Mods/." "${mods_base_dir}/"
        add_deployed_ue4ss_file "$(realpath --relative-to="${bin_dir}" "${mods_base_dir}")"
    fi
}

#-------------------------------------------------
# workshop functions
#-------------------------------------------------
cleanup_previous_state() {
    local state_json="$1"
    local item

    while IFS= read -r item; do
        [ -z "${item}" ] && continue
        rm -f "/palworld/Pal/Content/Paks/LogicMods/${item}"
    done < <(printf '%s' "${state_json}" | jq -r '.deployed_paks[]? // empty' 2>/dev/null)

    cleanup_previous_ue4ss_state "${state_json}"
}

read_workshop_ids() {
    local ids=()
    local raw_id
    local line

    if [ -n "${WORKSHOP_MOD_IDS:-}" ]; then
        IFS=',' read -r -a raw_ids <<< "${WORKSHOP_MOD_IDS}"
        for raw_id in "${raw_ids[@]}"; do
            raw_id="$(_trim "${raw_id}")"
            if [ -n "${raw_id}" ]; then
                ids+=("${raw_id}")
            fi
        done
    fi

    if [ -f "${workshop_mods_file}" ]; then
        while IFS= read -r line || [ -n "${line:-}" ]; do
            line="${line%%#*}"
            line="$(_trim "${line}")"
            if [ -n "${line}" ]; then
                ids+=("${line}")
            fi
        done < "${workshop_mods_file}"
    fi

    printf '%s\n' "${ids[@]}" | awk 'NF && !seen[$0]++'
}

find_workshop_source_dir() {
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

collect_package_name() {
    local source_dir="$1"
    local fallback_name="$2"
    local info_json="${source_dir}/Info.json"
    local package_name=""

    if [ -f "${info_json}" ]; then
        package_name="$(jq -r '.PackageName // empty' "${info_json}" 2>/dev/null || true)"
    fi

    if [ -n "${package_name}" ] && [ "${package_name}" != "null" ]; then
        printf '%s' "${package_name}"
    else
        printf '%s' "${fallback_name}"
    fi
}

copy_mod_files() {
    local source_dir="$1"
    local target_dir="$2"

    rm -rf "${target_dir}"
    mkdir -p "${target_dir}"
    cp -a "${source_dir}/." "${target_dir}/"
}

deploy_pak_file() {
    local pak_file="$1"
    local pak_name
    pak_name="$(basename "${pak_file}")"
    mkdir -p "/palworld/Pal/Content/Paks/LogicMods"
    cp -f "${pak_file}" "/palworld/Pal/Content/Paks/LogicMods/"
    local existing
    for existing in "${DEPLOYED_PAKS[@]}"; do
        [ "${existing}" = "${pak_name}" ] && return 0
    done
    DEPLOYED_PAKS+=("${pak_name}")
}

_track_lua_mod() {
    local name="$1"
    local existing
    for existing in "${DEPLOYED_LUA_MODS[@]}"; do
        [ "${existing}" = "${name}" ] && return 0
    done
    DEPLOYED_LUA_MODS+=("${name}")
}

_track_palschema_mod() {
    local name="$1"
    local existing
    for existing in "${DEPLOYED_PALSCHEMA_MODS[@]}"; do
        [ "${existing}" = "${name}" ] && return 0
    done
    DEPLOYED_PALSCHEMA_MODS+=("${name}")
}

# Sync dest from source: copy new/updated files (cp -au), remove unmodified obsolete files.
_sync_dir() {
    local source_dir="$1"
    local dest_dir="$2"
    local src_ref_time dest_file rel_path dest_mtime

    mkdir -p "${dest_dir}"
    cp -au "${source_dir}/." "${dest_dir}/"

    src_ref_time="$(find "${source_dir}" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n1 | awk -F. '{print $1}')"
    [ -z "${src_ref_time}" ] && return 0

    while IFS= read -r -d '' dest_file; do
        rel_path="${dest_file#"${dest_dir}"/}"
        if [ ! -e "${source_dir}/${rel_path}" ]; then
            dest_mtime="$(stat -c '%Y' "${dest_file}" 2>/dev/null || echo 0)"
            if [ "${dest_mtime}" -le "${src_ref_time}" ]; then
                rm -f "${dest_file}"
            else
                LogDebug "Kept user-modified file absent from source: ${rel_path}"
            fi
        fi
    done < <(find "${dest_dir}" -type f -print0 2>/dev/null)
}

# Remove mod dirs from previous state that are no longer in the current deployment.
cleanup_removed_mods() {
    local prev_mod current_mod found
    while IFS= read -r prev_mod; do
        [ -z "${prev_mod}" ] && continue
        found=false
        for current_mod in "${DEPLOYED_LUA_MODS[@]}"; do
            [ "${current_mod}" = "${prev_mod}" ] && found=true && break
        done
        if [ "${found}" = false ]; then
            rm -rf "${mods_base_dir:?}/${prev_mod}"
            LogDebug "Removed undeployed lua mod: ${prev_mod}"
        fi
    done < <(printf '%s' "${previous_state}" | jq -r '.deployed_lua_mods[]? // empty' 2>/dev/null)

    while IFS= read -r prev_mod; do
        [ -z "${prev_mod}" ] && continue
        found=false
        for current_mod in "${DEPLOYED_PALSCHEMA_MODS[@]}"; do
            [ "${current_mod}" = "${prev_mod}" ] && found=true && break
        done
        if [ "${found}" = false ]; then
            rm -rf "${mods_base_dir:?}/PalSchema/mods/${prev_mod}"
            LogDebug "Removed undeployed palschema mod: ${prev_mod}"
        fi
    done < <(printf '%s' "${previous_state}" | jq -r '.deployed_palschema_mods[]? // empty' 2>/dev/null)
}

deploy_mod_via_rules() {
    local dest_dir="$1"
    local pkg_name="$2"
    local info_json="${dest_dir}/Info.json"
    local rules_json rule type target clean_target target_path dest

    LogDebug "deploy_mod_via_rules: ${pkg_name}"

    if jq -e '.InstallRule[]? | select(.IsServer == true)' "${info_json}" >/dev/null 2>&1; then
        rules_json="$(jq -c '.InstallRule[]? | select(.IsServer == true)' "${info_json}" 2>/dev/null || true)"
    else
        rules_json="$(jq -c '.InstallRule[]?' "${info_json}" 2>/dev/null || true)"
    fi

    while IFS= read -r rule; do
        [ -z "${rule}" ] && continue
        type="$(printf '%s' "${rule}" | jq -r '.Type // empty')"

        while IFS= read -r target; do
            clean_target="${target#./}"
            clean_target="${clean_target#/}"
            target_path="${dest_dir}/${clean_target}"
            if [ "${clean_target}" = "." ] || [ -z "${clean_target}" ]; then
                target_path="${dest_dir}"
            fi

            if [ ! -e "${target_path}" ]; then
                LogWarn "Target path ${target_path} not found for type ${type}"
                continue
            fi

            case "${type}" in
                Lua)
                    dest="${mods_base_dir}/${pkg_name}"
                    LogInfo "  [Lua] ${pkg_name} → ${dest}"
                    mkdir -p "${dest}"
                    if [ -d "${target_path}" ]; then _sync_dir "${target_path}" "${dest}"; else cp -u "${target_path}" "${dest}/"; fi
                    _track_lua_mod "${pkg_name}"
                    ;;
                Paks)
                    LogInfo "  [Paks] ${pkg_name} → LogicMods"
                    while IFS= read -r -d '' pak; do
                        deploy_pak_file "${pak}"
                    done < <(find "${target_path}" -type f -name '*.pak' -print0)
                    ;;
                PalSchema)
                    dest="${mods_base_dir}/PalSchema/mods/${pkg_name}"
                    LogInfo "  [PalSchema] ${pkg_name} → ${dest}"
                    mkdir -p "${dest}"
                    if [ -d "${target_path}" ]; then _sync_dir "${target_path}" "${dest}"; else cp -u "${target_path}" "${dest}/"; fi
                    _track_palschema_mod "${pkg_name}"
                    ;;
                UE4SS)
                    LogInfo "  [UE4SS] deploying framework from ${target_path}"
                    deploy_ue4ss_artifacts "${target_path}"
                    ;;
            esac
        done < <(printf '%s' "${rule}" | jq -r '.Targets[]? // empty')
    done < <(printf '%s\n' "${rules_json}")
}

deploy_mod_auto_discover() {
    local dest_dir="$1"
    local pkg_name="$2"
    local d sub name dest found_flat pak

    LogDebug "deploy_mod_auto_discover: ${pkg_name}"

    while IFS= read -r -d '' pak; do
        deploy_pak_file "${pak}"
    done < <(find "${dest_dir}" -type f -name '*.pak' -print0)

    if [ -d "${dest_dir}/Mods" ]; then
        for d in "${dest_dir}/Mods"/*/; do
            [ -d "${d}" ] || continue
            name="$(basename "${d}")"
            _sync_dir "${d}" "${mods_base_dir}/${name}"
            if [ "${name}" = "PalSchema" ] && [ -d "${d}/mods" ]; then
                for sub in "${d}/mods"/*/; do
                    [ -d "${sub}" ] && _track_palschema_mod "$(basename "${sub}")"
                done
            else
                _track_lua_mod "${name}"
            fi
        done
    fi

    if [ -d "${dest_dir}/PalSchema/mods" ]; then
        mkdir -p "${mods_base_dir}/PalSchema/mods"
        for d in "${dest_dir}/PalSchema/mods"/*/; do
            [ -d "${d}" ] || continue
            _sync_dir "${d}" "${mods_base_dir}/PalSchema/mods/$(basename "${d}")"
            _track_palschema_mod "$(basename "${d}")"
        done
    elif [ -d "${dest_dir}/PalSchema" ]; then
        if [ -f "${dest_dir}/PalSchema/scripts/main.lua" ] || [ -f "${dest_dir}/PalSchema/main.lua" ]; then
            _sync_dir "${dest_dir}/PalSchema" "${mods_base_dir}/PalSchema"
            _track_lua_mod "PalSchema"
        else
            dest="${mods_base_dir}/PalSchema/mods/${pkg_name}"
            mkdir -p "${dest}"
            _sync_dir "${dest_dir}/PalSchema" "${dest}"
            _track_palschema_mod "${pkg_name}"
        fi
    elif [ -d "${dest_dir}/mods" ]; then
        mkdir -p "${mods_base_dir}/PalSchema/mods"
        for d in "${dest_dir}/mods"/*/; do
            [ -d "${d}" ] || continue
            _sync_dir "${d}" "${mods_base_dir}/PalSchema/mods/$(basename "${d}")"
            _track_palschema_mod "$(basename "${d}")"
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
        dest="${mods_base_dir}/PalSchema/mods/${pkg_name}"
        mkdir -p "${dest}"
        _sync_dir "${dest_dir}" "${dest}"
        _track_palschema_mod "${pkg_name}"
    fi
}

deploy_mod() {
    local source_dir="$1"
    local dest_dir="$2"
    local pkg_name="$3"
    local info_json

    copy_mod_files "${source_dir}" "${dest_dir}"
    info_json="${dest_dir}/Info.json"
    if [ -f "${info_json}" ] && jq -e '.InstallRule' "${info_json}" >/dev/null 2>&1; then
        deploy_mod_via_rules "${dest_dir}" "${pkg_name}"
    else
        deploy_mod_auto_discover "${dest_dir}" "${pkg_name}"
    fi
}

ensure_palmodsettings_ini() {
    local ini_file="/palworld/Mods/PalModSettings.ini"
    local tmp_file
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

    mv "${tmp_file}" "${ini_file}"
    chmod 644 "${ini_file}"
}

update_mods_txt() {
    local mods_txt="${mods_base_dir}/mods.txt"
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

build_state_json() {
    local workshop_json='{}'
    local native_json='{}'
    local ue4ss_files_json='[]'
    local deployed_paks_json='[]'
    local deployed_lua_json='[]'
    local deployed_palschema_json='[]'
    local mod_id source_dir version mod_name native_version tracked_file item

    for mod_id in "${WORKSHOP_IDS[@]}"; do
        source_dir="$(find_workshop_source_dir "${mod_id}" || true)"
        if [ -n "${source_dir}" ] && [ -f "${source_dir}/Info.json" ]; then
            version="$(jq -r '.Version // "unknown"' "${source_dir}/Info.json" 2>/dev/null || echo unknown)"
        else
            version="missing"
        fi
        workshop_json="$(jq -cn --argjson base "${workshop_json}" --arg key "${mod_id}" --arg value "${version}" '$base + {($key): $value}')"
    done

    for mod_name in "${NATIVE_MOD_NAMES[@]}"; do
        source_dir="${src_dir:?}/${mod_name}"
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

download_workshop_mods() {
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
    LogDebug "${steamcmd_bin} +login ${login_source} +workshop_download_item ... +quit"
    if ! "${steamcmd_bin}" "${steamcmd_args[@]}"; then
        LogWarn "SteamCMD reported an error while downloading workshop mods. Continuing with any files that were downloaded."
    fi
}

#-------------------------------------------------
# Main flow
#-------------------------------------------------

# Windows only
if [ "${platform}" != "windows" ]; then
    LogInfo "Mod support is enabled only for ${image}."
    exit 0
fi

# Load previous state if available
if [ -f "${state_file}" ]; then
    previous_state="$(jq -c . "${state_file}" 2>/dev/null || echo '{}')"
fi

mapfile -t WORKSHOP_IDS < <(read_workshop_ids || true)
download_workshop_mods "${WORKSHOP_IDS[@]}"

ACTIVE_PACKAGES=()
NATIVE_MOD_NAMES=()
DEPLOYED_UE4SS_FILES=()
DEPLOYED_PAKS=()
DEPLOYED_LUA_MODS=()
DEPLOYED_PALSCHEMA_MODS=()

cleanup_previous_state "${previous_state}"

# Deploy NativeMods/*
while IFS= read -r -d '' mod_path; do
    mod_name="$(basename "${mod_path}")"
    pkg_name="$(collect_package_name "${mod_path}" "${mod_name}")"
    dest_dir="${mods_base_dir}/${mod_name}"

    deploy_mod "${mod_path}" "${dest_dir}" "${pkg_name}"
    ACTIVE_PACKAGES+=("${pkg_name}")
    NATIVE_MOD_NAMES+=("${mod_name}")
    LogInfo "Deployed NativeMods/${mod_name} (${pkg_name}) to ${dest_dir}"
done < <(find "${src_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

# Wipe Workshop staging so stale entries from prior naming don't accumulate
rm -rf "${workshop_staging_dir}"
mkdir -p "${workshop_staging_dir}"

for mod_id in "${WORKSHOP_IDS[@]}"; do
    source_dir="$(find_workshop_source_dir "${mod_id}" || true)"
    if [ -z "${source_dir}" ]; then
        LogWarn "Workshop mod ${mod_id} was not found after download."
        continue
    fi

    pkg_name="$(collect_package_name "${source_dir}" "${mod_id}")"
    dest_dir="${workshop_staging_dir}/${pkg_name}"
    deploy_mod "${source_dir}" "${dest_dir}" "${pkg_name}"
    ACTIVE_PACKAGES+=("${pkg_name}")
    LogInfo "Deployed workshop mod ${mod_id} (${pkg_name}) to ${dest_dir}"
done

# override with UE4SS experimental if enabled
sync_ue4ss_experimental_source "/palworld/Mods/.tmp/ue4ss-experimental"
deploy_ue4ss_artifacts "/palworld/Mods/.tmp/ue4ss-experimental"

cleanup_removed_mods
update_mods_txt
ensure_palmodsettings_ini

current_state="$(build_state_json)"

printf '%s\n' "${current_state}" | jq '.' > "${state_file}"
chmod 644 "${state_file}"

LogDebug "previous state: ${previous_state}"
LogDebug "current state: ${current_state}"

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
