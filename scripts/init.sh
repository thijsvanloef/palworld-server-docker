#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

if [[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]; then
    if [[ "${PUID}" -ne 0 ]] && [[ "${PGID}" -ne 0 ]]; then
        LogAction "EXECUTING USERMOD"
        usermod -o -u "${PUID}" steam
        groupmod -o -g "${PGID}" steam
        chown -R steam:steam /palworld /home/steam/
    else
        LogError "Running as root is not supported, please fix your PUID and PGID!"
        exit 1
    fi
elif [[ "$(id -u)" -eq 0 ]] || [[ "$(id -g)" -eq 0 ]]; then
   LogError "Running as root is not supported, please fix your user!"
   exit 1
fi

if ! [ -w "/palworld" ]; then
    LogError "/palworld is not writable."
    exit 1
fi

# launch proxy for keep community server list in paused.
if isTrue "${AUTO_PAUSE_ENABLED}" && isTrue "${COMMUNITY}" && isTrue "${ENABLE_PLAYER_LOGGING}"; then
    LogAction "AUTO PAUSE with Community"
    LogInfo "Launch proxy."
    if isTrue "${AUTO_PAUSE_DEBUG}"; then
        mitmweb --web-host 0.0.0.0 --set block_global=false --ssl-insecure -s /home/steam/autopause/addons/PalIntercept.py  &
        LogInfo "Web Interface URL: http://localhost:8081/"
    else
        mitmdump --set block_global=false --ssl-insecure -s /home/steam/autopause/addons/PalIntercept.py > /var/log/mitmdump.log &
    fi

    trap 'exit 1' SIGTERM
    echo -n "Wait until proxy is initialized..."
    while [ ! -f "/home/steam/.mitmproxy/mitmproxy-ca-cert.pem" ]; do
        echo -n "."
        sleep 0.5
    done
    echo "done."
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "${PUID}:${PGID}" "/home/steam/.mitmproxy"
        chown -R "${PUID}:${PGID}" "/home/steam/autopause/addons/__pycache__"
    fi

    LogInfo "Update ca-certificates."
    #ln -sf /home/steam/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitmproxy.crt
    sudo update-ca-certificates

    LogInfo "Using proxy now."
    export http_proxy="localhost:8080"
    export https_proxy="localhost:8080"
    export no_proxy="localhost,127.0.0.1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"
fi

mkdir -p /palworld/backups

# shellcheck disable=SC2317
term_handler() {
    autopause stop "term_handler"

  DiscordMessage "Shutdown" "${DISCORD_PRE_SHUTDOWN_MESSAGE}" "in-progress" "${DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_PRE_SHUTDOWN_MESSAGE_URL}"

    if ! shutdown_server; then
        # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Shipping)"
    fi

    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c ./start.sh &
else
    ./start.sh &
fi
# Process ID of su
killpid="$!"
wait "$killpid"

mapfile -t backup_pids < <(pgrep backup)
if [ "${#backup_pids[@]}" -ne 0 ]; then
    LogInfo "Waiting for backup to finish"
    for pid in "${backup_pids[@]}"; do
        tail --pid="$pid" -f 2>/dev/null
    done
fi

mapfile -t restore_pids < <(pgrep restore)
if [ "${#restore_pids[@]}" -ne 0 ]; then
    LogInfo "Waiting for restore to finish"
    for pid in "${restore_pids[@]}"; do
        tail --pid="$pid" -f 2>/dev/null
    done
fi
