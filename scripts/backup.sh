#!/bin/bash

if [ -n "$PRE_BACKUP_HOOK" ]; then
    echo "PRE_BACKUP_HOOK: $PRE_BACKUP_HOOK"
    eval "$PRE_BACKUP_HOOK"
fi

if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"
echo "backup created at $FILE_PATH"

if [ -n "$POST_BACKUP_HOOK" ]; then
    echo "POST_BACKUP_HOOK: $POST_BACKUP_HOOK"
    eval "$POST_BACKUP_HOOK"
fi