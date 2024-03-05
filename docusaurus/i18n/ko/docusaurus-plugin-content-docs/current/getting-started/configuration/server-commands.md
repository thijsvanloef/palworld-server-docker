---
sidebar_position: 4
title: 팔월드 데디케이드 서버 명령어 (RCON)
description: RCON을 사용하여 서버와 상호 작용하는 방법을 소개합니다.
keywords: [Palworld, palworld dedicated server, Palworld Server Commands, Palworld server how to ban player, Palworld server how to kick player]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Server Commands (RCON)
---

<!-- markdownlint-disable-next-line -->
# 팔월드 데디케이드 서버 명령어 (RCON)

RCON을 사용하여 서버와 상호 작용하는 방법을 소개합니다.

## RCON

RCON은 palworld-server-docker 이미지에 기본적으로 활성화되어 있습니다. RCON CLI는 아주 쉽게 열 수 있습니다:

```bash
docker exec -it palworld-server rcon-cli "<command> <value>"
```

예를 들어, 다음 명령어를 사용하여 서버의 모든 사람에게 메시지를 방송할 수 있습니다:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hello everyone"
```

위 명령어를 사용 하면 RCON을 사용하여 Palworld 서버 명령어를 작성할 수 있는 CLI가 열립니다.

### 서버 명령어 리스트

| 명령어                           | 정보                                               |
| -------------------------------- | -------------------------------------------------- |
| Shutdown (Seconds) (MessageText) | (Seconds)가 지나면 서버가 종료됩니다.              |
| DoExit                           | 서버를 강제 종료합니다.                            |
| Broadcast                        | 서버에 있는 모든 플레이어에게 메시지를 전송합니다. |
| KickPlayer (SteamID)             | 서버에서 플레이어를 추방합니다.                    |
| BanPlayer (SteamID)              | 서버에서 사용자를 차단합니다.                      |
| TeleportToPlayer (SteamID)       | 대상 플레이어의 위치로 순간이동합니다.             |
| TeleportToMe (SteamID)           | 대상 플레이어가 현재 위치로 순간이동합니다.        |
| ShowPlayers                      | 서버에 있는 모든 플레이어의 정보를 표시합니다.     |
| Info                             | 서버 정보를 표시합니다.                            |
| Save                             | 월드 정보를 저장합니다.                            |

전체 명령어 목록을 보려면 다음으로 이동하세요: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)
