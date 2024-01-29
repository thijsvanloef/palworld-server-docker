#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
fi

STARTCOMMAND=("./PalServer.sh")

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${SERVER_NAME}" ]; then
    STARTCOMMAND+=("-servername=${SERVER_NAME}")
fi

if [ -n "${SERVER_DESCRIPTION}" ]; then
    STARTCOMMAND+=("-serverdescription=${SERVER_DESCRIPTION}")
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    STARTCOMMAND+=("-serverpassword=${SERVER_PASSWORD}")
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    STARTCOMMAND+=("-adminpassword=${ADMIN_PASSWORD}")
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

printf "\e[0;32m*****CHECKING FOR EXISTING CONFIG*****\e[0m\n"

# shellcheck disable=SC2143
if [ ! "$(grep -s '[^[:space:]]' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)" ]; then

    printf "\e[0;32m*****GENERATING CONFIG*****\e[0m\n"

    # Server will generate all ini files after first run.
    timeout --preserve-status 15s ./PalServer.sh 1> /dev/null

    # Wait for shutdown
    sleep 5
    cp /palworld/DefaultPalWorldSettings.ini /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

./compile-settings.sh

cd /palworld || exit

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: ${ADMIN_PASSWORD}
EOL

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

