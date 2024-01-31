# Palworld 전용 서버 도커

[![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)](https://github.com/thijsvanloef/palworld-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker/tags)
[![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)](https://discord.com/invite/UxBxStPAAE)
[![Static Badge](https://img.shields.io/badge/README-0.16.0-blue?link=https%3A%2F%2Fgithub.com%2Fthijsvanloef%2Fpalworld-server-docker%2Fblob%2Fmain%2FREADME.md)](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docs/kr/README.md?tab=readme-ov-file#palworld-dedicated-server-docker)

[Docker Hub에서 보기](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)

[Discord에서 커뮤니티와 채팅하세요](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md) | [简体中文](/docs/zh-CN/README.md)

> [!Tip]
> 어떻게 시작해야 할지 모르시나요? [제가 작성한 이 가이드](https://tice.tips/containerization/palworld-server-docker/)를 확인해 보세요

[Palworld](https://store.steampowered.com/app/1623730/Palworld/) 전용 서버 호스팅을 시작하는 데 도움이 되는 Docker 컨테이너입니다.

이 도커 컨테이너는 테스트되었으며 Linux(Ubuntu/Debian) 및 Windows 10 모두에서 작동합니다.

> [!Important]
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

서버를 가동하기 위해서는 반드시 [환경 변수](#환경-변수)를 수정해야 합니다. 잊지 마세요!

### Docker Compose

이 저장소에는 서버를 설정하는 데 사용할 수 있는 [docker-compose.yml](/docker-compose.yml)예제 파일이 포함되어 있습니다.

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
      - PUID=1000
      - PGID=1000
      - PORT=8211 # 선택사항이지만 설정하는 것을 권장합니다.
      - PLAYERS=16 # 선택사항이지만 설정하는 것을 권장합니다.
      - SERVER_PASSWORD="worldofpals" # 선택사항이지만 설정하는 것을 권장합니다.
      - MULTITHREADING=true
      - RCON_ENABLED=true
      - RCON_PORT=25575
      - TZ=UTC
      - ADMIN_PASSWORD="adminPasswordHere"
      - COMMUNITY=false # 커뮤니티 서버 탐색기에 서버가 표시 되는 것을 허용합니다 (USE WITH SERVER_PASSWORD 와 함께 사용하는 것을 권장합니다)
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
    -e SERVER_DESCRIPTION="Awesome World of Pal" \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker:latest

```

> [!TIP]
> 사용자 지정 중지 유예 기간을 설정하여 컨테이너를 중지하려면 다음을 실행하세요:
> `docker stop --name palworld-server --time 30`

### Kubernetes

쿠버네티스에 이 컨테이너를 배포하는 데 필요한 모든 파일은 [k8s 폴더](/k8s/)에 있습니다.

[README.md](/k8s/readme.md) 에 있는 지침을 따라 배포를 진행해주세요.

#### Using helm chart

[README.md](/charts/palworld/README.md) 에 있는 지침을 따라 배포를 진행해주세요.

### 환경 변수

다음 값을 사용하여 부팅 시 서버의 설정을 변경할 수 있습니다.
서버를 시작하기 전에 다음 환경 변수를 설정하는 것이 좋습니다

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
| SERVER_DESCRIPTION        | 서버 설명                                                                                                                                                |        | "string"                                                                                               |
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

전체 명령어 목록을 보려면 다음으로 이동하세요: [https://tech.palworldgame.com/server-commands](https://tech.palworldgame.com/server-commands)

## 백업 만들기

현재 시점의 게임 세이브 백업을 생성하려면 다음 명령을 사용합니다.

```bash
docker exec palworld-server backup
```

다음 위치에 백업이 생성됩니다. `/palworld/backups/`

rcon이 활성화된 경우 서버는 백업 전에 저장을 실행합니다.

## 서버 설정 편집

### 환경 변수 사용 설정

> [!Important]
>
> 게임이 아직 베타버전이므로 이러한 환경 변수/설정은 변경될 수 있습니다

| 변수                                  | 설명                                                    | 기본값                                                                                | 허용값                          |
|-------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | 게임 난이도                                                | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | 낮 시간 속도 - 숫자가 작을수록 낮이 짧아짐             | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | 밤 시간 속도 - 숫자가 작을수록 밤이 짧아짐         | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | 경험치 획득 비율                                                 | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | PAL 포획률                                               | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | PAL 출현 비율                                            | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | PAL이 주는 데미지 배수                                    | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | PAL이 받는 데미지 배수                                      | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | 플레이어가 주는 데미지 배수                                  | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | 플레이어가 받는 데미지 배수                                   | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | 플레이어 포만도 감소율                                   | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | 플레이어 기력 감소율                                 | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | 플레이어 HP 자연 회복률                               | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | 플레이어 수면 시 HP 회복률                              | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | PAL 포만도 감소율                                      | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | PAL 기력 감소율                                     | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | PAL HP 자연 회복률                                  | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | PAL 수면 시 HP 회복률 (PLA상자 내 HP 회복률)                 | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | 구조물 피해 배수                                 | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | 구조물 노화 속도 배수                                   | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | 채집 아이템 획득량 배수                                    | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | 채집 오브젝트 HP 배수                               | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | 채집 오브젝트 생성 간격 - 숫자가 작을수록 재 생성이 빨라짐                           | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | 드롭 아이템 양 배수                                       | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | 사망 패널티</br>None: 사망 패널티 없음</br>Item: 장비 이외의 아이템 드롭</br>ItemAndEquipment: 모든 아이템 드롭</br>All: 모든 PAL과 모든 아이템 드롭                                   | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | 플레이어간 데미지 여부                      | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | 아군간 데미지 여부                                            | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | 습격 이벤트 발생 여부                                                | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | UNKO 활성화 여부(?)                                                | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | 컨트롤러 조준 보조 활성화                                   | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | 키보드 조준 보조 활성화                                     | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | 월드 내의 드롭 아이템 최대 수                           | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | 월드 내의 UNKO 드롭 최대 수                      | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | 거점 최대 수량                                   | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAXNUM                   | 거점 작업 PAL 최대 수                                      | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | 드롭 아이템이 사라지기까지 걸리는 시간                    | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | 온라인 플레이어가 없을 때 길드 자동 리셋 여부          | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | 온라인 플레이어가 없을 때 길드를 자동 리셋 시간(h)   | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | 길드 내 최대 인원 수                                            | 20                                                                                           | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | 거대알 부화에 걸리는 시간(h)                                | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | 작업 속도 배수                                          | 1.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | 멀티플레이 활성화 여부                                             | False                                                                                        | Boolean                                |
| IS_PVP                                    | PVP 활성화 여부                                                     | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | 다른 길드 플레이어의 데스 페널티 드롭 아이템 획득 가능 여부 | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | 비 로그인 패널티 활성화 여부                                       | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | 빠른 이동 활성화 여부                                             | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | 시작 위치를 지도로 선택할 수 있는지 여부                             | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | 로그오프 후 플레이어 삭제 여부                  | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | 다른 길드 플레이어에 대한 방어 허용 여부                     | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | 협동던전 최대인원                           | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                         |                                                                                              | String                                 |
| USEAUTH                                   | 인증 사용 여부                                             | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | 사용할 BAN 목록                                          | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |

### 수동 설정

서버가 시작되면 `PalWorldSettings.ini` 파일은 다음 위치에 생성됩니다.
`<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

환경 변수 설정은 항상 `PalWorldSettings.ini`의 변경 사항을 덮어쓴다는 점에 유의하세요.

> [!IMPORTANT]
> 서버가 꺼져 있을 때만 `PalWorldSettings.ini`를 변경할 수 있습니다.
>
> 서버가 작동하는 동안 변경한 내용은 서버가 중지되면 덮어쓰기됩니다.

서버 설정에 대한 자세한 설명 목록을 보려면 다음을 참조하세요: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

> [!Tip]
> 만약 `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` 파일 내부가 비어 있으면,
> 파일을 삭제하고 서버를 다시 시작하면 콘텐츠가 포함된 새 파일이 생성됩니다.

## 이슈/기능 요청

문제/기능 요청은 다음 [링크](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose)에서 제출할 수 있습니다.

### 알려진 이슈

알려진 이슈는 [Wiki](https://github.com/thijsvanloef/palworld-server-docker/wiki/Known-Issues)에 나열되어 있습니다.
