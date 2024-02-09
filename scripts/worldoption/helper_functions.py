#!/usr/bin/env python3

from enum import Enum
from typing import Dict
import sys
import re
import json
import os

from palworld_save_tools.gvas import GvasFile
from palworld_save_tools.palsav import compress_gvas_to_sav
from palworld_save_tools.paltypes import PALWORLD_CUSTOM_PROPERTIES

# Modified version of https://github.com/legoduded/palworld-worldoptions/blob/master/src/lib/palworldsettings.py

DEATHPENALTY_VALUES = ["None", "Item", "ItemAndEquipment", "All"]

class StructTypes(Enum):
    Int = 1
    Str = 2
    Float = 3
    Bool = 4
    Enum = 5

class ConfigOption:
    def __init__(self, option_name: str, struct: StructTypes, default_value):
        self.option_name = option_name
        self.struct = struct
        self.default_value = default_value

    def _typecast(self, value):
        if self.struct == StructTypes.Int:
            # work around if the values are a float
            return int(float(value))
        elif self.struct == StructTypes.Float:
            return float(value)
        elif self.struct == StructTypes.Bool:
            if value.lower() in ["false", "0"]:
                return False
            else:
                return True
        elif self.struct == StructTypes.Enum:
            if len(value) == 1:
                # Going to assume its an int
                index_value = int(value)
                if index_value >= len(DEATHPENALTY_VALUES):
                    raise AttributeError(f"{value} is not a valid option for DeathPenalty")
                else:
                    return DEATHPENALTY_VALUES[index_value]
            else:
                return value
        else:
            return value

    def is_default(self, value) -> bool:
        return self.default_value == self._typecast(value)

    def json_struct(self, value) -> Dict:
        if self.struct == StructTypes.Enum:

            if len(value) == 1:
                # Going to assume its an int
                index_value = int(value)
                if index_value >= len(DEATHPENALTY_VALUES):
                    raise AttributeError(f"{value} is not a valid option for DeathPenalty")
            else:
                # Lets make this case insensitive
                if value.lower() in [death.lower() for death in DEATHPENALTY_VALUES]:
                    index_value = [death.lower() for death in DEATHPENALTY_VALUES].index(value.lower())
                else:
                    raise AttributeError(f"{value} is not a valid option for DeathPenalty")
            return {
                self.struct.name: {
                    "value": f"EPalOptionWorldDeathPenalty::{DEATHPENALTY_VALUES[index_value]}",
                    "enum_type": "EPalOptionWorldDeathPenalty"
                }
            }
        else:
            return {
                self.struct.name: {
                    "value": self._typecast(value)
                }
            }

