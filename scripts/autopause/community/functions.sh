#!/bin/bash
# This file included from autopause/services.sh only.

#-------------------------------
# AutoPause Community vars
#-------------------------------

declare -r APComm_API_URL="${COMMUNITY_API_URL:-https://api.palworldgame.com/}"
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
    local url="${APComm_API_URL}${api}"
    local accept="Accept: application/json"
    local agent="X-UnrealEngine-Agent"

    # Use -sS for silent but show errors, --fail to fail on HTTP errors, --max-time for timeout
    curl -sS --fail --max-time 10 --retry 2 --retry-delay 1 -L -X POST "${url}" -H "${accept}" -A "${agent}" --json "${data}" 2>&1
}

APComm_loadJSON() {
    if [ ! -f "${APComm_register_file}" ] || [ ! -f "${APComm_update_file}" ]; then
        APLog_error "Captured file not found. Perhaps your mitmproxy server is misconfigured, down, or has lost its connection to api.palworldgames.com."
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
    local data response id key
    
    if ! data=$(echo "${APComm_jsonRegister}" | jq -c --arg name "${SERVER_NAME} (paused)" '.name = $name'); then
        APLog_error "Error creating register data JSON"
        return 1
    fi

    if ! response=$(APComm_API "server/register" "${data}"); then
        APLog_error "server/register API call failed: $(printf '%.200s' "${response}")"
        return 1
    fi

    if ! echo "${response}" | jq empty > /dev/null 2>&1; then
        APLog_error "server/register API returned invalid JSON response: $(printf '%.200s' "${response}")"
        return 1
    fi

    id=$(echo "${response}" | jq -r '.server_id // empty')
    key=$(echo "${response}" | jq -r '.update_key // empty')

    if [ -n "${id}" ] && [ -n "${key}" ]; then
        # Update APComm_jsonUpdate safely
        APComm_jsonUpdate=$(echo "${APComm_jsonUpdate:-{}}" | jq -c --arg id "${id}" --arg key "${key}" '.server_id = $id | .update_key = $key')
        APLog "Community server registered ID: ${id}"
        return 0
    fi

    # Mask sensitive data in log if possible, or just truncate
    APLog_error "Registration failed (missing id or key): $(printf '%.200s' "${response}")"
    return 1
}

APComm_update() {
    local response message status

    if ! response=$(APComm_API "server/update" "${APComm_jsonUpdate}"); then
        APLog_error "server/update API call failed: $(printf '%.200s' "${response}")"
        return 1
    fi

    if ! echo "${response}" | jq empty > /dev/null 2>&1; then
        APLog_error "server/update API returned invalid JSON response: $(printf '%.200s' "${response}")"
        return 1
    fi

    status=$(echo "${response}" | jq -r '.status // empty')
    message=$(echo "${response}" | jq -r '.error_message // empty')

    if [ "${status}" = "ok" ]; then
        return 0
    elif [ -n "${message}" ]; then
        APLog "${status}: ${message}"
        return 1
    fi

    APLog_error "Update failed: $(printf '%.200s' "${response}")"
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
