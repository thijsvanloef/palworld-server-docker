---
sidebar_position: 1
slug: /
title: Palworld Dedicated server Quick Setup
description: This guide will help you get setup with hosting your Palworld Dedicated server on Docker! This Palworld server quick setup will only take a couple of minutes and you'll have a working server.
keywords: [Palworld, palworld dedicated server, how to setup palworld dedicated server, palworld server docker, palworld docker]
image: ../assets/Palworld_Banner.jpg
sidebar_label: Quick Setup
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated server Quick Setup

This guide will help you get setup with hosting your Palworld Dedicated server on Docker!
This Palworld server quick setup will only take a couple of minutes and you'll have a working server.

## Prerequisites

:::warning
At the moment, Xbox Gamepass/Xbox Console players will not be able to join a dedicated server.

They will need to join players using the invite code and are limited to sessions of 4 players max.
:::

* Virtualization enabled in the BIOS/UEFI
* Must have [Docker](https://docs.docker.com/engine/install/) installed

## Server Requirements

| Resource | Minimum | Recommended                              |
|----------|---------|------------------------------------------|
| CPU      | 4 cores | 4+ cores                                 |
| RAM      | 16GB    | Recommend over 32GB for stable operation |
| Storage  | 8GB     | 20GB                                     |

## Docker Compose

This repository includes an example
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
file you can use to set up your server.

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
        # - 8212:8212/tcp   # Port for REST API if REST_API_ENABLED: true
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
      volumes:
         - ./palworld:/palworld/
```
<!-- markdownlint-disable-next-line -->
As an alternative, you can copy the [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) file to a new file called **.env** file.
<!-- markdownlint-disable-next-line -->
Modify it to your needs, check out the [environment variables](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings#environment-variables) section to check the correct 
values.
<!-- markdownlint-disable-next-line -->
Modify your [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml) to this:

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

### Starting the server

Use `docker compose up -d` in the same folder as the `docker-compose.yml` to start the server in the background

### Stopping the server

Use `docker compose stop` in the same folder as the `docker-compose.yml` to stop the server

Use `docker compose down --rmi all` in the same folder as the `docker-compose.yml`
to stop and remove the server and remove the docker image from your computer

## Docker Run

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
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```
<!-- markdownlint-disable-next-line -->
As an alternative, you can copy the [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) file to a new file called **.env** file.
<!-- markdownlint-disable-next-line -->
Modify it to your needs, check out the [environment variables](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings#environment-variables) section to check the
correct values.

Change your docker run command to this:

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
