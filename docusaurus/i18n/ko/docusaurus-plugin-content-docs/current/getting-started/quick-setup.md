---
sidebar_position: 1
slug: /
title: 팔월드 데디케이드 서버 빠른설정
description: 이 가이드는 팔월드 데디케이드 서버를 도커에서 설정하는 방법입니다! 불과 몇분만에 데디케이드 서버를 설정해보세요.
keywords: [Palworld, palworld dedicated server, how to setup palworld dedicated server, palworld server docker, palworld docker]
image: ../assets/Palworld_Banner.jpg
sidebar_label: 빠른설정
---
<!-- markdownlint-disable-next-line -->
# 빠른 설정

Palworld 전용 서버를 이용해 보세요!

:::warning
현재 Xbox Gamepass/Xbox 콘솔 플레이어는 전용 서버에 참여할 수 없습니다.

초대 코드를 통해 다른 플레이어들과 함께 게임을 즐길 수 있으며, 게임은 최대 4명의 플레이어로 제한됩니다.
:::

## 서버 요구 사양

| 리소스 | 최소    | 추천                                |
| ------ | ------- | ----------------------------------- |
| CPU    | 4 cores | 4+ cores                            |
| RAM    | 16GB    | 안정적인 운영을 위해 32GB 이상 권장 |
| 저장소 | 8GB     | 20GB                                |

## Docker Compose

이 저장소에는 서버를 설정하는 데 사용할 수 있는
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml) 예제 파일이 포함되어 있습니다.

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # 컨테이너가 정상적으로 중지될 때까지 기다리는 시간을 설정합니다.
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         PUID: 1000
         PGID: 1000
         PORT: 8211 # 선택사항이지만 설정하는 것을 권장합니다.
         PLAYERS: 16 # 선택사항이지만 설정하는 것을 권장합니다.
         SERVER_PASSWORD: "worldofpals" # 선택사항이지만 설정하는 것을 권장합니다.
         MULTITHREADING: true
         RCON_ENABLED: true
         RCON_PORT: 25575
         TZ: "UTC"
         ADMIN_PASSWORD: "adminPasswordHere"
         COMMUNITY: false  # 커뮤니티 서버 탐색기에 서버가 표시 되는 것을 허용합니다 (SERVER_PASSWORD 와 함께 사용하는 것을 권장합니다)
         SERVER_NAME: "palworld-server-docker by Thijs van Loef"
         SERVER_DESCRIPTION: "palworld-server-docker by Thijs van Loef"
      volumes:
         - ./palworld:/palworld/
```
<!-- markdownlint-disable-next-line -->
환경 변수를 설정하는 또 다른 방법으로 [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) 파일을 **.env** 라는 새로운 파일에 복사할 수 있습니다.
<!-- markdownlint-disable-next-line -->
필요에 맞게 수정하고 [환경 변수](https://palworld-server-docker.loef.dev/ko/getting-started/configuration/server-settings/#환경-변수) 섹션에서 올바른 값을 확인해보세요. 
<!-- markdownlint-disable-next-line -->
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)을 다음과 같이 수정합니다:

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest 
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # 컨테이너가 정상적으로 중지될 때까지 기다리는 시간을 설정합니다.
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      env_file:
         -  .env
      volumes:
         - ./palworld:/palworld/
```

### 서버 시작하기

`docker compose up -d` 명령어를 `docker-compose.yml`가 들어있는 폴더안에서 입력해 백그라운드에서 실행하세요.

### 서버 정지하기

`docker compose stop` 명령어를 `docker-compose.yml`가 들어있는 폴더안에서 입력해 서버를 정지하세요.

`docker compose down --rmi all` 명령어를 `docker-compose.yml`가 들어있는 폴더안에서 입력해 서버와 이미지를 정지해 지우세요.

### Docker Run

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
환경 변수를 설정하는 또 다른 방법으로 [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) 파일을 **.env** 라는 새로운 파일에 복사할 수 있습니다.
<!-- markdownlint-disable-next-line -->
필요에 맞게 수정하고 [환경 변수](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings#environment-variables) 섹션에서 올바른 값을 확인해보세요. docker run 명령어를 다음과 같이 변경합니다:

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
