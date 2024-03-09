---
sidebar_position: 3
title: How to update the palworld-server-docker container
description: How to update your Palworld dedicated server docker container to enjoy the latest features.
keywords: [Palworld, palworld dedicated server, Palworld Update, Palworld dedicated server update]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Update the docker container
---
<!-- markdownlint-disable-next-line -->
# How to update the docker container

How to update your Palworld dedicated server docker container to enjoy the latest features.

## docker compose

1. Open the docker-compose.yml
2. Check if your image is either:

    ```yml
    image: thijsvanloef/palworld-server-docker:latest
    ```

    or

    ```yml
    image: thijsvanloef/palworld-server-docker:<release-version>  ## For example: v0.32.0
    ```

3. Run `docker compose down --rmi all` to make sure that there is no other palworld image
4. Run `docker compose up -d` to bring up the container

## docker run

1. Run `docker stop palworld-server`
2. Run `docker rm palworld-server`
3. Run the [docker run command](https://palworld-server-docker.loef.dev/#docker-run) again with the `latest` tag
