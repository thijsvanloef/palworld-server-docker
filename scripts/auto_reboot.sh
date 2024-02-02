#!/bin/bash

if [ "${RCON_ENABLED,,}" = true ]; then
    if [ -z "${AUTO_REBOOT_WARN_MINUTES}" ]; then
        echo "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is empty."
    elif [[ "${AUTO_REBOOT_WARN_MINUTES}" =~ ^[0-9]+$ ]]; then
        for ((i = "${AUTO_REBOOT_WARN_MINUTES}" ; i > 0 ; i--)); do
            rcon-cli -c /home/steam/server/rcon.yaml "broadcast The_Server_will_reboot_in_${i}_Minutes"
            sleep "1m"
        done

        rcon-cli -c /home/steam/server/rcon.yaml save
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    else
        echo "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is not an integer: ${AUTO_REBOOT_WARN_MINUTES}"
    fi
else
    echo "Unable to reboot. RCON is required."
fi
