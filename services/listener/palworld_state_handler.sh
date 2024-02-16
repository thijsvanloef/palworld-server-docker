#!/bin/bash

send_discord_message() {
    "$(/home/steam/server/discord.sh "${1}" "${2}" &)"
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
            PROCESS_STATE_STARTING)
                send_discord_message "${processname} is starting" "in-progress"
                ;;
            PROCESS_STATE_RUNNING)
                send_discord_message "${processname} is running" "success"
                ;;
            PROCESS_STATE_STOPPING)
                send_discord_message "${processname} is stopping." "in-progress"
                ;;
            PROCESS_STATE_STOPPED)
                send_discord_message "${processname} has stopped." "failure"
                ;;
            PROCESS_STATE_EXITED)
                send_discord_message "${processname} has exited." "failure"
                ;;
            *)
                send_discord_message "Unkown event: $header" "failure"
                ;;
        esac
    fi
    printf "RESULT 2\nOK"
done