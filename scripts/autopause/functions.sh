#!/bin/bash
# This file contains functions which can be used in multiple scripts

#-------------------------------
# AutoPause vars
#-------------------------------
declare -r DATA_DIR="${DATA_DIR:-/palworld}"
declare -r AP_pause_file="${DATA_DIR}/.paused"
declare -r AP_request_file="${DATA_DIR}/.autopause-request"
declare -r AP_disable_file="${DATA_DIR}/.autopause-disabled" # for shutdown and reboot

#-------------------------------
# AutoPause Log
#-------------------------------

APLog() {
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogInfo "[AUTO PAUSE] ${1}"
}

APLog_debug() {
    isTrue "${AUTO_PAUSE_DEBUG:-false}" && LogInfo "[AUTO PAUSE DEBUG] ${1}"
}

#-------------------------------
# AutoPause Common
#-------------------------------

AP_clean() {
    rm -f "${AP_disable_file}" "${AP_pause_file}" "${AP_request_file}"
}

AP_isEnabled() {
    isTrue "${AUTO_PAUSE_ENABLED}" && PlayerLogging_isEnabled
}

AP_isPaused() {
    test -e "${AP_pause_file}"
}

AP_isForceDisabled() {
    test -e "${AP_disable_file}"
}

# is realy paused
AP_isSleep() {
    test -n "$(pgrep -r T 'PalServer-Linux')"
}

AP_do() {
    if [[ "$(id -u)" -eq 0 ]]; then
        su steam -c "${1}"
    else
        eval "${1}"
    fi
}

AP_touch() {
    if isTrue "${1:-on}"; then
        AP_do "touch ${2}"
    else
        rm -f "${2}"
    fi
}

AP_disable() {
    AP_touch "${1:-on}" "${AP_disable_file}"
}

AP_pause() {
    local -r on="${1:-on}"
    local -r pid=$(pidof PalServer-Linux-Shipping)
    if isTrue "${on}"; then
        if AP_isSleep; then
            APLog "[WARNING] Already sleeped..."
            return 0
        fi
        APLog "Paused. (PID:${pid})"
        kill -STOP "${pid}"
        AP_touch on "${AP_pause_file}"
    else
        if ! AP_isSleep; then
            APLog "[WARNING] Already wakeuped..."
            return 0
        fi
        APLog "Wakeup!!! (PID:${pid})"
        kill -CONT "${pid}"
        AP_touch off "${AP_pause_file}"
    fi
    return 0
}

#-------------------------------
# AutoPause Request
#-------------------------------

AP_pullRequest() {
    local -i size
    if size=$(stat -c %s "${AP_request_file}" 2>/dev/null) && [ "${size}" -gt 0 ]; then
        cat "${AP_request_file}"
        rm -f "${AP_request_file}"
        return 0
    fi
    return 1
}

AP_pushRequest() {
    AP_do "echo \"${1}\" > \"${AP_request_file}\""
}

AP_waitPullRequest()
{
    local -i i=0 max="${1:-100}"
    while [[ i -lt max ]]; do
        ((i++))
        if [ ! -f "${AP_request_file}" ]; then
            return 0
        fi
        sleep 0.1
    done
    rm -f "${AP_request_file}"
    APLog_debug "AP_waitPullRequest ... time out."
    return 1
}

