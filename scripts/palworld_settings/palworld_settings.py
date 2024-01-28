# using standard library for simplicity
import json
import inspect
import argparse
import configparser
import os

# load environment variables
def initArgs():
    global args

    parser = argparse.ArgumentParser(description="Palworld Settings Script")
    parser.add_argument(
        '-h', '--help',
        action='help',
        default=argparse.SUPPRESS,
        help='show this help message and exit'
    )
    parser.add_argument(
        '--workpath', 
        type=str, 
        default=os.getenv('WORKPATH', '/palworld'), 
        help='set the workpath (default: /palworld)'
    )
    parser.add_argument(
        '--default-palworld-settings-ini', 
        type=str, 
        default='DefaultPalWorldSettings.ini', 
        help='set the path of "DefaultPalWorldSettings.ini" under workpath (default: DefaultPalWorldSettings.ini)'
    )
    parser.add_argument(
        '--default-palworld-settings-json', 
        type=str, 
        default='DefaultPalWorldSettings.json', 
        help='set the path of "DefaultPalWorldSettings.json" under workpath (default: DefaultPalWorldSettings.json)'
    )
    parser.add_argument(
        '--palworld-settings-ini', 
        type=str, 
        default='Pal/Saved/Config/LinuxServer/PalWorldSettings.ini', 
        help='set the path of "PalWorldSettings.ini" under workpath (default: Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)'
    )
    parser.add_argument(
        '--description-json', 
        type=str, 
        default='palworld_settings/description.json', 
        help='set the path of "description.json" under workpath (default: palworld_settings/description.json)'
    )
    parser.add_argument(
        '--description-lang',
        type=str, 
        default=os.getenv('ENHANCED_PALWORLD_SETTINGS_LANG', 'en'), 
        help='set the language of description in "DefaultPalWorldSettings.json" (default: en)'
    )
    parser.add_argument(
        '--keep-invalid-settings', 
        action='store_true', 
        default=os.getenv('KEEP_INVALID_SETTINGS', False), 
        help='if true, the regacy settings will be kept in "DefaultPalWorldSettings.json" (default: False)'
    )

    args = parser.parse_args()

# define paths with workpath
def initEnv():
    global ENHANCED_PALWORLD_SETTINGS_LANG
    global KEEP_INVALID_SETTINGS
    global PATH_DEFAULT_PALWORLD_SETTINGS_INI
    global PATH_DEFAULT_PALWORLD_SETTINGS_JSON
    global PATH_PALWORLD_SETTINGS_INI
    global PATH_DESCRIPTION_JSON
    
    WORKPATH = args.workpath + '/'

    ENHANCED_PALWORLD_SETTINGS_LANG = args.description_lang
    KEEP_INVALID_SETTINGS = args.keep_invalid_settings
    PATH_DEFAULT_PALWORLD_SETTINGS_INI = WORKPATH + args.default_palworld_settings_ini
    PATH_DEFAULT_PALWORLD_SETTINGS_JSON = WORKPATH + args.default_palworld_settings_json
    PATH_PALWORLD_SETTINGS_INI = WORKPATH + args.palworld_settings_ini
    PATH_DESCRIPTION_JSON = WORKPATH + args.description_json

#######################################################################
############################## Config #################################
#######################################################################
# migration regacy settings
# - key: regacy function name, value: new function name
#  - if function naming is changed, add the mapping here
#  - if the function is removed, just remove the key
#  - if function does not exist and not in here, remove the key from the DefaultPalWorldSettings.json
REGACY_TO_NEW = {
    # 'old_function_name': 'new_function_name'
}
#######################################################################
############################## Functions ##############################
#######################################################################
MESSAGE_FOR_NO_LANG = 'No description for lang: {}. will use "en" as fallback'
FALLBACK_DESCRIPTION = 'No description for key: {} in lang: {}'

def palGameWorldSettings():
    # parse the palworld settings
    defaultPalWorldSettings = _parseIni()
    # parse the description.json
    descriptions = _parseDescription()

    resultPalWorldSettings = []
    for key, value in defaultPalWorldSettings.items():
        description = None
        descriptionForKey = None

        # Find description with ENHANCED_PALWORLD_SETTINGS_LANG
        for element in descriptions.get('descriptions', []):
            if element['lang'] == ENHANCED_PALWORLD_SETTINGS_LANG:
                description = element
                break
        
        # If not found, use 'en' as fallback
        if description is None:
            print(MESSAGE_FOR_NO_LANG.format(ENHANCED_PALWORLD_SETTINGS_LANG))
            for element in descriptions.get('descriptions', []):
                if element['lang'] == 'en':
                    description = element
                    break
        else: descriptionForKey = description.get('description', {}).get(key, FALLBACK_DESCRIPTION.format(key, description['lang']))
        
        resultPalWorldSettings.append({
            'key': key,
            'value': value,
            'hint': descriptions.get('hint', {}).get(key),
            'description': descriptionForKey,
        })

    return resultPalWorldSettings

