#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Helper Functions for installation & updates
# shellcheck source=scripts/helper_install.sh
source "/home/steam/server/helper_install.sh"

dirExists "/palworld" || exit
isWritable "/palworld" || exit
isExecutable "/palworld" || exit

cd /palworld || exit

# Get the architecture using dpkg
architecture=$(dpkg --print-architecture)

if [ "$architecture" == "arm64" ] && [ "${ARM_COMPATIBILITY_MODE,,}" = true ]; then
    LogInfo "ARM compatibility mode enabled"
    export DEBUGGER="/usr/bin/qemu-i386-static"

    # Arbitrary number to avoid CPU_MHZ warning due to qemu and steamcmd
    export CPU_MHZ=2000
fi

IsInstalled
ServerInstalled=$?
if [ "$ServerInstalled" == 1 ]; then
    LogInfo "Server installation not detected."
    LogAction "Starting Installation"
    InstallServer
fi

# Update Only If Already Installed
if [ "$ServerInstalled" == 0 ] && [ "${UPDATE_ON_BOOT,,}" == true ]; then
    UpdateRequired
    IsUpdateRequired=$?
    if [ "$IsUpdateRequired" == 0 ]; then
        LogAction "Starting Update"
        InstallServer
    fi
fi

# Check if the architecture is arm64
if [ "$architecture" == "arm64" ]; then
    # create an arm64 version of ./PalServer.sh
    cp ./PalServer.sh ./PalServer-arm64.sh

    pagesize=$(getconf PAGESIZE)
    box64_binary="box64"

    case $pagesize in
        8192)
            LogInfo "Using Box64 for 8k pagesize"
            box64_binary="box64-8k"
            ;;
        16384)
            LogInfo "Using Box64 for 16k pagesize"
            box64_binary="box64-16k"
            ;;
        65536)
            LogInfo "Using Box64 for 64k pagesize"
            box64_binary="box64-64k"
            ;;
    esac
    
    sed -i "s|\(\"\$UE_PROJECT_ROOT\/Pal\/Binaries\/Linux\/PalServer-Linux-Test\" Pal \"\$@\"\)|LD_LIBRARY_PATH=/home/steam/steamcmd/linux64:\$LD_LIBRARY_PATH $box64_binary \1|" ./PalServer-arm64.sh
    chmod +x ./PalServer-arm64.sh
    STARTCOMMAND=("./PalServer-arm64.sh")
else
    STARTCOMMAND=("./PalServer.sh")
fi


#Validate Installation
if ! fileExists "${STARTCOMMAND[0]}"; then
    LogError "Server Not Installed Properly"
    exit 1
fi

isReadable "${STARTCOMMAND[0]}" || exit
isExecutable "${STARTCOMMAND[0]}" || exit

# Prepare Arguments
if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${QUERY_PORT}" ]; then
    STARTCOMMAND+=("-queryport=${QUERY_PORT}")
fi

if [ "${COMMUNITY,,}" = true ]; then
    STARTCOMMAND+=("-publiclobby")
fi

if [ "${MULTITHREADING,,}" = true ]; then
    STARTCOMMAND+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

# fix bug and enable rcon for v0.1.5.0 only
if [ "${TARGET_MANIFEST_ID}" == "3750364703337203431" ] && [ "${RCON_ENABLED,,}" = true ]; then
    STARTCOMMAND+=("-rcon")
fi

if [ "${DISABLE_GENERATE_SETTINGS,,}" = true ]; then
  LogAction "GENERATING CONFIG"
  LogWarn "Env vars will not be applied due to DISABLE_GENERATE_SETTINGS being set to TRUE!"

  # shellcheck disable=SC2143
  if [ ! "$(grep -s '[^[:space:]]' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)" ]; then
      LogAction "GENERATING CONFIG"
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
else
  LogAction "GENERATING CONFIG"
  LogInfo "Using Env vars to create PalWorldSettings.ini"
  /home/steam/server/compile-settings.sh || exit
fi

if [ "${DISABLE_GENERATE_ENGINE,,}" = false ]; then
    /home/steam/server/compile-engine.sh || exit
fi
LogAction "GENERATING CRONTAB"
truncate -s 0  "/home/steam/server/crontab"
if [ "${BACKUP_ENABLED,,}" = true ]; then
    LogInfo "BACKUP_ENABLED=${BACKUP_ENABLED,,}"
    LogInfo "Adding cronjob for auto backups"
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    LogInfo "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED,,}"
    LogInfo "Adding cronjob for auto updating"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash /usr/local/bin/update" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if [ "${AUTO_REBOOT_ENABLED,,}" = true ] && [ "${RCON_ENABLED,,}" = true ]; then
    LogInfo "AUTO_REBOOT_ENABLED=${AUTO_REBOOT_ENABLED,,}"
    LogInfo "Adding cronjob for auto rebooting"
    echo "$AUTO_REBOOT_CRON_EXPRESSION bash /home/steam/server/auto_reboot.sh" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if { [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT,,}" = true ]; } || [ "${BACKUP_ENABLED,,}" = true ] || \
    [ "${AUTO_REBOOT_ENABLED,,}" = true ]; then
    supercronic "/home/steam/server/crontab" &
    LogInfo "Cronjobs started"
else
    LogInfo "No Cronjobs found"
fi

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: "${ADMIN_PASSWORD}"
EOL

if [ "${ENABLE_PLAYER_LOGGING,,}" = true ] && [[ "${PLAYER_LOGGING_POLL_PERIOD}" =~ ^[0-9]+$ ]] && [ "${RCON_ENABLED,,}" = true ]; then
    if [[ "$(id -u)" -eq 0 ]]; then
        su steam -c /home/steam/server/player_logging.sh &
    else
        /home/steam/server/player_logging.sh &
    fi
fi

LogAction "Starting Server"
DiscordMessage "Start" "${DISCORD_PRE_START_MESSAGE}" "success" "${DISCORD_PRE_START_MESSAGE_ENABLED}" "${DISCORD_PRE_START_MESSAGE_URL}"

echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

DiscordMessage "Stop" "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure" "${DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_POST_SHUTDOWN_MESSAGE_URL}"
exit 0

# Temporarily adding here before we determine where in the sequence it should be added

# Read the local version from the VERSION file
current_version=$(head -n 1 /home/steam/server/VERSION)

# Query GitHub API to get the latest tag version
latest_version=$(curl -s "https://api.github.com/repos/thijsvanloef/palworld-server-docker/releases/latest" | grep -oP '"tag_name": "\K[^"]+')

# Check if the local version is older than the latest version and link to documentation if not
if [[ "$current_version" != "$latest_version" ]]; then
    echo "Your container image is outdated. Current Version is ${current_version}, Latest version is v${latest_version}."
    echo -e "See '\e]8;;https://palworld-server-docker.loef.dev/guides/updating-container\ahttps://palworld-server-docker.loef.dev/guides/updating-container\e]8;;\a' for instructions on how to update."
fi
