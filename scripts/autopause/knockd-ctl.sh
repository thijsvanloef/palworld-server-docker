#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

basedir="/home/steam/server/autopause"
config="${basedir}/knockd.cfg"

case "${1}" in
"start")
    if [ ! -f "${config}" ]; then
        cat - << EOF > "${config}"
[options]
 logfile = /dev/null
[resume-by-player]
 sequence = ${PORT:-8211}:udp
 seq_cooldown = 5
 command = autopause resume "LOGIN from %IP%"
[resume-by-rcon]
 sequence = ${RCON_PORT:-25575}
 seq_timeout = 1
 command = autopause resume "RCON from %IP%"
 tcpflags = syn
[resume-by-rest]
 sequence = ${REST_API_PORT:-8212}
 seq_timeout = 1
 command = autopause resume "REST_API from %IP%"
 tcpflags = syn
EOF
    fi
    pid=$(pidof knockd)
    if [ -n "${pid}" ]; then
        echo "Already started knockd (PID:${pid})"
        exit 1
    fi
    knockdArgs=(-d -c "${config}")
    if isTrue "${AUTO_PAUSE_DEBUG:-false}"; then
        knockdArgs+=(-D)
    fi
    # Detects knocks coming from outside the container.
    knockd "${knockdArgs[@]}" -i eth0
    # Detects knocks coming from inside the container.
    knockd "${knockdArgs[@]}" -i lo
    ;;
"stop")
    pid=$(pidof knockd)
    if [ -z "${pid}" ]; then
        echo "Already stopped knockd (PID:${pid})"
        exit 1
    fi
    echo -n "${pid}" | xargs -d ' ' -i kill -KILL "{}"
    ;;
*)
    echo "Usage: $(basename "${0}") <command>"
    echo "command:"
    echo "    start ... launch knockd"
    echo "    stop  ... kill knockd"
esac
