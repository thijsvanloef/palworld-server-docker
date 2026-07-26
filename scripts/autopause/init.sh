#!/bin/bash

monitorBackendFile="/home/steam/server/autopause/.monitor-backend"

if isTrue "${AUTO_PAUSE_ENABLED}"; then
    if ! PlayerLogging_isEnabled; then
        LogError "AUTO_PAUSE requires ENABLE_PLAYER_LOGGING=True and REST_API_ENABLED=True."
        exit 1
    fi

    # Decide monitor backend at startup and persist it for services.sh.
    # Priority:
    #   1. NFLOG (requires iptables + tcpdump + NET_RAW,NET_ADMIN capability)
    #   2. knockd (requires knockd binary + NET_RAW capability)
    #   3. Error (no suitable backend available)
    if command -v iptables > /dev/null 2>&1 && command -v tcpdump > /dev/null 2>&1; then
        monitorBackend="nflog"
        LogInfo "AUTO_PAUSE packet monitor: NFLOG (iptables+tcpdump) available."
    else
        LogInfo "AUTO_PAUSE packet monitor: NFLOG (iptables+tcpdump) unavailable."
        LogWarn "NET_ADMIN & NET_RAW capability required for NFLOG. e.g) podman run --cap-add=NET_ADMIN --cap-add=NET_RAW ..."
        if command -v knockd > /dev/null 2>&1 && knockd --version > /dev/null 2>&1; then
            monitorBackend="knockd"
            LogInfo "AUTO_PAUSE packet monitor: knockd available."
        else
            LogInfo "AUTO_PAUSE packet monitor: knockd unavailable."
            LogError "AUTO_PAUSE requires NET_RAW capability. e.g) podman run --cap-add=NET_RAW ..."
            exit 1
        fi
    fi

    printf '%s\n' "${monitorBackend}" > "${monitorBackendFile}"
    chmod 0644 "${monitorBackendFile}" || true
    if [ "$(id -u)" -eq 0 ]; then
        chown steam:steam "${monitorBackendFile}" || true
    fi

    # shellcheck source=scripts/autopause/community/init.sh
    source "/home/steam/server/autopause/community/init.sh"
fi
