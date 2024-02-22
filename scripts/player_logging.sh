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
        mapfile -t new_player_list < <( get_players_list | tail -n +2 | sed '/,00000000,[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/d' )
        
        # See players whose states have changed
        mapfile -t players_change_list < <( printf '%s\n' "${old_player_list[@]}" "${new_player_list[@]}" | sort | uniq -u )

        # Go through the list of changes
        for player in "${players_change_list[@]}"; do
            # Steam ID to check since names are not unique in game
            player_steamid=$(get_steamid "${player}")

            # Searching players who have joined
            for new_player in "${new_player_list[@]}"; do
                new_player_steamid=$(get_steamid "${new_player}")
                # If in new player list then they joined
                if [ "$new_player_steamid" = "$player_steamid" ]; then
                    player_name=$( get_playername "${player}" )
                    LogInfo "${player_name} has joined"
                    broadcast_command "${player_name} has joined"
                    continue 2
                fi
            done

            # Searching players who have left
            for old_player in "${old_player_list[@]}"; do
                old_player_steamid=$(get_steamid "${old_player}")
                # If in old player list then they left
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
