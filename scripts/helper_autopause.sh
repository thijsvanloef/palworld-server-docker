#!/bin/bash
# This file contains functions which can be used in multiple scripts

#-------------------------------
# Env vars
#-------------------------------
AUTO_PAUSE_LOG=${AUTO_PAUSE_LOG:-true}
AUTO_PAUSE_TIMEOUT_EST=${AUTO_PAUSE_TIMEOUT_EST:-30}
AUTO_PAUSE_KNOCK_INTERFACE=${AUTO_PAUSE_KNOCK_INTERFACE:-eth0}
AUTO_PAUSE_DEBUG=${AUTO_PAUSE_DEBUG:-false}

#-------------------------------
# PalConfig vars
#-------------------------------
declare -r DATA_DIR="${DATA_DIR:-/palworld}"
SAVE_DIR=""
SERVER_ID=""

#-------------------------------
# AutoPause vars
#-------------------------------
declare -r AP_pause_file="${DATA_DIR}/.paused"
declare -r AP_skip_file="${DATA_DIR}/.skip-pause" # for shutdown and reboot
declare -r AP_basedir="/home/steam/autopause"
declare -i AP_no_player_sec=0
declare -r APLog_pipe="${AP_basedir}/.logpipe"
declare -r APLog_pid="${AP_basedir}/.pid"
AP_is_service_side=false

#-------------------------------
# AutoPause Community vars
#-------------------------------
APComm_jsonRegister=""
APComm_jsonUpdate=""
declare -r APComm_datadir="${AP_basedir}"
declare -i APComm_seq=0  # 0:register / 1:update
declare -i APComm_timer=0

#-------------------------------
# PalConfig
#-------------------------------

PalConfig_init() {
    # The PalServer configuration file must already be generated.
    # fetch SERVER_ID from GameUserSettings.ini
    SERVER_ID="$(sed -n -re 's/DedicatedServerName=(.*)/\1/p' "${DATA_DIR}/Pal/Saved/Config/LinuxServer/GameUserSettings.ini")"
    # update SAVE_DIR
    SAVE_DIR="${DATA_DIR}/Pal/Saved/SaveGames/0/${SERVER_ID}"
}

#-------------------------------
# AutoPause Log
#-------------------------------

APLog() {
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogInfo "[AUTO PAUSE] ${1}" | APLog_send
}

APLog_debug() {
    isTrue "${AUTO_PAUSE_DEBUG:-false}" && LogInfo "[AUTO PAUSE DEBUG] ${1}" | APLog_send
}

APLog_send() {
    if "${AP_is_service_side}"; then
        cat -
        return 0
    fi
    # send log from application to server via named pipe.
    local pid
    pid="$(cat "${APLog_pid}")"
    if [ -n "${pid}" ]; then
        kill -USR1 "${pid}" && cat - > "${APLog_pipe}"
        return 0
    fi
    return 1
}

APLog_receive() {
    cat "${APLog_pipe}"
}

APLog_init() {
    test -p "${APLog_pipe}" || mkfifo "${APLog_pipe}"
    trap 'APLog_receive' USR1
    echo -n "$$" > ${APLog_pid}
}

#-------------------------------
# AutoPause Core
#-------------------------------

AP_startDaemon() {
    autopaused-ctl start
    pid=$(pidof knockd)
    APLog_debug "Start knockd pid:${pid}"
}

AP_stopDaemon() {
    local pid
    pid=$(pidof knockd)
    if [ ! "${pid}" = "" ]; then
        APLog_debug "Stop knockd pid:${pid}"
        autopaused-ctl stop
    fi
}

AP_skip() {
    if isTrue "${1:-on}"; then
        if [[ "$(id -u)" -eq 0 ]]; then
            su steam -c "touch ${AP_skip_file}"
        else
            touch "${AP_skip_file}"
        fi
    else
        rm -f "${AP_skip_file}"
    fi
}

AP_isSkipped() {
    test -e "${AP_skip_file}"
}

AP_isEnabled() {
    isTrue "${AUTO_PAUSE_ENABLED}"
}

AP_isRunning() {
    pidof ""
}

AP_isPaused() {
    test -e "${AP_pause_file}"
}

# is realy paused
AP_isSleep() {
    test -n "$(pgrep -r T 'PalServer-Linux')"
}

