#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

UpdateRequired
updateRequired=$?
# Check if Update was actually required
if [ "$updateRequired" != 0 ]; then
  exit 0
fi

if [ "${UPDATE_ON_BOOT}" = false ]; then
    LogWarn "An update is available however, UPDATE_ON_BOOT needs to be enabled for auto updating"
    DiscordMessage "An update is available however, UPDATE_ON_BOOT needs to be enabled for auto updating" "warn"
    exit 1
fi

if [ "${RCON_ENABLED,,}" = false ]; then
    LogWarn "An update is available however auto updating without rcon is not supported"
    DiscordMessage "An update is available however auto updating without rcon is not supported" "warn"
    exit 1
fi

if [ "$(get_player_count)" -gt 0 ]; then
  LogAction "Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
  DiscordMessage "Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes"
  RCON "broadcast The_Server_will_update_in_${AUTO_UPDATE_WARN_MINUTES}_Minutes"
  sleep "${AUTO_UPDATE_WARN_MINUTES}m"
fi

rm /palworld/steamapps/appmanifest_2394010.acf
backup
RCON "shutdown 1"