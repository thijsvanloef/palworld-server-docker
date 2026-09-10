#!/bin/bash
# Linux UE4SS helpers for the dedicated server.
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

UE4SS_IMAGE_LIB="${UE4SS_IMAGE_LIB:-/home/steam/server/ue4ss/libUE4SS.so}"
UE4SS_BIN_DIR="/palworld/Pal/Binaries/Linux"
UE4SS_MODS_DIR="${UE4SS_BIN_DIR}/Mods"
UE4SS_PAKS_DIR="/palworld/Pal/Content/Paks/~Mods"
UE4SS_NATIVE_MODS_DIR="/palworld/Mods/NativeMods"
UE4SS_PAKS_SOURCE_DIR="/palworld/Mods/Paks"
UE4SS_SETTINGS_TEMPLATE="/home/steam/server/files/UE4SS-settings.ini"

UE4SS_isEnabled() {
    isTrue "${ENABLE_UE4SS:-false}"
}

UE4SS_prepareDirectories() {
    mkdir -p \
        "${UE4SS_BIN_DIR}" \
        "${UE4SS_MODS_DIR}" \
        "${UE4SS_PAKS_DIR}" \
        "${UE4SS_NATIVE_MODS_DIR}" \
        "${UE4SS_PAKS_SOURCE_DIR}"
}

UE4SS_installLibrary() {
    local target_lib="${UE4SS_BIN_DIR}/libUE4SS.so"

    if [ ! -f "${UE4SS_IMAGE_LIB}" ]; then
        LogError "ENABLE_UE4SS is true, but ${UE4SS_IMAGE_LIB} is missing from the image."
        LogError "Rebuild the image on amd64, or mount a compatible libUE4SS.so and set UE4SS_IMAGE_LIB."
        return 1
    fi

    # Keep a copy beside the shipping binary (volume-backed) so LD_LIBRARY_PATH resolves cleanly.
    if [ ! -f "${target_lib}" ] || ! cmp -s "${UE4SS_IMAGE_LIB}" "${target_lib}"; then
        LogInfo "Installing libUE4SS.so into ${UE4SS_BIN_DIR}"
        cp -f "${UE4SS_IMAGE_LIB}" "${target_lib}"
        chmod 755 "${target_lib}"
    fi
}

UE4SS_ensureSettings() {
    local settings_file="${UE4SS_BIN_DIR}/UE4SS-settings.ini"
    local user_settings="/palworld/Mods/UE4SS-settings.ini"

    if [ -f "${user_settings}" ]; then
        cp -f "${user_settings}" "${settings_file}"
        return 0
    fi

    if [ ! -f "${settings_file}" ]; then
        LogInfo "Creating default UE4SS-settings.ini"
        cp -f "${UE4SS_SETTINGS_TEMPLATE}" "${settings_file}"
    fi
}

UE4SS_ensureModsTxt() {
    local mods_txt="${UE4SS_MODS_DIR}/mods.txt"

    if [ ! -f "${mods_txt}" ]; then
        LogInfo "Creating default Mods/mods.txt"
        cat > "${mods_txt}" <<'EOF'
UE4SSStatus : 1
Keybinds : 0
ConsoleCommands : 0
ConsoleEnablerMod : 0
BPML_GenericFunctions : 1
BPModLoaderMod : 1
EOF
    fi
}

UE4SS_syncNativeMods() {
    local mod_path mod_name

    if [ ! -d "${UE4SS_NATIVE_MODS_DIR}" ]; then
        return 0
    fi

    while IFS= read -r -d '' mod_path; do
        mod_name="$(basename "${mod_path}")"
        # Skip the auto-downloaded UE4SS package staging dir if present
        if [ "${mod_name}" = "ue4ss-linux" ]; then
            continue
        fi
        LogInfo "Syncing native mod '${mod_name}' into ${UE4SS_MODS_DIR}"
        mkdir -p "${UE4SS_MODS_DIR}/${mod_name}"
        cp -a "${mod_path}/." "${UE4SS_MODS_DIR}/${mod_name}/"
    done < <(find "${UE4SS_NATIVE_MODS_DIR}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
}

UE4SS_syncPaks() {
    local pak_count=0

    if [ ! -d "${UE4SS_PAKS_SOURCE_DIR}" ]; then
        return 0
    fi

    pak_count="$(find "${UE4SS_PAKS_SOURCE_DIR}" -maxdepth 1 -type f \( -name '*.pak' -o -name '*.ucas' -o -name '*.utoc' \) 2>/dev/null | wc -l | tr -d ' ')"
    if [ "${pak_count}" != "0" ]; then
        LogInfo "Syncing ${pak_count} pak file(s) into ${UE4SS_PAKS_DIR}"
        find "${UE4SS_PAKS_SOURCE_DIR}" -maxdepth 1 -type f \( -name '*.pak' -o -name '*.ucas' -o -name '*.utoc' \) -exec cp -f {} "${UE4SS_PAKS_DIR}/" \;
    fi
}

UE4SS_warnAboutCppDlls() {
    local dll_count
    dll_count="$(find "${UE4SS_MODS_DIR}" -type f -name '*.dll' 2>/dev/null | wc -l | tr -d ' ')"
    if [ "${dll_count}" != "0" ]; then
        LogWarn "Found ${dll_count} Windows .dll file(s) under ${UE4SS_MODS_DIR}."
        LogWarn "Linux UE4SS cannot load .dll files. C++ mods need a native libs/main.so build."
    fi
}

# Prepare UE4SS files and export LD_PRELOAD for the server process.
# Returns 0 on success / when disabled, 1 on hard failure.
SetupUE4SS() {
    local architecture
    architecture="$(dpkg --print-architecture)"

    if ! UE4SS_isEnabled; then
        return 0
    fi

    LogAction "Setting up Linux UE4SS"

    if [ "${architecture}" != "amd64" ]; then
        LogError "ENABLE_UE4SS is only supported on amd64. Current architecture: ${architecture}."
        return 1
    fi

    UE4SS_prepareDirectories || return 1
    UE4SS_installLibrary || return 1
    UE4SS_ensureSettings || return 1
    UE4SS_ensureModsTxt || return 1
    UE4SS_syncNativeMods
    UE4SS_syncPaks
    UE4SS_warnAboutCppDlls

    export LD_PRELOAD="${UE4SS_BIN_DIR}/libUE4SS.so${LD_PRELOAD:+:${LD_PRELOAD}}"
    export LD_LIBRARY_PATH="${UE4SS_BIN_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

    LogInfo "UE4SS enabled via LD_PRELOAD=${UE4SS_BIN_DIR}/libUE4SS.so"
    LogInfo "Place Lua mods in /palworld/Mods/NativeMods/<ModName>/ (synced to Binaries/Linux/Mods)."
    LogInfo "Place .pak files in /palworld/Mods/Paks/ (synced to Content/Paks/~Mods)."
    return 0
}
