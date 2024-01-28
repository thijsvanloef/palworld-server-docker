#!/bin/bash

if [ -n "$PRE_INIT_HOOK" ]; then
    echo "PRE_INIT_HOOK: $PRE_INIT_HOOK"
    eval "$PRE_INIT_HOOK"
fi

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
    exit 1
fi

mkdir -p /palworld/backups
chown -R steam:steam /palworld /home/steam/

term_handler() {
    if [ -n "$PRE_SHUTDOWN_HOOK" ]; then
        echo "PRE_SHUTDOWN_HOOK: $PRE_SHUTDOWN_HOOK"
        eval "$PRE_SHUTDOWN_HOOK"
    fi

    if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
        rcon-cli "shutdown 1"
    else # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi
    tail --pid=$killpid -f 2>/dev/null

    if [ -n "$POST_SHUTDOWN_HOOK" ]; then
        echo "POST_SHUTDOWN_HOOK: $POST_SHUTDOWN_HOOK"
        eval "$POST_SHUTDOWN_HOOK"
    fi
}

trap 'term_handler' SIGTERM

if [ -n "$POST_INIT_HOOK" ]; then
    echo "POST_INIT_HOOK: $POST_INIT_HOOK"
    eval "$POST_INIT_HOOK"
fi

su steam -c ./start.sh &
# Process ID of su
killpid="$!"
wait $killpid
