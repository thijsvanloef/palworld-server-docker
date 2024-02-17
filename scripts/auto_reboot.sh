#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [ "${RCON_ENABLED,,}" = true ]; then
    if [ "${AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE,,}" != true ]; then
        players_count=$(get_player_count)

        if [ "$players_count" -gt 0 ]; then
            LogWarn "There are ${players_count} players online. Skipping auto reboot."
            exit 0
        fi
    fi

    if countdown_message "${AUTO_REBOOT_WARN_MINUTES}" "The_Server_will_reboot"; then
        shutdown_server
    elif [ -z "${AUTO_REBOOT_WARN_MINUTES}" ]; then
        LogError "Unable to auto reboot, the server is not empty and AUTO_REBOOT_WARN_MINUTES is empty"
        exit 1
    else
        LogError "Unable to auto reboot, the server is not empty and AUTO_REBOOT_WARN_MINUTES is not an integer: ${AUTO_REBOOT_WARN_MINUTES}"
    fi
else
    LogWarn "Unable to reboot. RCON is required."
    exit 1
fi
