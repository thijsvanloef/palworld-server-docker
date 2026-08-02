#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

basedir="/home/steam/server/autopause"
Knockd_baseConfig="${basedir}/knockd"
Nflog_pidFile="${basedir}/.nflog.pid"
Nflog_logFile="${basedir}/.nflog.log"
Nflog_stateFile="${basedir}/.nflog.state"
Nflog_chainBase="${AUTO_PAUSE_NFLOG_CHAIN_BASE:-PalServer_AutoPause_Nflog}"
Nflog_groupStart="${AUTO_PAUSE_NFLOG_GROUP:-100}"
Nflog_groupEnd="${AUTO_PAUSE_NFLOG_GROUP_MAX:-199}"
Nflog_chainName=""
Nflog_group=""

# AUTO_PAUSE_KNOCKD_IF configuration:
#   - "auto" (default): Automatically detect active network interfaces
#   - Explicit list: Space-separated interface names (e.g., "eth0 lo wlan0")
#   - "any": Ignored for knockd backend (warning logged)
# This is necessary when the container shares the host's network namespace
# (docker run --network=host or compose.yaml network_mode: host) where interface
# names may change dynamically depending on host OS and network configuration.
Knockd_interfaces="${AUTO_PAUSE_KNOCKD_IF:-auto}"
Nflog_interfaces=(any)  # NFLOG backend always uses "any" to match all incoming packets via iptables rules.

declare -a Knockd_resolvedInterfaces=()

# Add an interface to the Knockd_resolvedInterfaces array if it exists and is not already present.
# Validates interface exists via /sys/class/net and prevents duplicates.
Knockd_appendInterface() {
    local iface="${1}" existing

    [ -z "${iface}" ] && return

    # "any" is not a valid interface for knockd.
    # Keep backward compatibility by warning and ignoring it.
    if [ "${iface}" = "any" ]; then
        APLog_warn "AUTO_PAUSE_KNOCKD_IF contains 'any', but knockd backend does not support it. Ignoring 'any'. Use 'auto' for automatic detection."
        return
    fi
    
    # Verify interface exists in sysfs
    if [ ! -d "/sys/class/net/${iface}" ]; then
        return
    fi

    # Check for duplicates
    for existing in "${Knockd_resolvedInterfaces[@]}"; do
        [ "${existing}" = "${iface}" ] && return
    done

    Knockd_resolvedInterfaces+=("${iface}")
}

