# Palworld server docker

![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)
![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)
![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)
![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)

[View on Docker Hub](https://hub.docker.com/repository/docker/thijsvanloef/palworld-server-docker)

This is a Dockerized version of the [Palworld](https://store.steampowered.com/app/1623730/Palworld/) dedicated server.

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
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker

```

### Environment variables

You can use the following values to change the settings of the server on boot.
It is highly recommended you set the following environment values before starting the server:

* PLAYERS
* PORT
* MULTITHREADING

| Variable         | Info                                                                                                                                                                                   | Default Values | Allowed Values |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------|
| PLAYERS*         | Max amount of players that are able to join the server                                                                                                                                 | 16             | 1-31           |
| PORT*            | UDP port that the server will expose                                                                                                                                                   | 8211           | 1024-65535     |
| MULTITHREADING** | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense. | false          | true/false     |

*highly recommended to set

** Make sure you know what you are doing when running this this option enabled

### Game Ports

| Port  | Info             | note                                           |
|-------|------------------|------------------------------------------------|
| 8211  | Game Port (UDP)  |                                                |
| 27015 | Query Port (UDP) | You are not able to change this port as of now |

## Reporting Issues/Feature Requests

Issues/Feature requests can be submitted by using [this link](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).
