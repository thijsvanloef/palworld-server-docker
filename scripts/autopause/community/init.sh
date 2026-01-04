#!/bin/bash

#-------------------------------
# launch proxy
#-------------------------------
if isTrue "${COMMUNITY}" && isTrue "${AUTO_PAUSE_ENABLED}" && PlayerLogging_isEnabled; then
    LogAction "AUTO PAUSE with Community"

    LogInfo "Launch proxy."
    MITMPROXY_ADDONS_DIR="/home/steam/server/autopause/community/addons"
    IGNORE_HOSTS="api.steamcmd.net"
    IGNORE_HOSTS_PATTERN=$(echo "$IGNORE_HOSTS" | tr ',' '\n' | sed 's/\./\\./g' | paste -sd '|' -)
    MITMPROXY_OPTIONS=(
        "--set" "block_global=false"
        "--ssl-insecure"
        "--ignore-hosts" "^(${IGNORE_HOSTS_PATTERN})\$"
        "-s" "${MITMPROXY_ADDONS_DIR}/PalCommCapture.py"
    )
    if isTrue "${AUTO_PAUSE_DEBUG}"; then
        mitmweb --web-host 0.0.0.0 "${MITMPROXY_OPTIONS[@]}" &
        LogInfo "Web Interface URL: http://localhost:8081/"
    else
        mitmdump "${MITMPROXY_OPTIONS[@]}" > /var/log/mitmdump.log &
    fi

    LogInfo "Wait until proxy is initialized..."
    while [ ! -d "${MITMPROXY_ADDONS_DIR}/__pycache__" ]; do
        sleep 0.5
    done
    LogInfo "Proxy initialized."
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "${PUID}:${PGID}" "${MITMPROXY_ADDONS_DIR}/__pycache__"
        chown -R "${PUID}:${PGID}" "/home/steam/.mitmproxy"
    fi

    LogInfo "Using proxy now."
    export http_proxy="localhost:8080"
    export https_proxy="localhost:8080"
    export no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,.local,${IGNORE_HOSTS}"
fi
