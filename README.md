# Palworld Dedicated Server Docker

[![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)](https://github.com/thijsvanloef/palworld-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker/tags)
[![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)](https://discord.com/invite/UxBxStPAAE)

[![CodeFactor](https://www.codefactor.io/repository/github/thijsvanloef/palworld-server-docker/badge)](https://www.codefactor.io/repository/github/thijsvanloef/palworld-server-docker)
[![Release](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/release.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/release.yml)
[![Linting](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/linting.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/linting.yml)
[![Security](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/security.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/security.yml)

[![Docker Hub](https://img.shields.io/badge/Docker_Hub-palworld-blue?logo=docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![GHCR](https://img.shields.io/badge/GHCR-palworld-blue?logo=docker)](https://github.com/thijsvanloef/palworld-server-docker/pkgs/container/palworld-server-docker)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/palworld-server-chart)](https://artifacthub.io/packages/search?repo=palworld-server-chart)

[Chat with the community on Discord](https://discord.gg/UxBxStPAAE)

> [!TIP]
> Unsure how to get started? Check out [this guide I wrote!](https://tice.tips/containerization/palworld-server-docker/)

This is a Docker container to help you get started with hosting your own
[Palworld](https://store.steampowered.com/app/1623730/Palworld/) dedicated server.

This Docker container has been tested and will work on the following OS:

* Linux (Ubuntu/Debian)
* Windows 10,11
* MacOS (including Apple Silicon M1/M2/M3).

This container has also been tested and will work on both `x64` and `ARM64` based CPU architecture.

> [!IMPORTANT]
> Looking to host a server for Xbox players? [Follow this guide here!](https://palworld-server-docker.loef.dev/quick-setup-xbox)

## Sponsors

| Company                                                                                                                                                                                                                                                                                                                       | About                                                                                                                                                                                                                                            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <!-- markdownlint-disable-line --><a href="https://indifferentbroccoli.com/palworld-server-hosting"><img src="https://github.com/thijsvanloef/palworld-server-docker/assets/58031337/f091b205-d6be-49fe-a508-4a23087023a1" width="150px" alt="Indifferent Broccoli" /></a><p align="center">indifferent broccoli \(\:\|\)</p> | Thank you to our sponsor indifferent broccoli. If you decide to rent a Palworld server, rather than host yourself, try indifferent broccoli's [Palword server hosting](https://indifferentbroccoli.com/palworld-server-hosting) 2-day free trial |

### Massive shoutout to the following individual sponsors

<p align="left"><!-- markdownlint-disable-line --><!-- markdownlint-disable-next-line -->
<!-- sponsors --><a href="https://github.com/AshishT112203"><img src="https://github.com/AshishT112203.png" width="50px" alt="AshishT112203" /></a>&nbsp;&nbsp;<a href="https://github.com/stoprx"><img src="https://github.com/stoprx.png" width="50px" alt="stoprx" /></a>&nbsp;&nbsp;<a href="https://github.com/indifferentbroccoli"><img src="https://github.com/indifferentbroccoli.png" width="50px" alt="indifferentbroccoli" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## Official Documentation

[![Documentation](https://github.com/thijsvanloef/palworld-server-docker/assets/58031337/b92d76d1-5efb-438d-9ffd-5385544a831b)](https://palworld-server-docker.loef.dev/)

## Server Requirements

| Resource | Minimum | Recommended                              |
|----------|---------|------------------------------------------|
| CPU      | 4 cores | 4+ cores                                 |
| RAM      | 16GB    | Recommend over 32GB for stable operation |
| Storage  | 8GB     | 20GB                                     |

## How to use

Keep in mind that you'll need to change the [environment variables](#environment-variables).

### Docker Compose

This repository includes an example [docker-compose.yml](/docker-compose.yml) file you can use to set up your server.

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # Set to however long you are willing to wait for the container to gracefully stop
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
        # - 8212:8212/tcp  # Port for REST API if REST_API_ENABLED: true
      environment:
         PUID: 1000
         PGID: 1000
         PORT: 8211 # Optional but recommended
         PLAYERS: 16 # Optional but recommended
         SERVER_PASSWORD: "worldofpals" # Optional but recommended
         MULTITHREADING: true
         RCON_ENABLED: true
         RCON_PORT: 25575
         TZ: "UTC"
         ADMIN_PASSWORD: "adminPasswordHere"
         COMMUNITY: false  # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
         SERVER_NAME: "palworld-server-docker by Thijs van Loef"
         SERVER_DESCRIPTION: "palworld-server-docker by Thijs van Loef"
         ALLOW_CONNECT_PLATFORM: "Steam" # Defaults to "Steam" if not set, set this to "Xbox" if you want to host a server for Xbox players. CROSSPLAY BETWEEN XBOX-STEAM IS NOT YET SUPPORTED
      volumes:
         - ./palworld:/palworld/
```

As an alternative, you can copy the [.env.example](.env.example) file to a new file called **.env** file.
Modify it to your needs, check out the [environment variables](#environment-variables) section to check the correct
values. Modify your [docker-compose.yml](docker-compose.yml) to this:

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # Set to however long you are willing to wait for the container to gracefully stop
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
        # - 8212:8212/tcp  # Port for REST API if REST_API_ENABLED: true
      env_file:
         -  .env
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
    -v ./palworld:/palworld/ \
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
    -e SERVER_NAME="palworld-server-docker by Thijs van Loef" \
    -e SERVER_DESCRIPTION="palworld-server-docker by Thijs van Loef" \
    -e ALLOW_CONNECT_PLATFORM="Steam" \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```

As an alternative, you can copy the [.env.example](.env.example) file to a new file called **.env** file.
Modify it to your needs, check out the [environment variables](#environment-variables) section to check the
correct values. Change your docker run command to this:

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./palworld:/palworld/ \
    --env-file .env \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```

### Kubernetes

All files you will need to deploy this container to kubernetes are located in the [k8s folder](k8s/).

Follow the steps in the [README.md here](k8s/readme.md) to deploy it.

### Running without root

This is only for advanced users

It is possible to run this container and
[override the default user](https://docs.docker.com/engine/reference/run/#user) which is root in this image.

Because you are specifiying the user and group `PUID` and `PGID` are ignored.

If you want to find your UID: `id -u`
If you want to find your GID: `id -g`

You must set user to `NUMBERICAL_UID:NUMBERICAL_GID`

Below we assume your UID is 1000 and your GID is 1001

* In docker run add `--user 1000:1001 \` above the last line.
* In docker compose add `user: 1000:1001` above ports.

If you wish to run it with a different UID/GID than your own you will need to change the ownership of the directory that
is being bind: `chown UID:GID palworld/`
or by changing the permissions for all other: `chmod o=rwx palworld/`

#### Using helm chart

The official helm chart can be found in a seperate repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)

### Environment variables

You can use the following values to change the settings of the server on boot.
It is highly recommended you set the following environment values before starting the server:

* PLAYERS
* PORT
* PUID
* PGID

| Variable                                   | Info                                                                                                                                                                                                | Default Values                                                                                     | Allowed Values                                                                                                    | Added in Version |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|------------------|
| TZ                                         | Timezone used for time stamping backup server                                                                                                                                                       | UTC                                                                                                | See [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations)        | 0.1.0            |
| PLAYERS*                                   | Max amount of players that are able to join the server                                                                                                                                              | 16                                                                                                 | 1-32                                                                                                              | 0.1.0            |
| PORT*                                      | UDP port that the server will expose                                                                                                                                                                | 8211                                                                                               | 1024-65535                                                                                                        | 0.1.0            |
| PUID*                                      | The uid of the user the server should run as                                                                                                                                                        | 1000                                                                                               | !0                                                                                                                | 0.6.0            |
| PGID*                                      | The gid of the group the server should run as                                                                                                                                                       | 1000                                                                                               | !0                                                                                                                | 0.6.0            |
| MULTITHREADING**                           | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense.              | false                                                                                              | true/false                                                                                                        | 0.1.0            |
| COMMUNITY                                  | Whether or not the server shows up in the community server browser (USE WITH SERVER_PASSWORD)                                                                                                       | false                                                                                              | true/false                                                                                                        | 0.1.0            |
| PUBLIC_IP                                  | You can manually specify the global IP address of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |                                                                                                    | x.x.x.x                                                                                                           | 0.1.0            |
| PUBLIC_PORT                                | You can manually specify the port number of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration.       |                                                                                                    | 1024-65535                                                                                                        | 0.1.0            |
| SERVER_NAME                                | A name for your server                                                                                                                                                                              |                                                                                                    | "string"                                                                                                          | 0.1.0            |
| SERVER_DESCRIPTION                         | Your server Description                                                                                                                                                                             |                                                                                                    | "string"                                                                                                          | 0.1.0            |
| SERVER_PASSWORD                            | Secure your community server with a password                                                                                                                                                        |                                                                                                    | "string"                                                                                                          | 0.1.0            |
| ADMIN_PASSWORD                             | Secure administration access in the server with a password                                                                                                                                          |                                                                                                    | "string"                                                                                                          | 0.4.0            |
| UPDATE_ON_BOOT**                           | Update/Install the server when the docker container starts (THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER)                                                                            | true                                                                                               | true/false                                                                                                        | 0.3.0            |
| RCON_ENABLED***                            | Enable RCON for the Palworld server                                                                                                                                                                 | true                                                                                               | true/false                                                                                                        | 0.1.0            |
| RCON_PORT                                  | RCON port to connect to                                                                                                                                                                             | 25575                                                                                              | 1024-65535                                                                                                        | 0.1.0            |
| REST_API_ENABLED                           | Enable REST API for the palworld server                                                                                                                                                             | false                                                                                              | true/false                                                                                                        | 0.35.0           |
| REST_API_PORT                              | REST API port to connect to                                                                                                                                                                         | 8212                                                                                               | 1024-65535                                                                                                        | 0.35.0           |
| QUERY_PORT                                 | Query port used to communicate with Steam servers                                                                                                                                                   | 27015                                                                                              | 1024-65535                                                                                                        | 0.1.0            |
| ALLOW_CONNECT_PLATFORM                     | Specify if you are hosting a dedicated server for Steam or Xbox players                                                                                                                             | Steam                                                                                              | Steam/Xbox                                                                                                        | 0.38.0           |
| BACKUP_CRON_EXPRESSION                     | Setting affects frequency of automatic backups.                                                                                                                                                     | 0 0 \* \* \*                                                                                       | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](#configuring-automatic-backups-with-cron) | 0.19.0           |
| BACKUP_ENABLED                             | Enables automatic backups                                                                                                                                                                           | true                                                                                               | true/false                                                                                                        | 0.19.0           |
| USE_BACKUP_SAVE_DATA                       | Enables native automatic backups                                                                                                                                                                    | true                                                                                               | true/false                                                                                                        | 0.35.0           |
| DELETE_OLD_BACKUPS                         | Delete backups after a certain number of days                                                                                                                                                       | false                                                                                              | true/false                                                                                                        | 0.19.0           |
| OLD_BACKUP_DAYS                            | How many days to keep backups                                                                                                                                                                       | 30                                                                                                 | any positive integer                                                                                              | 0.19.0           |
| AUTO_UPDATE_CRON_EXPRESSION                | Setting affects frequency of automatic updates.                                                                                                                                                     | 0 \* \* \* \*                                                                                      | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](#configuring-automatic-backups-with-cron) | 0.20.0           |
| AUTO_UPDATE_ENABLED                        | Enables automatic updates                                                                                                                                                                           | false                                                                                              | true/false                                                                                                        | 0.20.0           |
| AUTO_UPDATE_WARN_MINUTES                   | How long to wait to update the server, after the player were informed. (This will be ignored, if no Players are connected)                                                                          | 30                                                                                                 | Integer                                                                                                           | 0.20.0           |
| AUTO_REBOOT_CRON_EXPRESSION                | Setting affects frequency of automatic updates.                                                                                                                                                     | 0 0 \* \* \*                                                                                       | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](#configuring-automatic-reboots-with-cron) | 0.21.0           |
| AUTO_REBOOT_ENABLED                        | Enables automatic reboots                                                                                                                                                                           | false                                                                                              | true/false                                                                                                        | 0.21.0           |
| AUTO_REBOOT_WARN_MINUTES                   | How long to wait to reboot the server, after the player were informed.                                                                                                                              | 5                                                                                                  | Integer                                                                                                           | 0.21.0           |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE         | Restart the Server even if there are players online.                                                                                                                                                | false                                                                                              | true/false                                                                                                        | 0.21.0           |
| TARGET_MANIFEST_ID                         | Locks game version to corespond with Manifest ID from Steam Download Depot.                                                                                                                         |                                                                                                    | See [Manifest ID Table](#locking-specific-game-version)                                                           | 0.27.0           |
| INSTALL_BETA_INSIDER                       | Installs the latest Beta version of the Palworld dedicated server                                                                                                                                   | false                                                                                              | true/false                                                                                                        | 0.38.0           |
| DISCORD_WEBHOOK_URL                        | Discord webhook url found after creating a webhook on a discord server.                                                                                                                             |                                                                                                    | `https://discord.com/api/webhooks/<webhook_id>`                                                                   | 0.22.0           |
| DISCORD_SUPPRESS_NOTIFICATIONS             | Enables/Disables `@silent` messages for the server messages.                                                                                                                                        | false                                                                                              | boolean                                                                                                           | 0.34.0           |
| DISCORD_CONNECT_TIMEOUT                    | Discord command initial connection timeout                                                                                                                                                          | 30                                                                                                 | !0                                                                                                                | 0.22.0           |
| DISCORD_MAX_TIMEOUT                        | Discord total hook timeout                                                                                                                                                                          | 30                                                                                                 | !0                                                                                                                | 0.22.0           |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE            | Discord message sent when server begins updating                                                                                                                                                    | Server is updating...                                                                              | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE_ENABLED    | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE_URL        | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_UPDATE_BOOT_MESSAGE           | Discord message sent when server completes updating                                                                                                                                                 | Server update complete!                                                                            | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_UPDATE_BOOT_MESSAGE_ENABLED   | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_POST_UPDATE_BOOT_MESSAGE_URL       | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_START_MESSAGE                  | Discord message sent when server begins to start                                                                                                                                                    | Server has been started!                                                                           | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_START_MESSAGE_ENABLED          | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PRE_START_MESSAGE_URL              | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_SHUTDOWN_MESSAGE               | Discord message sent when server begins to shutdown                                                                                                                                                 | Server is shutting down...                                                                         | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED       | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PRE_SHUTDOWN_MESSAGE_URL           | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_SHUTDOWN_MESSAGE              | Discord message sent when server has stopped                                                                                                                                                        | Server is stopped!                                                                                 | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED      | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_POST_SHUTDOWN_MESSAGE_URL          | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PLAYER_JOIN_MESSAGE                | Discord message sent when player joins the server                                                                                                                                                   | `player_name` has joined Palworld!                                                                 | "string"                                                                                                          | 0.31.0           |
| DISCORD_PLAYER_JOIN_MESSAGE_ENABLED        | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PLAYER_JOIN_MESSAGE_URL            | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PLAYER_LEAVE_MESSAGE               | Discord message sent when player leaves the server                                                                                                                                                  | `player_name` has left Palworld.                                                                   | "string"                                                                                                          | 0.31.0           |
| DISCORD_PLAYER_LEAVE_MESSAGE_ENABLED       | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PLAYER_LEAVE_MESSAGE_URL           | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_BACKUP_MESSAGE                 | Discord message when starting to create a backup                                                                                                                                                    | Creating backup...                                                                                 | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_BACKUP_MESSAGE_ENABLED         | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PRE_BACKUP_MESSAGE_URL             | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_BACKUP_MESSAGE                | Discord message when a backup has been made                                                                                                                                                         | Backup created at `file_path`                                                                      | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_BACKUP_MESSAGE_ENABLED        | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_POST_BACKUP_MESSAGE_URL            | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_BACKUP_DELETE_MESSAGE          | Discord message when starting to remove older backups                                                                                                                                               | Removing backups older than `old_backup_days` days                                                 | "string"                                                                                                          | 0.31.0           |
| DISCORD_PRE_BACKUP_DELETE_MESSAGE_ENABLED  | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_PRE_BACKUP_DELETE_MESSAGE_URL      | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_BACKUP_DELETE_MESSAGE         | Discord message when successfully removed older backups                                                                                                                                             | Removed backups older than `old_backup_days` days                                                  | "string"                                                                                                          | 0.31.0           |
| DISCORD_POST_BACKUP_DELETE_MESSAGE_ENABLED | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_POST_BACKUP_DELETE_MESSAGE_URL     | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISCORD_ERR_BACKUP_DELETE_MESSAGE          | Discord message when there has been an error removing older backups                                                                                                                                 | Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=`old_backup_days` | "string"                                                                                                          | 0.31.0           |
| DISCORD_ERR_BACKUP_DELETE_MESSAGE_ENABLED  | If the Discord message is enabled for this message                                                                                                                                                  | true                                                                                               | boolean                                                                                                           | 0.31.0           |
| DISCORD_ERR_BACKUP_DELETE_MESSAGE_URL      | Discord Webhook URL for this message (if left empty will use DISCORD_WEBHOOK_URL)                                                                                                                   |                                                                                                    | "string"                                                                                                          | 0.31.0           |
| DISABLE_GENERATE_SETTINGS                  | Whether to automatically generate the PalWorldSettings.ini                                                                                                                                          | false                                                                                              | true/false                                                                                                        | 0.24.0           |
| DISABLE_GENERATE_ENGINE                    | Whether to automatically generate the Engine.ini                                                                                                                                                    | true                                                                                               | true/false                                                                                                        | 0.30.0           |
| ENABLE_PLAYER_LOGGING                      | Enables Logging and announcing when players join and leave                                                                                                                                          | true                                                                                               | true/false                                                                                                        | 0.31.0           |
| PLAYER_LOGGING_POLL_PERIOD                 | Polling period (in seconds) to check for players who have joined or left                                                                                                                            | 5                                                                                                  | !0                                                                                                                | 0.31.0           |
| USE_DEPOT_DOWNLOADER                     | Uses DepotDownloader to download game server files instead of steamcmd. This will help hosts incompatible with steamcmd (e.g. M-series Mac)                                                    | false                                                                                              | true/false                                                                                                        | 0.39.0           |

*highly recommended to set

** Make sure you know what you are doing when running this option enabled

*** Required for docker stop to save and gracefully close the server

### ARM64-exclusive environment variables

ARM64 hosts can use the following variables to tweak their server setup. This includes
known relevant Box64 configurations one can modify for better server stability/performance.

For the Box64 configurations, please see the their official documentation for more info.

> [!TIP]
> Set `ARM64_DEVICE` to the most appropriate setting for your device. `generic` is expected
> to work on all devices but better stability can be found with specifying your device.
> For more specific device compatibility, create an issue on the
> [base image repo](https://github.com/sonroyaalmerol/steamcmd-arm64).

| Variable                                   | Info                                                                                                                                                                                                | Default Values                                                                                     | Allowed Values                                                                                                                                  | Added in Version |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|------------------|
| BOX64_DYNAREC_STRONGMEM                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_strongmem-)] Enable/Disable simulation of Strong Memory model                                                    | 1                                                                                              | 0, 1, 2, 3                                                                                                        | 0.23.0           |
| BOX64_DYNAREC_BIGBLOCK                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_bigblock-)] Enables/Disables Box64's Dynarec building BigBlock.                                                    | 1                                                                                              | 0, 1, 2, 3                                                                                                        | 0.23.0           |
| BOX64_DYNAREC_SAFEFLAGS                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_safeflags-)] Handling of flags on CALL/RET opcodes                                                    | 1                                                                                              | 0, 1, 2                                                                                                        | 0.23.0           |
| BOX64_DYNAREC_FASTROUND                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_fastround-)] Enable/Disable generation of precise x86 rounding                                                    | 1                                                                                              | 0, 1                                                                                                        | 0.23.0           |
| BOX64_DYNAREC_FASTNAN                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_fastnan-)] Enable/Disable generation of -NAN                                                    | 1                                                                                              | 0, 1                                                                                                        | 0.23.0           |
| BOX64_DYNAREC_X87DOUBLE                     | [[Box64 config](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_x87double-)] Force the use of Double for x87 emulation                                                    | 0                                                                                              | 0, 1                                                                                                        | 0.23.0           |
| ARM64_DEVICE                     | Specify Box64 build to be used based on host device. This setting is only applicable for ARM64 hosts.                                                    | generic                                                                                              | generic, m1, rpi5, adlink                                                                                                        | 0.39.0           |

### Game Ports

| Port  | Info                |
|-------|---------------------|
| 8211  | Game Port (UDP)     |
| 8212  | REST API Port (TCP) |
| 27015 | Query Port (UDP)    |
| 25575 | RCON Port (TCP)     |

## Using RCON

RCON is enabled by default for the palworld-server-docker image.
Opening the RCON CLI is quite easy:

```bash
docker exec -it palworld-server rcon-cli "<command> <value>"
```

For example, you can broadcast a message to everyone in the server with the following command:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hello everyone"
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
| UnBanPlayer {SteamID}            | Unban player {SteamID} from the server.             |

For a full list of commands go to: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)

## Using REST API

REST API is not enabled by default.
If used, please set REST_API_ENABLED to true.

docker-compose.override.yml

```yaml
services:
  palworld:
    environment:
      REST_API_ENABLED: true
```

The palworld-server-docker image provides rcon-cli as well as rest-cli.

```bash
$ docker exec -it palworld-server rest-cli
Usage: rest-cli <api> [options]
api:
  announce <json> ... announce message.
  ban <json>      ... ban player.
  info            ... show server informations.
  kick <json>     ... kick player.
  metrics         ... show server metrics.
  players         ... show online players.
  save            ... save the world.
  settings        ... show server settings.
  shutdown <json> ... shutdown server.
  stop            ... force stop server.
  unban <json>    ... unban player.
options:
  '{...}'         ... json.
  -               ... json from stdin.
  -h, --help      ... help.
```

For example, you can broadcast a message to everyone in the server with the following command:

CLI parameter style:

```bash
docker exec -i palworld-server rest-cli announce "Broadcast Hello everyone"
```

JSON parameter style:

```bash
docker exec -i palworld-server rest-cli announce '{"message":"Broadcast Hello everyone"}'
```

JSON pipe style:

```bash
echo '{"message":"Broadcast Hello everyone"}' | docker exec -i palworld-server rest-cli announce -
```

rest-cli allows you to call REST APIs directly without exposing ports outside the container.

### List of REST APIs

| API                              | Info                        |
|----------------------------------|-----------------------------|
| info                             | Get the server information. |
| players                          | Get player list.            |
| settings                         | Get the server settings.    |
| metrics                          | Get the server metrics.     |
| announce                         | Announce message.           |
| kick {SteamID}                   | Kick player.                |
| ban {SteamID}                    | Ban player.                 |
| unban {SteamID}                  | Unban player.               |
| save                             | Save the world.             |
| shutdown {Seconds} {MessageText} | Shutdown the server         |
| stop                             | Force stop the server.      |

For an official documents go to: [https://tech.palworldgame.com/category/rest-api](https://tech.palworldgame.com/category/rest-api)

## Creating a backup

To create a backup of the game's save at the current point in time, use the command:

```bash
docker exec palworld-server backup
```

This will create a backup at `/palworld/backups/`

The server will run a save before the backup if rcon is enabled.

## Restore from a backup

To restore from a backup, use the command:

```bash
docker exec -it palworld-server restore
```

The `RCON_ENABLED` environment variable must be set to `true` to use this command.
> [!IMPORTANT]
> If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be
> manually restarted.
>
> The example docker run command and docker compose file in [How to Use](#how-to-use) already uses the needed policy

## Manually restore from a backup

Locate the backup you want to restore in `/palworld/backups/` and decompress it.
Need to stop the server before task.

```bash
docker compose down
```

Delete the old saved data folder located at `palworld/Pal/Saved/SaveGames/0/<old_hash_value>`.

Copy the contents of the newly decompressed saved data folder `Saved/SaveGames/0/<new_hash_value>` to `palworld/Pal/Saved/SaveGames/0/<new_hash_value>`.

Replace the DedicatedServerName inside `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` with the new folder name.

```ini
DedicatedServerName=<new_hash_value>  # Replace it with your folder name.
```

Restart the game. (If you are using Docker Compose)

```bash
docker compose up -d
```

## Configuring Automatic Backups with Cron

The server is automatically backed up everynight at midnight according to the timezone set with TZ

Set BACKUP_ENABLED enable or disable automatic backups (Default is enabled)

BACKUP_CRON_EXPRESSION is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

> [!TIP]
> This image uses Supercronic for crons
> see [supercronic](https://github.com/aptible/supercronic#crontab-format)
> or
> [Crontab Generator](https://crontab-generator.org).

Set BACKUP_CRON_EXPRESSION to change the default schedule.
Example Usage: If BACKUP_CRON_EXPRESSION to `0 2 * * *`, the backup script will run every day at 2:00 AM.

## Configuring Automatic Updates with Cron

To be able to use automatic Updates with this Server the following environment variables **have** to be set to `true`:

* RCON_ENABLED
* UPDATE_ON_BOOT

> [!IMPORTANT]
>
> If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be
> manually restarted.
>
> The example docker run command and docker compose file in [How to Use](#how-to-use) already use the needed policy

Set AUTO_UPDATE_ENABLED enable or disable automatic updates (Default is disabled)

AUTO_UPDATE_CRON_EXPRESSION is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

> [!TIP]
> This image uses Supercronic for crons
> see [supercronic](https://github.com/aptible/supercronic#crontab-format)
> or
> [Crontab Generator](https://crontab-generator.org).

Set AUTO_UPDATE_CRON_EXPRESSION to change the default schedule.

## Configuring Automatic Reboots with Cron

To be able to use automatic reboots with this server RCON_ENABLED enabled.

> [!IMPORTANT]
>
> If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be
> manually restarted.
>
> The example docker run command and docker compose file in [How to Use](#how-to-use) already use the needed policy

Set AUTO_REBOOT_ENABLED enable or disable automatic reboots (Default is disabled)

AUTO_REBOOT_CRON_EXPRESSION is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

> [!TIP]
> This image uses Supercronic for crons
> see [supercronic](https://github.com/aptible/supercronic#crontab-format)
> or
> [Crontab Generator](https://crontab-generator.org).

Set AUTO_REBOOT_CRON_EXPRESSION to change the set the schedule, default is everynight at midnight according to the
timezone set with TZ

## Editing Server Settings

### With Environment Variables

> [!IMPORTANT]
>
> These Environment Variables/Settings are subject to change since the game is still in beta.
> Check out the [official webpage for the supported parameters.](https://tech.palworldgame.com/optimize-game-balance)

Converting server settings to environment variables follow the same principles (with some exceptions):

* all capital letters
* split words by inserting an underscore
* remove the single letter if the setting starts with one (like 'b')

For example:

* Difficulty -> DIFFICULTY
* PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
* bIsPvP -> IS_PVP

| Variable                                  | Description                                                                                                                                                      | Default Value                                                                                | Allowed Value                          |
|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | Game Difficulty                                                                                                                                                  | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | Day time speed - Larger number means shorter days                                                                                                                | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | Night time speed - Larger number means shorter nights                                                                                                            | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | EXP earn rate                                                                                                                                                    | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | Pal capture rate                                                                                                                                                 | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | Pal appearance rate                                                                                                                                              | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | Damage from pals multipiler                                                                                                                                      | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | Damage to pals multipiler                                                                                                                                        | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | Damage from player multipiler                                                                                                                                    | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | Damage to  player multipiler                                                                                                                                     | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | Player hunger depletion rate                                                                                                                                     | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | Player stamina reduction rate                                                                                                                                    | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | Player auto HP regeneration rate                                                                                                                                 | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | Player sleep HP regeneration rate                                                                                                                                | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | Pal hunger depletion rate                                                                                                                                        | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | Pal stamina reduction rate                                                                                                                                       | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | Pal auto HP regeneration rate                                                                                                                                    | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | Pal sleep health regeneration rate (in Palbox)                                                                                                                   | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | Damage to structure multipiler                                                                                                                                   | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | Structure determination rate                                                                                                                                     | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | Getherable items multipiler                                                                                                                                      | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | Getherable objects HP multipiler                                                                                                                                 | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | Getherable objects respawn interval - The smaller the number, the faster the regeneration                                                                        | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | Dropped Items Multipiler                                                                                                                                         | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | Death Penalty</br>None: No death penalty</br>Item: Drops items other than equipment</br>ItemAndEquipment: Drops all items</br>All: Drops all PALs and all items. | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | Allows players to cause damage to players                                                                                                                        | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | Allow friendly fire                                                                                                                                              | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | Enable invaders                                                                                                                                                  | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | Enable UNKO (?)                                                                                                                                                  | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | Enable controller aim assist                                                                                                                                     | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | Enable Keyboard aim assist                                                                                                                                       | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | Maximum number of drops in the world                                                                                                                             | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | Maximum number of UNKO drops in the world                                                                                                                        | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | Maximum number of base camps                                                                                                                                     | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAX_NUM                  | Maximum number of workers                                                                                                                                        | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | Time it takes for items to despawn in hours                                                                                                                      | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | Automatically reset guild when no players are online                                                                                                             | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | Time to automatically reset guild when no players are online                                                                                                     | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | Max player of Guild                                                                                                                                              | 20                                                                                           | Integer                                |
| BASE_CAMP_MAX_NUM_IN_GUILD                | Max bases of Guild                                                                                                                                               | 4                                                                                            | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | Time(h) to incubate massive egg                                                                                                                                  | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | Work speed muliplier                                                                                                                                             | 1.000000                                                                                     | Float                                  |
| AUTO_SAVE_SPAN                           | Time between autosaves (seconds)                                                                                                                                             | 30.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | Enable multiplayer                                                                                                                                               | False                                                                                        | Boolean                                |
| IS_PVP                                    | Enable PVP                                                                                                                                                       | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | Allow players from other guilds to pick up death penalty items                                                                                                   | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | Enable non-login penalty                                                                                                                                         | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | Enable fast travel                                                                                                                                               | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | Enable selecting of start location                                                                                                                               | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | Toggle for deleting players when they log off                                                                                                                    | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | Allows defense against other guild players                                                                                                                       | False                                                                                        | Boolean                                |
| INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX         | unknown                                                                                                                       | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | Maximum number of players in a guild                                                                                                                             | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                                                                                                                           |                                                                                              | String                                 |
| USEAUTH                                   | Use authentication                                                                                                                                               | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | Which ban list to use                                                                                                                                            | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |
| SHOW_PLAYER_LIST                          | Enable show player list                                                                                                                                          | True                                                                                         | Boolean                                |
| SUPPLY_DROP_SPAN                          |  Interval for supply drop (minutes)                                                                                                                                         | 180                                                                                         | Integer                                |

### Manually

When the server starts, a `PalWorldSettings.ini` file will be created in the following location: `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Please keep in mind that the ENV variables will always overwrite the changes made to `PalWorldSettings.ini`.

> [!IMPORTANT]
> Changes can only be made to `PalWorldSettings.ini` while the server is off.
>
> Any changes made while the server is live will be overwritten when the server stops.

For a more detailed list of server settings go to: [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

For more detailed server settings explanations go to: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

## Using discord webhooks

1. Generate a webhook url for your discord server in your discord's server settings.

2. Set the environment variable with the unique token at the end of the discord webhook url example: `https://discord.com/api/webhooks/1234567890/abcde`

send discord messages with docker run:

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
```

send discord messages with docker compose:

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Server is updating...
```

## Locking Specific Game Version

>[!WARNING]
>Downgrading to a lower game version is possible, but it is unknown what impact it will have on existing saves.
>
>**Please do so at your own risk!**

If **TARGET_MANIFEST_ID** environment variable is set, will lock server version to specific manifest.
The manifest corresponds to the release date/update versions. Manifests can be found using SteamCMD or websites like [SteamDB](https://steamdb.info/depot/2394012/manifests/).

### Version To Manifest ID Table

| Version | Manifest ID         |
|---------|---------------------|
| 0.1.3.0 | 1354752814336157338 |
| 0.1.4.0 | 4190579964382773830 |
| 0.1.4.1 | 6370735655629434989 |
| 0.1.5.0 | 3750364703337203431 |
| 0.1.5.1 | 2815085007637542021 |
| 0.2.0.6 | 1677469329840659324 |
| 0.2.1.0 | 8977386334474359538 |

## Reporting Issues/Feature Requests

Issues/Feature requests can be submitted by using [this link](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).

### Known Issues

Known issues are listed in the [documentation](https://palworld-server-docker.loef.dev/known-issues/)