# Automatically detect active network interfaces to listen on.
# Detects default gateway interface and loopback interfaces.
Knockd_resolveAutoInterfaces() {
    local iface destination flags type netPath

    if [ -r "/proc/net/route" ]; then
        while read -r iface destination _gateway flags _rest; do
            # Look for the default route (destination 00000000 in hex)
            if [ "${destination}" = "00000000" ] && [ -n "${flags}" ]; then
                Knockd_appendInterface "${iface}"
            fi
        done < "/proc/net/route"
    fi

    # Find loopback interfaces (type 772 = ARPHRD_LOOPBACK)
    for netPath in /sys/class/net/*; do
        if [ ! -r "${netPath}/type" ]; then
            continue
        fi
        type=$(cat "${netPath}/type")
        if [ "${type}" = "772" ]; then
            Knockd_appendInterface "$(basename "${netPath}")"
        fi
    done
}

Knockd_resolveInterfaces() {
    local iface

    Knockd_resolvedInterfaces=()
    if [ "${Knockd_interfaces}" = "auto" ]; then
        # Automatic detection mode: find default gateway and loopback interfaces
        Knockd_resolveAutoInterfaces
        return
    fi

    # Explicit interface specification mode: parse space-separated list
    for iface in ${Knockd_interfaces}; do
        Knockd_appendInterface "${iface}"
    done
}

# ============================================================================
# NFLOG Backend Functions
# ============================================================================

Nflog_waitTcpdumpExit() {
    local -i i=0
    while pgrep -f "tcpdump -n -l -i nflog:${Nflog_group}" >/dev/null 2>&1; do
        ((i++))
        if [ "${i}" -ge 30 ]; then
            return 1
        fi
        sleep 0.1
    done
    return 0
}

Nflog_killTcpdump() {
    # Ensure stale NFLOG tcpdump instances do not keep the group bound.
    pkill -TERM -f "tcpdump -n -l -i nflog:${Nflog_group}" 2>/dev/null || true
    Nflog_waitTcpdumpExit || pkill -KILL -f "tcpdump -n -l -i nflog:${Nflog_group}" 2>/dev/null || true
}

Nflog_loadState() {
    if [ ! -r "${Nflog_stateFile}" ]; then
        return 1
    fi

    # shellcheck disable=SC1090
    . "${Nflog_stateFile}"
    if [ -z "${Nflog_chainName:-}" ] || [ -z "${Nflog_group:-}" ]; then
        return 1
    fi
    return 0
}

Nflog_saveState() {
    cat > "${Nflog_stateFile}" << EOF
Nflog_chainName='${Nflog_chainName}'
Nflog_group='${Nflog_group}'
EOF
}

Nflog_setupRules() {
    local iface

    iptables -N "${Nflog_chainName}" 2>/dev/null || true
    iptables -F "${Nflog_chainName}"

    iptables -A "${Nflog_chainName}" -p udp --dport "${PORT:-8211}" -j NFLOG --nflog-group "${Nflog_group}" --nflog-prefix "LOGIN"
    iptables -A "${Nflog_chainName}" -p tcp --dport "${RCON_PORT:-25575}" -j NFLOG --nflog-group "${Nflog_group}" --nflog-prefix "RCON"
    iptables -A "${Nflog_chainName}" -p tcp --dport "${REST_API_PORT:-8212}" -j NFLOG --nflog-group "${Nflog_group}" --nflog-prefix "REST_API"

    for iface in "${Nflog_interfaces[@]}"; do
        if [ "${iface}" = "any" ]; then
            iptables -C INPUT -j "${Nflog_chainName}" 2>/dev/null || iptables -I INPUT 1 -j "${Nflog_chainName}"
        else
            iptables -C INPUT -i "${iface}" -j "${Nflog_chainName}" 2>/dev/null || iptables -I INPUT 1 -i "${iface}" -j "${Nflog_chainName}"
        fi
    done
}

Nflog_teardownRules() {
    local iface

    for iface in "${Nflog_interfaces[@]}"; do
        if [ "${iface}" = "any" ]; then
            while iptables -C INPUT -j "${Nflog_chainName}" 2>/dev/null; do
                iptables -D INPUT -j "${Nflog_chainName}"
            done
        else
            while iptables -C INPUT -i "${iface}" -j "${Nflog_chainName}" 2>/dev/null; do
                iptables -D INPUT -i "${iface}" -j "${Nflog_chainName}"
            done
        fi
    done

    iptables -F "${Nflog_chainName}" 2>/dev/null || true
    iptables -X "${Nflog_chainName}" 2>/dev/null || true
}

Nflog_startMonitor() {
    local detected="false" line ip

    tcpdump -n -l -i "nflog:${Nflog_group}" 2>&1 | while read -r line; do
        printf '%s\n' "${line}" >> "${Nflog_logFile}"
        if isTrue "${AUTO_PAUSE_DEBUG:-false}"; then
            APLog "nflog: ${line}"
        fi

        if [ "${detected}" = "false" ]; then
            if [[ "${line}" =~ \>\ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.${PORT:-8211}:.*UDP ]]; then
                ip=$(echo "${line}" | awk '{print $3}' | cut -d. -f1-4)
                autopause resume "LOGIN from ${ip} on any"
                detected="true"
            fi
            if [[ "${line}" =~ \>\ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.${RCON_PORT:-25575}: ]]; then
                ip=$(echo "${line}" | awk '{print $3}' | cut -d. -f1-4)
                autopause resume "RCON from ${ip} on any"
                detected="true"
            fi
            if [[ "${line}" =~ \>\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|::1)\.${REST_API_PORT:-8212}: ]]; then
                ip=$(echo "${line}" | awk '{print $3}' | cut -d. -f1-4)
                autopause resume "REST_API from ${ip} on any"
                detected="true"
            fi
        fi
    done
}

Nflog_startBackend() {
    local candidate monitorPid

    if isTrue "${AUTO_PAUSE_DEBUG:-false}"; then
        APLog "NFLOG backend listening on all interfaces (kernel socket mode)"
    fi

    if [ -f "${Nflog_pidFile}" ] && kill -0 "$(cat "${Nflog_pidFile}")" 2>/dev/null; then
        APLog_warn "NFLOG monitor already running (PID:$(cat "${Nflog_pidFile}"))"
        return 0
    fi

    if ! command -v iptables > /dev/null 2>&1; then
        APLog_warn "NFLOG backend requires iptables."
        return 1
    fi

    if ! [[ "${Nflog_groupStart}" =~ ^[0-9]+$ ]] || ! [[ "${Nflog_groupEnd}" =~ ^[0-9]+$ ]] || [ "${Nflog_groupStart}" -gt "${Nflog_groupEnd}" ]; then
        APLog_warn "Invalid NFLOG range: start=${Nflog_groupStart}, max=${Nflog_groupEnd}"
        return 1
    fi

    rm -f "${Nflog_stateFile}"

    # Clean up stale listeners before creating new rules/listener.
    Nflog_killTcpdump

    for candidate in $(seq "${Nflog_groupStart}" "${Nflog_groupEnd}"); do
        Nflog_group="${candidate}"
        Nflog_chainName="${Nflog_chainBase}${candidate}"

        # Atomic collision check: only winner can create this chain.
        if ! iptables -N "${Nflog_chainName}" 2>/dev/null; then
            continue
        fi

        : > "${Nflog_logFile}"
        Nflog_setupRules || {
            Nflog_teardownRules
            continue
        }

        Nflog_startMonitor &
        monitorPid="$!"

        # If tcpdump cannot bind NFLOG group, it exits immediately.
        sleep 0.2
        if kill -0 "${monitorPid}" 2>/dev/null; then
            echo "${monitorPid}" > "${Nflog_pidFile}"
            Nflog_saveState
            APLog_debug "Start NFLOG monitor (PID:${monitorPid}, chain:${Nflog_chainName}, group:${Nflog_group})"
            return
        fi

        if [ -s "${Nflog_logFile}" ]; then
            APLog_warn "NFLOG monitor failed on chain=${Nflog_chainName}, group=${Nflog_group}: $(tail -n 1 "${Nflog_logFile}")"
            # Permission/capability problems are not solved by trying another number.
            if grep -qiE "operation not permitted|permission denied" "${Nflog_logFile}"; then
                Nflog_teardownRules
                return 1
            fi
        else
            APLog_warn "NFLOG monitor failed on chain=${Nflog_chainName}, group=${Nflog_group}. Trying next candidate."
        fi
        Nflog_teardownRules
    done

    APLog_warn "No available NFLOG chain/group candidates in range ${Nflog_groupStart}-${Nflog_groupEnd}."
    return 1
}

Nflog_stopBackend() {
    local pid

    # Restore the runtime-selected chain/group if available.
    Nflog_loadState || {
        Nflog_group="${Nflog_groupStart}"
        Nflog_chainName="${Nflog_chainBase}${Nflog_groupStart}"
    }

    if [ -f "${Nflog_pidFile}" ]; then
        pid="$(cat "${Nflog_pidFile}")"
        kill -TERM "${pid}" 2>/dev/null || true
        pkill -TERM -P "${pid}" 2>/dev/null || true
        rm -f "${Nflog_pidFile}"
    fi
    Nflog_killTcpdump
    rm -f "${Nflog_logFile}"
    Nflog_teardownRules
    rm -f "${Nflog_stateFile}"

    APLog_debug "Stop NFLOG monitor (PID:${pid:-unknown}, chain:${Nflog_chainName}, group:${Nflog_group})"
}

# ============================================================================
# Knockd Backend Functions
# ============================================================================

Knockd_startBackend() {
    # Verify knockd is available and has NET_RAW capability
    if ! command -v knockd > /dev/null 2>&1; then
        APLog_warn "knockd backend requires knockd binary (not found)."
        return 1
    fi

    if ! knockd --version > /dev/null 2>&1; then
        APLog_warn "knockd backend requires NET_RAW capability. e.g) podman run --cap-add=NET_RAW ..."
        return 1
    fi

    Knockd_resolveInterfaces
    if [ "${#Knockd_resolvedInterfaces[@]}" -eq 0 ]; then
        APLog_warn "AUTO_PAUSE_KNOCKD_IF=${Knockd_interfaces} did not resolve any usable interfaces."
        return 1
    fi
    knockdArgs=(-d)
    if isTrue "${AUTO_PAUSE_DEBUG:-false}"; then
        APLog "AUTO_PAUSE_KNOCKD_IF=\"${Knockd_interfaces}\" resolved to: \"${Knockd_resolvedInterfaces[*]}\""
        knockdArgs+=(-D -v)
    fi
    # Start knockd for each resolved interface with separate process/PID file
    # This allows listening on multiple interfaces simultaneously
    for iface in "${Knockd_resolvedInterfaces[@]}"; do
        config="${Knockd_baseConfig}-${iface}.cfg"
        cat - << EOF > "${config}"
[options]
 logfile = /dev/null
[resume-by-player]
 sequence = ${PORT:-8211}:udp
 seq_cooldown = 5
 command = autopause resume "LOGIN from %IP% on ${iface}"
[resume-by-rcon]
 sequence = ${RCON_PORT:-25575}
 seq_timeout = 1
 command = autopause resume "RCON from %IP% on ${iface}"
 tcpflags = syn
[resume-by-rest]
 sequence = ${REST_API_PORT:-8212}
 seq_timeout = 1
 command = autopause resume "REST_API from %IP% on ${iface}"
 tcpflags = syn
EOF
        knockd "${knockdArgs[@]}" -i "${iface}" -p "${basedir}/.knockd-${iface}.pid" -c "${config}"
    done

    local pids
    pids=$(pidof knockd)
    APLog_debug "Start knockd (PIDs:${pids})"
}

Knockd_stopBackend() {
    local pids
    pids=$(pidof knockd)
    APLog_debug "Stop knockd (PIDs:${pids})"

    # Kill all knockd processes and clean up their PID files
    for pidFile in "${basedir}"/.knockd-*.pid; do
        if [ -f "${pidFile}" ]; then
            kill -KILL "$(cat "${pidFile}")"
            rm -f "${pidFile}"
        fi
    done
}

# ============================================================================
# Main Dispatcher
# ============================================================================

COMMAND="${1:-}"

case "${COMMAND}" in
"start")
    backend=$(APMonitor_determineBackend)
    if [ "${backend}" = "nflog" ]; then
        Nflog_startBackend
    else
        Knockd_startBackend
    fi
    ;;
"stop")
    backend=$(APMonitor_determineBackend)
    if [ "${backend}" = "nflog" ]; then
        Nflog_stopBackend
    else
        Knockd_stopBackend
    fi
    ;;
*)
    echo "Usage: $(basename "${0}") <command>"
    echo "command:"
    echo "    start ... launch NFLOG or knockd based on .monitor-backend"
    echo "    stop  ... stop NFLOG or knockd"
esac
