#!/bin/bash

# Defaults
DEFAULT_CONNECT_TIMEOUT=30
DEFAULT_MAX_TIMEOUT=30
DEFAULT_LEVEL="info"
DISCORD_BLUE=1127128
DISCORD_YELLOW=15258703
DISCORD_ORANGE=14177041
DISCORD_RED=14614528
DISCORD_GREEN=52224

# Parse arguments
MESSAGE=$1
LEVEL=$2

if [ -n "${DISCORD_CONNECT_TIMEOUT}" ] && [[ "${DISCORD_CONNECT_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    CONNECT_TIMEOUT=$DISCORD_CONNECT_TIMEOUT
else
    echo "CONNECT_TIMEOUT is not an integer, using default ${DEFAULT_CONNECT_TIMEOUT} seconds."
    CONNECT_TIMEOUT=$DEFAULT_CONNECT_TIMEOUT
fi

if [ -n "${DISCORD_MAX_TIMEOUT}" ] && [[ "${DISCORD_MAX_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    MAX_TIMEOUT=$DISCORD_MAX_TIMEOUT
else
    echo "MAX_TIMEOUT is not an integer, using default ${DEFAULT_MAX_TIMEOUT} seconds."
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
            echo "Could not find \"${LEVEL}\", using \"${DEFAULT_LEVEL}\""
            COLOR=$DISCORD_BLUE
            ;;
    esac
else
    COLOR=$DISCORD_BLUE
fi

JSON=$(jo embeds[]="$(jo title="$MESSAGE" color=$COLOR)")
echo "Sending Discord json: ${JSON}"
curl -sfSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIMEOUT" -H "Content-Type: application/json" -d "$JSON" "$DISCORD_WEBHOOK_URL"
