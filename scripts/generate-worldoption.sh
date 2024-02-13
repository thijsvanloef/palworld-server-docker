#!/bin/bash

# Function to map out struct type of each config attributes
config_to_struct_type() {
    # Define struct type for each config attribute
    case "$1" in
        "DayTimeSpeedRate" | "NightTimeSpeedRate" | "ExpRate" | "PalCaptureRate" | "PalSpawnNumRate" | "PalDamageRateAttack" | \
        "PalDamageRateDefense" | "PlayerDamageRateAttack" | "PlayerDamageRateDefense" | "PlayerStomachDecreaceRate" | \
        "PlayerStaminaDecreaceRate"| "PlayerAutoHPRegeneRate" | "PlayerAutoHpRegeneRateInSleep" | "PalStomachDecreaceRate" | \
        "PalStaminaDecreaceRate" | "PalAutoHPRegeneRate" | "PalAutoHpRegeneRateInSleep" | "BuildObjectDamageRate" | \
        "BuildObjectDeteriorationDamageRate" | "CollectionDropRate" | "CollectionObjectHpRate" | "CollectionObjectRespawnSpeedRate" | \
        "EnemyDropItemRate" | "DropItemAliveMaxHours" | "GuildPlayerMaxNum" | "PalEggDefaultHatchingTime" | "WorkSpeedRate" | \
        "CoopPlayerMaxNum" | "ServerPlayerMaxNum" | "PublicPort" | "RCONPort" )
            echo "Float" # Floating point number
            ;;
        "DeathPenalty" )
            echo "Enum_DeathPenalty" # DeathPenalty Enums
            ;;
        "Difficulty" )
            echo "Enum_Difficulty" # Difficulty Enums
            ;;
        "DropItemMaxNum" | "DropItemMaxNum_UNKO" | "BaseCampMaxNum" | "BaseCampWorkerMaxNum" | "AutoResetGuildTimeNoOnlinePlayers" )
            echo "Int" # Integer
            ;;
        "bEnablePlayerToPlayerDamage" | "bEnableFriendlyFire" | "bEnableInvaderEnemy" | "bActiveUNKO" | "bEnableAimAssistPad" | \
        "bEnableAimAssistKeyboard" | "bAutoResetGuildNoOnlinePlayers" | "bIsMultiplay" | "bIsPvP" | \
        "bCanPickupOtherGuildDeathPenaltyDrop" | "bEnableNonLoginPenalty" | "bEnableFastTravel" | "bIsStartLocationSelectByMap" | \
        "bExistPlayerAfterLogout" | "bEnableDefenseOtherGuildPlayer" | "RCONEnabled" | "bUseAuth" )
            echo "Bool" # Boolean
            ;;
        "ServerName" | "ServerDescription" | "AdminPassword" | "ServerPassword" | "PublicIP" | "Region" | "BanListURL" )
            echo "Str" # String
            ;;
        *)
            echo "Unknown" # Unknown type
            ;;
    esac
}