def serverBackupSchedule():
    # TODO
    pass

def autoRestartForMemoryLeak():
    # TODO
    pass

def autoBroadcastMessage():
    # TODO
    pass

functions = [
    palGameWorldSettings, 
    # serverBackupSchedule, 
    # autoRestartForMemoryLeak, 
    # autoBroadcastMessage
]
palGameWorldSettingsName = inspect.getfunction(palGameWorldSettings).__name__

#######################################################################
############################## Settings ###############################
#######################################################################
def _parseIni():
    config = configparser.ConfigParser()
    config.read(PATH_DEFAULT_PALWORLD_SETTINGS_INI)
    settings = dict(config['/Script/Pal.PalGameWorldSettings'])
    return settings

def _parseDescription():
    with open(PATH_DESCRIPTION_JSON, 'r') as f:
        descriptions = json.load(f)
    return descriptions

def _createDefaultPalWorldSettingsJson():
    defaultPalWorldSettingsJson = []
    for function in functions:
        defaultPalWorldSettingsJson.append({
            inspect.getfunction(function).__name__ : function(),
        })
    return defaultPalWorldSettingsJson

def _loadDefaultPalWorldSettingsJson():
    if os.path.exists(PATH_DEFAULT_PALWORLD_SETTINGS_JSON):
        with open(PATH_DEFAULT_PALWORLD_SETTINGS_JSON, 'r') as f:
            defaultPalWorldSettingsJson = json.load(f)
    else:
        defaultPalWorldSettingsJson = []
    return defaultPalWorldSettingsJson

def _saveDefaultPalWorldSettingsJson(defaultPalWorldSettingsJson):
    with open(PATH_DEFAULT_PALWORLD_SETTINGS_JSON, 'w') as f:
        json.dump(defaultPalWorldSettingsJson, f, indent=4)



# using REGACY_TO_NEW, KEEP_INVALID_SETTINGS
def _fixInvalidKeysFromJson(defaultInit, currentJson):
    # check if the function name is changed
    for item in currentJson:
        for key, value in item.items():
            if key in REGACY_TO_NEW:
    # if the function name is changed then change the key
                item[REGACY_TO_NEW[key]] = value
                del item[key]
            elif key not in defaultInit and not KEEP_INVALID_SETTINGS:
    # if the function is removed and KEEP_INVALID_SETTINGS is False then remove the key
                del item[key]
    # check if the function is added
    for item in defaultInit:
        for key, value in item.items():
            if key not in currentJson:
                currentJson.append(item)

def _updateHintsAndDescriptions(defaultJson, currentJson):
    # update the hints and descriptions
    for defaultItem in defaultJson.get(palGameWorldSettingsName, []):
        for currentItem in currentJson.get(palGameWorldSettingsName, []):
            if defaultItem['key'] == currentItem['key']:
                currentItem['hint'] = defaultItem['hint']
                currentItem['description'] = defaultItem['description']

def _convertDefaultPalWorldSettingsJsonToIni(defaultPalWorldSettingsJson):
    config = _parseIni()
    # clear the default '/Script/Pal.PalGameWorldSettings'
    config['/Script/Pal.PalGameWorldSettings'] = {}

    # add default settings
    for item in defaultPalWorldSettingsJson.get(palGameWorldSettingsName, []):
        for key, value in item.items():
            config['/Script/Pal.PalGameWorldSettings'][key] = value
    return config

def _saveDefaultPalWorldSettingsIni(config):
    with open(PATH_PALWORLD_SETTINGS_INI, 'w') as f:
        config.write(f)

#######################################################################
############################## Main ###################################
#######################################################################

if __name__ == '__main__':
    initArgs()
    initEnv()

    # load the DefaultPalWorldSettings.json or create a new one
    defaultJson = _createDefaultPalWorldSettingsJson()
    currentJson = _loadDefaultPalWorldSettingsJson()

    # fix invalid keys from json
    _fixInvalidKeysFromJson(defaultJson, currentJson)

    # update the hints and descriptions
    _updateHintsAndDescriptions(defaultJson, currentJson)

    # save to DefaultPalWorldSettings.json
    _saveDefaultPalWorldSettingsJson(currentJson)

    # save to DefaultPalWorldSettings.ini
    currentIni = _convertDefaultPalWorldSettingsJsonToIni(currentJson)
    _saveDefaultPalWorldSettingsIni(currentIni)