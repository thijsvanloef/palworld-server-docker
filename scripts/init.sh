#!/bin/bash

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
    exit 1
fi

mkdir -p /palworld/backups
chown -R steam:steam /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    su steam -c '/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit'
fi

./start.sh
