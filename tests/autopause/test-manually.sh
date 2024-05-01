#!/bin/bash
# Even if the server is in a PAUSE state, communication will continue on its behalf
# so that it does not disappear from the community server list.
# If the communication content changes in a future version update,
# Use this script to make the fix.

CNAME="palworld-server"

function down()
{
    docker logs "${CNAME}" > last.log 2>&1
    docker compose down
    tail last.log
}

trap 'down' SIGINT
set -x
docker compose up --build
