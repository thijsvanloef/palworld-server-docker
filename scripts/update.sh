#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [ "${UPDATE_ON_BOOT}" = false ]; then
    echo "Update on Boot needs to be enabled for auto updating"
    exit 0
fi

temp_file=$(mktemp)
http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_2394010.acf)
TARGET_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')
rm "$temp_file"

if [ "$http_code" -ne 200 ]; then
    echo "There was a problem reaching the Steam api. Unable to check for updates!"
    exit 1
fi

if [ -z "$TARGET_MANIFEST" ]; then
    echo "The server response does not contain the expected BuildID. Unable to check for updates!"
    exit 1
fi
echo "player count: $(get_player_count)"
if [ "$CURRENT_MANIFEST" != "$TARGET_MANIFEST" ]; then
    if [ "${RCON_ENABLED,,}" != true ]; then
        echo "An update is available however auto updating without rcon is not supported"
        exit 0
    fi
    echo "New Build was found. Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
    rm /palworld/steamapps/appmanifest_2394010.acf

    if [ "$(get_player_count)" -gt 0 ]; then
        rcon-cli -c /home/steam/server/rcon.yaml "broadcast Server_will_update_in_${AUTO_UPDATE_WARN_MINUTES}_Minutes"
        sleep "${AUTO_UPDATE_WARN_MINUTES}m"
    fi
    backup
    rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
else
    echo "The Server is up to date!"
fi