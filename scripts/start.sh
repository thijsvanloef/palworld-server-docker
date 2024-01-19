#!/bin/sh

STARTCOMMAND="./PalServer.sh -port=${PORT} -players=${PLAYERS}"

printf "\e[0;32m*****STARTING SERVER*****\e[0m"
cd /palworld || exit


if [ "${MULTITHREADING}" = true ]; then
    su steam -c "${STARTCOMMAND} -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
else
    su steam -c "${STARTCOMMAND}"
fi