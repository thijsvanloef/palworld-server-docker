#!/bin/bash

printf "\e[0;34m***** RUNNING SCRIPTS backup.sh *****\e[0m\n"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DESTINATION_PATH="/palworld/backups"
FILE_PATH="${DESTINATION_PATH}/backup_palworld_${DATE}.tar.gz"

if [ ! -f ${FILE_PATH} ]; then
    printf "\e[0;32m***** CREATING BACKUPS FOLDER *****\e[0m\n"
    mkdir -p "${DESTINATION_PATH}"
fi

cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"
echo "backup created at $FILE_PATH"

find "${DESTINATION_PATH}" -type f -name "backup_palworld_*.tar.gz" -ctime +7 -exec rm -f {} \;