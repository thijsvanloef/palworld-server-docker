---
sidebar_position: 1
slug: /
---

# Configuração rápida

Vamos começar a configurar um servidor dedicado do Palworld!

:::warning
De momento, os jogadores Xbox Gamepass/Xbox Console não podem entrar nos servidores dedicados.

Eles podem se juntar a outros jogadores com códigos de convite e estão limitados a 4 jogadores.
:::

## Pré-requisitos

- Virtualização ativa no BIOS/UEFI
- Precisam de ter o [Docker](https://docs.docker.com/engine/install/) instalado

## Requisitos do servidor

| Recurso       | Mínimo  | Recomendado                                    |
| ------------- | ------- | ---------------------------------------------- |
| CPU           | 4 cores | 4+ cores                                       |
| RAM           | 16GB    | Recomendado mais de 32GB para operação estável |
| Armazenamento | 8GB     | 20GB                                           |

## Docker Compose

Este repositório inclui o ficheiro exemplo
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
que podes utilizar para configurar o teu servidor.

```yml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
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
      COMMUNITY: false # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
      SERVER_NAME: "palworld-server-docker by Thijs van Loef"
      SERVER_DESCRIPTION: "palworld-server-docker by Thijs van Loef"
    volumes:
      - ./palworld:/palworld/
```

<!-- markdownlint-disable-next-line -->

Como alternativa, podes copiar o ficheiro
[.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example)
para um novo ficheiro com o nome **.env**.

<!-- markdownlint-disable-next-line -->

Modifica o ficheiro conforme as tuas necessidades, vai á secção
[environment variables](/pt-PT/getting-started/configuration/server-settings#variáveis-do-ambiente)
para verificar os valores corretos.

<!-- markdownlint-disable-next-line -->

Modifica o teu [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
para:

```yml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
    restart: unless-stopped
    container_name: palworld-server
    stop_grace_period: 30s # Set to however long you are willing to wait for the container to gracefully stop
    ports:
      - 8211:8211/udp
      - 27015:27015/udp
    env_file:
      - .env
    volumes:
      - ./palworld:/palworld/
```

### Iniciar o servidor

Usa `docker compose up -d` na mesma diretoria que `docker-compose.yml` para iniciar o servidor em segundo plano.

### Parar o servidor

Usa `docker compose stop` na mesma diretoria que `docker-compose.yml` para parar o servidor.

Usa `docker compose down --rmi all` na mesma diretoria que `docker-compose.yml` para parar,
remover o servidor e remover a imagem docker do teu computador.

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
    thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
```

<!-- markdownlint-disable-next-line -->

Como alternativa, podes copiar o ficheiro
[.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example)
para um novo ficheiro com o nome **.env**.

<!-- markdownlint-disable-next-line -->

Modifica o ficheiro conforme as tuas necessidades, vai á secção
[environment variables](/pt-PT/getting-started/configuration/server-settings#variáveis-do-ambiente)
para verificar os valores corretos.

Modifica o commando docker run para:

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./palworld:/palworld/ \
    --env-file .env \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
```
