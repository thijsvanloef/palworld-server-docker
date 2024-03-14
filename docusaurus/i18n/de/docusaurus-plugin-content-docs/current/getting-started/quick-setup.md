---
sidebar_position: 1
slug: /
title: Palworld Dedicated Server-Schnelleinrichtung
description: Diese Anleitung wird Ihnen dabei helfen, Ihren Palworld Dedicated Server mit Docker zu hosten! Mit dieser Anleitung dauert die Einrichtung des Palworld-Servers  nur ein paar Minuten, und Sie haben einen laufenden Server.
keywords: [Palworld, palworld dedicated server, schnelleinrichtung palworld dedicated server, palworld server docker, palworld docker]
image: ../assets/Palworld_Banner.jpg
sidebar_label: Schnelleinrichtung
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server-Schnelleinrichtung

Diese Anleitung wird Ihnen dabei helfen, Ihren Palworld Dedicated Server mit Docker zu hosten!
Mit dieser Anleitung dauert die Einrichtung des Palworld-Servers  nur ein paar Minuten, und Sie haben einen laufenden Server.

## Voraussetzungen

:::warning
Zum aktuellen Zeitpunkt können Xbox Gamepass/Xbox-Konsolenspieler nicht an einem dedizierten Server teilnehmen.

Sie müssen sich Spielern mit einem Einladungscode anschließen und sind auf Sitzungen mit maximal 4 Spielern beschränkt.
:::

* Virtualisierung im BIOS/UEFI aktiviert
* [Docker](https://docs.docker.com/engine/install/) installiert

## Server-Anforderungen

| Ressource | Mindestens | Empfohlen                                 |
|-----------|------------|-------------------------------------------|
| CPU       | 4 Kerne    | 4+ Kerne                                  |
| RAM       | 16GB       | Empfohlen über 32GB für stabilen Betrieb  |
| Speicher  | 8GB        | 20GB                                      |

## Docker Compose

Dieses Repository enthält eine Beispiel
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
Datei, die Sie verwenden können, um Ihren Server aufzusetzen.

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # Auf die Zeit festlegen, die Sie bereit sind zu warten, bis der Container ordnungsgemäß beendet ist
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         PUID: 1000
         PGID: 1000
         PORT: 8211 # Optional, aber empfohlen
         PLAYERS: 16 # Optional, aber empfohlen
         SERVER_PASSWORD: "worldofpals" # Optional, aber empfohlen
         MULTITHREADING: true
         RCON_ENABLED: true
         RCON_PORT: 25575
         TZ: "UTC"
         ADMIN_PASSWORD: "adminPasswordHere"
         COMMUNITY: false  # Aktivieren Sie dies, wenn Ihr Server im Tab für Community-Server angezeigt werden soll, VERWENDEN SIE ES AUSSCHLIEẞLICH MIT SERVER_PASSWORD!
         SERVER_NAME: "palworld-server-docker by Thijs van Loef"
         SERVER_DESCRIPTION: "palworld-server-docker von Thijs van Loef"
      volumes:
         - ./palworld:/palworld/
```
<!-- markdownlint-disable-next-line -->
Als Alternative können Sie die [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) Datei in eine neue Datei mit dem Namen **.env** kopieren.
<!-- markdownlint-disable-next-line -->
Passen Sie es an Ihre Bedürfnisse an, sehen Sie sich die [Umgebungsvariablen-Übersicht](https://palworld-server-docker.loef.dev/de/getting-started/configuration/server-settings#umgebungsvariablen) an, um die korrekten Werte zu überprüfen.
<!-- markdownlint-disable-next-line -->
Ändern Sie Ihre [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml) wie folgt:

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # die Zeit, die Sie bereit sind zu warten, bis der Container ordnungsgemäß beendet ist
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      env_file:
         -  .env
      volumes:
         - ./palworld:/palworld/
```

### Starten des Servers

Verwenden Sie `docker compose up -d` im gleichen Ordner wie die `docker-compose.yml`, um den Server im Hintergrund zu
starten.

### Stoppen des Servers

Verwenden Sie `docker compose stop` im gleichen Ordner wie die `docker-compose.yml`, um den Server zu stoppen.

Nutzen Sie `docker compose down --rmi all` im gleichen Ordner wie die `docker-compose.yml`, um den Server zu stoppen und
zu entfernen und das Docker-Image von Ihrem System zu entfernen.

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
    -e SERVER_DESCRIPTION="palworld-server-docker von Thijs van Loef" \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```
<!-- markdownlint-disable-next-line -->
Als Alternative können Sie die [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) Datei in eine neue Datei mit dem Namen **.env** kopieren.
<!-- markdownlint-disable-next-line -->
Passen Sie es an Ihre Bedürfnisse an, sehen Sie sich die [Umgebungsvariablen-Übersicht](https://palworld-server-docker.loef.dev/de/getting-started/configuration/server-settings#umgebungsvariablen) an, um die korrekten Werte zu überprüfen.

Ändern Sie Ihren `docker run` Befehl wie folgt:

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
