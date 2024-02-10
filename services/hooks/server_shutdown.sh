#!/bin/bash

shutdown() {
    if [ "${RCON_ENABLED,,}" = true ]; then
        rcon-cli save
        rcon-cli "shutdown 1"
    #else # Does not save
        #kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi


    mapfile -t backup_pids < <(pgrep backup)
    if [ "${#backup_pids[@]}" -ne 0 ]; then
        echo "Waiting for backup to finish"
        for pid in "${backup_pids[@]}"; do
            tail --pid="$pid" -f 2>/dev/null
        done
    fi

    mapfile -t restore_pids < <(pgrep restore)
    if [ "${#restore_pids[@]}" -ne 0 ]; then
        echo "Waiting for restore to finish"
        for pid in "${restore_pids[@]}"; do
            tail --pid="$pid" -f 2>/dev/null
        done
    fi
}