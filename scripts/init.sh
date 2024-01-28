#!/bin/bash

if ! [[[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]]; then
   printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
   exit 1
fi

mkdir -p /palworld/backups

term_handler() {
    if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
        rcon-cli "shutdown 1"
    else # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi
    tail --pid=$killpid -f 2>/dev/null
}

trap 'term_handler' SIGTERM

su steam -c ./start.sh &
# Process ID of su
killpid="$!"
wait $killpid
