#!/bin/bash

if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli -c /home/steam/server/rcon.yaml save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
        chown steam:steam "$FILE_PATH"
fi

echo "backup created at $FILE_PATH"

if [ "${DELETE_OLD_BACKUPS}" = true ]; then
        echo "removing backups older than ${OLD_BACKUP_DAYS} days"
        if [ "$(id -u)" -eq 0 ]; then
                su steam -c "find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete"
        else
                find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
        fi
fi