class SettingStructs:
    DayTimeSpeedRate = ConfigOption("DayTimeSpeedRate", StructTypes.Float, 1.000000)
    NightTimeSpeedRate = ConfigOption("NightTimeSpeedRate", StructTypes.Float, 1.000000)
    ExpRate = ConfigOption("ExpRate", StructTypes.Float, 1.000000)
    PalCaptureRate = ConfigOption("PalCaptureRate", StructTypes.Float, 1.000000)
    PalSpawnNumRate = ConfigOption("PalSpawnNumRate", StructTypes.Float, 1.000000)
    PalDamageRateAttack = ConfigOption("PalDamageRateAttack", StructTypes.Float, 1.000000)
    PalDamageRateDefense = ConfigOption("PalDamageRateDefense", StructTypes.Float, 1.000000)
    PlayerDamageRateAttack = ConfigOption("PlayerDamageRateAttack", StructTypes.Float, 1.000000)
    PlayerDamageRateDefense = ConfigOption("PlayerDamageRateDefense", StructTypes.Float, 1.000000)
    PlayerStomachDecreaceRate = ConfigOption("PlayerStomachDecreaceRate", StructTypes.Float, 1.000000)
    PlayerStaminaDecreaceRate = ConfigOption("PlayerStaminaDecreaceRate", StructTypes.Float, 1.000000)
    PlayerAutoHPRegeneRate = ConfigOption("PlayerAutoHPRegeneRate", StructTypes.Float, 1.000000)
    PlayerAutoHpRegeneRateInSleep = ConfigOption("PlayerAutoHpRegeneRateInSleep", StructTypes.Float, 1.000000)
    PalStomachDecreaceRate = ConfigOption("PalStomachDecreaceRate", StructTypes.Float, 1.000000)
    PalStaminaDecreaceRate = ConfigOption("PalStaminaDecreaceRate", StructTypes.Float, 1.000000)
    PalAutoHPRegeneRate = ConfigOption("PalAutoHPRegeneRate", StructTypes.Float, 1.000000)
    PalAutoHpRegeneRateInSleep = ConfigOption("PalAutoHpRegeneRateInSleep", StructTypes.Float, 1.000000)
    BuildObjectDamageRate = ConfigOption("BuildObjectDamageRate", StructTypes.Float, 1.000000)
    BuildObjectDeteriorationDamageRate = ConfigOption("BuildObjectDeteriorationDamageRate", StructTypes.Float, 1.000000)
    CollectionDropRate = ConfigOption("CollectionDropRate", StructTypes.Float, 1.000000)
    CollectionObjectHpRate = ConfigOption("CollectionObjectHpRate", StructTypes.Float, 1.000000)
    CollectionObjectRespawnSpeedRate = ConfigOption("CollectionObjectRespawnSpeedRate", StructTypes.Float, 1.000000)
    EnemyDropItemRate = ConfigOption("EnemyDropItemRate", StructTypes.Float, 1.000000)
    DeathPenalty = ConfigOption("DeathPenalty", StructTypes.Enum, "All")
    bEnablePlayerToPlayerDamage = ConfigOption("bEnablePlayerToPlayerDamage", StructTypes.Bool, False)
    bEnableFriendlyFire = ConfigOption("bEnableFriendlyFire", StructTypes.Bool, False)
    bEnableInvaderEnemy = ConfigOption("bEnableInvaderEnemy", StructTypes.Bool, True)
    bActiveUNKO = ConfigOption("bActiveUNKO", StructTypes.Bool, False)
    bEnableAimAssistPad = ConfigOption("bEnableAimAssistPad", StructTypes.Bool, True)
    bEnableAimAssistKeyboard = ConfigOption("bEnableAimAssistKeyboard", StructTypes.Bool, False)
    DropItemMaxNum = ConfigOption("DropItemMaxNum", StructTypes.Int, 3000)
    DropItemMaxNum_UNKO = ConfigOption("DropItemMaxNum_UNKO", StructTypes.Int, 100)
    BaseCampMaxNum = ConfigOption("BaseCampMaxNum", StructTypes.Int, 128)
    BaseCampWorkerMaxNum = ConfigOption("BaseCampWorkerMaxNum", StructTypes.Int, 15)
    DropItemAliveMaxHours = ConfigOption("DropItemAliveMaxHours", StructTypes.Float, 1.000000)
    bAutoResetGuildNoOnlinePlayers = ConfigOption("bAutoResetGuildNoOnlinePlayers", StructTypes.Bool, False)
    AutoResetGuildTimeNoOnlinePlayers = ConfigOption("AutoResetGuildTimeNoOnlinePlayers", StructTypes.Float, 72.000000)
    GuildPlayerMaxNum = ConfigOption("GuildPlayerMaxNum", StructTypes.Int, 20)
    PalEggDefaultHatchingTime = ConfigOption("PalEggDefaultHatchingTime", StructTypes.Float, 72.000000)
    WorkSpeedRate = ConfigOption("WorkSpeedRate", StructTypes.Float, 1.000000)
    bIsMultiplay = ConfigOption("bIsMultiplay", StructTypes.Bool, False)
    bIsPvP = ConfigOption("bIsPvP", StructTypes.Bool, False)
    bCanPickupOtherGuildDeathPenaltyDrop = ConfigOption("bCanPickupOtherGuildDeathPenaltyDrop", StructTypes.Bool, False)
    bEnableNonLoginPenalty = ConfigOption("bEnableNonLoginPenalty", StructTypes.Bool, True)
    bEnableFastTravel = ConfigOption("bEnableFastTravel", StructTypes.Bool, True)
    bIsStartLocationSelectByMap = ConfigOption("bIsStartLocationSelectByMap", StructTypes.Bool, True)
    bExistPlayerAfterLogout = ConfigOption("bExistPlayerAfterLogout", StructTypes.Bool, False)
    bEnableDefenseOtherGuildPlayer = ConfigOption("bEnableDefenseOtherGuildPlayer", StructTypes.Bool, False)
    CoopPlayerMaxNum = ConfigOption("CoopPlayerMaxNum", StructTypes.Int, 4)
    ServerPlayerMaxNum = ConfigOption("ServerPlayerMaxNum", StructTypes.Int, 32)
    ServerName = ConfigOption("ServerName", StructTypes.Str, "Default Palworld Server")
    ServerDescription = ConfigOption("ServerDescription", StructTypes.Str, "")
    AdminPassword = ConfigOption("AdminPassword", StructTypes.Str, "")
    ServerPassword = ConfigOption("ServerPassword", StructTypes.Str, "")
    PublicPort = ConfigOption("PublicPort", StructTypes.Int, 8211)
    PublicIP = ConfigOption("PublicIP", StructTypes.Str, "")
    RCONEnabled = ConfigOption("RCONEnabled", StructTypes.Bool, False)
    RCONPort = ConfigOption("RCONPort", StructTypes.Int, 25575)
    Region = ConfigOption("Region", StructTypes.Str, "")
    bUseAuth = ConfigOption("bUseAuth", StructTypes.Bool, True)
    BanListURL = ConfigOption("BanListURL", StructTypes.Str, "https://api.palworldgame.com/api/banlist.txt")

    @staticmethod
    def get_config_option(option_name: str) -> ConfigOption:
        return getattr(SettingStructs, option_name)

