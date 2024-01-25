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

sed -i "s/DedicatedServerName=.*/DedicatedServerName=${MIGRATION_SERVER_NAME}/" ./palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini

echo "########## STARTING CONTAINER ${CONTAINER_NAME} NOW ##########"
docker start "${CONTAINER_ID}"


