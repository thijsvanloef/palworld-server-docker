#!/usr/bin/env python3

import sys
import json
import os

from helper_functions import load_palworldsettings, parse_config, generate_json_config, convert_json_to_sav

try:
    print("Generating WorldOption.sav...")

    savegames_directory = "/palworld/Pal/Saved/SaveGames/0/"

    # Find generated directory within /palworld/Pal/Saved/SaveGames/0/
    target_directory = next((os.path.join(savegames_directory, d) for d in os.listdir(savegames_directory) if os.path.isdir(os.path.join(savegames_directory, d))), None)

    if not os.path.isdir(savegames_directory) or not os.path.isdir(target_directory):
        print("Saved game not found! This is expected if it is your first time running the container. Restart the container after it initializes the save folder to generate a WorldOption file.")
        raise Exception()
    
    worldoption = None

    # Load JSON Template for WorldOption
    with open(os.path.join(os.path.dirname(__file__), '../files/WorldOption.json.template')) as f:
        worldoption = json.load(f)

    if worldoption == None:
        print("WorldOption Generator: WorldOption.json.template not found!")
        raise Exception()

    raw_config = load_palworldsettings("/palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini")

    if raw_config == '':
        print("WorldOption Generator: Raw config is empty.")
        raise Exception()

    parsed_config = parse_config(raw_config)
    worldoption["root"]["properties"]["OptionWorldData"]["Struct"]["value"]["Struct"]["Settings"]["Struct"]["value"][
        "Struct"] = generate_json_config(parsed_config)

    convert_json_to_sav(worldoption, target_directory)

    print("Generating WorldOption.sav done!")
except Exception as e:
    print(f"WorldOption Generator Error: {e}")
    print("WorldOption will not be generated. PalWorldSettings.ini will apply.")