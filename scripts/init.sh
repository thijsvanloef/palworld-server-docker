#!/bin/bash

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    echo "Executing usermod..."
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    echo "Running as root is not supported, please fix your PUID and PGID!"
    exit 1
fi

mkdir -p /palworld
chown -R steam:steam /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m"
    su steam -c '/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit'
fi

./start.sh
