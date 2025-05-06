#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"
# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

#-------------------------------
# private functions
#-------------------------------

request() {
    AP_pushRequest "${1}"
    AP_waitPullRequest 100
}

resume() {
    if AP_isEnabled && AP_isPaused; then
        local by=""
        if [ -n "${1}" ]; then by=" by ${1}"; fi
        request "Resumed${by}."
    fi
}

stopService() {
    if ! AP_isEnabled; then return; fi
    local on="${1:-on}"
    local by=""
    if [ -n "${2}" ]; then by=" by ${2}"; fi
    if isTrue "${on}"; then
        if AP_isForceDisabled; then
            echo "Service has already disabled${by}."
        else
            request "Disable service${by}."
        fi
    else
        if ! AP_isForceDisabled; then
            echo "Service has already enabled${by}."
        else
            request "Enable service${by}."
        fi
    fi
}

#-------------------------------
# autopause main
#-------------------------------

case "${1}" in
"resume")
    resume "${2}"
    ;;
"stop")
    stopService on "${2}"
    ;;
"continue")
    stopService off "${2}"
    ;;
*)
    echo "Usage: $(basename "${0}") <command> [reason]"
    echo "command:"
    echo "    resume    ... resume from paused state"
    echo "    stop      ... stop service"
    echo "    continue  ... continue service"
esac
