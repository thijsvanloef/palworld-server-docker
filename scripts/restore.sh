#!/bin/bash
source "/home/steam/server/helper_functions.sh"

# Backup file directory path
BACKUP_DIRECTORY_PATH="/palworld/backups"

# Resotre path
RESTORE_PATH="/palworld/Pal"

# Copy the save file before restore temporary path
TMP_SAVE_PATH="/palworld/backups/restore-"$(date +"%Y-%m-%d_%H-%M-%S")

# shellcheck disable=SC2317
term_error_handler() {
    LogError "An error occurred during server shutdown."
    exit 1
}

# shellcheck disable=SC2317
restore_error_handler() {
    LogError "An error occurred during restore"
    if [ -d "$TMP_SAVE_PATH/Saved" ]; then
        read -rp "I have a backup before recovery can proceed. Do you want to recovery it? (y/n): " RUN_ANSWER
        if [[ ${RUN_ANSWER,,} == "y" ]]; then
            rm -rf "$RESTORE_PATH/Saved"
            mv "$TMP_SAVE_PATH/Saved" "$RESTORE_PATH"
            LogSuccess "Recovery complete!"
        fi
    fi

    LogInfo "Clean up the temporary directory."
    rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"

    exit 1
}

if [ "${RCON_ENABLED}" != true ]; then
    LogError "RCON is not enabled. Please enable RCON to use this feature."
    exit 1
fi

# Show up backup list
LogInfo "Backup List:"
mapfile -t BACKUP_FILES < <(find "$BACKUP_DIRECTORY_PATH" -type f -name "*.tar.gz" | sort)
select BACKUP_FILE in "${BACKUP_FILES[@]}"; do
    if [ -n "$BACKUP_FILE" ]; then
        LogInfo "Selected backup: $BACKUP_FILE"
        break
    else
        LogError "Invalid selection. Please try again."
    fi
done

if [ -f "$BACKUP_FILE" ]; then
    printf "\033[0;31mThis script has been designed to help you restore; however, I am not responsible for any data loss. It is recommended that you create a backup beforehand, and in the event of script failure, be prepared to restore it manually.\033[0m\n"
    echo "Do you understand the above and would you like to proceed with this command?"
    read -rp "When you run it, the server will be stopped and the recovery will proceed. (y/n): " RUN_ANSWER
    if [[ ${RUN_ANSWER,,} == "y" ]]; then
        LogAction "STARTING PROCESS"
        # Shutdown server
        trap 'term_error_handler' ERR

        if [ "${RCON_ENABLED}" = true ]; then
            LogAction "SHUTDOWN SERVER"
            rcon-cli -c /home/steam/server/rcon.yaml save
            rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
        else
            LogError "RCON is not enabled. Please enable RCON to use this feature. Unable to restore backup."
            exit 1
        fi
        LogSuccess "Shutdown complete."

        trap - ERR

        trap 'restore_error_handler' ERR

        LogAction "START RESTORE"

        # Recheck the backup file
        if [ -f "$BACKUP_FILE" ]; then
            # Copy the save file before restore
            if [ -d "$RESTORE_PATH/Saved" ]; then
                LogInfo "Saves the current state before the restore proceeds."
                LogInfo "$TMP_SAVE_PATH"
                mkdir -p "$TMP_SAVE_PATH"
                if [ "$(id -u)" -eq 0 ]; then
                    chown steam:steam "$TMP_SAVE_PATH"
                fi
                \cp -rf "$RESTORE_PATH/Saved" "$TMP_SAVE_PATH/Saved"

                while [ ! -d "$TMP_SAVE_PATH/Saved" ]; do
                    sleep 1
                done

                LogSuccess "Save Complete"
            fi
            
            # Create tmp directory
            TMP_PATH=$(mktemp -d -p "/palworld/backups")
            if [ "$(id -u)" -eq 0 ]; then
                chown steam:steam "$TMP_PATH"
            fi
            
            # Decompress the backup file in tmp directory
            tar -zxvf "$BACKUP_FILE" -C "$TMP_PATH"

            # Move the backup file to the restore directory
            \cp -rf -f "$TMP_PATH/Saved/" "$RESTORE_PATH"

            LogInfo "Clean up the temporary directory."
            rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"

            LogSuccess "Restore Complete!"
            LogInfo "Please Restart the container"
            exit 0
        else 
            LogError "The selected backup file does not exist."
            exit 1
        fi
    else
        LogError "Abort the recovery."
        exit 1
    fi
else
    LogError "The selected backup file does not exist."
    exit 1
fi