---
sidebar_position: 3
title: Aktualisieren des Palworld-Server-Docker-Container
description: So aktualisieren Sie Ihren dedizierten Palworld-Server-Docker-Container, um die neuesten Funktionen zu genießen.
keywords: [Palworld, palworld dedicated server, Palworld Aktualisierung, Palworld dedicated server Aktualisierung]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Docker-Container aktualisieren
---
<!-- markdownlint-disable-next-line -->
# Aktualisieren des Palworld-Server-Docker-Container

So aktualisieren Sie Ihren dedizierten Palworld-Server-Docker-Container, um die neuesten Funktionen zu genießen.

## Docker Compose

1. Öffnen Sie die docker-compose.yml.
2. Überprüfen Sie, ob Ihr Abbild entweder:

    ```yml
    image: thijsvanloef/palworld-server-docker:latest
    ```

    oder

    ```yml
    image: thijsvanloef/palworld-server-docker:<release-version>  ## Beispiel: v0.32.0
    ```

3. Führen Sie `docker compose down --rmi all` aus, um sicherzustellen, dass kein anderes Palworld-Abbild vorhanden ist.
4. Führen Sie `docker compose up -d` aus, um den Container hochzufahren.

## Docker Run

1. Führen Sie `docker stop palworld-server` aus.
2. Führen Sie `docker rm palworld-server` aus.
<!-- markdownlint-disable-next-line -->
3. Führen Sie das [Docker-Run-Befehl](https://palworld-server-docker.loef.dev/de/#docker-run) erneut mit dem `latest`-Tag aus.
