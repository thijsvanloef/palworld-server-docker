#!/bin/bash

STARTCOMMAND=("./PalServer.sh")

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${PLAYERS}" ]; then
    STARTCOMMAND+=("-players=${PLAYERS}")
fi

if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND+=("EpicApp=PalServer")
fi

if [ -n "${PUBLIC_IP}" ]; then
    STARTCOMMAND+=("-publicip=${PUBLIC_IP}")
fi

if [ -n "${PUBLIC_PORT}" ]; then
    STARTCOMMAND+=("-publicport=${PUBLIC_PORT}")
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

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

cd /palworld || exit

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

if [ -n "${RCON_ENABLED}" ]; then
    echo "RCON_ENABLED=${RCON_ENABLED}"
    sed -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=$RCON_ENABLED/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${RCON_PORT}" ]; then
    echo "RCON_PORT=${RCON_PORT}"
    sed -i "s/RCONPort=[0-9]*/RCONPort=$RCON_PORT/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

# Configure RCON settings
cat >rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: ${ADMIN_PASSWORD}
EOL

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "bash -c '${STARTCOMMAND[*]}'"
"${STARTCOMMAND[@]}"

