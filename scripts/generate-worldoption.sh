#!/bin/bash

error_msg="Error: POST request to WorldOption generator failed with HTTP status code"
no_directory_msg="Saved game not found! This is expected if it is your first time running the container. Restart the container after it initializes the save folder to generate a WorldOption file."
world_option_msg="WorldOption will not be generated. PalWorldSettings.ini will apply."

# Remove existing WorldOption.sav
rm -f /palworld/Pal/Saved/SaveGames/0/*/WorldOption.sav

if [ "${GENERATE_WORLD_OPTION,,}" = true ]; then
    echo "Generating WorldOption.sav..."

    # Take variables inside OptionSettings
    variables=$(echo "$1" | sed 's/OptionSettings=\(.*\)/\1/' | tr -d '()')

    # Transforming variables into splitable form
    encoded_data=$(echo "$variables" | tr -d '"' | tr ',' '&')

    # Split the string into an array using '&' as the delimiter
    IFS='&' read -r -a settings_pairs <<< "$encoded_data"
    
    # Declare an associative array to store key-value pairs
    declare -A settings_array
    
    # Iterate over the array of key-value pairs and populate the associative array
    for pair in "${settings_pairs[@]}"; do
        IFS='=' read -r key value <<< "$pair"
        settings_array["$key"]="$value"
    done

    savegames_directory="/palworld/Pal/Saved/SaveGames/0/"

    # Find generated directory within /palworld/Pal/Saved/SaveGames/0/
    target_directory=$(find "$savegames_directory" -mindepth 1 -maxdepth 1 -type d -print -quit)

    if [ -d "$savegames_directory" ] && [ -d "$target_directory" ]; then
        # Temporary file to store response
        response_file=$(mktemp)
    
    	curl_command="curl -s -X POST -H \"Content-Type: application/x-www-form-urlencoded\""
    
        # Generate data for curl
        for key in "${!settings_array[@]}"; do
            # Replace boolean to integers
            value=$(echo "${settings_array[$key]}" | sed 's/true/1/gI; s/false/0/gI')
            curl_command+=" --data-urlencode \"$key=$value\""
        done
    
    	curl_command+=" -o \"$response_file\" -w \"%{http_code}\""
    	curl_command+=" \"https://palworldoptions.com/generate\""
        # Send POST request with curl
        curl_output=$(eval "$curl_command")

        # Extract HTTP status code from curl output
        http_status_code=${curl_output: -3}

        # Check if HTTP status code is 201
        if [ "$http_status_code" -eq 201 ]; then
            echo "WorldOption generator request successful."

            mv "$response_file" "$target_directory/WorldOption.sav"

            echo "WorldOption.sav generated: $target_directory/WorldOption.sav"
            echo "Generating WorldOption.sav done!"
        else
            echo "$error_msg: $http_status_code"
            echo "$world_option_msg"
        fi
    else
        echo "$no_directory_msg"
        echo "$world_option_msg"
    fi
fi
