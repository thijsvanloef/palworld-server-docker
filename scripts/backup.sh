#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

DiscordMessage "Backup" "${DISCORD_PRE_BACKUP_MESSAGE}" "in-progress" "${DISCORD_PRE_BACKUP_MESSAGE_ENABLED}" "${DISCORD_PRE_BACKUP_MESSAGE_URL}"
if [ "${RCON_ENABLED,,}" = true ]; then
    save_server
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

LogAction "Creating backup"
tar -zcf "$FILE_PATH" --exclude "backup" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
    chown steam:steam "$FILE_PATH"
fi
LogInfo "Backup created at ${FILE_PATH}"
DiscordMessage "Backup" "${DISCORD_POST_BACKUP_MESSAGE//file_path/${FILE_PATH}}" "success" "${DISCORD_POST_BACKUP_MESSAGE_ENABLED}" "${DISCORD_POST_BACKUP_MESSAGE_URL}"

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
    DiscordMessage "Backup" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE//old_backup_days/${OLD_BACKUP_DAYS}}" "in-progress" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE_URL}"
    find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
    DiscordMessage "Backup" "${DISCORD_POST_BACKUP_DELETE_MESSAGE//old_backup_days/${OLD_BACKUP_DAYS}}" "success" "${DISCORD_POST_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_POST_BACKUP_DELETE_MESSAGE_URL}"
    exit 0
fi

LogError "Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
DiscordMessage "Backup" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE//old_backup_days/${OLD_BACKUP_DAYS}}" "failure" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE_URL}"
