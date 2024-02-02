#!/bin/bash

# Backup file directory path
BACKUP_DIRECTORY_PATH="/palworld/backups"

# Resotre path
RESTORE_PATH="/palworld/Pal"

# Copy the save file before restore temporary path
TMP_SAVE_PATH="/palworld/backups/restore-"$(date +"%Y-%m-%d_%H-%M-%S")

# shellcheck disable=SC2317
term_error_handler() {
    echo "An error occurred during server shutdown."
    exit 1
}

# shellcheck disable=SC2317
restore_error_handler() {
    printf "\033[0;31mAn error occurred during restore.\033[0m\n"
    if [ -d "$TMP_SAVE_PATH/Saved" ]; then
        read -rp "I have a backup before recovery can proceed. Do you want to recovery it? (y/n): " RUN_ANSWER
        if [[ ${RUN_ANSWER,,} == "y" ]]; then
            rm -rf "$RESTORE_PATH/Saved"
            mv "$TMP_SAVE_PATH/Saved" "$RESTORE_PATH"
            printf "\e[0;32mRecovery complete.\e[0m\n"
        fi
    fi

    echo "Clean up the temporary directory."
    rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"

    exit 1
}

if [ "${RCON_ENABLED}" != true ]; then
    echo "RCON is not enabled. Please enable RCON to use this feature."
    exit 1
fi

# Show up backup list
echo "Backup List:"
mapfile -t BACKUP_FILES < <(find "$BACKUP_DIRECTORY_PATH" -type f -name "*.tar.gz" | sort)
select BACKUP_FILE in "${BACKUP_FILES[@]}"; do
    if [ -n "$BACKUP_FILE" ]; then
        echo "Selected backup: $BACKUP_FILE"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

if [ -f "$BACKUP_FILE" ]; then
    printf "\033[0;31mThis script has been designed to help you restore; however, I am not responsible for any data loss. It is recommended that you create a backup beforehand, and in the event of script failure, be prepared to restore it manually.\033[0m\n"
    echo "Do you understand the above and would you like to proceed with this command?"
    read -rp "When you run it, the server will be stopped and the recovery will proceed. (y/n): " RUN_ANSWER
    if [[ ${RUN_ANSWER,,} == "y" ]]; then
        printf "\e[0;32m*****STARTING PROCESS*****\e[0m\n"
        # Shutdown server
        trap 'term_error_handler' ERR

        if [ "${RCON_ENABLED}" = true ]; then
            printf "\e[0;32m*****SHUTDOWN SERVER*****\e[0m\n"
            rcon-cli -c /home/steam/server/rcon.yaml save
            rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
        else
            echo "RCON is not enabled. Please enable RCON to use this feature. Unable to restore backup."
            exit 1
        fi
        printf "\e[0;32mShutdown complete.\e[0m\n"

        trap - ERR

        trap 'restore_error_handler' ERR
        
        printf "\e[0;32m*****START RESTORE*****\e[0m\n"

        # Recheck the backup file
        if [ -f "$BACKUP_FILE" ]; then
            # Copy the save file before restore
            if [ -d "$RESTORE_PATH/Saved" ]; then
                echo "Saves the current state before the restore proceeds."
                echo "$TMP_SAVE_PATH"
                mkdir -p "$TMP_SAVE_PATH"
                if [ "$(id -u)" -eq 0 ]; then
                    chown steam:steam "$TMP_SAVE_PATH"
                fi
                \cp -rf "$RESTORE_PATH/Saved" "$TMP_SAVE_PATH/Saved"

                while [ ! -d "$TMP_SAVE_PATH/Saved" ]; do
                    sleep 1
                done

                printf "\e[0;32mSave complete.\e[0m\n"
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

            echo "Clean up the temporary directory."
            rm -rf "$TMP_PATH" "$TMP_SAVE_PATH"

            printf "\e[0;32mRestore complete!!!! Please restart the Docker container\e[0m\n"
            
            exit 0
        else 
            echo "The selected backup file does not exist."
            exit 1
        fi
    else
        echo "Abort the recovery."
        exit 1
    fi
else
    echo "The selected backup file does not exist."
    exit 1
fi