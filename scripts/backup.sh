#!/bin/bash

if [ -n "$DISCORD_PRE_BACKUP_JSON" ]; then
    discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_PRE_BACKUP_JSON &
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

echo "backup created at ${FILE_PATH}"

if [ -n "$DISCORD_POST_BACKUP_JSON" ]; then
    discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_POST_BACKUP_JSON &
fi

if [ "${DELETE_OLD_BACKUPS}" = true ]; then
    echo "removing backups older than ${OLD_BACKUP_DAYS:=30} days"
    if [ -n "$DISCORD_PRE_BACKUP_DELETE_JSON" ]; then
        discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_PRE_BACKUP_DELETE_JSON &
    fi
    find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -print -delete
    if [ -n "$DISCORD_POST_BACKUP_DELETE_JSON" ]; then
        discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_POST_BACKUP_DELETE_JSON &
    fi
fi
