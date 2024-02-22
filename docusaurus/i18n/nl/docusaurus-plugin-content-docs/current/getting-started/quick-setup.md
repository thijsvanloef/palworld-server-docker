---
sidebar_position: 1
slug: /
---

# Snelle Installatie

Laten we je op weg helpen met de Palworld Dedicated server!

:::warning
Op dit moment zullen Xbox Gamepass/Xbox Console spelers niet in staat zijn om zich bij een dedicated server aan te sluiten.

Ze moeten spelers die de uitnodigingscode gebruiken om deel te nemen en zijn beperkt tot sessies van maximaal 4 spelers.
:::

## Prerequisites

* Virtualisatie ingeschakeld in de BIOS/UEFI
* Moet [Docker](https://docs.docker.com/engine/install/) geïnstalleerd hebben.

## Server Requirements

| Resource | Minimum | Recommended                              |
|----------|---------|------------------------------------------|
| CPU      | 4 cores | 4+ cores                                 |
| RAM      | 16GB    | Aanbevolen is meer dan 32GB voor stabiele werking |
| Storage  | 8GB     | 20GB                                     |

## Docker Compose

Deze repository bevat een voorbeeld
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
bestand dat je kunt gebruiken om je server in te stellen.

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
Als alternatief kun je het [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) bestand kopiëren naar een nieuw bestand genaamd .env.
<!-- markdownlint-disable-next-line -->
Pas het aan naar jouw behoeften, bekijk de [environment variables](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings#environment-variables) sectie om de juiste waarden te controleren.
<!-- markdownlint-disable-next-line -->
Pas je [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml) aan naar dit:

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
      env_file:
         -  .env
      volumes:
         - ./palworld:/palworld/
```

### De server starten

Gebruik `docker compose up -d` in dezelfde map als de `docker-compose.yml` om de server op de achtergrond te starten.

### De server stoppen

Gebruik `docker compose stop` in dezelfde map als de `docker-compose.yml` om de server te stoppen.

Gebruik `docker compose down --rmi all` in dezelfde map als de `docker-compose.yml`
om de server te stoppen en te verwijderen, en om het docker-image van je computer te verwijderen.

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
Als alternatief kun je het [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) bestand kopiëren naar een nieuw bestand genaamd .env.
<!-- markdownlint-disable-next-line -->
Pas het aan naar jouw behoeften, bekijk de [environment variables](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings#environment-variables) sectie om de juiste waarden te controleren.

Pas je docker run commando aan naar dit:

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
