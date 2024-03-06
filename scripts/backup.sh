#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

discord_message "Backup" "${DISCORD_PRE_BACKUP_MESSAGE}" "in-progress" "${DISCORD_PRE_BACKUP_MESSAGE_ENABLED}" "${DISCORD_PRE_BACKUP_MESSAGE_URL}"
if [ "${RCON_ENABLED,,}" = true ]; then
    save_server
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/ || exit

log_action "Creating backup"
tar -zcf "$FILE_PATH" "Saved/"

if [ "$(id -u)" -eq 0 ]; then
    chown steam:steam "$FILE_PATH"
fi
log_info "Backup created at ${FILE_PATH}"
discord_message "Backup" "${DISCORD_POST_BACKUP_MESSAGE//\$\{FILE_PATH\}/${FILE_PATH}}" "success" "${DISCORD_POST_BACKUP_MESSAGE_ENABLED}" "${DISCORD_POST_BACKUP_MESSAGE_URL}"

if [ "${DELETE_OLD_BACKUPS,,}" != true ]; then
  exit 0
fi

if [ -z "${OLD_BACKUP_DAYS}" ]; then
    log_warn "Unable to delete old backups, OLD_BACKUP_DAYS is empty."
    discord_message "Backup" "Unable to delete old backups, OLD_BACKUP_DAYS is empty." "warn"
    exit 0
fi

if [[ "${OLD_BACKUP_DAYS}" =~ ^[0-9]+$ ]]; then
    log_action "Removing Old Backups"
    log_info "Removing backups older than ${OLD_BACKUP_DAYS} days"
    discord_message "Backup" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE//\$\{FILE_PATH\}/${FILE_PATH}}" "in-progress" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_PRE_BACKUP_DELETE_MESSAGE_URL}"
    find /palworld/backups/ -mindepth 1 -maxdepth 1 -mtime "+${OLD_BACKUP_DAYS}" -type f -name 'palworld-save-*.tar.gz' -print -delete
    discord_message "Backup" "${DISCORD_POST_BACKUP_DELETE_MESSAGE//\$\{FILE_PATH\}/${FILE_PATH}}" "success" "${DISCORD_POST_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_POST_BACKUP_DELETE_MESSAGE_URL}"
    exit 0
fi

log_error "Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=${OLD_BACKUP_DAYS}"
discord_message "Backup" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE//\$\{OLD_BACKUP_DAYS\}/${OLD_BACKUP_DAYS}}}" "failure" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE_ENABLED}" "${DISCORD_ERR_BACKUP_DELETE_MESSAGE_URL}"