#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Helper Functions for installation & updates
# shellcheck source=scripts/helper_install.sh
source "/home/steam/server/helper_install.sh"

UpdateRequired
updateRequired=$?
# Check if Update was actually required
if [ "$updateRequired" != 0 ]; then
  exit 0
fi

if [ "${UPDATE_ON_BOOT,,}" != true ]; then
    LogWarn "An update is available however, UPDATE_ON_BOOT needs to be enabled for auto updating"
    DiscordMessage "Update" "An update is available however, UPDATE_ON_BOOT needs to be enabled for auto updating" "warn"
    exit 1
fi

if [ "${RCON_ENABLED,,}" != true ]; then
    LogWarn "An update is available however auto updating without rcon is not supported"
    DiscordMessage "Update" "An update is available however auto updating without rcon is not supported" "warn"
    exit 1
fi

if [[ "${AUTO_UPDATE_WARN_MINUTES}" =~ ^[0-9]+$ ]]; then
    DiscordMessage "Update" "Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes"
fi

countdown_message "${AUTO_UPDATE_WARN_MINUTES}" "Server will update"
countdown_exit_code=$?
case "${countdown_exit_code}" in
    0 )
        LogAction "Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
        rm /palworld/steamapps/appmanifest_2394010.acf

        backup
        shutdown_server
        ;;
    1 )
        LogWarn "Unable to auto update, the server is not empty and AUTO_UPDATE_WARN_MINUTES is empty."
        exit 1
        ;;
    2 )
        LogWarn "Unable to auto update, the server is not empty and AUTO_UPDATE_WARN_MINUTES is not an integer: ${AUTO_UPDATE_WARN_MINUTES}"
        exit 1
        ;;
esac
