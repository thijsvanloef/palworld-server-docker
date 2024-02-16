#!/bin/bash
# shellcheck source=/dev/null
source "/home/steam/server/helper_functions.sh"

if [ "${UPDATE_ON_BOOT}" = false ]; then
    echo "Update on Boot needs to be enabled for auto updating"
    if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
        /home/steam/server/discord.sh "Update on Boot needs to be enabled for auto updating" "warn"
    fi
    exit 0
fi

temp_file=$(mktemp)
http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_2394010.acf)
TARGET_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')
rm "$temp_file"

if [ "$http_code" -ne 200 ]; then
    echo "There was a problem reaching the Steam api. Unable to check for updates!"
    if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
        /home/steam/server/discord.sh "There was a problem reaching the Steam api. Unable to check for updates!" "failure" &
    fi
    exit 1
fi

if [ -z "$TARGET_MANIFEST" ]; then
    echo "The server response does not contain the expected BuildID. Unable to check for updates!"
    if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
        /home/steam/server/discord.sh "Steam servers response does not contain the expected BuildID. Unable to check for updates!" "failure" &
    fi
    exit 1
fi
echo "player count: $(get_player_count)"
if [ "$CURRENT_MANIFEST" != "$TARGET_MANIFEST" ]; then
    if [ "${RCON_ENABLED,,}" != true ]; then
        echo "An update is available however auto updating without rcon is not supported"
        if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
            /home/steam/server/discord.sh "An update is available however auto updating without rcon is not supported" "warn"
        fi
        exit 0
    fi

    if [ -z "${AUTO_UPDATE_WARN_MINUTES}" ]; then
        echo "Unable to auto update, AUTO_UPDATE_WARN_MINUTES is empty."
    elif [[ "${AUTO_UPDATE_WARN_MINUTES}" =~ ^[0-9]+$ ]]; then
        echo "New Build was found. Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
        rm /palworld/steamapps/appmanifest_2394010.acf

        if [ "$(get_player_count)" -gt 0 ]; then
            if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
                /home/steam/server/discord.sh "Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes" "info" &
            fi
            countdown_message "${AUTO_UPDATE_WARN_MINUTES}" "Server_will_update_in"
        fi
        backup
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    else
        echo "Unable to auto update, AUTO_UPDATE_WARN_MINUTES is not an integer: ${AUTO_UPDATE_WARN_MINUTES}"
    fi
else
    echo "The Server is up to date!"
fi
