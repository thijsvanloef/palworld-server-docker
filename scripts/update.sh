#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = false ]; then
    echo "Update on Boot needs to be enabled for auto updating"
    exit 1
fi

CURRENTBUILD=$(awk '/buildid/{ print $2 }' < palworld/steamapps/appmanifest_2394010.acf)
TARGETBUILD=$(curl https://api.steamcmd.net/v1/info/2394010 --silent | grep -P '"public": {"buildid": "\d+"' -o | sed -r 's/.*("[0-9]+")$/\1/')

if [ "$CURRENTBUILD" != "$TARGETBUILD" ]; then
    echo "New Build was found. Updating the server from $CURRENTBUILD to $TARGETBUILD."
    if [ "${RCON_ENABLED}" = true ]; then
        rm /palworld/steamapps/appmanifest_2394010.acf
        rcon-cli -c /home/steam/server/rcon.yaml "broadcast The_Server_will_update_in_${WARN_MINUTES}_Minutes"
        sleep "${WARN_MINUTES}m"
        backup
        rcon-cli -c /home/steam/server/rcon.yaml "shutdown 1"
    else
        echo "An update is available however auto updating without rcon is not supported"
    fi
else
    echo "The Server is up to date!"
fi