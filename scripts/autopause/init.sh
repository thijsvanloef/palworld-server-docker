#!/bin/bash

# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

if isTrue "${AUTO_PAUSE_ENABLED}"; then
    if ! PlayerLogging_isEnabled; then
        LogError "AUTO_PAUSE requires ENABLE_PLAYER_LOGGING=True and REST_API_ENABLED=True."
        exit 1
    fi

    if ! APMonitor_detectAvailableBackend; then
        LogError "AUTO_PAUSE requires either KNOCKD or NFLOG to be available."
        exit 1
    fi

    # shellcheck source=scripts/autopause/community/init.sh
    source "/home/steam/server/autopause/community/init.sh"
fi
