#!/bin/bash

if [[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]; then
    if [[ "${PUID}" -ne 0 ]] && [[ "${PGID}" -ne 0 ]]; then
        printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
        usermod -o -u "${PUID}" steam
        groupmod -o -g "${PGID}" steam
        chown -R steam:steam /palworld /home/steam/
    else
        printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
        exit 1
    fi
elif [[ "$(id -u)" -eq 0 ]] || [[ "$(id -g)" -eq 0 ]]; then
   printf "\033[31mRunning as root is not supported, please fix your user!\n"
   exit 1
fi

mkdir -p /palworld/backups

# shellcheck disable=SC2317
term_handler() {
    if [ "${RCON_ENABLED,,}" = true ]; then
        rcon-cli save
        rcon-cli "shutdown 1"
    else # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi
    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c ./start.sh &
else
    ./start.sh &
fi
# Process ID of su
killpid="$!"
wait "$killpid"

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
