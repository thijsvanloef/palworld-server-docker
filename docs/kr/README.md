# Palworld 전용 서버 도커

![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)
![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)
![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)
![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)
![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)
[![Static Badge](https://img.shields.io/badge/README-0.15.0-blue?link=https%3A%2F%2Fgithub.com%2Fthijsvanloef%2Fpalworld-server-docker%2Fblob%2Fmain%2FREADME.md)](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docs/kr/README.md)

[Docker Hub에서 보기](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)

[Discord에서 커뮤니티와 채팅하세요](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md)

> [!팁]
> 어떻게 시작해야 할지 모르시나요? [제가 작성한 이 가이드](https://tice.tips/containerization/palworld-server-docker/)를 확인해 보세요

[Palworld](https://store.steampowered.com/app/1623730/Palworld/) 전용 서버 호스팅을 시작하는 데 도움이 되는 Docker 컨테이너입니다.

이 도커 컨테이너는 테스트되었으며 Linux(Ubuntu/Debian) 및 Windows 10 모두에서 작동합니다.

> [!중요]
> 현재 Xbox Gamepass/Xbox 콘솔 플레이어는 전용 서버에 참여할 수 없습니다.
>
> 초대 코드를 통해 다른 플레이어들과 함께 게임을 즐길 수 있으며, 게임은 최대 4명의 플레이어로 제한됩니다.

## 서버 요구 사양

| 리소스 | 최소    | 추천                                |
| ------ | ------- | ----------------------------------- |
| CPU    | 4 cores | 4+ cores                            |
| RAM    | 16GB    | 안정적인 운영을 위해 32GB 이상 권장 |
| 저장소 | 4GB     | 12GB                                |

## 사용하기

서버를 가동하기 위해서는 반드시 [환경변수](#환경변수)를 수정해야 합니다. 잊지 마세요!

### Docker Compose

이 저장소에는 서버를 설정하는 데 사용할 수 있는 [docker-compose.yml](/docker-compose.yml)예제 파일이 포함되어 있습니다.

```yml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest
    restart: unless-stopped
    container_name: palworld-server
    ports:
      - 8211:8211/udp
      - 27015:27015/udp
    environment:
      - PUID=1000
      - PGID=1000
      - PORT=8211 # Optional but recommended
      - PLAYERS=16 # Optional but recommended
      - SERVER_PASSWORD="worldofpals" # Optional but recommended
      - MULTITHREADING=true
      - RCON_ENABLED=true
      - RCON_PORT=25575
      - TZ=UTC
      - ADMIN_PASSWORD="adminPasswordHere"
      - COMMUNITY=false # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
      - SERVER_NAME="World of Pals"
    volumes:
      - ./palworld:/palworld/
```

### Docker Run

모든 <>를 자신만의 구성으로 변경하세요.

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./<palworld-folder>:/palworld/ \
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
    -e SERVER_NAME="World of Pals" \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker:latest

```

### Kubernetes

쿠버네티스에 이 컨테이너를 배포하는 데 필요한 모든 파일은 [k8s 폴더](k8s/)에 있습니다.

[README.md](k8s/readme.md) 에 있는 지침을 따라 배포를 진행해주세요.

#### Using helm chart

[README.md](./chart/README.md) 에 있는 지침을 따라 배포를 진행해주세요.

### 환경변수

다음 값을 사용하여 부팅 시 서버의 설정을 변경할 수 있습니다.
서버를 시작하기 전에 다음 환경변수를 설정하는 것이 좋습니다

- PLAYERS
- PORT
- PUID
- PGID

| 변수명             | 정보                                                                                                                                                     | 기본값 | 허용되는 값                                                                                            |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------ |
| TZ                 | 서버 백업에 사용되는 타임스템프 시간대                                                                                                                   | UTC    | [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
| PLAYERS\*          | 서버에 참여할 수 있는 최대 플레이어 수                                                                                                                   | 16     | 1-32                                                                                                   |
| PORT\*             | 서버에 사용되는 포트(UDP)                                                                                                                                | 8211   | 1024-65535                                                                                             |
| PUID\*             | 서버를 실행할 사용자의 아이디입니다.                                                                                                                     | 1000   | !0                                                                                                     |
| PGID\*             | 서버가 실행해야 하는 그룹의 GID입니다.                                                                                                                   | 1000   | !0                                                                                                     |
| MULTITHREADING\*\* | 멀티 스레드 CPU 환경에서 성능을 향상시킵니다. 최대 약 4개의 스레드까지만 효과가 있으며, 이 이상의 스레드를 할당하는 것은 큰 의미가 없습니다.             | false  | true/false                                                                                             |
| COMMUNITY          | 커뮤니티 서버 탐색기에 서버가 표시되는지 여부(USE WITH SERVER_PASSWORD 와 함께 사용)                                                                     | false  | true/false                                                                                             |
| PUBLIC_IP          | 서버가 실행 중인 네트워크의 PUBLIC IP를 수동으로 지정할 수 있습니다. 지정하지 않으면 자동으로 감지됩니다. 제대로 작동하지 않으면 수동 구성을 시도하세요. |        | x.x.x.x                                                                                                |
| PUBLIC_PORT        | 서버가 실행 중인 네트워크의 포트 번호를 수동으로 지정할 수 있습니다. 지정하지 않으면 자동으로 감지됩니다. 제대로 작동하지 않으면 수동 구성을 시도하세요. |        | 1024-65535                                                                                             |
| SERVER_NAME        | 서버 이름                                                                                                                                                |        | "string"                                                                                               |
| SERVER_PASSWORD    | 서버 접속을 위한 비밀번호                                                                                                                                |        | "string"                                                                                               |
| ADMIN_PASSWORD     | 관리자 비밀번호                                                                                                                                          |        | "string"                                                                                               |
| UPDATE_ON_BOOT\*\* | 도커 컨테이너가 시작될 때 서버 업데이트/설치(컨테이너를 처음 실행할 때 이 기능을 활성화해야 합니다).                                                     | true   | true/false                                                                                             |
| RCON_ENABLED\*\*\* | Palworld RCON 활성화                                                                                                                                     | true   | true/false                                                                                             |
| RCON_PORT          | RCON접속 포트                                                                                                                                            | 25575  | 1024-65535                                                                                             |
| QUERY_PORT         | Steam 서버와 통신하는 데 사용되는 쿼리 포트                                                                                                              | 27015  | 1024-65535                                                                                             |

\* 설정하는 것을 적극 권장합니다.

\*\* 이 옵션을 활성화하여 실행할 때 주의해야 할 사항을 확인하세요.

\*\*\* docker stop이 서버를 저장하고 정상적으로 종료하는 데 필요합니다.

> [!IMPORTANT]
> 환경 변수에 사용되는 부울(true/false) 값은 shell 스크립트에서 사용되므로 대소문자를 구분합니다.
>
> 옵션이 적용되려면 정확히 `true` 또는 `false`를 사용하여 설정해야 합니다.

### 사용되는 포트

| Port  | Info             |
| ----- | ---------------- |
| 8211  | Game Port (UDP)  |
| 27015 | Query Port (UDP) |
| 25575 | RCON Port (TCP)  |

## RCON 사용

RCON은 palworld-server-docker 이미지에 기본적으로 활성화되어 있습니다. RCON CLI는 아주 쉽게 열 수 있습니다:

```bash
docker exec -it palworld-server rcon-cli
```

위 명령어를 사용 하면 RCON을 사용하여 Palworld 서버 명령어를 작성할 수 있는 CLI가 열립니다.

### 서버 명령어 리스트

| 명령어                           | 정보                                               |
| -------------------------------- | -------------------------------------------------- |
| Shutdown {Seconds} {MessageText} | {Seconds}가 지나면 서버가 종료됩니다.              |
| DoExit                           | 서버를 강제 종료합니다.                            |
| Broadcast                        | 서버에 있는 모든 플레이어에게 메시지를 전송합니다. |
| KickPlayer {SteamID}             | 서버에서 플레이어를 추방합니다.                    |
| BanPlayer {SteamID}              | 서버에서 사용자를 차단합니다.                      |
| TeleportToPlayer {SteamID}       | 대상 플레이어의 위치로 순간이동합니다.             |
| TeleportToMe {SteamID}           | 대상 플레이어가 현재 위치로 순간이동합니다.        |
| ShowPlayers                      | 서버에 있는 모든 플레이어의 정보를 표시합니다.     |
| Info                             | 서버 정보를 표시합니다.                            |
| Save                             | 월드 정보를 저장합니다.                            |

전체 명령어 목록을 보려면 다음으로 이동하세요.: [https://tech.palworldgame.com/server-commands](https://tech.palworldgame.com/server-commands)

## 백업 만들기

현재 시점의 게임 세이브 백업을 생성하려면 다음 명령을 사용합니다.

```bash
docker exec palworld-server backup
```

다음 위치에 백업이 생성됩니다. `/palworld/backups/`

rcon이 활성화된 경우 서버는 백업 전에 저장을 실행합니다.

## 서버 설정 편집

서버가 시작되면 `PalWorldSettings.ini` 파일은 다음 위치에 생성됩니다.
`<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

여기서 변경한 사항은 다음 부팅 시 서버에 적용됩니다.

환경 변수는 항상 `PalWorldSettings.ini`의 변경 사항을 덮어쓴다는 점에 유의하세요.

서버 설정에 대한 자세한 설명 목록을 보려면 다음을 참조하세요.: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

> [!팁]
> 만약 `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` 파일 내부가 비어 있으면,
> 파일을 삭제하고 서버를 다시 시작하면 콘텐츠가 포함된 새 파일이 생성됩니다.

## 이슈/기능 요청

문제/기능 요청은 다음 [링크](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose)에서 제출할 수 있습니다.

### 알려진 이슈

알려진 이슈는 [Wiki](https://github.com/thijsvanloef/palworld-server-docker/wiki/Known-Issues)에 나열되어 있습니다.
