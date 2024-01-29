# using standard library for simplicity
import re
import json
import argparse
import configparser
import os

# load environment variables
def initArgs():
    global args

    parser = argparse.ArgumentParser(description="Palworld Settings Script")
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
        '--description-lang',
        type=str, 
        default=os.getenv('ENHANCED_PALWORLD_SETTINGS_LANG', 'en'), 
        help='set the language of description in "DefaultPalWorldSettings.json" (default: en)'
    )
    parser.add_argument(
        '--keep-invalid-settings', 
        type=bool,
        default=os.getenv('KEEP_INVALID_SETTINGS', False), 
        help='if true, the regacy settings will be kept in "DefaultPalWorldSettings.json" (default: False)'
    )
    parser.add_argument(
        '--write-json-file-always',
        type=bool,
        default=os.getenv('WRITE_JSON_FILE_ALWAYS', False),
        help='if true, the "PalWorldSettings.json" will be written always (default: False)'
    )
    parser.add_argument(
        '--description-json', 
        type=str, 
        default='/home/steam/server/palworld_settings/description.json', 
        help='set the path of "description.json" (default: /home/steam/server/palworld_settings/description.json)'
    )
    args = parser.parse_args()

# define paths with workpath
def initEnv():
    global ENHANCED_PALWORLD_SETTINGS_LANG
    global KEEP_INVALID_SETTINGS
    global WRITE_JSON_FILE_ALWAYS
    
    global PATH_DEFAULT_PALWORLD_SETTINGS_INI
    global PATH_DEFAULT_PALWORLD_SETTINGS_JSON
    global PATH_PALWORLD_SETTINGS_INI
    global PATH_DESCRIPTION_JSON
    
    WORKPATH = args.workpath + '/'

    ENHANCED_PALWORLD_SETTINGS_LANG = args.description_lang.lower()
    KEEP_INVALID_SETTINGS = args.keep_invalid_settings
    WRITE_JSON_FILE_ALWAYS = args.write_json_file_always

    PATH_DEFAULT_PALWORLD_SETTINGS_INI = WORKPATH + args.default_palworld_settings_ini
    PATH_DEFAULT_PALWORLD_SETTINGS_JSON = WORKPATH + args.default_palworld_settings_json
    PATH_PALWORLD_SETTINGS_INI = WORKPATH + args.palworld_settings_ini
    
    PATH_DESCRIPTION_JSON = args.description_json

    print('workpath: {}'.format(WORKPATH))
    # exist + path
    print('default-palworld-settings-ini[{}] : {}'.format(os.path.exists(PATH_DEFAULT_PALWORLD_SETTINGS_INI), PATH_DEFAULT_PALWORLD_SETTINGS_INI))
    print('default-palworld-settings-json[{}] : {}'.format(os.path.exists(PATH_DEFAULT_PALWORLD_SETTINGS_JSON), PATH_DEFAULT_PALWORLD_SETTINGS_JSON))
    print('palworld-settings-ini[{}] : {}'.format(os.path.exists(PATH_PALWORLD_SETTINGS_INI), PATH_PALWORLD_SETTINGS_INI))
    print('description-json[{}] : {}'.format(os.path.exists(PATH_DESCRIPTION_JSON), PATH_DESCRIPTION_JSON))
    print('')


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
# MESSAGE_FOR_NO_LANG = 'No description for lang[{}] at key[{}]. will use "en" as fallback'
FALLBACK_DESCRIPTION = 'No description for key: {}'

def palGameWorldSettings():
    print('DefaultPalWorldSettings.json')
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
        if description is None or description.get('description', {}).get(key) in [None, '', '""']:
            # print(MESSAGE_FOR_NO_LANG.format(ENHANCED_PALWORLD_SETTINGS_LANG, key))
            for element in descriptions.get('descriptions', []):
                if element['lang'] == 'en':
                    description = element
                    break
        
        descriptionForKey = description.get('description', {}).get(key)
        if descriptionForKey is None or descriptionForKey == '' or descriptionForKey == '""':
            descriptionForKey = FALLBACK_DESCRIPTION.format(key)
        
        resultPalWorldSettings.append({
            'key': key,
            'value': value,
            'hint': descriptions.get('hint', {}).get(key),
            'description': descriptionForKey,
        })

        print('- {}={} -> {}'.format(key, value, descriptionForKey))

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

def debugLog():
    # TODO print ini file to log
    pass

functions = [
    palGameWorldSettings, 
    # serverBackupSchedule, 
    # autoRestartForMemoryLeak, 
    # autoBroadcastMessage,
    # debugLog,
]

#######################################################################
############################## Settings ###############################
#######################################################################
def _parseIni():
    # config = configparser.ConfigParser(encoding='utf-8')
    config = configparser.ConfigParser()
    config.read(PATH_DEFAULT_PALWORLD_SETTINGS_INI)
    option_settings = config.get('/Script/Pal.PalGameWorldSettings', 'OptionSettings')
    option_settings_match = re.search(r'\((.*?)\)', option_settings)
    if option_settings_match:
        option_settings_value = option_settings_match.group(1)
        settings_list = option_settings_value.split(",")

        settings_dict = {}
        for setting in settings_list:
            key, value = setting.split("=")
            settings_dict[key.strip()] = value.strip()
    return settings_dict

