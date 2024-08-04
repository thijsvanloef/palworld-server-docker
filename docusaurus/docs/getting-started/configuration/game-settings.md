---
sidebar_position: 2
title: Palworld Server Game Settings
description: How to change the Palworld Game Settings (PalWorldSettings.ini file) using Docker Environment variables.
keywords: [Palworld, palworld dedicated server, Palworld PalWorldSettings.ini, palworld game settings, PalWorldSettings.ini]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Game Settings
---
<!-- markdownlint-disable-next-line -->
# Palworld Server Game Settings

How to change the Palworld Game Settings (PalWorldSettings.ini file) using Docker Environment variables.

## With Environment Variables

:::warning
These Environment Variables and Settings are subject to change since the game is still in beta.

Check out the [official webpage for the supported parameters.](https://tech.palworldgame.com/optimize-game-balance)
:::

Converting server settings to environment variables follow the same principles (with some exceptions):

* all capital letters
* split words by inserting an underscore
* remove the single letter if the setting starts with one (like 'b')

For example:

* Difficulty -> DIFFICULTY
* PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
* bIsPvP -> IS_PVP

| Variable                                  | Description                                                    | Default Value                                                                                | Allowed Value                          |
|-------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | Game Difficulty                                                | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | Day time speed - Larger number means shorter days             | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | Night time speed - Larger number means shorter nights         | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | EXP earn rate                                                  | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | Pal capture rate                                               | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | Pal appearance rate                                            | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | Damage from pals multipiler                                    | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | Damage to pals multipiler                                      | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | Damage from player multipiler                                  | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | Damage to  player multipiler                                   | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | Player hunger depletion rate                                   | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | Player stamina reduction rate                                  | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | Player auto HP regeneration rate                               | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | Player sleep HP regeneration rate                              | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | Pal hunger depletion rate                                      | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | Pal stamina reduction rate                                     | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | Pal auto HP regeneration rate                                  | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | Pal sleep health regeneration rate (in Palbox)                 | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | Damage to structure multipiler                                 | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | Structure determination rate                                   | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | Getherable items multipiler                                    | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | Getherable objects HP multipiler                               | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | Getherable objects respawn interval - The smaller the number, the faster the regeneration                            | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | Dropped Items Multipiler                                       | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | Death Penalty None: No death penalty Item: Drops items other than equipment ItemAndEquipment: Drops all items All: Drops all PALs and all items.                                    | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | Allows players to cause damage to players                      | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | Allow friendly fire                                            | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | Enable invaders                                                | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | Enable UNKO (?)                                                | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | Enable controller aim assist                                   | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | Enable Keyboard aim assist                                     | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | Maximum number of drops in the world                           | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | Maximum number of UNKO drops in the world                      | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | Maximum number of base camps                                   | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAX_NUM                  | Maximum number of workers                                      | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | Time it takes for items to despawn in hours                    | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | Automatically reset guild when no players are online           | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | Time to automatically reset guild when no players are online   | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | Max player of Guild                                            | 20                                                                                           | Integer                                |
| BASE_CAMP_MAX_NUM_IN_GUILD                | Max bases of Guild                                             | 4                                                                                            | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | Time(h) to incubate massive egg                                | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | Work speed muliplier                                           | 1.000000                                                                                     | Float                                  |
| AUTO_SAVE_SPAN                            | Time between autosaves (seconds)                               | 30.000000                                                                                    | Float                                  |
| IS_MULTIPLAY                              | Enable multiplayer                                             | False                                                                                        | Boolean                                |
| IS_PVP                                    | Enable PVP                                                     | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | Allow players from other guilds to pick up death penalty items | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | Enable non-login penalty                                       | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | Enable fast travel                                             | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | Enable selecting of start location                             | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | Toggle for deleting players when they log off                  | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | Allows defense against other guild players                     | False                                                                                        | Boolean                                |
| INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX   | unknown                                                        | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | Maximum number of players in a guild                           | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                         |                                                                                              | String                                 |
| USEAUTH                                   | Use authentication                                             | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | Which ban list to use                                          | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |
| SHOW_PLAYER_LIST                          | Enable show player list                                        | True                                                                                         | Boolean                                |
| SUPPLY_DROP_SPAN                          | Interval for supply drop (minutes)                            | 180                                                                                          | Integer                                |
| TARGET_MANIFEST_ID | Locks game version to corespond with Manfiest ID from Steam Download Depot. | | See [Manifest ID Table](https://palworld-server-docker.loef.dev/guides/pinning-game-version) |
| ENABLE_PLAYER_LOGGING      | Enables Logging and announcing when players join and leave | true         | true/false |
| PLAYER_LOGGING_POLL_PERIOD          | Polling period (in seconds) to check for players who have joined or left | 5                      | !0 |

### Manually

:::info
Manually changing the `PalWorldSettings.ini` requires you to set `DISABLE_GENERATE_SETTINGS` to `true`
in the environment settings
:::

When the server starts, a `PalWorldSettings.ini` file will be created in the following location: `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Please keep in mind that the ENV variables will always overwrite the changes made to `PalWorldSettings.ini`.

:::warning
Changes can only be made to `PalWorldSettings.ini` while the server is off.

Any changes made while the server is live will be overwritten when the server stops.
:::

For a more detailed list of server settings go to: [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

For more detailed server settings explanations go to: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)
