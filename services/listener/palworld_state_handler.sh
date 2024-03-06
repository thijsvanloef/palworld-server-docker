#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

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
                #Ignore Starting Event
                LogAction "*****STARTING SERVER*****" >&2
                DiscordMessage "Server is starting" "in-progress" >&2
                ;;
            PROCESS_STATE_RUNNING)
                LogAction "*****STARTED SERVER*****" >&2
                DiscordMessage "${DISCORD_PRE_START_MESSAGE}" "success" >&2
                ;;
            PROCESS_STATE_STOPPING)
                LogAction "*****STOPPING SERVER*****" >&2
                DiscordMessage "${DISCORD_PRE_SHUTDOWN_MESSAGE}" "in-progress" >&2
                ;;
            PROCESS_STATE_STOPPED|PROCESS_STATE_EXITED)
                LogAction "*****STOPPED SERVER*****" >&2
                DiscordMessage "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure" >&2
                ;;
            PROCESS_STATE_BACKOFF)
                LogAction "*****FAILED TO START (RETRY)*****" >&2
                ;;
            PROCESS_STATE_FATAL)
                LogAction "*****COULD NOT START SERVER*****" >&2
                DiscordMessage "Server was not able to Start. Please check your configuration." "failure" >&2
                ;;
            *)
                LogError "Unkown event occured: $header" "failure" >&2
                ;;
        esac
    fi
    printf "RESULT 2\nOK"
done
exit 0