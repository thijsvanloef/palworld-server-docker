#!/bin/bash

# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

if isTrue "${AUTO_PAUSE_ENABLED}"; then
    if ! PlayerLogging_isEnabled; then
        LogError "AUTO_PAUSE requires ENABLE_PLAYER_LOGGING=True and REST_API_ENABLED=True."
        exit 1
    fi

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

    # shellcheck source=scripts/autopause/community/init.sh
    source "/home/steam/server/autopause/community/init.sh"
fi
