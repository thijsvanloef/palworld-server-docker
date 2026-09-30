#!/bin/bash
# ------------------------------------------------------------
# UE4SS Logging Script
# ------------------------------------------------------------

# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

UE4SS_LOGFILE="/palworld/Pal/Binaries/Win64/ue4ss/UE4SS.log"
SERVER_PID=""

function get_server_pid() {
    local timeout="${1:-10}"  # Default timeout is 10 seconds
    local elapsed=0
    local pid=""

    while [ "${elapsed}" -lt "${timeout}" ]; do
        pid="$(PalworldServerPid)"
        if [ -n "${pid}" ]; then
            echo -n "${pid}"
            return 0  # Palworld server started successfully
        fi
        sleep 1
        ((elapsed++))
    done

    return 1  # Timeout reached, return failure
}

# ------------------------------------------------------------
# Prepare for UE4SS logging
# ------------------------------------------------------------

# Check that PalServer is not running yet and delete the UE4SS log file.
if PalworldServerPid >/dev/null 2>&1; then
    LogInfo "PalServer is already running, skipping UE4SS log file deletion."
else
    rm -f "${UE4SS_LOGFILE}"
fi

# Wait until PalServer starts, and abort if it cannot be confirmed to start.
if ! SERVER_PID="$(get_server_pid 10)"; then
    LogError "PalServer did not start within 10 seconds, aborting UE4SS logging."
    exit 1
fi

# Wait for the UE4SS log file to be generated.
while [ ! -f "${UE4SS_LOGFILE}" ]; do
    sleep 1
    LogInfo "Waiting for UE4SS log file to be generated..."
    # Abort if SERVER_PID is lost.
    if ! kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
        LogError "PalServer has stopped unexpectedly, aborting UE4SS logging."
        exit 1
    fi
done

# ------------------------------------------------------------
# Start UE4SS logging
# ------------------------------------------------------------

LogInfo "UE4SS log file generated, starting to tail the log."

# Display the log file in real-time until SERVER_PID dies.
exec tail -f "${UE4SS_LOGFILE}" --pid="${SERVER_PID}"
