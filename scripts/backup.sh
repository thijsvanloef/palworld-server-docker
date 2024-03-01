#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

DiscordMessage "Backup" "Creating backup..." "in-progress"
if [ "${RCON_ENABLED,,}" = true ]; then
    save_server
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

LogAction "Creating backup"
tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
    chown steam:steam "$FILE_PATH"
fi
LogInfo "Backup created at ${FILE_PATH}"
DiscordMessage "Backup" "Backup created at ${FILE_PATH}" "success"

if [ "${DELETE_OLD_BACKUPS,,}" != true ]; then
  exit 0
fi

if [ -z "${OLD_BACKUP_DAYS}" ]; then
    LogWarn "Unable to delete old backups, OLD_BACKUP_DAYS is empty."
    DiscordMessage "Backup" "Unable to delete old backups, OLD_BACKUP_DAYS is empty." "warn"
    exit 0
fi

if [[ "${OLD_BACKUP_DAYS}" =~ ^[0-9]+$ ]]; then
    LogAction "Removing Old Backups"
    LogInfo "Removing backups older than ${OLD_BACKUP_DAYS} days"
    DiscordMessage "Backup" "Removing backups older than ${OLD_BACKUP_DAYS} days..." "in-progress"
    find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
    DiscordMessage "Backup" "Removed backups older than ${OLD_BACKUP_DAYS} days" "success"
    exit 0
fi

LogError "Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
DiscordMessage "Backup" "Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}" "failure"