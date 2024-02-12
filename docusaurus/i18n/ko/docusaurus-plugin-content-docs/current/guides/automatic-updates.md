---
sidebar_position: 5
---

# 자동 업데이트

## Cron을 이용한 자동 업데이트 설정

이 서버에서 자동 업데이트를 사용하려면 다음 환경 변수들을 `true`로 **설정해야 합니다**:

- `RCON_ENABLED`
- `UPDATE_ON_BOOT`

:::warning
도커 `restart` 정책이 `always` 또는 `unless-stopped`로 설정 되어있지 않다면, 서버는 종료되고 수동으로 다시 시작해야 합니다.

[빠른 설정](https://palworld-server-docker.loef.dev/ko/)에서 제공된 Docker 실행 명령어와 Docker Compose 파일 예시는 이미 필요한 정책을 적용하고 있습니다.
:::

`AUTO_UPDATE_ENABLED`를 설정하여 자동 업데이트를 활성화하거나 비활성화합니다 (기본값은 비활성화됨).

`AUTO_UPDATE_CRON_EXPRESSION`은 cron 표현식으로, Cron 표현식에서는 작업을 실행할 간격을 정의합니다.

:::tip
이 이미지는 cron 작업을 위해 Supercronic을 사용합니다. [supercronic](https://github.com/aptible/supercronic#crontab-format) 또는
[Crontab Generator](https://crontab-generator.org)를 참조하세요.
:::

`AUTO_UPDATE_CRON_EXPRESSION`을 설정하여 기본 스케줄을 변경합니다.
