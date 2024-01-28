#!/bin/bash

if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
        chown steam:steam "$FILE_PATH"
fi

echo "backup created at $FILE_PATH"
