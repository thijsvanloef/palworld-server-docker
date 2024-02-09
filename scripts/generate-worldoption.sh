#!/bin/bash

error_msg="Error: POST request to WorldOption generator failed with HTTP status code"
no_directory_msg="Saved game not found! This is expected if it is your first time running the container. Restart the container after it initializes the save folder to generate a WorldOption file."
world_option_msg="WorldOption will not be generated. PalWorldSettings.ini will apply."

if [ "${GENERATE_WORLD_OPTION,,}" = true ]; then
    echo "Generating WorldOption.sav..."

    # Take variables inside OptionSettings
    variables=$(echo "$1" | sed 's/OptionSettings=\(.*\)/\1/' | tr -d '()')

    # Transforming variables into URL encoded form data
    encoded_data=$(echo "$variables" | tr -d '"' | tr ',' '&' | sed 's/\([^=]*\)=\([^&]*\)/\1=\2/g')

    savegames_directory="/palworld/Pal/Saved/SaveGames/0/"

    if ! [ -d "$savegames_directory" ]; then
        echo "$no_directory_msg"
        echo "$world_option_msg"
        return
    fi

    # Find generated directory within /palworld/Pal/Saved/SaveGames/0/
    target_directory=$(find "$savegames_directory" -mindepth 1 -maxdepth 1 -type d -print -quit)

    if [ -d "$target_directory" ]; then
	# Delete existing WorldOption.sav to make sure the .ini config applies if generation fails.
        rm -f "$target_directory/WorldOption.sav"

        # Temporary file to store response
        response_file=$(mktemp)

        # Send POST request with curl
        curl_output=$(curl -s -X POST \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "$encoded_data" \
            -o "$response_file" \
            -w "%{http_code}" \
            "https://palworldoptions.com/generate")

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
