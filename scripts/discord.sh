#!/bin/bash

# Command usage
usage() {
cat << EOH
Usage: $0 [OPTION]... -i WEBHOOK_ID -c CONNECT_TIMEOUT -M MAX_TIMEOUT -m MESSAGE -l level
Post a discord message via a discord webhook. Webhook id and message are required to send a discord webhook. By default uses a 30s connect-timeout and 30s max-timeout and level is info.
A good example for discord json formatting is located here: https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html
Package requirement: curl

Examples:
    $0 -i 01234/56789 -c 30 -M 30 -m "Server is started!" -l success
    $0 --webhook-id  01234/56789 --connect-timeout 30 --max-timeout 30 --message "Server is started!" --level success

Options:
    -i, --webhook-id        The unique id that is used by discord to determine what server/channel/thread to post. ex: https://discord.com/api/webhooks/<your id>
    -c, --connect-timeout   The timeout for connecting to the discord webhook (Default: 30)
    -M, --max-timeout       The maximum time curl will wait for a response (Default: 30)
    -m, --message           The json message body sent to the discord webhook
    -l, --level             The level affects the color of the embeds sidebar, available choices are: info, in-progress, warn, failure, success (Default: info)
    -h, --help              Display help text and exit
EOH
}

# Defaults
RED='\033[0;31m'
NC='\033[0m'
REQ=2
REQ_FLAG=0
DEFAULT_CONNECT_TIMEOUT=30
DEFAULT_MAX_TIMEOUT=30
DEFAULT_LEVEL="info"
DISCORD_BLUE=1127128
DISCORD_YELLOW=15258703
DISCORD_ORANGE=14177041
DISCORD_RED=14614528
DISCORD_GREEN=52224

# Show usage if no arguments specified
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -i|--webhook-id )
            WEBHOOK_ID="$2"
            ((REQ_FLAG++))
            shift
            shift
            ;;
        -c|--connect-timeout )
            CONNECT_TIMEOUT="$2"
            shift
            shift
            ;;
        -M|--max-timeout )
            MAX_TIMEOUT="$2"
            shift
            shift
            ;;
        -m|--message )
            MESSAGE="$2"
            ((REQ_FLAG++))
            shift
            shift
            ;;
        -l|--level )
            LEVEL="$2"
            shift
            shift
            ;;
        -h|--help )
            usage
            exit 0
            ;;
        * )
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}"

# Check required options
if [ $REQ_FLAG -lt $REQ ]; then
    printf "%b\n" "${RED}webhook-id and message are required${NC}"
    usage
    exit 1
fi

if [ -n "${CONNECT_TIMEOUT}" ] && [[ "${CONNECT_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    CONNECT_TIMEOUT=$DISCORD_CONNECT_TIMEOUT
else
    echo "CONNECT_TIMEOUT is not an integer, using default ${DEFAULT_CONNECT_TIMEOUT} seconds."
    CONNECT_TIMEOUT=$DEFAULT_CONNECT_TIMEOUT
fi

if [ -n "${MAX_TIMEOUT}" ] && [[ "${MAX_TIMEOUT}" =~ ^[0-9]+$ ]]; then
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

# Set discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/$WEBHOOK_ID"

JSON=$(jo embeds[]="$(jo title="$MESSAGE" color=$COLOR)")
echo "Sending Discord json: ${JSON}"
curl -sfSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIMEOUT" -H "Content-Type: application/json" -d "$JSON" "$DISCORD_WEBHOOK"
