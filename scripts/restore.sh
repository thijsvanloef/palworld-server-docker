#!/bin/bash

# Backup file directory path
BACKUP_DIRECTORY_PATH="/palworld/backups"

# Resotre path
RESTORE_PATH="/palworld/Pal"

term_error_handler() {
    echo "An error occurred during server shutdown."
    exit 1
}

restore_error_handler() {
    printf "\033[0;31mAn error occurred during restore.\033[0m\n"
    if [ -d "./tmp_save/Saved" ]; then
      read -rp "I have a backup before recovery can proceed. Do you want to recovery it? (y/n): " RUN_ANSWER
      if [[ $RUN_ANSWER == "y" ]] || [[ $RUN_ANSWER == "Y" ]]; then
        rm -rf "$RESTORE_PATH/Saved"
        mv "./tmp_save/Saved" "$RESTORE_PATH"
        printf "\e[0;32mRecovery complete.\e[0m\n"
      fi
    fi

    rm -rf "./tmp"
    rm -rf "./tmp_save"

    exit 1
}

if [ "${RCON_ENABLED}" != true ]; then
  echo "RCON is not enabled. Please enable RCON to use this feature."
  exit 1
fi

# Show up backup list
echo "Backup List:"
select BACKUP_FILE in "$BACKUP_DIRECTORY_PATH"/*; do
    if [ -n "$BACKUP_FILE" ]; then
        echo "Selected backup: $BACKUP_FILE"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

if [ -f "$BACKUP_FILE" ]; then
  echo "Do you want to continue with the command?"
  read -rp "When you run it, the server will be stopped and the recovery will proceed. (y/n): " RUN_ANSWER
  if [[ $RUN_ANSWER == "y" ]] || [[ $RUN_ANSWER == "Y" ]]; then
    printf "\e[0;32m*****STARTING PROCESS*****\e[0m\n"
    # Shutdown server
    trap 'term_error_handler' ERR

    printf "\e[0;32m*****SHUTDOWN SERVER*****\e[0m\n"
    if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli -c /home/steam/server/rcon.yaml save
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    else
        echo "RCON is not enabled. Please enable RCON to use this feature."
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
        rm -rf "./tmp_save"
        mkdir -p "./tmp_save"
        \cp -rf "$RESTORE_PATH/Saved" "./tmp_save/Saved"

        while [ ! -d "./tmp_save/Saved" ]; do
          sleep 1
        done

        printf "\e[0;32mSave complete.\e[0m\n"
      fi
      
      # Create tmp directory
      rm -rf "./tmp"
      mkdir -p "./tmp"
      
      # Decompress the backup file in tmp directory
      tar -zxvf "$BACKUP_FILE" -C "./tmp"

      # Move the backup file to the restore directory
      \cp -rf -f "./tmp/Saved/" "$RESTORE_PATH"

      # Remove tmp directory
      rm -rf "./tmp"
      rm -rf "./tmp_save"

      printf "\e[0;32mRestore complete!!!! Please restart the Docker container\e[0m\n"
      
      trap - ERR
      exit 0
    else 
      echo "The selected backup file does not exist."
      trap - ERR
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