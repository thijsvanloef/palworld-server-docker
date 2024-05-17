#!/bin/bash
SCRIPT_DIR=${SCRIPT_DIR:-$(dirname "$(readlink -fn "${0}")")}
#shellcheck source=scripts/helper_functions.sh
source "${SCRIPT_DIR}/helper_functions.sh"
#shellcheck source=scripts/helper_autopause.sh
source "${SCRIPT_DIR}/helper_autopause.sh"

get_steamid(){
    local player_info="${1}"
    echo "${player_info: -17}"
}

get_playername(){
    local player_info="${1}"
    echo "${player_info}" | sed -E 's/,([0-9A-Z]+),[0-9]+//g'
}

# Prefer REST API
if [ "${REST_API_ENABLED,,}" = true ]; then
    _PORT=${REST_API_PORT}
    _LABEL="REST API"
else
    _PORT=${RCON_PORT}
    _LABEL="RCON"
fi

# Wait until rcon/rest-api port is open
while ! nc -z localhost "${_PORT}"; do
    sleep 5
    LogInfo "Waiting for ${_LABEL}(${_PORT}) port to open to show player logging..."
done

AutoPause_init

while true; do
    server_pid=$(pidof PalServer-Linux-Shipping)
    if [ -n "${server_pid}" ]; then
        # Player IDs are usally 9 or 10 digits however when a player joins for the first time for a given boot their ID is temporary 00000000 (8x zeros or 32x zeros) while loading
        # Player ID is also 00000000 (8x zeros or 32x zeros) when in character creation
        online_players="$(get_players_list | tail -n +2)"
        mapfile -t current_player_list < <( echo -n "${online_players}" | sed -E '/,(0{8}|0{32}),[0-9]+/d' | sort )
        mapfile -t current_no_id_list < <( echo -n "${online_players}" | sed -n -E '/,(0{8}|0{32}),[0-9]+/p' | sort)

        # Players still loading or creating characters
        if [ "${#current_no_id_list[@]}" -gt 0 ]; then
            AutoPause_resetTimer
        fi

        # If there are current players then some may have joined
        if [ "${#current_player_list[@]}" -gt 0 ]; then
            # Get list of players who have joined
            mapfile -t players_who_joined_list < <( comm -13 \
                <(printf '%s\n' "${old_player_list[@]}") \
                <(printf '%s\n' "${current_player_list[@]}") )
            AutoPause_resetTimer
        fi

        # If there are old players then some may have left
        if [ "${#old_player_list[@]}" -gt 0 ]; then
            # Get list of players who have left
            mapfile -t players_who_left_list < <( comm -23 \
                <(printf '%s\n' "${old_player_list[@]}") \
                <(printf '%s\n' "${current_player_list[@]}") )
        fi

        # Notify Discord and log all players who have left
        for player in "${players_who_left_list[@]}"; do
            player_name=$( get_playername "${player}" )
            LogInfo "${player_name} has left"
            broadcast_command "${player_name} has left"

            # Replace ${player_name} with actual player's name
            DiscordMessage "Player Left" "${DISCORD_PLAYER_LEAVE_MESSAGE//player_name/${player_name}}" "failure" "${DISCORD_PLAYER_LEAVE_MESSAGE_ENABLED}" "${DISCORD_PLAYER_LEAVE_MESSAGE_URL}"
        done

        # Notify Discord and log all players who have joined
        for player in "${players_who_joined_list[@]}"; do
            player_name=$( get_playername "${player}" )
            LogInfo "${player_name} has joined"
            broadcast_command "${player_name} has joined"

            # Replace ${player_name} with actual player's name
            DiscordMessage "Player Joined" "${DISCORD_PLAYER_JOIN_MESSAGE//player_name/${player_name}}" "success" "${DISCORD_PLAYER_JOIN_MESSAGE_ENABLED}" "${DISCORD_PLAYER_JOIN_MESSAGE_URL}"
        done

        old_player_list=("${current_player_list[@]}")
        players_who_left_list=( )
        players_who_joined_list=( )

        if AutoPause_checkTimer; then
            # Safely pause the server when it is not writing files.
            if AutoPause_challengeToPause; then
                # paused
                AutoPause_waitWakeup # Block until player logs in or receives REST API or RCON
                # wake up
                AutoPause_resetTimer
            fi
        fi
    fi
    sleep "${PLAYER_LOGGING_POLL_PERIOD}"
    AutoPause_addTimer "${PLAYER_LOGGING_POLL_PERIOD}"
done
