# Palworld Dedicated Server Docker

[![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)](https://github.com/thijsvanloef/palworld-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker/tags)
[![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)](https://discord.com/invite/UxBxStPAAE)
[![Static Badge](https://img.shields.io/badge/README-0.16.0-blue?link=https%3A%2F%2Fgithub.com%2Fthijsvanloef%2Fpalworld-server-docker%2Fblob%2Fmain%2FREADME.md)](https://github.com/thijsvanloef/palworld-server-docker?tab=readme-ov-file#palworld-dedicated-server-docker)

[View on Docker Hub](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)

[Chat with the community on Discord](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md) | [简体中文](/docs/zh-CN/README.md)

> [!TIP]
> Unsure how to get started? Check out the [this guide I wrote!](https://tice.tips/containerization/palworld-server-docker/)

This is a Docker container to help you get started with hosting your own
[Palworld](https://store.steampowered.com/app/1623730/Palworld/) dedicated server.

This Docker container has been tested and will work on both Linux (Ubuntu/Debian) and Windows 10.

> [!IMPORTANT]
> At the moment, Xbox Gamepass/Xbox Console players will not be able to join a dedicated server.
>
> They will need to join players using the invite code and are limited to sessions of 4 players max.

## Server Requirements

| Resource | Minimum | Recommended                              |
|----------|---------|------------------------------------------|
| CPU      | 4 cores | 4+ cores                                 |
| RAM      | 16GB    | Recommend over 32GB for stable operation |
| Storage  | 4GB     | 12GB                                     |

## How to use

Keep in mind that you'll need to change the [environment variables](#environment-variables).

### Docker Compose

This repository includes an example [docker-compose.yml](/docker-compose.yml) file you can use to setup your server.

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         - PUID=1000
         - PGID=1000
         - PORT=8211 # Optional but recommended
         - PLAYERS=16 # Optional but recommended
         - SERVER_PASSWORD="worldofpals" # Optional but recommended
         - MULTITHREADING=true
         - RCON_ENABLED=true
         - RCON_PORT=25575
         - TZ=UTC
         - ADMIN_PASSWORD="adminPasswordHere"
         - COMMUNITY=false  # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
         - SERVER_NAME="World of Pals"
         - SERVER_DESCRIPTION="Awesome World of Pal"
      volumes:
         - ./palworld:/palworld/
```

### Docker Run

Change every <> to your own configuration

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./<palworld-folder>:/palworld/ \
    -e PUID=1000 \
    -e PGID=1000 \
    -e PORT=8211 \
    -e PLAYERS=16 \
    -e MULTITHREADING=true \
    -e RCON_ENABLED=true \
    -e RCON_PORT=25575 \
    -e TZ=UTC \
    -e ADMIN_PASSWORD="adminPasswordHere" \
    -e SERVER_PASSWORD="worldofpals" \
    -e COMMUNITY=false \
    -e SERVER_NAME="World of Pals" \
    -e SERVER_DESCRIPTION="Awesome World of Pal" \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker:latest

```

### Kubernetes

All files you will need to deploy this container to kubernetes are located in the [k8s folder](k8s/).

Follow the steps in the [README.md here](k8s/readme.md) to deploy it.

#### Using helm chart

Follow up the docs on the [README.md for the helm chart](./chart/README.md) to deploy.

### Environment variables

You can use the following values to change the settings of the server on boot.
It is highly recommended you set the following environment values before starting the server:

* PLAYERS
* PORT
* PUID
* PGID

| Variable           | Info                                                                                                                                                                                                | Default Values | Allowed Values                                                                                             |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------|
| TZ                 | Timezone used for time stamping backup server                                                                                                                                                       | UTC            | See [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
| PLAYERS*           | Max amount of players that are able to join the server                                                                                                                                              | 16             | 1-32                                                                                                       |
| PORT*              | UDP port that the server will expose                                                                                                                                                                | 8211           | 1024-65535                                                                                                 |
| PUID*              | The uid of the user the server should run as                                                                                                                                                        | 1000           | !0                                                                                                         |
| PGID*              | The gid of the group the server should run as                                                                                                                                                       | 1000           | !0                                                                                                         |
| MULTITHREADING**   | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense.              | false          | true/false                                                                                                 |
| COMMUNITY          | Whether or not the server shows up in the community server browser (USE WITH SERVER_PASSWORD)                                                                                                       | false          | true/false                                                                                                 |
| PUBLIC_IP          | You can manually specify the global IP address of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |                | x.x.x.x                                                                                                    |
| PUBLIC_PORT        | You can manually specify the port number of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration.       |                | 1024-65535                                                                                                 |
| SERVER_NAME        | A name for your server                                                                                                                                                                              |                | "string"                                                                                                   |
| SERVER_DESCRIPTION | Your server Description                                                                                                                                                                             |                | "string"                                                                                                   |
| SERVER_PASSWORD    | Secure your community server with a password                                                                                                                                                        |                | "string"                                                                                                   |
| ADMIN_PASSWORD     | Secure administration access in the server with a password                                                                                                                                          |                | "string"                                                                                                   |
| UPDATE_ON_BOOT**   | Update/Install the server when the docker container starts (THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER)                                                                            | true           | true/false                                                                                                 |
| RCON_ENABLED***    | Enable RCON for the Palworld server                                                                                                                                                                 | true           | true/false                                                                                                 |
| RCON_PORT          | RCON port to connect to                                                                                                                                                                             | 25575          | 1024-65535                                                                                                 |
| QUERY_PORT         | Query port used to communicate with Steam servers                                                                                                                                                   | 27015          | 1024-65535                                                                                                 |

*highly recommended to set

** Make sure you know what you are doing when running this option enabled

*** Required for docker stop to save and gracefully close the server

> [!IMPORTANT]
> Boolean values used in environment variables are case sensitive because they are used in the shell script.
>
> They must be set using exactly `true` or `false` for the option to take effect.

### Game Ports

| Port  | Info             |
|-------|------------------|
| 8211  | Game Port (UDP)  |
| 27015 | Query Port (UDP) |
| 25575 | RCON Port (TCP)  |

## Using RCON

RCON is enabled by default for the palworld-server-docker image.
Opening the RCON CLI is quite easy:

```bash
docker exec -it palworld-server rcon-cli
```

This will open a CLI that uses RCON to write commands to the Palworld Server.

### List of server commands

| Command                          | Info                                                |
|----------------------------------|-----------------------------------------------------|
| Shutdown {Seconds} {MessageText} | The server is shut down after the number of Seconds |
| DoExit                           | Force stop the server.                              |
| Broadcast                        | Send message to all player in the server            |
| KickPlayer {SteamID}             | Kick player from the server..                       |
| BanPlayer {SteamID}              | BAN player from the server.                         |
| TeleportToPlayer {SteamID}       | Teleport to current location of target player.      |
| TeleportToMe {SteamID}           | Target player teleport to your current location     |
| ShowPlayers                      | Show information on all connected players.          |
| Info                             | Show server information.                            |
| Save                             | Save the world data.                                |

For a full list of commands go to: [https://tech.palworldgame.com/server-commands](https://tech.palworldgame.com/server-commands)

## Creating a backup

To create a backup of the game's save at the current point in time, use the command:

```bash
docker exec palworld-server backup
```

This will create a backup at `/palworld/backups/`

The server will run a save before the backup if rcon is enabled.

## Editing Server Settings

### With Environment Variables

> [!IMPORTANT]
>
> These Environment Variables/Settings are subject to change since the game is still in beta

| Variable                                  | Description                                                    | Default Value                                                                                | Allowed Value                          |
|-------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | Game Difficulty                                                | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | Day time speed - Smaller number means shorter days             | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | Night time speed - Smaller number means shorter nights         | 1.000000                                                                                     | Float                                  |
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
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | Getherable objects respawn interval                            | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | Dropped Items Multipiler                                       | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | What will drop when you die                                    | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | Allows players to cause damage to players                      | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | Allow friendly fire                                            | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | Enable invaders                                                | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | Enable UNKO (?)                                                | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | Enable controller aim assist                                   | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | Enable Keyboard aim assist                                     | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | Maximum number of drops in the world                           | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | Maximum number of UNKO drops in the world                      | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | Maximum number of base camps                                   | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAXNUM                   | Maximum number of workers                                      | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | Time it takes for items to despawn in hours                    | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | Automatically reset guild when no players are online           | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | Time to automatically reset guild when no players are online   | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | Max player of Guild                                            | 20                                                                                           | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | Time(h) to incubate massive egg                                | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | Work speed muliplier                                           | 1.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | Enable multiplayer                                             | False                                                                                        | Boolean                                |
| IS_PVP                                    | Enable PVP                                                     | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | Allow players from other guilds to pick up death penalty items | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | Enable non-login penalty                                       | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | Enable fast travel                                             | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | Enable selecting of start location                             | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | Toggle for deleting players when they log off                  | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | Allows defense against other guild players                     | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | Maximum number of players in a guild                           | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                         |                                                                                              | String                                 |
| USEAUTH                                   | Use authentication                                             | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | Which ban list to use                                          | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |

### Manually

When the server starts, a `PalWorldSettings.ini` file will be created in the following location: `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Any changes made while the server is live will be overridden.

Please keep in mind that the ENV variables will always overwrite the changes made to `PalWorldSettings.ini`.

> [!IMPORTANT]
> Changes can only be made to `PalWorldSettings.ini` while the server is off.

For a more detailed list of explanations of server settings go to: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

## Reporting Issues/Feature Requests

Issues/Feature requests can be submitted by using [this link](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).

### Known Issues

Known issues are listed in the [wiki](https://github.com/thijsvanloef/palworld-server-docker/wiki/Known-Issues)
