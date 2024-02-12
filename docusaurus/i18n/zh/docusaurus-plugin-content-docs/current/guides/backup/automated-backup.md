---
sidebar_position: 3
---

# 配置自动备份

服务器每天午夜根据设置的时区进行自动备份。

设置 `BACKUP_ENABLED` 以启用或禁用自动备份（默认已启用）。

`BACKUP_CRON_EXPRESSION` 是一个 cron 表达式，您可以在其中定义运行作业的间隔。

:::tip
该镜像使用 Supercronic 进行 cron 作业。
请参阅 [supercronic](https://github.com/aptible/supercronic#crontab-format)
或 [Crontab Generator](https://crontab-generator.org).
:::

将 `BACKUP_CRON_EXPRESSION` 设置为默认计划。

**示例用法**：如果将BACKUP_CRON_EXPRESSION设置为 `0 2 * * *`, 则备份脚本将每天上午 2:00 运行一次。
