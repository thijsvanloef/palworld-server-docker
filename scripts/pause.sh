#!/bin/bash
PID=$(pidof PalServer-Linux-Test)
PID_STATE=$(grep State "/proc/$PID/status" | cut -d '(' -f2 | cut -d ')' -f1)
LOCKFILE=/tmp/port_listener.lock

if [ -f "$LOCKFILE" ]; then
    exit 0
fi

if [ "${RCON_ENABLED}" = true ]; then
    PLAYERLIST=$(rcon-cli -c /home/steam/server/rcon.yaml "ShowPlayers")

    if [ "$(echo -n "$PLAYERLIST" | wc -l)" -gt 0 ]; then
        exit 0
    fi
    rcon-cli -c /home/steam/server/rcon.yaml save  
fi

monitor_traffic() {
    touch "$LOCKFILE"
    cleanup() {
        # shellcheck disable=SC2317
        rm -f "$LOCKFILE"
    }
    trap 'cleanup' EXIT
    while true; do
        packet_capture=$(tcpdump -n -c 1 -i any port "$1" 2>/dev/null)
        if [ -n "$packet_capture" ]; then
            echo "Connection attempt detected resuming the server" >> /proc/1/fd/1
            kill -CONT "$2"
            break
        fi
        sleep 1
    done
    exit 0
}

if [ "$PID_STATE" != "stopped" ]; then
    kill -STOP "$PID"
    echo "Server paused" >> /proc/1/fd/1
    monitor_traffic "$PORT" "$PID" &
fi
