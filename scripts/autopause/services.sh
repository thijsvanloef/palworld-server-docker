#!/bin/bash
# This file included from player_logging.sh only.
# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

#-------------------------------
# AutoPause vars
#-------------------------------
declare -i AP_no_player_sec=0

#-------------------------------
# AutoPause Knockd
#-------------------------------

AP_startDaemon() {
    knockd-ctl start
    local pid
    pid=$(pidof knockd)
    APLog_debug "Start knockd (PID:${pid})"
}

AP_stopDaemon() {
    local pid
    pid=$(pidof knockd)
    APLog_debug "Stop knockd (PID:${pid})"
    if [ -n "${pid}" ]; then
        knockd-ctl stop
    fi
}

#-------------------------------
# AutoPause Service API
#-------------------------------

AutoPause_init() {
    APLog "Service ... start"
    AP_clean
    AutoPause_resetTimer
}

AutoPause_resetTimer() {
    AP_no_player_sec=0
}

AutoPause_addTimer() {
    if AP_isForceDisabled; then return; fi
    local -i delta="${1}"
    ((AP_no_player_sec+=delta))
}

AutoPause_checkRequest() {
    local request
    if request=$(AP_pullRequest); then
        local -r paused="${1:-false}"
        case ${request} in
        Resume*)
            if isTrue "${paused}"; then
                APLog "${request}"
                AP_pause off
            else
                APLog "${request} ... already resumed."
            fi
            ;;
        Disable*)
            if isTrue "${paused}"; then
                APLog "${request}"
                AP_pause off
                AP_disable on
            else
                if AP_isForceDisabled; then
                    APLog "${request} ... already disabled."
                else
                    APLog "${request}"
                    AP_disable on
                fi
            fi
            ;;
        Enable*)
            if isTrue "${paused}"; then
                APLog "${request} ... already enabled."
            else
                if ! AP_isForceDisabled; then
                    APLog "${request} ... already enabled."
                else
                    APLog "${request}"
                    AP_disable off
                fi
            fi
            ;;
        *)
            APLog "Unkown request ... '${request}'"
            ;;
        esac
    fi
}

AutoPause_checkTimer() {
    AP_isEnabled && ! AP_isForceDisabled && test "${AP_no_player_sec}" -gt "${AUTO_PAUSE_TIMEOUT_EST}"
}

AutoPause_preSave() {
    local result
    if isTrue "${REST_API_ENABLED}"; then
        if result=$(REST_API save) && [ -z "${result}" ]; then
            echo -n "OK"
            return 0;
        fi
    elif isTrue "${RCON_ENABLED}"; then
        if result=$(RCON save) && [[ "${result}" =~ ^Complete\ Save ]]; then
            echo -n "OK"
            return 0;
        fi
    else
        result="REST_API_ENABLED or RCON_ENABLED must be set to true."
    fi
    echo -n "${result}"
    return 1;
}

AutoPause_challengeToPause() {
    if ! local -r result=$(AutoPause_preSave); then
        APLog "Save failed before pausing... ${result}"
        return 1
    fi

    AP_pause on;
}

AutoPause_waitWakeup() {
    AP_startDaemon
    while true; do
        sleep 0.5
        AutoPause_checkRequest true
        # resumed by "autopause resume" command
        if ! AP_isSleep; then
            break
        fi
        if ! AP_isPaused || AP_isForceDisabled; then
            APLog "Detected file changed and will resume it."
            AP_pause off
            break
        fi
    done
    AP_stopDaemon
}

AutoPause_main() {
    AutoPause_checkRequest false
    if AutoPause_checkTimer; then
        # Safely pause the server when it is not writing files.
        if AutoPause_challengeToPause; then
            # paused
            AutoPause_waitWakeup # Block until player logs in or receives REST API or RCON
            # wake up
            AutoPause_resetTimer
        fi
    fi
}

AutoPause_end() {
    AP_clean
    APLog "Service ... stopped"
}
