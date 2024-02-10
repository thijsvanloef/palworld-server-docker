#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [ "${UPDATE_ON_BOOT}" = false ]; then
    LogWarn "Update on Boot needs to be enabled for auto updating"
    DiscordMessage "Update on Boot needs to be enabled for auto updating" "warn"
    exit 0
fi

temp_file=$(mktemp)
http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_2394010.acf)
TARGET_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')
rm "$temp_file"

if [ "$http_code" -ne 200 ]; then
    LogError "There was a problem reaching the Steam api. Unable to check for updates!"
    DiscordMessage "There was a problem reaching the Steam api. Unable to check for updates!" "failure"
    exit 1
fi

if [ -z "$TARGET_MANIFEST" ]; then
    LogError "The server response does not contain the expected BuildID. Unable to check for updates!"
    DiscordMessage "Steam servers response does not contain the expected BuildID. Unable to check for updates!" "failure"
    exit 1
fi

if [ "CURRENT_MANIFEST" = "$TARGET_MANIFEST" ]; then
    LogSuccess "The Server is up to date!"
    exit 0
fi

if [ "${RCON_ENABLED,,}" = false ]; then
    LogError "An update is available however auto updating without rcon is not supported"
    DiscordMessage "An update is available however auto updating without rcon is not supported" "warn"
    exit 1
fi


if [ "$(get_player_count)" -gt 0 ]; then
  LogAction "Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
  DiscordMessage "Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes"
  rcon-cli -c /home/steam/server/rcon.yaml "broadcast The_Server_will_update_in_${AUTO_UPDATE_WARN_MINUTES}_Minutes"
  sleep "${AUTO_UPDATE_WARN_MINUTES}m"
fi

rm /palworld/steamapps/appmanifest_2394010.acf
backup
rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"

