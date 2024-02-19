#!/bin/bash

# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

graceful_shutdown() {
    if [ "${RCON_ENABLED,,}" = true ]; then
        rcon-cli -c /home/steam/server/rcon.yaml save
        rcon-cli -c /home/steam/server/rcon.yaml doexit
    fi
    wait "$PID"
    exit 0
}

trap 'graceful_shutdown' TERM INT

STARTCOMMAND=$(BuildStartCommand)
if [ "$!" == 1 ]; then
    LogWarn "Server Not Installed Properly"
    exit 1
fi

${STARTCOMMAND} &
PID=$!
wait "$PID"