# Function to convert option value based on struct type
type_cast() {
    local struct=$1
    local value=$2

    # Convert values based on struct type
    if [[ $struct == "Int" ]]; then
        # work around if the values are a float
        echo "${value%.*}"
    elif [[ $struct == "Float" ]]; then
        echo "$value"
    elif [[ $struct == "Bool" ]]; then
        lower_value=$(echo "$value" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_value" == "false" || "$value" == "0" ]]; then
            echo "false"
        else
            echo "true"
        fi
    elif [[ $struct == "Str" ]]; then
        echo "\"$value\""
    else
        echo "$value"
    fi
}

# Function to convert JSON struct based on struct type
json_struct() {
    local struct=$1
    local value=$2
    local struct_property="${struct}Property"

    if [[ $struct == "Unknown" ]]; then
        echo ""
    fi

    # Construct JSON struct based on struct type
    if [[ $struct == *"Enum"* ]]; then
        if [[ $struct == *"DeathPenalty"* ]]; then
            echo "{\"id\": null, \"value\": {\"value\": \"EPalOptionWorldDeathPenalty::$(type_cast "$struct" "$value")\", \"type\": \"EPalOptionWorldDeathPenalty\"}, \"type\": \"EnumProperty\"}"
        elif [[ $struct == *"Difficulty"* ]]; then
            echo "{\"id\": null, \"value\": {\"value\": \"EPalOptionWorldDifficulty::$(type_cast "$struct" "$value")\", \"type\": \"EPalOptionWorldDifficulty\"}, \"type\": \"EnumProperty\"}"
        fi
    else
        echo "{\"id\": null, \"value\": $(type_cast "$struct" "$value"), \"type\": \"$struct_property\"}"
    fi
}

# Function to generate JSON config
generate_json_config() {
    local json_config="{}"
    local config=${1//,/$'\n'}

    # Loop through each key-value pair
    while IFS='=' read -r key value; do
        if [[ "$value" == \"*\" ]]; then
            value="${value//\"/}"  # Remove quotes from value
        fi
        config_properties="$(json_struct "$(config_to_struct_type "$key")" "$value")"

        if [[ -n "$config_properties" ]]; then
            json_config=$(echo "$json_config" | jq --arg key "$key" --argjson config_properties "$config_properties" '.[$key] = $config_properties')
        fi
    done <<< "$config"

    echo "$json_config"
}

# Function to load Palworldsettings.ini
load_palworldsettings() {
    local path="$1"
    local config
    config=$(grep "OptionSettings" "$path")
    if [[ -z "$config" ]]; then
        echo "WorldOption Generator: Failed to get OptionSettings from PalWorldSettings.ini"
        exit 1
    fi
    config=$(echo "$config" | sed 's/OptionSettings=//; s/,$//' | tr -d '() ')
    echo "$config"
}

# Python script for converting JSON to .sav
convert_json_to_sav_python=$(
cat <<EOF
import sys
import json
from palworld_save_tools.gvas import GvasFile
from palworld_save_tools.palsav import compress_gvas_to_sav
from palworld_save_tools.paltypes import PALWORLD_CUSTOM_PROPERTIES

gvas_file = GvasFile.load(json.loads(sys.stdin.read()))
if ("Pal.PalWorldSaveGame" in gvas_file.header.save_game_class_name or "Pal.PalLocalWorldSaveGame" in gvas_file.header.save_game_class_name):
    save_type = 0x32
else:
    save_type = 0x31
sav_file = compress_gvas_to_sav(
    gvas_file.write(PALWORLD_CUSTOM_PROPERTIES), save_type
)
sys.stdout.buffer.write(sav_file)
EOF
)

# Function to convert JSON to .sav
convert_json_to_sav() {
    local json_data="$1"
    local output_path="$2"

    echo "WorldOption Generator: Compressing WorldOption to .sav"
    if echo "$json_data" | python3 -c "$convert_json_to_sav_python" > "$output_path/WorldOption.sav"; then
        echo "WorldOption Generator: Generated WorldOption.sav file to $output_path"
        echo "Generating WorldOption.sav done!"
    else
        echo "WorldOption Generator: WorldOption.sav generation failed."
    fi
}

############

echo "Generating WorldOption.sav..."

first_time_error="Saved game not found! This is expected if it is your first time running the container. Restart the container after it initializes the save folder to generate a WorldOption file."
savegames_directory="/palworld/Pal/Saved/SaveGames/0/"

# Check if save games directory exists
if [ ! -d "$savegames_directory" ]; then
    echo "$first_time_error"
    exit 1
fi

# Find target directory within save games directory
target_directory=$(find "$savegames_directory" -maxdepth 1 -mindepth 1 -type d -print -quit)

# Check if target directory exists
if [ -z "$target_directory" ] || [ ! -d "$target_directory" ]; then
    echo "$first_time_error"
    exit 1
fi

# Read WorldOption JSON template
worldoption=$(cat "/home/steam/server/files/WorldOption.json.template")

# Check if WorldOption template is found
if [ -z "$worldoption" ]; then
    echo "WorldOption Generator: WorldOption.json.template not found!"
    exit 1
fi

# Parse configuration from PalWorldSettings.ini
parsed_config=$(load_palworldsettings "/palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini")

# Check if parsed configuration is empty
if [ -z "$parsed_config" ]; then
    echo "WorldOption Generator: Parsed config is empty."
    exit 1
fi

# Generate JSON settings from parsed configuration
settings_json=$(generate_json_config "$parsed_config")

if [ "${DEBUG,,}" = true ]; then
    echo "====Debug===="
    echo "$settings_json"
    echo "====Debug===="
fi

# Update JSON data with generated settings
json_data=$(jq --argjson new "$settings_json" '.properties.OptionWorldData.value.Settings.value = $new' <<< "$worldoption")

# Convert JSON data to .sav
convert_json_to_sav "$json_data" "$target_directory"