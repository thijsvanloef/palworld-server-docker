#!/bin/bash

# Backup file directory path
BACKUP_DIRECTORY_PATH="/palworld/backups"

# Resotre path
RESTORE_PATH="/palworld/Pal"

term_error_handler() {
    echo "An error occurred during server shutdown."
    exit 1
}

term_handler() {
  trap 'term_error_handler' ERR

  printf "\e[0;32m*****SHUTDOWN SERVER*****\e[0m\n"
  if [ "${RCON_ENABLED}" = true ]; then
      rcon-cli save
      rcon-cli "shutdown 1"
  else
      kill -SIGTERM "$(pidof PalServer-Linux)"
  fi
  # 프로세스가 종료될 때까지 대기
  tail --pid="$(pidof PalServer-Linux)" -f 2>/dev/null

  printf "\e[0;32mShutdown complete.\e[0m\n"
  trap - ERR
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

start_restore() {
  trap 'restore_error_handler' ERR
  # Shutdown server
  # term_handler
  printf "\e[0;32m*****START RESTORE*****\e[0m\n"

  # Recheck the backup file
  if [ -f "$BACKUP_DIRECTORY_PATH/$FILE_NAME" ]; then
    ls
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
    tar -zxvf "$BACKUP_DIRECTORY_PATH/$FILE_NAME" -C "./tmp"

    # Move the backup file to the restore directory
    \cp -rf -f "./tmp/Saved/" "$RESTORE_PATH"

    # Remove tmp directory
    rm -rf "./tmp"
    rm -rf "./tmp_save"

    printf "\e[0;32mRestore complete!!!! Please restart the Docker container\e[0m\n"

    exit 0
  else 
    echo "The selected backup file does not exist."
    exit 1
  fi

  trap - ERR
}

# Go to backup file directory
cd "$BACKUP_DIRECTORY_PATH"

# Show up backup list
echo "Backup List:"
select FILE_NAME in *; do
    if [ -n "$FILE_NAME" ]; then
        echo "Selected backup: $FILE_NAME"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

if [ -f "$BACKUP_DIRECTORY_PATH/$FILE_NAME" ]; then
  echo "Do you want to continue with the command?"
  read -rp "When you run it, the server will be stopped and the recovery will proceed. (y/n): " RUN_ANSWER
  if [[ $RUN_ANSWER == "y" ]] || [[ $RUN_ANSWER == "Y" ]]; then
    printf "\e[0;32m*****STARTING PROCESS*****\e[0m\n"
      start_restore
  else
      echo "Abort the recovery."
      exit 1
  fi
else
    echo "The selected backup file does not exist."
    exit 1
fi
