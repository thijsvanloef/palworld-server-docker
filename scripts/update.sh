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

if [ "$CURRENT_MANIFEST" != "$TARGET_MANIFEST" ]; then
    if [ "${RCON_ENABLED,,}" != true ]; then
        echo "An update is available however auto updating without rcon is not supported"
        if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
            /home/steam/server/discord.sh "An update is available however auto updating without rcon is not supported" "warn"
        fi
        exit 0
    fi

    echo "An update is available"
    if [[ "${AUTO_UPDATE_WARN_MINUTES}" =~ ^[0-9]+$ ]]; then
        DiscordMessage "Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes"
    fi
    if countdown_message "${AUTO_UPDATE_WARN_MINUTES}" "Server_will_update"; then
        LogAction "Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
        rm /palworld/steamapps/appmanifest_2394010.acf

        backup
        shutdown_server
    elif [ -z "${AUTO_UPDATE_WARN_MINUTES}" ]; then
        echo "Unable to auto update, the server is not empty and AUTO_UPDATE_WARN_MINUTES is empty."
    else
        echo "Unable to auto update, the server is not empty and AUTO_UPDATE_WARN_MINUTES is not an integer: ${AUTO_UPDATE_WARN_MINUTES}"
    fi
else
    echo "The Server is up to date!"
fi
