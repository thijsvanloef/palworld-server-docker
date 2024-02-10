#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

dirExists "/palworld" || exit
isWritable "/palworld" || exit
isExecutable "/palworld" || exit

LogAction "GENERATING CONFIGS"

./compile-settings.sh || exit

cd /palworld || exit

# Get the architecture using dpkg
architecture=$(dpkg --print-architecture)

# Get host kernel page size
kernel_page_size=$(getconf PAGESIZE)

# Check kernel page size for arm64 hosts before running steamcmd
if [ "$architecture" == "arm64" ] && [ "$kernel_page_size" != "4096" ]; then
    LogError "Only ARM64 hosts with 4k page size is supported."
    exit 1
fi

# Locked Version Install Based On Steam Depot Manifest ID
if [ -n "${DEPOT_MANIFEST_ID}" ]; then
    locked_manifest_id="${DEPOT_MANIFEST_ID}"
    current_manifest_id=0
    if [ -e /palworld/steamapps/appmanifest_2394010.acf ]; then
      mapfile -t manifest_ids < <(awk '/manifest/{ print $2 }' /palworld/steamapps/appmanifest_2394010.acf | tr -d '"')
      current_manifest_id=${manifest_ids[1]} # 0 is steamworks SDK
    fi
    if [ "$locked_manifest_id" != "$current_manifest_id" ]; then
      LogAction "Locking Game Version to Manifest ID $locked_manifest_id"
      /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +download_depot 2394010 2394012 "$locked_manifest_id" +quit
      if ! fileExists /home/steam/steamcmd/linux32/steamapps/content/app_2394010/depot_2394012/; then
        LogError "DOWNLOAD OF REQUESTED MANIFEST ID $locked_manifest_id FAILED!"
        exit 1
      fi

      cp -vr "/home/steam/steamcmd/linux32/steamapps/content/app_2394010/depot_2394012/." "/palworld/"
      CreateACFFile "$locked_manifest_id"
    fi
fi

if [ -z "${DEPOT_MANIFEST_ID}" ] && [ "${UPDATE_ON_BOOT,,}" = true ]; then
    if [ -e /palworld/steamapps/appmanifest_2394010.acf ]; then
      LogAction "UPDATING TO LATEST VERSION"
    else
      LogAction "INSTALLING LATEST VERSION"
    fi

    if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" ]; then
        /home/steam/server/discord.sh "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" "in-progress" &
    fi

    /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

    if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" ]; then
        /home/steam/server/discord.sh "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" "success"
    fi
fi

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
    LogError "Could Not Start Server. Try restarting with UPDATE_ON_BOOT=true"
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
    LogInfo "BACKUP_ENABLED=${BACKUP_ENABLED,,}"
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" >> "/home/steam/server/crontab"
fi

if [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    LogInfo "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED,,}"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash /usr/local/bin/update" >> "/home/steam/server/crontab"
fi

if [ "${AUTO_REBOOT_ENABLED,,}" = true ] && [ "${RCON_ENABLED,,}" = true ]; then
    LogInfo "AUTO_REBOOT_ENABLED=${AUTO_REBOOT_ENABLED,,}"
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

LogAction "STARTING SERVER"
if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_PRE_START_MESSAGE}" ]; then
    /home/steam/server/discord.sh "${DISCORD_PRE_START_MESSAGE}" "success" &
fi

echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

if [ -n "${DISCORD_WEBHOOK_URL}" ] && [ -n "${DISCORD_POST_SHUTDOWN_MESSAGE}" ]; then
    /home/steam/server/discord.sh "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure"
fi

exit 0
