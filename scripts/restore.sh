#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Backup file directory path
BACKUP_DIRECTORY_PATH="/palworld/backups"

# Restore path
RESTORE_PATH="/palworld/Pal"

# Copy the save file before restore temporary path
TMP_SAVE_PATH="/palworld/backups/restore-"$(date +"%Y-%m-%d_%H-%M-%S")

# shellcheck disable=SC2317
term_error_handler() {
    log_error "An error occurred during server shutdown."
    exit 1
}

# shellcheck disable=SC2317
restore_error_handler() {
    log_error "Error occurred during restore."
    if [ -d "$TMP_SAVE_PATH/Saved" ]; then
        read -rp "I have a backup before recovery can proceed. Do you want to recovery it? (y/n): " RUN_ANSWER
        if [[ ${RUN_ANSWER,,} == "y" ]]; then
            rm -rf "$RESTORE_PATH/Saved"
            mv "$TMP_SAVE_PATH/Saved" "$RESTORE_PATH"
            PrintSuccess "Recovery Complete"
        fi
    fi

    log_info "Clean up the temporary directory."
    rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"

    exit 1
}

if [ "${RCON_ENABLED}" != true ]; then
    log_warn "RCON is not enabled. Please enable RCON to use this feature."
    exit 1
fi

# Show up backup list
log_info "Backup List:"
mapfile -t BACKUP_FILES < <(find "$BACKUP_DIRECTORY_PATH" -type f -name "*.tar.gz" | sort)
select BACKUP_FILE in "${BACKUP_FILES[@]}"; do
    if [ -n "$BACKUP_FILE" ]; then
        log_info "Selected backup: $BACKUP_FILE"
        break
    else
        log_warn "Invalid selection. Please try again."
    fi
done

if [ -f "$BACKUP_FILE" ]; then
    log_info "This script has been designed to help you restore; however, I am not responsible for any data loss. It is recommended that you create a backup beforehand, and in the event of script failure, be prepared to restore it manually."
    log_info "Do you understand the above and would you like to proceed with this command?"
    read -rp "When you run it, the server will be stopped and the recovery will proceed. (y/n): " RUN_ANSWER
    if [[ ${RUN_ANSWER,,} == "y" ]]; then
        log_action "Starting Recovery Process"
        # Shutdown server
        trap 'term_error_handler' ERR

        if [ "${RCON_ENABLED}" = true ]; then
            log_action "Shutting Down Server"
            shutdown_server
        else
            log_warn "RCON is not enabled. Please enable RCON to use this feature. Unable to restore backup."
            exit 1
        fi

        server_pid=$(pidof PalServer-Linux-Test)
        if [ -n "${server_pid}" ]; then
            log_info "Waiting for Palworld to exit.."
            tail --pid="${server_pid}" -f /dev/null
        fi
        log_success "Shutdown Complete"

        trap - ERR

        trap 'restore_error_handler' ERR

        log_action "Starting Restore"

        # Recheck the backup file
        if [ -f "$BACKUP_FILE" ]; then
            # Copy the save file before restore
            if [ -d "$RESTORE_PATH/Saved" ]; then
                log_info "Saves the current state before the restore proceeds."
                log_info "$TMP_SAVE_PATH"
                mkdir -p "$TMP_SAVE_PATH"
                if [ "$(id -u)" -eq 0 ]; then
                    chown steam:steam "$TMP_SAVE_PATH"
                fi
                \cp -rf "$RESTORE_PATH/Saved" "$TMP_SAVE_PATH/Saved"

                while [ ! -d "$TMP_SAVE_PATH/Saved" ]; do
                    sleep 1
                done
                log_success "Save Complete"
            fi
            
            # Create tmp directory
            TMP_PATH=$(mktemp -d -p "/palworld/backups")
            if [ "$(id -u)" -eq 0 ]; then
                chown steam:steam "$TMP_PATH"
            fi
            
            # Decompress the backup file in tmp directory
            tar -zxvf "$BACKUP_FILE" -C "$TMP_PATH"

            # Make sure Saves with a different ID are removed before restoring the save
            rm -rf "$RESTORE_PATH/Saved/"

            # Move the backup file to the restore directory
            \cp -rf -f "$TMP_PATH/Saved/" "$RESTORE_PATH"
            log_info "Clean up the temporary directory."
            rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"
            log_success "Restore Complete"
            log_info "Please restart the container"
            exit 0
        else 
            log_error "The selected backup file does not exist."
            exit 1
        fi
    else
        log_warn "Abort the recovery."
        exit 1
    fi
else
    log_error "The selected backup file does not exist."
    exit 1
fi