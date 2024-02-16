#!/bin/bash

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    printf "\033[31m%s\n" "Running as root is not supported, please fix your PUID and PGID!"
    exit 1
fi

mkdir -p /palworld/backups
mkdir -p /home/steam/server/logs/
chown -R steam:steam /palworld /home/steam/

su steam -c /home/steam/server/start.sh
mv /home/steam/server/services/supervisord.conf /etc/supervisor/supervisord.conf
exec /usr/bin/supervisord --configuration=/etc/supervisor/supervisord.conf