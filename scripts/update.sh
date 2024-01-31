#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = false ]; then
    echo "Update on Boot needs to be enabled for auto updating"
    exit 0
fi

temp_file=$(mktemp)
http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

CURRENTBUILD=$(awk '/buildid/{ print $2 }' < /palworld/steamapps/appmanifest_2394010.acf)
TARGETBUILD=$(grep -P '"public": {"buildid": "\d+"' -o <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')
rm "$temp_file"

if [ "$http_code" -ne 200 ]; then
    echo "There was a problem reaching the Steam api. Unable to check for updates!"
    exit 1
fi

if [ -z "$TARGETBUILD" ]; then
    echo "The server response does not contain the expected BuildID. Unable to check for updates!"
    exit 1
fi

if [ "$CURRENTBUILD" != "$TARGETBUILD" ]; then
    echo "New Build was found. Updating the server from $CURRENTBUILD to $TARGETBUILD."
    if [ "${RCON_ENABLED}" = true ]; then
        rm /palworld/steamapps/appmanifest_2394010.acf
        rcon-cli -c /home/steam/server/rcon.yaml "broadcast The_Server_will_update_in_${AUTO_UPDATE_WARN_MINUTES}_Minutes"
        sleep "${AUTO_UPDATE_WARN_MINUTES}m"
        backup
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    else
        echo "An update is available however auto updating without rcon is not supported"
    fi
else
    echo "The Server is up to date!"
fi