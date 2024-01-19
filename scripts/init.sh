#!/bin/sh
printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m"
mkdir -p /palworld

chown -R steam:steam /palworld
/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

# ln -s /home/steam/server/palworld /palworld

./start.sh