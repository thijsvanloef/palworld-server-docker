#!/bin/bash

# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

#
# Validate the AUTO_PAUSE and API_PROXY settings.
#
if isTrue "${API_PROXY_ENABLED:-false}"; then
    if ! isTrue "${AUTO_PAUSE_ENABLED:-false}" || ! isTrue "${REST_API_ENABLED:-false}"; then
        LogError "API_PROXY_ENABLED requires AUTO_PAUSE_ENABLED=true and REST_API_ENABLED=true."
        exit 1
    fi
    if [ -z "${ADMIN_PASSWORD:-}" ]; then
        LogError "The AUTO_PAUSE REST API proxy requires a non-empty ADMIN_PASSWORD."
        exit 1
    fi
    if ! [[ "${API_PROXY_PORT:-}" =~ ^[0-9]{1,5}$ ]] \
        || (( 10#${API_PROXY_PORT} < 1 || 10#${API_PROXY_PORT} > 65535 )); then
        LogError "API_PROXY_PORT must be an integer between 1 and 65535."
        exit 1
    fi
    if [ "${API_PROXY_PORT}" = "${REST_API_PORT}" ]; then
        LogError "API_PROXY_PORT must differ from REST_API_PORT."
        exit 1
    fi
fi

#
# Validate the AUTO_PAUSE prerequisites and capabilities.
#
if isTrue "${AUTO_PAUSE_ENABLED}"; then
    LogAction "Initializing AUTO_PAUSE"

    if ! PlayerLogging_isEnabled; then
        LogError "AUTO_PAUSE requires ENABLE_PLAYER_LOGGING=True and REST_API_ENABLED=True."
        exit 1
    fi

    if [ "$(id -u)" -eq 0 ]; then
        if ! setpriv --reuid=steam --regid=steam --init-groups -- /usr/local/sbin/knockd-ctl check; then
            # OMV8? (https://github.com/thijsvanloef/palworld-server-docker/issues/911)
            FORCE_CAPS=("--inh-caps=+net_raw,+net_admin" "--ambient-caps=+net_raw,+net_admin")
            if ! setpriv --reuid=steam --regid=steam --init-groups "${FORCE_CAPS[@]}" -- /usr/local/sbin/knockd-ctl check; then
                LogError "AUTO_PAUSE requires capabilities the NET_RAW and NET_ADMIN."
                LogError "See NOTE: https://palworld-server-docker.loef.dev/guides/automatic-server-pausing#network-interface-configuration"
                exit 1
            else
                LogWarn "A capability issue #911 was detected."
                LogWarn "Continuing with NET_RAW and NET_ADMIN capabilities enabled."
            fi
        fi
    else
        if ! /usr/local/sbin/knockd-ctl check; then
            LogError "AUTO_PAUSE requires capabilities the NET_RAW and NET_ADMIN."
            LogError "See NOTE: https://palworld-server-docker.loef.dev/guides/automatic-server-pausing#network-interface-configuration"
            exit 1
        fi
    fi

    # shellcheck source=scripts/autopause/community/init.sh
    source "/home/steam/server/autopause/community/init.sh"
fi

#
# API Proxy service control
#
APIProxy_pid=""

APIProxy_stop() {
    if [[ -n "${APIProxy_pid}" ]] && kill -0 "${APIProxy_pid}" 2>/dev/null; then
        kill -TERM "${APIProxy_pid}" 2>/dev/null || true
        wait "${APIProxy_pid}" 2>/dev/null || true
        LogInfo "Stopping REST API proxy with PID ${APIProxy_pid}"
    fi
    APIProxy_pid=""
}

APIProxy_start() {
    if ! isTrue "${API_PROXY_ENABLED:-false}"; then
        return 0
    fi

    local host="127.0.0.1"
    if isTrue "${API_PROXY_ENABLED:-false}"; then
        host="0.0.0.0"
    fi
    local -a command=(
        /opt/api-proxy-venv/bin/uvicorn api_proxy:app
        --app-dir /home/steam/server/autopause
        --host "${host}"
        --port "${API_PROXY_PORT}"
        --log-level error
        --no-access-log
    )
    LogAction "Starting REST API proxy on port ${API_PROXY_PORT}"
    if [[ "$(id -u)" -eq 0 ]]; then
        setpriv --reuid=steam --regid=steam --init-groups -- "${command[@]}" &
    else
        "${command[@]}" &
    fi
    APIProxy_pid="$!"

    local -i attempt=0
    while (( attempt < 50 )); do
        if ! kill -0 "${APIProxy_pid}" 2>/dev/null; then
            wait "${APIProxy_pid}" 2>/dev/null || true
            APIProxy_pid=""
            LogError "REST API proxy failed to start."
            return 1
        fi
        if nc -z -w 1 127.0.0.1 "${API_PROXY_PORT}"; then
            return 0
        fi
        sleep 0.1
        ((attempt+=1))
    done

    LogError "REST API proxy did not listen on port ${API_PROXY_PORT}."
    APIProxy_stop
    return 1
}
