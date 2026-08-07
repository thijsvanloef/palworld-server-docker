#!/bin/bash
# update-wine-rt — Install / update Visual C++ Runtime 2022 via winetricks.
#
# Usage (as steam user):
#   update-wine-rt            # Install if not already installed (idempotent)
#   update-wine-rt --force    # Force reinstall regardless of marker file
#
#   docker exec -itu steam <container> update-wine-rt [--force]
#
# If called as root, automatically re-execs as the steam user.
# Xvfb is started internally (user process, no root required) and stopped on exit.
set -euo pipefail

# Group-writable umask: all Wine-created files inherit the wine group with rw access
umask 002

WINEPREFIX="${WINEPREFIX:-/opt/wine}"
export WINEPREFIX
export WINEARCH="${WINEARCH:-win64}"
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree,mshtml=;dwmapi=n,b}"

MARKER_FILE="${WINEPREFIX}/.vcrun2022-installed"
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# --- Root guard: drop to steam user (same mechanism as init.sh) ---
if [[ "${EUID}" -eq 0 ]]; then
    exec su steam -c "exec \"\$0\" \"\$@\"" -- "$0" "$@"
fi

# --- Find a free X display number (starting from :99) ---
_DISP_NUM=99
while true; do
    _LOCK="/tmp/.X${_DISP_NUM}-lock"
    if [[ ! -f "${_LOCK}" ]]; then
        break
    fi
    # Check if the owning process is still alive; if not, treat as stale
    _LOCK_PID=$(tr -d ' \n' < "${_LOCK}" 2>/dev/null || true)
    if [[ -n "${_LOCK_PID}" ]] && ! kill -0 "${_LOCK_PID}" 2>/dev/null; then
        rm -f "${_LOCK}" "/tmp/.X11-unix/X${_DISP_NUM}" 2>/dev/null || true
        break
    fi
    _DISP_NUM=$((_DISP_NUM + 1))
    if [[ "${_DISP_NUM}" -gt 120 ]]; then
        echo "ERROR: No free X display found in :99-:120" >&2
        exit 1
    fi
done
_DISP=":${_DISP_NUM}"

# --- Start Xvfb and register EXIT cleanup ---
Xvfb "${_DISP}" -ac -nolisten tcp -screen 0 640x480x8 &
_XVFB_PID=$!
# shellcheck disable=SC2064
trap "kill ${_XVFB_PID} 2>/dev/null; wait ${_XVFB_PID} 2>/dev/null || true" EXIT
export DISPLAY="${_DISP}"

# Give Xvfb a moment to initialise
sleep 1

# --- Initialise Wine prefix if not present ---
if [[ ! -d "${WINEPREFIX}" ]] || [[ ! -f "${WINEPREFIX}/.wine-initialized" ]]; then
    echo ">>> Initializing Wine prefix at ${WINEPREFIX}"
    mkdir -p "${WINEPREFIX}"
    # Best-effort: set wine group and setgid (no-op if already configured by Dockerfile)
    chgrp wine "${WINEPREFIX}" 2>/dev/null || true
    chmod 2770 "${WINEPREFIX}" 2>/dev/null || true
    WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init
    wineserver -w || true
    touch "${WINEPREFIX}/.wine-initialized"
fi

# --- Skip if already installed (unless --force) ---
if [[ "${FORCE}" == "false" ]] && [[ -f "${MARKER_FILE}" ]]; then
    echo ">>> Visual C++ Runtime 2022 already installed. Use --force to reinstall."
    exit 0
fi

# --- Install vcrun2022 ---
echo ">>> Installing Visual C++ Runtime 2022 via winetricks..."
/usr/local/bin/winetricks -q vcrun2022

touch "${MARKER_FILE}"
echo ">>> Visual C++ Runtime 2022 installed successfully."
