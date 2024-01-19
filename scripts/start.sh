#!/bin/sh


STARTCOMMAND="./PalServer.sh -port=${PORT} -players=${PLAYERS}"


if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} EpicApp=PalServer"
fi

if [ -n "${PUBLIC_IP}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publicip=${PUBLIC_IP}"
fi

if [ -n "${PUBLIC_PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publiport=${PUBLIC_PORT}"
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -serverpassword=${SERVER_PASSWORD}"
fi

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
fi 

cd /palworld || exit

echo "${STARTCOMMAND}"

printf "\e[0;32m*****STARTING SERVER*****\e[0m"

su steam -c "${STARTCOMMAND}"
