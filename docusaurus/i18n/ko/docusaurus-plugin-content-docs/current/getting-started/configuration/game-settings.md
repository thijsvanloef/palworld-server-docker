---
sidebar_position: 2
title: 팔월드 서버 게임설정
description: 도커의 환경변수로 팔월드 게임 설정하기 (PalWorldSettings.ini file).
keywords: [Palworld, palworld dedicated server, Palworld PalWorldSettings.ini, palworld game settings, PalWorldSettings.ini]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: 게임설정
---
<!-- markdownlint-disable-next-line -->
# 게임 설정

도커의 환경변수로 팔월드 게임 설정하기 (PalWorldSettings.ini file).

## 환경 변수로 설정

:::warning
게임이 아직 베타버전이므로 이러한 환경 변수 또는 설정은 변경될 수 있습니다.

지원되는 파라미터들을 [공식 웹페이지](https://tech.palworldgame.com/optimize-game-balance)에서 확인하세요.
:::

서버 설정을 환경 변수로 바꾸는 과정은 다음과 같은 규칙을 따릅니다 (몇가지 예외 있음):

* 모두 대문자로 작성
* 밑줄을 삽입하여 단어를 분할
* 한 글자로 시작하는 설정(예: 'b')의 경우 그 한 글자를 제거

아래는 예시입니다:

* Difficulty -> DIFFICULTY
* PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
* bIsPvP -> IS_PVP

| 변수                                      | 설명                                                           | 기본값                                                                                       | 허용값                                  |
|-------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | 게임 난이도                                                     | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | 낮 시간 속도 - 숫자가 작을수록 낮이 짧아짐                        | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | 밤 시간 속도 - 숫자가 작을수록 밤이 짧아짐                        | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | 경험치 획득 비율                                                | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | PAL 포획률                                                     | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | PAL 출현 비율                                                  | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | PAL이 주는 데미지 배수                                          | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | PAL이 받는 데미지 배수                                          | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | 플레이어가 주는 데미지 배수                                     | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | 플레이어가 받는 데미지 배수                                     | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | 플레이어 포만도 감소율                                          | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | 플레이어 기력 감소율                                            | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | 플레이어 HP 자연 회복률                                         | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | 플레이어 수면 시 HP 회복률                                      | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | PAL 포만도 감소율                                              | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | PAL 기력 감소율                                                | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | PAL HP 자연 회복률                                             | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | PAL 수면 시 HP 회복률 (PLA상자 내 HP 회복률)                    | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | 구조물 피해 배수                                               | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | 구조물 노화 속도 배수                                          | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | 채집 아이템 획득량 배수                                        | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | 채집 오브젝트 HP 배수                                          | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | 채집 오브젝트 생성 간격 - 숫자가 작을수록 재 생성이 빨라짐        | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | 드롭 아이템 양 배수                                            | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | 사망 패널티, None: 사망 패널티 없음, Item: 장비 이외의 아이템 드롭, ItemAndEquipment: 모든 아이템 드롭, All: 모든 PAL과 모든 아이템 드롭 | All                     | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | 플레이어간 데미지 여부                                         | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | 아군간 데미지 여부                                             | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | 습격 이벤트 발생 여부                                          | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | UNKO 활성화 여부(?)                                           | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | 컨트롤러 조준 보조 활성화                                      | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | 키보드 조준 보조 활성화                                        | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | 월드 내의 드롭 아이템 최대 수                                  | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | 월드 내의 UNKO 드롭 최대 수                                    | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | 거점 최대 수량                                                | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAX_NUM                  | 거점 작업 PAL 최대 수                                         | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | 드롭 아이템이 사라지기까지 걸리는 시간                          | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | 온라인 플레이어가 없을 때 길드 자동 리셋 여부                   | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | 온라인 플레이어가 없을 때 길드를 자동 리셋 시간(h)              | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | 길드 내 최대 인원 수                                          | 20                                                                                           | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | 거대알 부화에 걸리는 시간(h)                                   | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | 작업 속도 배수                                                | 1.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | 멀티플레이 활성화 여부                                         | False                                                                                        | Boolean                                |
| IS_PVP                                    | PVP 활성화 여부                                               | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | 다른 길드 플레이어의 데스 페널티 드롭 아이템 획득 가능 여부      | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | 비 로그인 패널티 활성화 여부                                   | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | 빠른 이동 활성화 여부                                         | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | 시작 위치를 지도로 선택할 수 있는지 여부                        | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | 로그오프 후 플레이어 삭제 여부                                 | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | 다른 길드 플레이어에 대한 방어 허용 여부                        | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | 협동던전 최대인원                                             | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                       |                                                                                              | String                                 |
| USEAUTH                                   | 인증 사용 여부                                                | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | 사용할 BAN 목록                                               | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |
| SHOW_PLAYER_LIST                          | ESC시 사용자 리스트                                           | True                                                                                         | Boolean                                |
| TARGET_MANIFEST_ID                        | 게임의 버젼을 스팀 다운로드 디포의 해당 Manifest ID로 고정.     |                                                                                              | [Manifest ID Table](#버전별Manifest ID표) 보기 |
| ENABLE_PLAYER_LOGGING                     | 플레이어가 접속 또는 종료시 로깅과 공지를 활성화                | true                                                                                         | true/false |
| PLAYER_LOGGING_POLL_PERIOD                | 플레이어의 접속과 종료를 확인하기위한 폴링시간(초) 설정         | 5                                                                                             | !0 |

### 수동으로 설정

서버가 시작되면 `PalWorldSettings.ini` 파일은 다음 위치에 생성됩니다.
`<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

환경 변수 설정은 항상 `PalWorldSettings.ini`의 변경 사항을 덮어쓴다는 점에 유의하세요.

:::warning
서버가 꺼져 있을 때만 `PalWorldSettings.ini`를 변경할 수 있습니다.

서버가 작동하는 동안 변경한 내용은 서버가 중지되면 덮어쓰기됩니다.
:::

서버 설정에 대한 자세한 목록을 보려면 다음을 참조하세요: [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

서버 설정에 대한 자세한 설명을 보려면 다음을 참조하세요: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)
