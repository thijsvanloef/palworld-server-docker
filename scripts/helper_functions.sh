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
    # Directories may be writable but not deletable causing -w to return false
    if [ -d "${path}" ]; then
        temp_file=$(mktemp -q -p "${path}")
        if [ -n "${temp_file}" ]; then
            rm -f "${temp_file}"
        else
            echo "${path} is not writable."
            return_val=1
        fi
    # If it is a file it must be writable
    elif ! [ -w "${path}" ]; then
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

# Convert player list from JSON format
convert_JSON_to_CSV_players() {
    echo 'name,playeruid,steamid'
    echo -n "${1}" | \
        jq -r '.players[] | [ .name, .playerId, .userId ] | @csv' | \
        sed -re 's/"None"/"00000000000000000000000000000000"/' \
        -re 's/"steam_/"/' \
        -re 's/"//g'
}

# Lists players
# Outputs nothing if REST API or RCON is not enabled and returns 1
# Outputs player list if REST API or RCON is enabled and returns 0
get_players_list() {
    # Prefer REST API
    if [ "${REST_API_ENABLED,,}" = true ]; then
        convert_JSON_to_CSV_players "$(REST_API players)"
        return 0
    fi
    if [ "${RCON_ENABLED,,}" = true ]; then
        RCON "ShowPlayers"
        return 0
    fi
    return 1
}

# Checks how many players are currently connected
# Outputs 0 if RCON is not enabled and returns 1
# Outputs the player count if rcon is enabled and returns 0
get_player_count() {
    local player_list
    local return_val=0
    if ! player_list=$(get_players_list); then
        return_val=1
    fi
    
    echo -n "${player_list}" | wc -l
    return "$return_val"
}

#
# Log Definitions
#
export LINE='\n'
export RESET='\033[0m'       # Text Reset
export WhiteText='\033[0;37m'        # White

# Bold
export RedBoldText='\033[1;31m'         # Red
export GreenBoldText='\033[1;32m'       # Green
export YellowBoldText='\033[1;33m'      # Yellow
export CyanBoldText='\033[1;36m'        # Cyan

LogInfo() {
  Log "$1" "$WhiteText"
}
LogWarn() {
  Log "$1" "$YellowBoldText"
}
LogError() {
  Log "$1" "$RedBoldText"
}
LogSuccess() {
  Log "$1" "$GreenBoldText"
}
LogAction() {
  Log "$1" "$CyanBoldText" "****" "****"
}
Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET$LINE" "$prefix$message$suffix"
}

# Send Discord Message
# Level is optional variable defaulting to info
DiscordMessage() {
  local title="$1"
  local message="$2"
  local level="$3"
  local enabled="$4"
  local webhook_url="$5"
  if [ -z "$level" ]; then
    level="info"
  fi
  if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
    /home/steam/server/discord.sh "$title" "$message" "$level" "$enabled" "$webhook_url" &
  fi
}

# REST API Call
REST_API(){
    local -r api="${1}"
    local -r data="${2}"
    local -r url="http://localhost:${REST_API_PORT}/v1/api/${api}"
    local -r accept="Accept: application/json"
    local -r userpass="admin:${ADMIN_PASSWORD}"
    local -r post_api="save|stop"
    local -i result=0
    if [ "${data}" = "" ] && [[ ! ${api} =~ ${post_api} ]]; then
        curl -s -L -X GET  "${url}" -H "${accept}" -u "${userpass}"
        result=$?
    else
        curl -s -L -X POST "${url}" -H "${accept}" -u "${userpass}" --json "${data}"
        result=$?
    fi
    return ${result}
}

# RCON Call
RCON() {
  local args="$1"
  rcon-cli -c /home/steam/server/rcon.yaml "$args"
}

# Given a message this will broadcast in game
# Since RCON does not support spaces this will replace all spaces with underscores
# Returns 0 on success
# Returns 1 if not able to broadcast
broadcast_command() {
    local return_val=0
    if [ "${REST_API_ENABLED,,}" = true ]; then
        local json="{\"message\":\"${1}\"}" result
        result="$(REST_API announce "${json}")"
        if [ ! "${result}" = "OK" ]; then
            return_val=1
        fi
        return "$return_val"
    fi
    # Replaces spaces with underscore
    local message="${1// /_}"
    if [[ $TEXT = *[![:ascii:]]* ]]; then
        LogWarn "Unable to broadcast since the message contains non-ascii characters: \"${message}\""
        return_val=1
    elif ! RCON "broadcast ${message}" > /dev/null; then
        return_val=1
    fi
    return "$return_val"
}

# Saves the server
# Returns 0 if it saves
# Returns 1 if it is not able to save
save_server() {
    local return_val=0
    if ! RCON save; then
        return_val=1
    fi
    return "$return_val"
}

# Saves then shutdowns the server
# Returns 0 if it is shutdown
# Returns 1 if it is not able to be shutdown
shutdown_server() {
    local return_val=0
    # Do not shutdown if not able to save
    if save_server; then
        if ! RCON "Shutdown 1"; then
            return_val=1
        fi
    else
        return_val=1
    fi
    return "$return_val"
}

# Given an amount of time in minutes and a message prefix
# Will skip countdown if no players are in the server, Will only check the mtime if there are players in the server
# Returns 0 on success
# Returns 1 if mtime is empty
# Returns 2 if mtime is not an integer
countdown_message() {
    local mtime="$1"
    local message_prefix="$2"
    local return_val=0

    # Only do countdown if there are players
    if [ "$(get_player_count)" -gt 0 ]; then
        if [[ "${mtime}" =~ ^[0-9]+$ ]]; then
            for ((i = "${mtime}" ; i > 0 ; i--)); do
                case "$i" in
                    1 ) 
                        broadcast_command "${message_prefix} in ${i} minute"
                        sleep 30s
                        broadcast_command "${message_prefix} in 30 seconds"
                        sleep 20s
                        broadcast_command "${message_prefix} in 10 seconds"
                        sleep 10s
                        ;;
                    2 )
                        ;&
                    3 )
                        ;&
                    10 )
                        ;&
                    15 )
                        ;&
                    "$mtime" )
                        broadcast_command "${message_prefix} in ${i} minutes"
                        ;&
                    * ) 
                        sleep 1m
                        # Checking for players every minute
                        # Checking after sleep since it is ran in the beginning of the function
                        if [ "$(get_player_count)" -eq 0 ]; then
                            break
                        fi
                        ;;
                esac
            done
        # If there are players but mtime is empty
        elif [ -z "${mtime}" ]; then
            return_val=1
        # If there are players but mtime is not an integer
        else
            return_val=2
        fi
    fi
    return "$return_val"
}

container_version_check() {
    local current_version
    local latest_version

    current_version=$(cat /home/steam/server/GIT_VERSION_TAG)
    latest_version=$(get_latest_version)

    if [ "${current_version}" != "${latest_version}" ]; then
        LogWarn "New version available: ${latest_version}"
        LogWarn "Learn how to update the container: https://palworld-server-docker.loef.dev/guides/update-the-container"
    else
        LogSuccess "The container is up to date!"

    fi
}
# Get latest release version from thijsvanloef/palworld-server-docker repository
# Returns the latest release version
get_latest_version() {
    local latest_version

    latest_version=$(curl https://api.github.com/repos/thijsvanloef/palworld-server-docker/releases/latest -s | jq .name -r)

    echo "$latest_version"
}

