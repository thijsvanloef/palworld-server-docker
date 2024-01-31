#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
fi

STARTCOMMAND=("./PalServer.sh")

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${QUERY_PORT}" ]; then
    STARTCOMMAND+=("-queryport=${QUERY_PORT}")
fi

if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND+=("EpicApp=PalServer")
fi

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

printf "\e[0;32m*****GENERATING CONFIGS*****\e[0m\n"

./compile-settings.sh

cd /palworld || exit

rm -f "/home/steam/server/crontab"
if [ "${BACKUP_ENABLED}" = true ]; then
    echo "BACKUP_ENABLED=${BACKUP_ENABLED}"
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" >> "/home/steam/server/crontab"
fi

if [ "${AUTO_UPDATE_ENABLED}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    echo "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED}"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash /usr/local/bin/update" >> "/home/steam/server/crontab"
fi

if { [ "${AUTO_UPDATE_ENABLED}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; } || [ "${BACKUP_ENABLED}" = true ]; then
    supercronic "/home/steam/server/crontab" &
fi

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: ${ADMIN_PASSWORD}
EOL

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

