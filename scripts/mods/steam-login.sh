#!/bin/bash
# usage:
# A) If compose.yaml does not exist:
#    docker run --rm -it -v /path/to/palworld:/palworld thijsvanloef/palworld-server-docker:latest steam-login [username]
# B) If compose.yaml exists:
#    docker compose run --rm -i palworld steam-login [username]
# C) If the container is already running:
#    docker exec -itu steam palworld-server steam-login [username]

set -euo pipefail

# If running as root, switch to the steam user
if [ "$(id -u)" -eq 0 ]; then
  exec su steam -c "$0 $*"
fi

STEAM_HOME="/palworld/.steam"
STEAM_LOGIN_USER_FILE="${STEAM_HOME}/.steam-login-user"

# The /palworld/.steam directory must exist.
if [ ! -d "${STEAM_HOME}" ]; then
  echo "ERROR: ${STEAM_HOME} directory does not exist."
  echo "Please mount your Palworld server directory to /palworld in the container."
  exit 1
fi

case "${1:-}" in
  --reset)
    echo "Wiping existing Steam session volume: ${STEAM_HOME}"
    rm -rf "${STEAM_HOME}/config/*.vdf" "${STEAM_LOGIN_USER_FILE}" 2>/dev/null || true
    exit 0
    ;;
  --help)
    echo "Usage: docker run --rm -it -v /path/to/palworld:/palworld thijsvanloef/palworld-server-docker:latest steam-login [username]"
    echo "Options:"
    echo "  --reset   Wipe existing Steam session volume and exit."
    echo "  --help    Show this help message and exit."
    exit 0
    ;;
  *)
    STEAM_USERNAME="${1:-${STEAM_USERNAME:-}}"
    STEAM_PASSWORD="${2:-${STEAM_PASSWORD:-}}"
    ;;
esac

# The STEAM_USERNAME environment variable must be set.
if [ -z "${STEAM_USERNAME:-}" ] || [ "${STEAM_USERNAME}" = "anonymous" ]; then
  echo "Please set STEAM_USERNAME to your Steam account name."
  exit 1
fi

mkdir -p "${STEAM_HOME}"

echo "Steam session volume: ${STEAM_HOME}"
echo "Logging in to Steam as: ${STEAM_USERNAME}"
if [ -n "${STEAM_PASSWORD:-}" ]; then
  echo "Using provided Steam password."
else
  echo "No Steam password provided. You will be prompted to enter it interactively."
fi
LOGIN_PARAMS=("+login" "${STEAM_USERNAME}" "${STEAM_PASSWORD:-}" "+quit")
/home/steam/steamcmd/steamcmd.sh "${LOGIN_PARAMS[@]}"

printf '%s\n' "${STEAM_USERNAME}" > "${STEAM_LOGIN_USER_FILE}"

echo
echo "Steam session is ready."
echo "Saved login user file: ${STEAM_LOGIN_USER_FILE}"
exit 0
