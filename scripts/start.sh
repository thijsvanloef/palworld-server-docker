#!/bin/bash

STARTCOMMAND="./PalServer.sh"

if [ -n "${GAME_PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -port=${GAME_PORT}"
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



if [ "${ENABLE_RCON}" = true ]; then
    cd /Pal/Saved/Config/LinuxServer/
    sed -i '/RCONEnabled=/ {s/False/True/; t; a\RCONEnabled=True}' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

    if [ -n "${RCON_PORT}" ]; then
        sed -i 's/RCONPort=.*/RCONPort='"${RCON_PORT}"'/' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || \
        echo "RCONPort=${RCON_PORT}" >> /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
fi


cd /palworld || exit

echo "${STARTCOMMAND}"

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"

su steam -c "${STARTCOMMAND}"
