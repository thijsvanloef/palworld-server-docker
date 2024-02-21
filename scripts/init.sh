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

mkdir -p /palworld/backups
mkdir -p /home/steam/server/logs/
if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c ./start.sh
else
    ./start.sh
fi

cp /home/steam/server/services/supervisord.conf /etc/supervisor/supervisord.conf
exec /usr/bin/supervisord --configuration=/etc/supervisor/supervisord.conf