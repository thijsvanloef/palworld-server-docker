#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    LogAction "EXECUTING USERMOD"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    LogError "Running as root is not supported, please fix your PUID and PGID!"
    exit 1
fi

mkdir -p /palworld/backups
mkdir -p /home/steam/server/logs/
chown -R steam:steam /palworld /home/steam/

su steam -c /home/steam/server/start.sh
cp /home/steam/server/services/supervisord.conf /etc/supervisor/supervisord.conf
exec /usr/bin/supervisord --configuration=/etc/supervisor/supervisord.conf