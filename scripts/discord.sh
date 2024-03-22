#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Defaults
DEFAULT_CONNECT_TIMEOUT=30
DEFAULT_MAX_TIMEOUT=30
DEFAULT_LEVEL="info"
DISCORD_BLUE=1127128
DISCORD_YELLOW=15258703
DISCORD_ORANGE=14177041
DISCORD_RED=14614528
DISCORD_GREEN=52224
DISCORD_FLAGS=0

# Parse arguments
TITLE=$1
MESSAGE=$2
LEVEL=$3
ENABLED=$4
URL=$5

if [ "$DISCORD_SUPPRESS_NOTIFICATIONS" = true ]; then
    DISCORD_FLAGS=4096
fi

if [ -n "${DISCORD_CONNECT_TIMEOUT}" ] && [[ "${DISCORD_CONNECT_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    CONNECT_TIMEOUT=$DISCORD_CONNECT_TIMEOUT
else
    LogWarn "CONNECT_TIMEOUT is not an integer, using default ${DEFAULT_CONNECT_TIMEOUT} seconds."
    CONNECT_TIMEOUT=$DEFAULT_CONNECT_TIMEOUT
fi

if [ -n "${DISCORD_MAX_TIMEOUT}" ] && [[ "${DISCORD_MAX_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    MAX_TIMEOUT=$DISCORD_MAX_TIMEOUT
else
    LogWarn "MAX_TIMEOUT is not an integer, using default ${DEFAULT_MAX_TIMEOUT} seconds."
    MAX_TIMEOUT=$DEFAULT_MAX_TIMEOUT
fi

if [ -n "${LEVEL}" ]; then
    case $LEVEL in
        info )
            COLOR=$DISCORD_BLUE
            ;;
        in-progress )
            COLOR=$DISCORD_YELLOW
            ;;
        warn )
            COLOR=$DISCORD_ORANGE
            ;;
        failure )
            COLOR=$DISCORD_RED
            ;;
        success )
            COLOR=$DISCORD_GREEN
            ;;
        * )
            LogWarn "Could not find \"${LEVEL}\", using \"${DEFAULT_LEVEL}\""
            COLOR=$DISCORD_BLUE
            ;;
    esac
else
    COLOR=$DISCORD_BLUE
fi

JSON=$(jo embeds[]="$(jo title="$TITLE" description="$MESSAGE" color=$COLOR)" flags="$DISCORD_FLAGS")

if [ "$ENABLED" = true ]; then
    if [ "$URL" == "" ]; then
        DISCORD_URL="$DISCORD_WEBHOOK_URL"
    else
        DISCORD_URL="$URL"
    fi
    LogInfo "Sending Discord json: ${JSON}"
    curl -sfSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIMEOUT" -H "Content-Type: application/json" -d "$JSON" "$DISCORD_URL"
fi
