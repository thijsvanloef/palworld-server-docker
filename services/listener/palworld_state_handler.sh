#!/bin/bash

send_discord_message() {
    "$(/home/steam/server/discord.sh "${@}" &)"
}

# generates variables from header String
# supervisor provides the following variables: ver, server, serial, pool, myeventpool, poolserial, processname, eventname, len
parse_headers() {
    
    IFS=' '
    for part in $1; do
        key=$(echo "$part" | cut -d':' -f1)
        value=$(echo "$part" | cut -d':' -f2)
        declare -g "$key=$value"
    done
}

declare eventname
declare processname

while true; do
    printf "READY\n"
    read -r header
    parse_headers "$header"

    if [ "${processname}" = "palworld" ]; then

        case $eventname in
            PROCESS_STATE_RUNNING)
                send_discord_message "${DISCORD_PRE_START_MESSAGE}" "success"
                ;;
            PROCESS_STATE_STOPPING)
                send_discord_message "${DISCORD_PRE_SHUTDOWN_MESSAGE}" "in-progress"
                ;;
            PROCESS_STATE_STOPPED|PROCESS_STATE_EXITED)
                send_discord_message "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure"
                ;;
            *)
                send_discord_message "Unkown event occured: $header" "failure"
                ;;
        esac
    fi
    printf "RESULT 2\nOK"
done