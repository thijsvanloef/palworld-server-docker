---
sidebar_position: 3
---

# 자동 백업 설정

서버는 TZ로 설정된 시간대에 따라 매일 자정에 자동으로 백업됩니다.

BACKUP_ENABLED를 설정하여 자동 백업을 활성화하거나 비활성화합니다. (기본값은 활성화됨)

BACKUP_CRON_EXPRESSION은 cron 표현식으로, Cron 표현식에서는 작업을 실행할 간격을 정의합니다.

:::tip
이 이미지는 cron 작업을 위해 Supercronic을 사용합니다. [supercronic](https://github.com/aptible/supercronic#crontab-format) 또는
[Crontab Generator](https://crontab-generator.org)를 참조하세요.
:::

BACKUP_CRON_EXPRESSION을 설정하여 기본 스케줄을 변경합니다.

**예시**: `0 2 * * *`로 BACKUP_CRON_EXPRESSION을 설정하면, 백업 스크립트는 매일 새벽 2시에 실행됩니다.
