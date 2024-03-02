---
sidebar_position: 3
title: 팔월드 서버 엔진설정
description: 도커 환경변수로 팔월드 엔진설정 (Engine.ini file)하는 법.
keywords: [Palworld, palworld dedicated server, Palworld Engine.ini, palworld engine settings]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: 엔진설정
---
<!-- markdownlint-disable-next-line -->
# 팔월드 서버 엔진설정

도커 환경변수로 팔월드 엔진설정 (Engine.ini file)하는 법.

## 환경변수

:::warning
해당 환경변수들과 설정들은 게임이 아직 베타이기 때문에 변경될 수 있습니다.
:::

설정을 이용하기 위해서는 `DISABLE_GENERATE_ENGINE: false`을 설정해주세요.

엔진 설정을 환경 변수로 바꾸는 과정은 다음과 같은 규칙을 따릅니다 (몇가지 예외 있음):

* 모두 대문자로 작성
* 밑줄을 삽입하여 단어를 분할
* 한 글자로 시작하는 설정(예: 'b')의 경우 그 한 글자를 제거

예시입니다:

* LanServerMaxTickRate -> LAN_SERVER_MAX_TICK_RATE
* bUseFixedFrameRate -> USE_FIXED_FRAME_RATE
* NetClientTicksPerSecond -> NET_CLIENT_TICKS_PER_SECOND

| 변수                          | 설명                                                                                                             | 기본값        | 허용값              |
|-------------------------------|-----------------------------------------------------------------------------------------------------------------|---------------|--------------------|
| DISABLE_GENERATE_ENGINE       | 엔진설정의 생성을 비활성화 합니다.ini                                                                             | true          | Boolean            |
| LAN_SERVER_MAX_TICK_RATE      | 내부서버 사용자의 최대 초당 tick을 설정합니다. 높을수록 게임이 부드러워집니다.                                        | 120           | Integer            |
| NET_SERVER_MAX_TICK_RATE      | 외부서버 사용자의 최대 초당 tick을 설정합니다. 높을수록 게임이 부드러워집니다.                                        | 120           | Integer            |
| CONFIGURED_INTERNET_SPEED     | 외부서버 사용자의 인터넷 속도를 (bytes per second) 설정합니다. 높을수록 대역폭의 병목현상이 줄어듭니다.                | 104857600     | Integer (in bytes) |
| CONFIGURED_LAN_SPEED          | 내부서버 사용자의 로컬 속도를 (bytes per second) 설정합니다.  높을수록 대역폭의 병목현상이 줄어듭니다.                 | 104857600     | Integer (in bytes) |
| MAX_CLIENT_RATE               | 모든 클라이언트의 최대 데이터 전송속도를 설정합니다. 높을수록 데이터의 한도초과를 방지합니다.                           | 104857600     | Integer (in bytes) |
| MAX_INTERNET_CLIENT_RATE      | 외부서버 사용자의 고용량 데이터 전송을 한도 없이 허가합니다.                                                         | 104857600     | Integer (in bytes) |
| SMOOTH_FRAME_RATE             | 일관된 시각적 경험을 위해 게임 엔진에서 변동 프레임율 설정을 활성화합니다.                                            | true          | Boolean            |
| SMOOTH_FRAME_RATE_UPPER_LIMIT | 부드럽게 하기위해 최대 목표 프레임률 범위을 설정합니다.                                                             | 120.000000    | Float              |
| SMOOTH_FRAME_RATE_LOWER_LIMIT | 부드럽게 하기위해 최소 목표 프레임률 범위을 설정합니다.                                                             | 30.000000     | Float              |
| USE_FIXED_FRAME_RATE          | 프레임률 고정을 활성화합니다.                                                                                     | false         | Boolean            |
| FIXED_FRAME_RATE              | 프레임률를 고정합니다                                                                                             | 120.000000    | Float              |
| MIN_DESIRED_FRAME_RATE        | 수용 가능한 최소 프레임률을 설정해 해당 프레임율에서 게임이 부드럽게 돌아가게 합니다.                                  | 60.000000     | Float              |
| NET_CLIENT_TICKS_PER_SECOND   | 클라이언트의 업데이트 주기를 늘려 렉과 반응도를 향상시킵니다.                                                        | 120           | Integer            |

:::tip
서버의 tickrate을 120이상으로 설정하는 것은 게임을 조금 더 부드럽게 하지만,
현재 문제가되는 물결현상 (rubber-banding)을 해결하지 못하고 하드웨어에 많은 부담을 줍니다.
:::
