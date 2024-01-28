#!/bin/bash

if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DESTINATION_PATH="/palworld/backups"
FILE_PATH="${DESTINATION_PATH}/backup_palworld_${DATE}.tar.gz"

if [ ! -f ${FILE_PATH} ]; then
    printf "\e[0;32m***** CREATING BACKUPS FOLDER *****\e[0m\n"
    mkdir -p "${DESTINATION_PATH}"
fi

cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
        chown steam:steam "$FILE_PATH"
fi

echo "backup created at $FILE_PATH"

if [[ -n "${DAYS_TO_KEEP}" && "${DAYS_TO_KEEP}" =~ ^[0-9]+$ ]]; then
    echo "DAYS_TO_KEEP=${DAYS_TO_KEEP}"
    if [[ "${DAYS_TO_KEEP}" -gt 0 ]]; then
        find "${DESTINATION_PATH}" -type f -mtime +"${DAYS_TO_KEEP}" -exec rm {} \;
    else
        echo "DAYS_TO_KEEP is zero. No files will be removed."
    fi
fi