AP_pause() {
    local on="${1:-on}"
    local pid
    pid=$(pidof PalServer-Linux-Shipping)
    if isTrue "${on}"; then
        if AP_isSleep; then
            APLog "[WARNING] Already sleeped..."
            return 0
        fi
        APLog "Paused."
        kill -STOP "${pid}"
        touch "${AP_pause_file}"
    else
        if ! AP_isSleep; then
            APLog "[WARNING] Already wakeuped..."
            return 0
        fi
        APLog "Wakeup!!!"
        kill -CONT "${pid}"
        rm -f "${AP_pause_file}"
    fi
    return 0
}

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
    if [ ! -f "${APComm_datadir}/register.json" ] || [ ! -f "${APComm_datadir}/update.json" ]; then
        APLog "Captured file not found. Perhaps your mitm proxy server is misconfigured, down, or has lost its connection to api.palworldgames.com."
        return 1
    fi
    local -i result=0 delta
    APComm_jsonRegister="$(jq -c < "${APComm_datadir}/register.json")"
    result=$?
    APComm_jsonUpdate="$(jq -c < "${APComm_datadir}/update.json")"
    ((result=result+$?))
    if [ ${result} -eq 0 ]; then
        # It's not fresh after 120 seconds.
        ((delta=$(date +%s)-$(date +%s -r "${APComm_datadir}/update.json")))
        if [ ${delta} -gt 120 ]; then
            APLog_debug "update.json is not fresh."
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
        fi
        APLog "status:\"${status}\" message:\"${message}\""
        return 1
    fi
    APLog "${response}"
    return 1
}

APComm_init() {
    if ! isTrue "${COMMUNITY}"; then return; fi

    if APComm_loadJSON; then
        APComm_seq=1 # keep continue same update data
    else
        APComm_seq=0 # Start over from registration
    fi
    APComm_timer=0
}

APComm_proc() {
    if ! isTrue "${COMMUNITY}"; then return; fi

    local -i now out
    now=$(date +%s)
    out=$((APComm_timer+30))
    if [ ${now} -gt ${out} ]; then
        APComm_timer=${now}
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

#-------------------------------
# AutoPause Service API
#-------------------------------

AutoPause_init() {
    AP_is_service_side=true
    APLog_init
    PalConfig_init
    AP_skip off
    rm -f "${AP_pause_file}"
    AutoPause_resetTimer
}

AutoPause_resetTimer() {
    AP_no_player_sec=0
}

AutoPause_addTimer() {
    if AP_isSkipped; then return; fi
    local -i delta="${1}"
    ((AP_no_player_sec+=delta))
}

AutoPause_checkTimer() {
    AP_isEnabled && ! AP_isSkipped && test "${AP_no_player_sec}" -gt "${AUTO_PAUSE_TIMEOUT_EST}"
}

AutoPause_challengeToPause() {
    local result
    result=$(is_safe_timing "${SAVE_DIR}")
    APLog "Challenge to pause ... ${result}"
    if [ "${result}" = "OK" ]; then
        if AP_pause on; then
            return 0
        fi
    fi
    return 1
}

AutoPause_waitWakeup() {
    AP_startDaemon
    APComm_init
    while true; do
        sleep 0.5
        # resumed by "autopause resume" command
        if ! AP_isSleep; then
            break
        fi
        if ! AP_isPaused; then
            APLog "Detected remove of ${AP_pause_file} and will resume it."
            AP_pause off
            break
        fi
        if AP_isSkipped; then
            APLog "Detected create of ${AP_skip_file} and will resume it."
            AP_pause off
            break
        fi
        # During PAUSE,
        # it will continue to register and update
        # the community server list as a dummy.
        APComm_proc
    done
    AP_stopDaemon
}

#-------------------------------
# AutoPause External API
#-------------------------------

AutoPauseEx_isEnabled() {
    AP_isEnabled && test -e "${APLog_pid}"
}

AutoPauseEx_resume() {
    if ! AutoPauseEx_isEnabled; then return; fi
    if AP_isPaused; then
        if [ -n "${1}" ]; then
            APLog "Resumed by \"${1}\""
        fi
        AP_pause off
    fi
}

AutoPauseEx_stopService() {
    if ! AutoPauseEx_isEnabled; then return; fi
    local on="${1:-on}"
    if isTrue "${on}"; then
        if AP_isPaused; then
            AP_pause off
        fi
        if AP_isSkipped; then
            APLog_debug "Service has already disabled. \"${2}\""
        else
            APLog "Service has been disabled. \"${2}\""
        fi
    else
        if AP_isSkipped; then
            APLog "Service has been enabled. \"${2}\""
        else
            APLog_debug "Service has already enabled. \"${2}\""
        fi
    fi

    AP_skip "${on}"
}
