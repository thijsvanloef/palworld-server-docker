#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f .env ]; then
    read -r -p "STEAM_USERNAME: " STEAM_USERNAME
    echo "STEAM_USERNAME=${STEAM_USERNAME}" > .env
fi

docker compose config --environment | grep STEAM_USERNAME || {
    echo "STEAM_USERNAME is not set in .env"
    exit 1
}

docker compose run --rm -i palworld steam-login "$@"
docker network prune -f
