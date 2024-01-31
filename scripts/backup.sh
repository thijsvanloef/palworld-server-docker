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
    if [ -z "${OLD_BACKUP_DAYS}" ]; then
        echo "Unable to deleted old backups, OLD_BACKUP_DAYS is empty."
    elif [[ "${OLD_BACKUP_DAYS}" =~ ^[0-9]+$ ]]; then
        echo "removing backups older than ${OLD_BACKUP_DAYS} days"
        find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
    else
        echo "Unable to deleted old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
    fi
fi
