#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

get_steamid(){
    local player_info="${1}"
    echo "${player_info: -17}"
}

get_playername(){
    local player_info="${1}"
    echo "${player_info}" | sed -E 's/,([0-9]+),[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]//g'
}

old_player_list=( )
while true; do
    mapfile -t server_pids < <(pgrep PalServer-Linux)
    if [ "${#server_pids[@]}" -ne 0 ]; then
        # Player IDs are usally 9 or 10 digits however when a player joins for the first time for a given boot their ID is temporary 00000000 (8x zeros) while loading
        # Player ID is also 00000000 (8x zeros) when in character creation
        mapfile -t new_player_list < <( get_players_list | sed '/,00000000,[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/d' )
        # No players
        if [ "${#new_player_list[@]}" -gt 0 ] && [ "${#old_player_list[@]}" -gt 0 ]; then
            mapfile -t players_change_list < <( comm -23  \
                <(printf '%s\n' "${old_player_list[@]}" | sort) \
                <(printf '%s\n' "${new_player_list[@]}" | sort) )

        # All have joined
        elif [ "${#new_player_list[@]}" -gt 0 ]; then
            players_change_list=("${new_player_list[@]}")
        # All have left
        elif [ "${#old_player_list[@]}" -gt 0 ]; then 
            players_change_list=("${old_player_list[@]}")
        fi

        for player in "${players_change_list[@]}"; do
            player_steamid=$(get_steamid "${player}")
            for new_player in "${new_player_list[@]}"; do
                new_player_steamid=$(get_steamid "${new_player}")
                # If a new player then a change
                if [ "$new_player_steamid" = "$player_steamid" ]; then
                    player_name=$( get_playername "${player}" )
                    LogInfo "${player_name} has joined"
                    broadcast_command "${player_name} has joined"
                    continue 2
                fi
            done
            for old_player in "${old_player_list[@]}"; do
                old_player_steamid=$(get_steamid "${old_player}")
                # If an old player then no change
                if [ "$old_player_steamid" = "$player_steamid" ]; then
                    player_name=$( get_playername "${player}" )
                    LogInfo "${player_name} has left"
                    broadcast_command "${player_name} has left"
                    continue 2
                fi
            done
        done
        old_player_list=("${new_player_list[@]}")
    fi
    sleep "${PLAYER_LOGGING_POLL_PERIOD}"
done
