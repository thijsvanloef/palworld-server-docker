#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# shellcheck source=scripts/negative_delta_recovery.sh
source "/home/steam/server/negative_delta_recovery.sh"

if ! ValidateNegativeDeltaRecoverySetting; then
    LogError "PALWORLD_ALLOW_NEGATIVE_DELTA_TIME must be true or false."
    exit 1
fi

mkdir -p /palworld/backups

init_steam_home() {
    # Redirect Steam home to persistent volume.
    local steam_org_home="/home/steam/Steam"
    local steam_new_home="/palworld/.steam"
    if [ ! -L "${steam_org_home}" ] && [ -d "${steam_org_home}" ]; then
        if [ ! -d "${steam_new_home}" ]; then
            LogInfo "Redirecting Steam home from ${steam_org_home} to ${steam_new_home}"
            mkdir -p "${steam_new_home}"
            cp -av "${steam_org_home}/." "${steam_new_home}/" 2>/dev/null || true
        else
            LogInfo "Steam home already redirected to ${steam_new_home}"
        fi
        rm -rf "${steam_org_home}"
        ln -sfn "${steam_new_home}" "${steam_org_home}"
    elif [ ! -e "${steam_org_home}" ]; then
        LogInfo "Creating Steam home at ${steam_new_home} and linking to ${steam_org_home}"
        mkdir -p "${steam_new_home}"
        ln -sfn "${steam_new_home}" "${steam_org_home}"
    elif [ -L "${steam_org_home}" ] && [ -d "${steam_new_home}" ]; then
        LogInfo "Steam home already redirected to ${steam_new_home}"
    else
        LogError "Unexpected state: ${steam_org_home} is a symlink but ${steam_new_home} does not exist or is not a directory."
        exit 1
    fi
}

if [[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]; then
    if [[ "${PUID}" -ne 0 ]] && [[ "${PGID}" -ne 0 ]]; then
        LogAction "EXECUTING USERMOD"
        usermod -o -u "${PUID}" steam
        groupmod -o -g "${PGID}" steam

        init_steam_home

        chown -R steam:steam /palworld /home/steam/
        # NOTE: The recursive chown above covers ${PalServerLog_fifo} under /home/steam,
        # so an explicit second chown/chmod for the FIFO is not required.
        # Fix Wine prefix top-level ownership (O(1), non-recursive).
        # Wine refuses to use a prefix whose directory is not owned by the running user.
        if [ -d "${WINEPREFIX:-/opt/wine}" ]; then
            chown "steam:wine" "${WINEPREFIX:-/opt/wine}" 2>/dev/null \
                || chown "steam:steam" "${WINEPREFIX:-/opt/wine}" 2>/dev/null || true
        fi
    else
        LogError "Running as root is not supported, please fix your PUID and PGID!"
        exit 1
    fi
elif [[ "$(id -u)" -eq 0 ]] || [[ "$(id -g)" -eq 0 ]]; then
   LogError "Running as root is not supported, please fix your user!"
   exit 1
fi

if ! [ -w "/palworld" ]; then
    LogError "/palworld is not writable."
    exit 1
fi

if [ "${1}" = "steam-login" ]; then
    shift
    exec steam-login "$@"
fi

if [ "${LOG_FILTER_ENABLED,,}" = true ]; then
    # Recreate FIFO at every boot to avoid stale descriptors and permission drift.
    rm -f "${PalServerLog_fifo}"

    if ! mkfifo -m 600 "${PalServerLog_fifo}"; then
        echo "ERROR: Failed to create log FIFO: ${PalServerLog_fifo}" >&2
        exit 1
    fi

    # Keep FIFO owned by steam so child processes can always write.
    if [[ "$(id -u)" -eq 0 ]]; then
        if ! chown steam:steam "${PalServerLog_fifo}"; then
            echo "ERROR: Failed to set log FIFO owner to steam:steam" >&2
            exit 1
        fi
    fi

    exec > >(python3 /home/steam/server/pal_logger.py) 2>&1
fi

# shellcheck source=scripts/autopause/init.sh
source "/home/steam/server/autopause/init.sh"

# shellcheck disable=SC2317,SC2329
term_handler() {
    autopause stop "term_handler"

  DiscordMessage "Shutdown" "${DISCORD_PRE_SHUTDOWN_MESSAGE}" "in-progress" "${DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_PRE_SHUTDOWN_MESSAGE_URL}"

    if ! shutdown_server; then
        # Does not save
        if server_pid="$(PalworldServerPid)"; then
            kill -SIGTERM "${server_pid}"
        fi
    fi

    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c ./start.sh &
else
    ./start.sh &
fi
# Process ID of su
killpid="$!"
wait "$killpid"
child_rc=$?

mapfile -t backup_pids < <(pgrep backup)
if [ "${#backup_pids[@]}" -ne 0 ]; then
    LogInfo "Waiting for backup to finish"
    for pid in "${backup_pids[@]}"; do
        tail --pid="$pid" -f 2>/dev/null
    done
fi

mapfile -t restore_pids < <(pgrep restore)
if [ "${#restore_pids[@]}" -ne 0 ]; then
    LogInfo "Waiting for restore to finish"
    for pid in "${restore_pids[@]}"; do
        tail --pid="$pid" -f 2>/dev/null
    done
fi

exit "$child_rc"
