#!/bin/bash

if [ -n "${DISCORD_WEBHOOK_ID}" ]; then
    discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Creating backup..." -l "in-progress" &
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

echo "Backup created at ${FILE_PATH}"
if [ -n "${DISCORD_WEBHOOK_ID}" ]; then
    discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Backup created at ${FILE_PATH}" -l "success"
fi

if [ "${DELETE_OLD_BACKUPS,,}" = true ]; then

    if [ -z "${OLD_BACKUP_DAYS}" ]; then
        echo "Unable to delete old backups, OLD_BACKUP_DAYS is empty."
        if [ -n "${DISCORD_WEBHOOK_ID}" ]; then
            discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Unable to deleted old backups, OLD_BACKUP_DAYS is empty." -l "warn"
        fi
    elif [[ "${OLD_BACKUP_DAYS}" =~ ^[0-9]+$ ]]; then
        echo "Removing backups older than ${OLD_BACKUP_DAYS} days"
        if [ -n "${DISCORD_WEBHOOK_ID}" ] && [ -n "${DISCORD_PRE_BACKUP_DELETE_MESSAGE}" ]; then
            discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Removing backups older than ${OLD_BACKUP_DAYS} days..." -l "in-progress" &
        fi
        find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
        if [ -n "${DISCORD_WEBHOOK_ID}" ]; then
            discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Removed backups older than ${OLD_BACKUP_DAYS} days" -l "success"
        fi
    else
        echo "Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
        if [ -n "${DISCORD_WEBHOOK_ID}" ]; then
            discord -i $DISCORD_WEBHOOK_ID -c $DISCORD_CONNECT_TIMEOUT -M $DISCORD_MAX_TIMEOUT -m "Unable to deleted old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}" -l "failure"
        fi
    fi
fi