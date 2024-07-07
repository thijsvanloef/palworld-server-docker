---
sidebar_position: 1
title: 팔월드 데디케이트 서버 설정
description: 도커 환경변수를 사용해 팔월드 서버 세팅 변경방법.
keywords: [Palworld, palworld dedicated server, Palworld Dedicated server settings, palworld server settings, Palworld Docker Dedicated server settings, palworld Docker server settings]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Server Settings
---
<!-- markdownlint-disable-next-line -->
# 팔월드 데디케이트 서버 설정

도커 환경변수를 사용해 팔월드 서버 세팅 변경방법.

## 환경 변수

다음 값을 사용하여 부팅 시 서버의 설정을 변경할 수 있습니다.
서버를 시작하기 전에 다음 환경 변수를 설정하는 것이 좋습니다:

- PLAYERS
- PORT
- PUID
- PGID

| 변수명             | 정보                                                                                                                                                     | 기본값 | 허용되는 값                                                                                            |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------ |
| TZ                 | 서버 백업에 사용되는 타임스템프 시간대                                                                                                                   | KST    | [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
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
| BACKUP_CRON_EXPRESSION  | 자동 백업 주기 | 0 0 \* \* \* | Cron 표현식 필요 - [cron을 이용한 자동 백업 설정](https://palworld-server-docker.loef.dev/ko/guides/backup/automated-backup) 참조 |
| BACKUP_ENABLED | 자동 백업을 활성화 여부 | true | true/false |
| DELETE_OLD_BACKUPS | 오래된 백업 파일 자동 삭제 여부                                                                                                                                                       | false          | true/false                                                                                                 |
| OLD_BACKUP_DAYS    | 백업 보관 일수                                                                                                                                                                       | 30             | 임의의 양의 정수                                                                                       |
| AUTO_UPDATE_CRON_EXPRESSION  | 자동 업데이트 주기. | 0 \* \* \* \* | Cron 표현식 필요 - [cron을 이용한 자동 업데이트 설정](https://palworld-server-docker.loef.dev/ko/guides/automatic-updates#cron%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EC%9E%90%EB%8F%99-%EC%97%85%EB%8D%B0%EC%9D%B4%ED%8A%B8-%EC%84%A4%EC%A0%95) 참조 |
| AUTO_UPDATE_ENABLED | 자동 업데이트 활성화 여부 | false | true/false |
| AUTO_UPDATE_WARN_MINUTES | 업데이트 대기 시간 설정(분), 이때 사용자는 분 단위로 서버 업데이트에 대한 알림을 받습니다 | 30 | !0 |
| AUTO_REBOOT_CRON_EXPRESSION  | 자동 서버 재부팅 주기 | 0 0 \* \* \* | Cron 표현식 필요 - [cron을 이용한 자동 재부팅 설정](https://palworld-server-docker.loef.dev/ko/guides/automatic-reboots#cron%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EC%9E%90%EB%8F%99-%EC%9E%AC%EB%B6%80%ED%8C%85-%EC%84%A4%EC%A0%95) 참조 |
| AUTO_REBOOT_ENABLED | 자동 서버 재부팅 활성화 여부 | false | true/false |
| AUTO_REBOOT_WARN_MINUTES | 재부팅 대기 시간 설정(분), 이때 사용자는 분 단위로 서버 종료에 대한 알림을 받습니다. | 5 | !0 |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | 플레이어 온라인시에도 재부팅.                                                                                                                                                | false                      | true/false                                                                                                        |
| TARGET_MANIFEST_ID                 | 게임의 버젼을 스팀 다운로드 디포의 해당 Manifest ID로 고정.                                                                                                                         |                           | See [Manifest ID Table](https://palworld-server-docker.loef.dev/guides/pinning-game-version#version-to-manifest-id-table)                                                           |
| DISCORD_WEBHOOK_URL | 디스코드 웹훅 URL | | `https://discord.com/api/webhooks/<webhook_id>` |
| DISCORD_CONNECT_TIMEOUT | 디스코드 명령 초기 연결 시간 초과 | 30 | !0 |
| DISCORD_MAX_TIMEOUT | Discord 총 훅 시간 초과 | 30 | !0 |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE | 서버 업데이트 시작 시 전송되는 디스코드 메시지 | Server is updating... | "string" |
| DISCORD_POST_UPDATE_BOOT_MESSAGE | 서버 업데이트 완료 시 전송되는 디스코드 메시지 | Server update complete! | "string" |
| DISCORD_PRE_START_MESSAGE | 서버가 시작될 때 전송되는 디스코드 메시지 | Server is started! | "string" |
| DISCORD_PRE_SHUTDOWN_MESSAGE | 서버가 종료되기 시작할 때 전송되는 디스코드 메시지 | Server is shutting down... | "string" |
| DISCORD_POST_SHUTDOWN_MESSAGE | 서버가 멈췄을 때 전송되는 디스코드 메시지 | Server is stopped! | "string" |
| DISABLE_GENERATE_SETTINGS | 자동으로 PalWorldSettings.ini를 생성할지 여부 | false | true/false |
| DISABLE_GENERATE_ENGINE          | 엔진설정의 생성을 비활성화 합니다.ini                                                                                                                                          | true                      | true/false                                                                                                        |
| ENABLE_PLAYER_LOGGING      | 플레이어가 접속 또는 종료시 로깅과 공지를 활성화 | true         | true/false |
| PLAYER_LOGGING_POLL_PERIOD          | 플레이어의 접속과 종료를 확인하기위한 폴링시간(초) 설정 | 5                      | !0 |

*설정하는 것을 적극 권장합니다.

** 이 옵션을 활성화하여 실행할 때 주의해야 할 사항을 확인하세요.

*** docker stop이 서버를 저장하고 정상적으로 종료하는 데 필요합니다.

### 사용되는 포트

서버에는 기본적으로 다음과 같은 포트가 필요합니다.

| Port  | Info             |
|-------|------------------|
| 8211  | Game Port (UDP)  |
| 27015 | Query Port (UDP) |
| 25575 | RCON Port (TCP)  |
