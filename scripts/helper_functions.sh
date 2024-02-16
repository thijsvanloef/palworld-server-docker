#!/bin/bash
# This file contains functions which can be used in multiple scripts

# Checks if a given path is a directory
# Returns 0 if the path is a directory
# Returns 1 if the path is not a directory or does not exists and produces an output message
dirExists() {
    local path="$1"
    local return_val=0
    if ! [ -d "${path}" ]; then
        echo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is a regular file
# Returns 0 if the path is a regular file
# Returns 1 if the path is not a regular file or does not exists and produces an output message
fileExists() {
    local path="$1"
    local return_val=0
    if ! [ -f "${path}" ]; then
        echo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path exists and is readable
# Returns 0 if the path exists and is readable
# Returns 1 if the path is not readable or does not exists and produces an output message
isReadable() {
    local path="$1"
    local return_val=0
    if ! [ -e "${path}" ]; then
        echo "${path} is not readable."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is writable
# Returns 0 if the path is writable
# Returns 1 if the path is not writable or does not exists and produces an output message
isWritable() {
    local path="$1"
    local return_val=0
    if ! [ -w "${path}" ]; then
        echo "${path} is not writable."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is executable
# Returns 0 if the path is executable
# Returns 1 if the path is not executable or does not exists and produces an output message
isExecutable() {
    local path="$1"
    local return_val=0
    if ! [ -x "${path}" ]; then
        echo "${path} is not executable."
        return_val=1
    fi
    return "$return_val"
}

# Checks how many players are currently connected
# Outputs 0 if RCON is not enabled
# Outputs the player count if rcon is enabled
get_player_count() {
    local player_list
    if [ "${RCON_ENABLED,,}" != true ]; then
        echo 0
        return 0
    fi
    player_list=$(rcon-cli -c /home/steam/server/rcon.yaml "ShowPlayers")
    echo -n "${player_list}" | wc -l
}

# Given an amount of time in minutes and a message prefix
countdown_message() {
    mtime="$1"
    message_prefix="$2"

    for ((i = "${mtime}" ; i > 0 ; i--)); do
        if [ "$(get_player_count)" -eq 0 ]; then
            break
        fi
        if [ "$i" -eq 1 ]; then
            rcon-cli -c /home/steam/server/rcon.yaml "broadcast ${message_prefix}_${i}_minute"
            sleep 30s
            rcon-cli -c /home/steam/server/rcon.yaml "broadcast ${message_prefix}_30_seconds"
            sleep 20s
            rcon-cli -c /home/steam/server/rcon.yaml "broadcast ${message_prefix}_10_seconds"
            sleep 10s
        else
            case "$i" in
                "$mtime" )
                    ;&
                15 )
                    ;&
                10 )
                    ;&
                5 )
                    ;&
                2 )
                    rcon-cli -c /home/steam/server/rcon.yaml "broadcast ${message_prefix}_${i}_minutes"
                    ;&
                * ) 
                    sleep 1m
                    ;;
            esac
        fi
    done   
}
