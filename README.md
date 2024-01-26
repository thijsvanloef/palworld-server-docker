# Palworld Dedicated Server Docker

![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)
![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)
![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)
![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)
![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)

[View on Docker Hub](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)

[Chat with the community on Discord](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md)

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

| Variable         | Info                                                                                                                                                                                               | Default Values | Allowed Values                                                                                             |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------|
| TZ               | Timezone used for time stamping backup server                                                                                                                                                      | UTC            | See [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
| PLAYERS*         | Max amount of players that are able to join the server                                                                                                                                             | 16             | 1-32                                                                                                       |
| PORT*            | UDP port that the server will expose                                                                                                                                                               | 8211           | 1024-65535                                                                                                 |
| PUID*            | The uid of the user the server should run as                                                                                                                                                       | 1000           | !0                                                                                                         |
| PGID*            | The gid of the group the server should run as                                                                                                                                                      | 1000           | !0                                                                                                         |
| MULTITHREADING** | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense.             | false          | true/false                                                                                                 |
| COMMUNITY        | Whether or not the server shows up in the community server browser (USE WITH SERVER_PASSWORD)                                                                                                      | false          | true/false                                                                                                 |
| PUBLIC_IP        | You can manually specify the global IP address of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |                | x.x.x.x                                                                                                    |
| PUBLIC_PORT      | You can manually specify the port number of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration.       |                | 1024-65535                                                                                                 |
| SERVER_NAME      | A name for your server               |                | "string"                                                                                                   |
| SERVER_PASSWORD  | Secure your community server with a password                                                                                                                                                       |                | "string"                                                                                                   |
| ADMIN_PASSWORD   | Secure administration access in the server with a password                                                                                                                                         |                | "string"                                                                                                   |
| UPDATE_ON_BOOT** | Update/Install the server when the docker container starts (THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER)                                                                           | true           | true/false                                                                                                 |
| RCON_ENABLED***  | Enable RCON for the Palworld server                                                                                                                                                                | true           | true/false                                                                                                 |
| RCON_PORT        | RCON port to connect to                                                                                                                                                                            | 25575          | 1024-65535                                                                                                 |
| QUERY_PORT       | Query port used to communicate with Steam servers                                                                                                                                                  | 27015          | 1024-65535                                                                                                 |

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

When the server starts, a `PalWorldSettings.ini` file will be created in the following location: `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Any changes made there will be applied to the Server on next boot.

Please keep in mind that the ENV variables will always overwrite the changes made to `PalWorldSettings.ini`.

For a more detailed list of explanations of server settings go to: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

> [!TIP]
> If the `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` is empty,
> delete the file and restart the server, a new file with content will be created.

## Reporting Issues/Feature Requests

Issues/Feature requests can be submitted by using [this link](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).

### Known Issues

Known issues are listed in the [wiki](https://github.com/thijsvanloef/palworld-server-docker/wiki/Known-Issues)
