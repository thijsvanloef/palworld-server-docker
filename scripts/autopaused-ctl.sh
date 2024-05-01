#!/bin/bash
# Control the port knock daemon.
# Called only on the server side.

basedir="/home/steam/autopause"
config="${basedir}/knockd.cfg"

case "${1}" in
"start")
    if [ ! -f "${config}" ]; then
        cat - << EOF > "${config}"
[options]
 logfile = ${basedir}/knockd.log
 interface = ${AUTO_PAUSE_KNOCK_INTERFACE:-eth0}
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
        echo "Already started knockd ${pid}"
        return
    fi
    knockd -d -c "${config}" -p "${basedir}/knockd.pid"
    ;;
"stop")
    pid=$(pidof knockd)
    if [ -z "${pid}" ]; then 
        echo "Already stopped knockd ${pid}"
        return
    fi
    kill -KILL "${pid}"
    ;;
*)
    echo "Usage: $(basename "${0}") <command>"
    echo "command:"
    echo "    start ... launch knockd"
    echo "    stop  ... kill knockd"
esac
