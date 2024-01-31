#!/bin/bash

if [ -n "$PRE_BACKUP_HOOK" ]; then
    echo "PRE_BACKUP_HOOK: $PRE_BACKUP_HOOK"
    eval "$PRE_BACKUP_HOOK"
fi

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

if [ -n "$POST_BACKUP_HOOK" ]; then
    echo "POST_BACKUP_HOOK: $POST_BACKUP_HOOK"
    eval "$POST_BACKUP_HOOK"
fi

if [ "${DELETE_OLD_BACKUPS}" = true ]; then
        echo "removing backups older than ${OLD_BACKUP_DAYS:=30} days"
        find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -print -delete
fi
