#!/bin/bash

dirExists() {
    local path="$1"
    local return_val=0
    if ! [ -d "${path}" ]; then
        echo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

fileExists() {
    local path="$1"
    local return_val=0
    if ! [ -f "${path}" ]; then
        echo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

isReadable() {
    local path="$1"
    local return_val=0
    if ! [ -e "${path}" ]; then
        echo "${path} is not readable."
        return_val=1
    fi
    return "$return_val"
}

isWritable() {
    local path="$1"
    local return_val=0
    if ! [ -w "${path}" ]; then
        echo "${path} is not writable."
        return_val=1
    fi
    return "$return_val"
}

isExecutable() {
    local path="$1"
    local return_val=0
    if ! [ -x "${path}" ]; then
        echo "${path} is not executable."
        return_val=1
    fi
    return "$return_val"
}

dirExists "/palworld" || exit
isWritable "/palworld" || exit
isExecutable "/palworld" || exit


if [ "${DISABLE_GENERATE_SETTINGS,,}" = false ]; then
  printf "\e[0;32m*****GENERATING CONFIGS*****\e[0m\n"
  ./compile-settings.sh
else
  printf "\e[0;32m%s\e[0m\n" "*****CHECKING FOR EXISTING CONFIG*****"

  # shellcheck disable=SC2143
  if [ ! "$(grep -s '[^[:space:]]' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)" ]; then

      printf "\e[0;32m%s\e[0m\n" "*****GENERATING CONFIG*****"

      # Server will generate all ini files after first run.
      if [ "$architecture" == "arm64" ]; then
          timeout --preserve-status 15s ./PalServer-arm64.sh 1> /dev/null
      else
          timeout --preserve-status 15s ./PalServer.sh 1> /dev/null
      fi

      # Wait for shutdown
      sleep 5
      cp /palworld/DefaultPalWorldSettings.ini /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
  fi
fi

cd /palworld || exit

if [ "${UPDATE_ON_BOOT,,}" = true ]; then
    printf "\e[0;32m%s\e[0m\n" "*****STARTING INSTALL/UPDATE*****"

    if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" ]; then
        /home/steam/server/discord.sh "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" "in-progress" &
    fi

    /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

    if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" ]; then
        /home/steam/server/discord.sh "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" "success"
    fi
fi

# Get the architecture using dpkg
architecture=$(dpkg --print-architecture)
# Check if the architecture is arm64
if [ "$architecture" == "arm64" ]; then
    # create an arm64 version of ./PalServer.sh
    cp ./PalServer.sh ./PalServer-arm64.sh
    # shellcheck disable=SC2016
    sed -i 's|\("$UE_PROJECT_ROOT\/Pal\/Binaries\/Linux\/PalServer-Linux-Test" Pal "$@"\)|LD_LIBRARY_PATH=/home/steam/steamcmd/linux64:$LD_LIBRARY_PATH box64 \1|' ./PalServer-arm64.sh
    chmod +x ./PalServer-arm64.sh
    STARTCOMMAND=("./PalServer-arm64.sh")
else
    STARTCOMMAND=("./PalServer.sh")
fi

if ! fileExists "${STARTCOMMAND[0]}"; then
    echo "Try restarting with UPDATE_ON_BOOT=true"
    exit 1
fi
isReadable "${STARTCOMMAND[0]}" || exit
isExecutable "${STARTCOMMAND[0]}" || exit

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${QUERY_PORT}" ]; then
    STARTCOMMAND+=("-queryport=${QUERY_PORT}")
fi

if [ "${COMMUNITY,,}" = true ]; then
    STARTCOMMAND+=("EpicApp=PalServer")
fi

if [ "${MULTITHREADING,,}" = true ]; then
    STARTCOMMAND+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

rm -f  "/home/steam/server/crontab"
if [ "${BACKUP_ENABLED,,}" = true ]; then
    echo "BACKUP_ENABLED=${BACKUP_ENABLED,,}"
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" >> "/home/steam/server/crontab"
fi

if [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    echo "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED,,}"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash /usr/local/bin/update" >> "/home/steam/server/crontab"
fi

if [ "${AUTO_REBOOT_ENABLED,,}" = true ] && [ "${RCON_ENABLED,,}" = true ]; then
    echo "AUTO_REBOOT_ENABLED=${AUTO_REBOOT_ENABLED,,}"
    echo "$AUTO_REBOOT_CRON_EXPRESSION bash /home/steam/server/auto_reboot.sh" >> "/home/steam/server/crontab"
fi

if { [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT,,}" = true ]; } || [ "${BACKUP_ENABLED,,}" = true ] || \
    [ "${AUTO_REBOOT_ENABLED,,}" = true ]; then
    supercronic "/home/steam/server/crontab" &
fi

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: "${ADMIN_PASSWORD}"
EOL

printf "\e[0;32m%s\e[0m\n" "*****STARTING SERVER*****"
if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_PRE_START_MESSAGE}" ]; then
    /home/steam/server/discord.sh "${DISCORD_PRE_START_MESSAGE}" "success" &
fi

echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_POST_SHUTDOWN_MESSAGE}" ]; then
    /home/steam/server/discord.sh "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure"
fi

exit 0
