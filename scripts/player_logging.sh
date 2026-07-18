#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"
# shellcheck source=scripts/autopause/services.sh
source "/home/steam/server/autopause/services.sh"

get_platform(){
    # <name>,<player_id>,(steam|ps5|xbox)_<id>
    local player_info="${1}"
    echo "${player_info}" | sed -E 's/.*,([0-9a-zA-Z]+)_([0-9A-Z]+)$/\1/'
}

get_playername(){
    local player_info="${1}"
    echo "${player_info}" | sed -E 's/,[0-9A-Z]+,[[:alnum:]_]+$//'
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
LogInfo "${_LABEL}(${_PORT}) port is open, player logging started"

AutoPause_init
while true; do
    server_pid=$(pidof PalServer-Linux-Shipping)
    if [ -n "${server_pid}" ]; then
        # Player IDs are usally 9 or 10 digits however when a player joins for the first time for a given boot their ID is temporary 00000000 (8x zeros or 32x zeros) while loading
        # Player ID is also 00000000 (8x zeros or 32x zeros) when in character creation
        online_players="$(get_players_list | tail -n +2)"
        mapfile -t current_player_list < <( echo -n "${online_players}" | sed -E '/,(0{8}|0{32}),\w+/d' | sort )
        mapfile -t current_no_id_list < <( echo -n "${online_players}" | sed -n -E '/,(0{8}|0{32}),\w+/p' | sort)

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
            player_platform=$( get_platform "${player}" )
            LogInfo "${player_name} (${player_platform}) has left"
            broadcast_command "${player_name} (${player_platform}) has left"

	        # Replace ${player_name} with actual player's name
            msg="${DISCORD_PLAYER_LEAVE_MESSAGE//player_name/${player_name}}"
            msg="${msg//player_platform/${player_platform}}"
            DiscordMessage "Player Left" "${msg}" "failure" "${DISCORD_PLAYER_LEAVE_MESSAGE_ENABLED}" "${DISCORD_PLAYER_LEAVE_MESSAGE_URL}"
        done

        # Notify Discord and log all players who have joined
        for player in "${players_who_joined_list[@]}"; do
            player_name=$( get_playername "${player}" )
            player_platform=$( get_platform "${player}" )
            LogInfo "${player_name} (${player_platform}) has joined"
            broadcast_command "${player_name} (${player_platform}) has joined"

            # Replace ${player_name} with actual player's name
            msg="${DISCORD_PLAYER_JOIN_MESSAGE//player_name/${player_name}}"
            msg="${msg//player_platform/${player_platform}}"
            DiscordMessage "Player Joined" "${msg}" "success" "${DISCORD_PLAYER_JOIN_MESSAGE_ENABLED}" "${DISCORD_PLAYER_JOIN_MESSAGE_URL}"
        done

        old_player_list=("${current_player_list[@]}")
        players_who_left_list=( )
        players_who_joined_list=( )
        AutoPause_main
    else
        break
    fi
    sleep "${PLAYER_LOGGING_POLL_PERIOD}"
    AutoPause_addTimer "${PLAYER_LOGGING_POLL_PERIOD}"
done
AutoPause_end
