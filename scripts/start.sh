#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Helper Functions for installation & updates
# shellcheck source=scripts/helper_install.sh
source "/home/steam/server/helper_install.sh"

dir_exists "/palworld" || exit
is_writable "/palworld" || exit
is_executable "/palworld" || exit

cd /palworld || exit

# Get the architecture using dpkg
architecture=$(dpkg --print-architecture)

if [ "$architecture" == "arm64" ] && [ "${ARM_COMPATIBILITY_MODE,,}" = true ]; then
    log_info "ARM compatibility mode enabled"
    export DEBUGGER="/usr/bin/qemu-i386-static"

    # Arbitrary number to avoid CPU_MHZ warning due to qemu and steamcmd
    export CPU_MHZ=2000
fi

is_installed
ServerInstalled=$?
if [ "$ServerInstalled" == 1 ]; then
    log_info "Server installation not detected."
    log_action "Starting Installation"
    install_server
fi

# Update Only If Already Installed
if [ "$ServerInstalled" == 0 ] && [ "${UPDATE_ON_BOOT,,}" == true ]; then
    update_required
    IsUpdateRequired=$?
    if [ "$IsUpdateRequired" == 0 ]; then
        log_action "Starting Update"
        install_server
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
            log_info "Using Box64 for 8k pagesize"
            box64_binary="box64-8k"
            ;;
        16384)
            log_info "Using Box64 for 16k pagesize"
            box64_binary="box64-16k"
            ;;
        65536)
            log_info "Using Box64 for 64k pagesize"
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
if ! file_exists "${STARTCOMMAND[0]}"; then
    log_error "Server Not Installed Properly"
    exit 1
fi

is_readable "${STARTCOMMAND[0]}" || exit
is_executable "${STARTCOMMAND[0]}" || exit

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
  log_action "GENERATING CONFIG"
  log_warn "Env vars will not be applied due to DISABLE_GENERATE_SETTINGS being set to TRUE!"

  # shellcheck disable=SC2143
  if [ ! "$(grep -s '[^[:space:]]' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)" ]; then
      log_action "GENERATING CONFIG"
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
  log_action "GENERATING CONFIG"
  log_info "Using Env vars to create PalWorldSettings.ini"
  /home/steam/server/compile-settings.sh || exit
fi

if [ "${DISABLE_GENERATE_ENGINE,,}" = false ]; then
    /home/steam/server/compile-engine.sh || exit
fi
log_action "GENERATING CRONTAB"
truncate -s 0  "/home/steam/server/crontab"
if [ "${BACKUP_ENABLED,,}" = true ]; then
    log_info "BACKUP_ENABLED=${BACKUP_ENABLED,,}"
    log_info "Adding cronjob for auto backups"
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    log_info "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED,,}"
    log_info "Adding cronjob for auto updating"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash /usr/local/bin/update" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if [ "${AUTO_REBOOT_ENABLED,,}" = true ] && [ "${RCON_ENABLED,,}" = true ]; then
    log_info "AUTO_REBOOT_ENABLED=${AUTO_REBOOT_ENABLED,,}"
    log_info "Adding cronjob for auto rebooting"
    echo "$AUTO_REBOOT_CRON_EXPRESSION bash /home/steam/server/auto_reboot.sh" >> "/home/steam/server/crontab"
    supercronic -quiet -test "/home/steam/server/crontab" || exit
fi

if { [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT,,}" = true ]; } || [ "${BACKUP_ENABLED,,}" = true ] || \
    [ "${AUTO_REBOOT_ENABLED,,}" = true ]; then
    supercronic "/home/steam/server/crontab" &
    log_info "Cronjobs started"
else
    log_info "No Cronjobs found"
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

log_action "Starting Server"
discord_message "Start" "${DISCORD_PRE_START_MESSAGE}" "success" "${DISCORD_PRE_START_MESSAGE_ENABLED}" "${DISCORD_PRE_START_MESSAGE_URL}"

echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

discord_message "Stop" "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure" "${DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_POST_SHUTDOWN_MESSAGE_URL}"
exit 0
