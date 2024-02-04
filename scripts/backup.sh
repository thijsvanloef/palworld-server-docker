#!/bin/bash

if [ -n "$DISCORD_PRE_BACKUP_JSON" ]; then
    discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_PRE_BACKUP_JSON &
fi

if [ "${RCON_ENABLED,,}" = true ]; then
    rcon-cli -c /home/steam/server/rcon.yaml save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

echo "Creating backup"
tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
    chown steam:steam "$FILE_PATH"
fi

echo "backup created at ${FILE_PATH}"

if [ -n "$DISCORD_POST_BACKUP_JSON" ]; then
    discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_POST_BACKUP_JSON &
fi

if [ "${DELETE_OLD_BACKUPS,,}" = true ]; then
    if [ -n "$DISCORD_PRE_BACKUP_DELETE_JSON" ]; then
        discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_PRE_BACKUP_DELETE_JSON &
    fi
    if [ -z "${OLD_BACKUP_DAYS}" ]; then
        echo "Unable to deleted old backups, OLD_BACKUP_DAYS is empty."
    elif [[ "${OLD_BACKUP_DAYS}" =~ ^[0-9]+$ ]]; then
        echo "removing backups older than ${OLD_BACKUP_DAYS} days"
        find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
    else
        echo "Unable to deleted old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
    fi
    if [ -n "$DISCORD_POST_BACKUP_DELETE_JSON" ]; then
        discord -i $DISCORD_WEBHOOK_ID -t $DISCORD_TIMEOUT -j $DISCORD_POST_BACKUP_DELETE_JSON &
    fi
fi