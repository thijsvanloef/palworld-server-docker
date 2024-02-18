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

    case "$(countdown_message "${AUTO_REBOOT_WARN_MINUTES}" "The_Server_will_reboot"; echo $?)" in
        0 )
            shutdown_server
            ;;
        1 )
            LogError "Unable to auto reboot, the server is not empty and AUTO_REBOOT_WARN_MINUTES is empty"
            exit 1
            ;;
        2 )
            LogError "Unable to auto reboot, the server is not empty and AUTO_REBOOT_WARN_MINUTES is not an integer: ${AUTO_REBOOT_WARN_MINUTES}"
            exit 1
            ;;
    esac
else
    LogWarn "Unable to reboot. RCON is required."
    exit 1
fi
