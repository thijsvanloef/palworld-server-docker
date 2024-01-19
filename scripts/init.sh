#!/bin/sh

mkdir -p /palworld

chown -R steam:steam /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then

    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

fi

./start.sh