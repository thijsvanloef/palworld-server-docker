# Palworld Dedicated Server Docker

![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)
![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)
![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)
![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)

[View on Docker Hub](https://hub.docker.com/repository/docker/thijsvanloef/palworld-server-docker)

> **_NOTE:_**  Unsure how to get started? Check out the [this guide I wrote!](https://tice.tips/containerization/palworld-server-docker/)  

This is a Docker container to help you get started with hosting your own [Palworld](https://store.steampowered.com/app/1623730/Palworld/) dedicated server.

This Docker container has been tested and will work on both Linux (Ubuntu/Debian) and Windows 10.

## How to use

Keep in mind that you'll need to change the [environment variables](##Environment-variables).

### Docker Compose

This repository includes an example [docker-compose.yml](example/docker-compose.yml) file you can use to setup your server.

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker
      restart: unless-stopped
      container_name: palworld-server
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         - PORT=8211
         - PLAYERS=16
         - MULTITHREADING=FALSE
         - COMMUNITY=false  # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
         # Enable the environment variables below if you have COMMUNITY=true
         # - SERVER_PASSWORD="worldofpals"
         # - SERVER_NAME="World of Pals"
         # - ADMIN_PASSWORD="someAdminPassword"
      volumes:
         - /path/to/your/palworld/folder:/palworld/
```

### Docker Run

Change every <> to your own configuration

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./<palworld-folder>:/palworld/ \
    -e PLAYERS=16 \
    -e PORT=8211 \
    -e COMMUNITY=false \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker

```

### Environment variables

You can use the following values to change the settings of the server on boot.
It is highly recommended you set the following environment values before starting the server:

* PLAYERS
* PORT
* MULTITHREADING

| Variable         | Info                                                                                                                                                                                               | Default Values | Allowed Values |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------- |
| PLAYERS*         | Max amount of players that are able to join the server                                                                                                                                             | 16             | 1-31           |
| PORT*            | UDP port that the server will expose                                                                                                                                                               | 8211           | 1024-65535     |
| MULTITHREADING** | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense.             | false          | true/false     |
| COMMUNITY        | Whether or not the server shows up in the community server browser (USE WITH SERVER_PASSWORD)                                                                                                      | false          | true/false     |
| PUBLIC_IP        | You can manually specify the global IP address of the network on which the server running.If not specified, it will be detected automatically. If it does not work well, try manual configuration. |                | x.x.x.x        |
| PUBLIC_PORT      | You can manually specify the port number of the network on which the server running.If not specified, it will be detected automatically. If it does not work well, try manual configuration.       |                | x.x.x.x        |
| SERVER_NAME      | A name for your community server                                                                                                                                                                   |                | "string"       |
| SERVER_PASSWORD  | Secure your community server with a password                                                                                                                                                       |                | "string"       |
| ADMIN_PASSWORD   | Secure administration access in the server with a password                                                                                                                                         |                | "string"       |
| UPDATE_ON_BOOT** | Update/Install the server when the docker container starts (THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER)                                                                           | true           | true/false     |


*highly recommended to set

** Make sure you know what you are doing when running this this option enabled

### Game Ports

| Port  | Info             | note                                           |
| ----- | ---------------- | ---------------------------------------------- |
| 8211  | Game Port (UDP)  |                                                |
| 27015 | Query Port (UDP) | You are not able to change this port as of now |

## Reporting Issues/Feature Requests

Issues/Feature requests can be submitted by using [this link](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).
