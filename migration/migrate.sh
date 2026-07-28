#!/bin/bash
set -e

CONTAINER_NAME=$1
MIGRATION_SERVER_NAME=$2

if [ ! -d ./"${MIGRATION_SERVER_NAME}" ]; then
  echo "can not find ${MIGRATION_SERVER_NAME} dir at current dir"
  exit 1
fi

if [ ! -d ./palworld ]; then
  echo "can not find palworld dir at current dir"
  exit 1
fi

CONTAINER_ID=$(docker ps --filter name="${CONTAINER_NAME}" --format '{{.ID}}')

echo "########## STOPPING CONTAINER ${CONTAINER_NAME} NOW ##########"
docker stop "${CONTAINER_ID}"

cp -r ./"${MIGRATION_SERVER_NAME}" ./palworld/Pal/Saved/SaveGames/0/"${MIGRATION_SERVER_NAME}"/

# A WorldOption.sav carried over from a save that was ever played on Windows takes
# priority over PalWorldSettings.ini and silently blocks the new server's settings
# (including AdminPassword) from applying -- see #886. Move it aside rather than
# deleting it outright, so it's still recoverable if needed.
WORLD_OPTION_SAV="./palworld/Pal/Saved/SaveGames/0/${MIGRATION_SERVER_NAME}/WorldOption.sav"
if [ -f "${WORLD_OPTION_SAV}" ]; then
  echo "########## MOVING ASIDE WorldOption.sav (see #886) ##########"
  mv "${WORLD_OPTION_SAV}" "${WORLD_OPTION_SAV}.bak"
fi

sed -i "s/DedicatedServerName=.*/DedicatedServerName=${MIGRATION_SERVER_NAME}/" ./palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini

echo "########## STARTING CONTAINER ${CONTAINER_NAME} NOW ##########"
docker start "${CONTAINER_ID}"