def _bindJsonToIni(palGameWorldSettings):
    # config = configparser.ConfigParser(encoding='utf-8')
    config = configparser.ConfigParser()
    config.read(PATH_DEFAULT_PALWORLD_SETTINGS_INI)

    # palGameWorldSettings
    # [
    #     {
    #         "key": "Difficulty",
    #         "value": "None"
    #         "hint": "[None, Casual, Normal, Hard]"
    #         "description": "난이도를 설정합니다."
    #     },
    #     {
    #         "key": "DayTimeSpeedRate",
    #         "value": "1.0",
    #         "description": "낮 경과 속도 (0.1 ~ 5)",
    #         "default": "1.0"
    #     }
    #     ...
    # ]
    # to settings_dict
    # {Difficulty=Normal, DayTimeSpeedRate=1.0, ...}
    settings_dict = {}
    for setting in palGameWorldSettings:
        settings_dict[setting['key']] = setting['value']

    # config['/Script/Pal.PalGameWorldSettings']['OptionSettings'] = toRequiredFormat(settings_dict)
    config.set('/Script/Pal.PalGameWorldSettings', 'OptionSettings', toRequiredFormat(settings_dict))
    return config

def toRequiredFormat(settings_dict):
    settings_list = []
    for key, value in settings_dict.items():
        settings_list.append(f"{key}={value}")
    return f"({','.join(settings_list)})"


def _parseDescription():
    with open(PATH_DESCRIPTION_JSON, 'r', encoding='utf-8') as f:
        descriptions = json.load(f)
    return descriptions

def _createDefaultPalWorldSettingsJson():
    defaultPalWorldSettingsJson = {}
    for function in functions:
        defaultPalWorldSettingsJson[function.__name__] = function()
    return defaultPalWorldSettingsJson

def _loadDefaultPalWorldSettingsJson():
    if not WRITE_JSON_FILE_ALWAYS and os.path.exists(PATH_DEFAULT_PALWORLD_SETTINGS_JSON):
        with open(PATH_DEFAULT_PALWORLD_SETTINGS_JSON, 'r', encoding='utf-8') as f:
            defaultPalWorldSettingsJson = json.load(f)
    else:
        defaultPalWorldSettingsJson = {}
    return defaultPalWorldSettingsJson

def _saveDefaultPalWorldSettingsJson(defaultPalWorldSettingsJson):
    with open(PATH_DEFAULT_PALWORLD_SETTINGS_JSON, 'w', encoding='utf-8') as f:
        json.dump(defaultPalWorldSettingsJson, f, indent=4, ensure_ascii=False)



# using REGACY_TO_NEW, KEEP_INVALID_SETTINGS
def _fixInvalidKeysFromJson(defaultInit, currentJson):
    for key in list(currentJson.keys()):
        if key not in defaultInit:
            if not KEEP_INVALID_SETTINGS:
                currentJson.pop(key)
            else:
                # fix invalid key
                if key in REGACY_TO_NEW:
                    currentJson[REGACY_TO_NEW[key]] = currentJson.pop(key)
        
    for key in defaultInit.keys():
        if key not in currentJson:
            currentJson[key] = defaultInit[key]
    

def _updateHintsAndDescriptions(defaultJson, currentJson):
    palGameWorldSettingsName = palGameWorldSettings.__name__

    # update the hints and descriptions
    for defaultItem in defaultJson.get(palGameWorldSettingsName, []):
        for currentItem in currentJson.get(palGameWorldSettingsName, []):
            if defaultItem['key'] == currentItem['key']:
                currentItem['hint'] = defaultItem['hint']
                currentItem['description'] = defaultItem['description']
                _checkAndFixInvalidValue(defaultItem, currentItem)

def _checkAndFixInvalidValue(defaultItem, currentItem):
    # ex) currentItem['hint'] = "[None, Casual, Normal, Hard]"
    if currentItem.get('hint') is None:
        return

    hints = [hint.strip() for hint in currentItem['hint'].replace('[', '').replace(']', '').split(',')]
    if currentItem['value'] not in hints:
        print('invalid value: "{}" for key. will use default value: "{}"'.format(currentItem['value'], defaultItem['value']))
        print('check the hint: {}'.format(currentItem['hint']))
        currentItem['value'] = defaultItem['value']



def _convertDefaultPalWorldSettingsJsonToIni(defaultPalWorldSettingsJson):
    return _bindJsonToIni(defaultPalWorldSettingsJson.get(palGameWorldSettings.__name__, {}))

def _saveDefaultPalWorldSettingsIni(config):
    dir_path = os.path.dirname(PATH_PALWORLD_SETTINGS_INI)
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)

    with open(PATH_PALWORLD_SETTINGS_INI, 'w', encoding='utf-8') as f:
        config.write(f, space_around_delimiters=False)

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