#!/bin/bash
# This file contains functions which can be used in multiple scripts

#-------------------------------
# AutoPause vars
#-------------------------------
declare -r DATA_DIR="${DATA_DIR:-/palworld}"
declare -r AP_pause_file="${DATA_DIR}/.paused"
declare -r AP_request_file="${DATA_DIR}/.autopause-request"
declare -r AP_disable_file="${DATA_DIR}/.autopause-disabled" # for shutdown and reboot
declare -r AP_monitor_backend_file="/home/steam/server/autopause/.monitor-backend"

#-------------------------------
# AutoPause Log
#-------------------------------

APLog() {
    local msg="${1:-(no message)}"
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogInfo "[AUTO PAUSE] ${msg}"
}

APLog_warn() {
    local msg="${1:-(no message)}"
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogWarn "[AUTO PAUSE] ${msg}"
}

APLog_error() {
    local msg="${1:-(no message)}"
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogError "[AUTO PAUSE] ${msg}"
}

APLog_debug() {
    local msg="${1:-(no message)}"
    isTrue "${AUTO_PAUSE_DEBUG:-false}" && LogInfo "[AUTO PAUSE DEBUG] ${msg}"
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
            APLog_warn "Already sleeped..."
            return 0
        fi
        APLog "Paused. (PID:${pid})"
        kill -STOP "${pid}"
        AP_touch on "${AP_pause_file}"
    else
        if ! AP_isSleep; then
            APLog_warn "Already wakeuped..."
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

#-------------------------------
# AutoPause Monitor Backend
#-------------------------------

APMonitor_detectAvailableBackend() {
    local monitorBackend
    # Decide monitor backend at startup and persist it for services.sh.
    # Priority:
    #   1. NFLOG (requires iptables + tcpdump + NET_RAW,NET_ADMIN capability)
    #   2. knockd (requires knockd binary + NET_RAW capability)
    #   3. Error (no suitable backend available)
    if command -v iptables > /dev/null 2>&1 && iptables -L > /dev/null 2>&1 && \
       command -v tcpdump > /dev/null 2>&1 && tcpdump --version > /dev/null 2>&1; then
        monitorBackend="nflog"
        APLog "AUTO_PAUSE packet monitor: NFLOG (iptables+tcpdump) available."
    else
        APLog "AUTO_PAUSE packet monitor: NFLOG (iptables+tcpdump) unavailable."
        APLog_warn "NET_ADMIN & NET_RAW capability required for NFLOG. e.g) podman run --cap-add=NET_ADMIN --cap-add=NET_RAW ..."
        if command -v knockd > /dev/null 2>&1 && knockd --version > /dev/null 2>&1; then
            monitorBackend="knockd"
            APLog "AUTO_PAUSE packet monitor: knockd available."
        else
            APLog "AUTO_PAUSE packet monitor: knockd unavailable."
            APLog_error "AUTO_PAUSE requires NET_RAW capability. e.g) podman run --cap-add=NET_RAW ..."
            return 1
        fi
    fi

    printf '%s\n' "${monitorBackend}" > "${AP_monitor_backend_file}"
    chmod 0644 "${AP_monitor_backend_file}" || true
    if [ "$(id -u)" -eq 0 ]; then
        chown steam:steam "${AP_monitor_backend_file}" || true
    fi
    return 0
}

APMonitor_determineBackend() {
    if [ -r "${AP_monitor_backend_file}" ]; then
        cat "${AP_monitor_backend_file}"
    else
        echo "knockd"
    fi
}
