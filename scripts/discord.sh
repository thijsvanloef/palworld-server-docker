#!/bin/bash

# Command usage
usage() {
cat << EOH
Usage: $0 [OPTION]... -d WEBHOOK_ID -t TIMEOUT -j JSON
Post a discord message via a discord webhook. By default uses a 30s connect-timeout. Webhook id an json are required. A good example for discord json formatting is located here: https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html
Package requirement: curl

Examples:
    $0 -i 01234/56789 -t 30 -l info -j {"username":"Palworld","content":"Server starting..."}
    $0 --webhook-id  01234/56789 --timeout 30 --level info --json {"username":"Palworld","content":"Server starting..."}

Options:
    -i, --webhook-id    The unique id that is used by discord to determine what server/channel/thread to post. ex: https://discord.com/api/webhooks/<your id>
    -t, --timeout       The timeout for connecting to the discord webhook (Default: 30)
    -j, --json          The json message body sent to the discord webhook
    -h, --help          Display help text and exit
EOH
}

# DISCORD_WEBHOOK
# DISCORD_USER
# DISCORD_TIMEOUT
# NICE_SHUTDOWN_TIME

# Defaults
RED='\033[0;31m'
NC='\033[0m'
REQ=2
REQ_FLAG=0
TIMEOUT=30

# # Decimal Colors
# INFO=1127128 # blue
# IN_PROGRESS=15258703 # yellow
# WARN=14177041 # orange
# FAILURE=14614528 # red
# SUCCESS=52224 # green

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
        -t|--timeout )
            TIMEOUT="$2"
            shift
            shift
            ;;
        -j|--json )
            JSON="$2"
            ((REQ_FLAG++))
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
    printf "%s\n" "${RED}webhook-id and json are required${NC}"
    usage
    exit 1
fi

# Set discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/$WEBHOOK_ID"
echo "Sending Discord json: ${JSON}"
curl -sfSL --connect-timeout "$TIMEOUT" -H "Content-Type: application/json" -d "$JSON" "$DISCORD_WEBHOOK"

# # Log into AWS CLI if not already logged in
# check-aws-login

# # Set AWS Profile for following aws commands
# export AWS_PROFILE=$PROFILE

# if [ -n "$SERVICE_NAME" ]; then
#     # Get arn of service
#     SERVICE_LIST=$(aws ecs describe-services --cluster $CLUSTER --services $SERVICE_NAME | jq --raw-output '.services[].serviceArn')
# else
#     # Get list of ECS service on cluster
#     SERVICE_LIST=$(aws ecs list-services --cluster $CLUSTER | jq --raw-output '.serviceArns[]')
# fi

# for SERVICE in $SERVICE_LIST; do
#     SERVICE_NAME=$(cut -d/ -f2 <<< $SERVICE)
#     TASK_DEF=$(aws ecs describe-services --cluster $CLUSTER --services $SERVICE_NAME | jq --raw-output '.services[].taskDefinition')

#     # Outputs the list of endpoints slightly formatted
#     echo "Service $SERVICE_NAME:"
#     aws ecs describe-task-definition --task-definition $TASK_DEF | jq -c '.taskDefinition.containerDefinitions[].environment[] | select(.value | contains("'$ELB_PREFIX'"))' | sed 's/{\"name\":\"/\t/; s/\",\"value\":\"/ = /; s/\"}//'
# done
