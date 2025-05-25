#!/bin/bash
# This file included from autopause/services.sh only.

#-------------------------------
# AutoPause Community vars
#-------------------------------

declare -r APComm_basedir="/home/steam/server/autopause/community"
declare -r APComm_register_file="${APComm_basedir}/register.json"
declare -r APComm_update_file="${APComm_basedir}/update.json"
declare -i APComm_seq=0  # 0:register / 1:update
declare -i APComm_timer=0
APComm_jsonRegister=""
APComm_jsonUpdate=""

#-------------------------------
# AutoPause Community API
#-------------------------------

# api.palworldgame.com/server Call
APComm_API() {
    local api="${1}"
    local data="${2}"
    local url="https://api.palworldgame.com/${api}"
    local accept="Accept: application/json"
    local agent="X-UnrealEngine-Agent"
    curl -s -L -X POST "${url}" -H "${accept}" -A "${agent}" --json "${data}"
}

APComm_loadJSON() {
    if [ ! -f "${APComm_register_file}" ] || [ ! -f "${APComm_update_file}" ]; then
        APLog "Captured file not found. Perhaps your mitmproxy server is misconfigured, down, or has lost its connection to api.palworldgames.com."
        return 1
    fi
    local -i result=0 delta
    APComm_jsonRegister="$(jq -c < "${APComm_register_file}")"
    result=$?
    APComm_jsonUpdate="$(jq -c < "${APComm_update_file}")"
    ((result=result+$?))
    if [ ${result} -eq 0 ]; then
        # It's not fresh after 120 seconds.
        ((delta=$(date +%s)-$(date +%s -r "${APComm_update_file}")))
        if [ ${delta} -gt 120 ]; then
            APLog_debug "${APComm_update_file} is not fresh."
            return 1
        fi
    fi
    return ${result}
}

APComm_register() {
    local data response
    data=$(echo -n "${APComm_jsonRegister//\"/\"}" | jq ".name|=\"${SERVER_NAME} (paused)\"")
    response=$(APComm_API "server/register" "${data}")
    local -i result=$?
    if [ ${result} -eq 0 ] && [ -n "${response}" ]; then
        id=$(echo -n "${response//\"/\"}" | jq -r '.server_id')
        key=$(echo -n "${response//\"/\"}" | jq -r '.update_key')
        APComm_jsonUpdate=$(echo -n "${APComm_jsonUpdate//\"/\"}" | jq ".server_id|=\"${id}\"" | jq ".update_key|=\"${key}\"")
        APLog "Community server registered ID: ${id}"
        return 0
    fi
    APLog "${response}"
    return 1
}

APComm_update() {
    response=$(APComm_API "server/update" "${APComm_jsonUpdate}")
    local -i result=$?
    if [ ${result} -eq 0 ] && [ -n "${response}" ]; then
        local message status
        message=$(echo "${response//\"/\"}" | jq -r '.error_message')
        status=$(echo "${response//\"/\"}" | jq -r '.status')
        if [ "${status}" = "ok" ]; then
            return 0
        elif [ -n "${message}" ]; then
            APLog "${status}: ${message}"
            return 1
        fi
    fi
    APLog "${response}"
    return 1
}

APComm_init() {
    if APComm_loadJSON; then
        APComm_seq=1 # keep continue same update data
    else
        APComm_seq=0 # Start over from registration
    fi
    APComm_timer=0
}

APComm_proc() {
    local -i now out
    now="$(date +%s)"
    out="$((APComm_timer+30))"
    if [ "${now}" -gt "${out}" ]; then
        APComm_timer="${now}"
        case ${APComm_seq} in
        0)
            if APComm_register && APComm_update; then
                APComm_seq=1
            fi
            ;;
        1)
            if ! APComm_update; then
                APComm_seq=0
            fi
            ;;
        esac
    fi
}

APComm_isCaptured() {
    test -f "${APComm_register_file}" -a -f "${APComm_update_file}"
}
