#!/bin/bash

STARTCOMMAND="./PalServer.sh"

if [ -n "${PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -port=${PORT}"
fi

if [ -n "${PLAYERS}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -players=${PLAYERS}"
fi

if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} EpicApp=PalServer"
fi

if [ -n "${PUBLIC_IP}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publicip=${PUBLIC_IP}"
fi

if [ -n "${PUBLIC_PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publicport=${PUBLIC_PORT}"
fi

if [ -n "${SERVER_NAME}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -servername=${SERVER_NAME}"
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -serverpassword=${SERVER_PASSWORD}"
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -adminpassword=${ADMIN_PASSWORD}"
fi

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
fi

cd /palworld || exit

printf "\e[0;32m*****CHECKING FOR EXISTING CONFIG*****\e[0m\n"

if [ ! -f /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then

    printf "\e[0;32m*****GENERATING CONFIG*****\e[0m\n"

    # Server will generate all ini files after first run.
    steam -c "timeout --preserve-status 15s ./PalServer.sh 1> /dev/null "

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

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND}"
su steam -c "${STARTCOMMAND}"