def generate_json_config(config: str) -> Dict:
    json_config = {}
    tokens = re.findall(r'(\w.*?)=([^"].*?|".*?")((?=,)|$)', config)
    for key, value, _ in tokens:
        try:
            if key == "Difficulty":
                continue
            if '"' in value:
                value = re.match(r'^"(.*)"$', value.strip()).group(1)
                # if it was already escaped in the config
                value = value.replace('\\"', '"')
            config_properties = SettingStructs.get_config_option(key)
            if not config_properties.is_default(value):
                json_config[key] = config_properties.json_struct(value)
        except AttributeError:
            print("WorldOption Generator: Error loading", key)
        except ValueError:
            print(f"WorldOption Generator: Error parsing {key}:{value}")
    return json_config

def parse_config(config: str) -> str:
    return config\
        .replace("OptionSettings=(", "")\
        .strip(") ")

def load_palworldsettings(path: str) -> str:
    with open(path, encoding="utf8") as f:
        config = None
        for line in f:
            if "OptionSettings" in line:
                config = line
        if config is None:
            print("WorldOption Generator: Failed to get OptionSettings from PalWorldSettings.ini")
            return ''
    return config

def convert_json_to_sav(json_data, output_path):
    print(f"WorldOption Generator: Compressing WorldOption to .sav")
    gvas_file = GvasFile.load(json_data)
    if (
        "Pal.PalWorldSaveGame" in gvas_file.header.save_game_class_name
        or "Pal.PalLocalWorldSaveGame" in gvas_file.header.save_game_class_name
    ):
        save_type = 0x32
    else:
        save_type = 0x31
    sav_file = compress_gvas_to_sav(
        gvas_file.write(PALWORLD_CUSTOM_PROPERTIES), save_type
    )
    print(f"WorldOption Generator: Writing WorldOption.sav file to {output_path}")
    with open(output_path, "wb") as f:
        f.write(sav_file)
