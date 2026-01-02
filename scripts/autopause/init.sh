#!/bin/bash

if isTrue "${AUTO_PAUSE_ENABLED}"; then
    if ! PlayerLogging_isEnabled; then
        LogError "AUTO_PAUSE requires ENABLE_PLAYER_LOGGING=True and REST_API_ENABLED=True."
        exit 1
    fi
    if command -v knockd > /dev/null 2>&1 && ! knockd --version > /dev/null 2>&1; then
        LogError "AUTO_PAUSE requires NET_RAW capability. e.g) podman run --cap-add=NET_RAW ..."
        exit 1
    fi

    # shellcheck source=scripts/autopause/community/init.sh
    source "/home/steam/server/autopause/community/init.sh"
fi
