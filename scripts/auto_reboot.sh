#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [ "${RCON_ENABLED,,}" = true ]; then
    if [ "${AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE,,}" != true ]; then
        players_count=$(get_player_count)

        if [ "$players_count" -gt 0 ]; then
            echo "There are ${players_count} players online. Skipping auto reboot."
            exit 1
        fi
    fi

    if countdown_message "${AUTO_REBOOT_WARN_MINUTES}" "The_Server_will_reboot"; then
        rcon-cli -c /home/steam/server/rcon.yaml save
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    elif [ -z "${AUTO_REBOOT_WARN_MINUTES}" ]; then
        echo "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is empty."
    else
        echo "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is not an integer: ${AUTO_REBOOT_WARN_MINUTES}"
    fi
else
    echo "Unable to reboot. RCON is required."
fi
