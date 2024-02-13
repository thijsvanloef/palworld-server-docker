---
sidebar_position: 4
---

# 自动重启

## 使用 Cron 执行自动重启

为了能够使用该服务器的自动重启功能，需要启用 `RCON_ENABLED` 。

:::warning

如果 Docker 重启策略不是设为 `always` 或 `unless-stopped`，那麽伺服器将会关闭，需要手动重新启动。

在 [开始使用](https://palworld-server-docker.loef.dev/zh/) 中的示例 Docker run 命令和 Docker Compose 文件已經使用了所需的策略。
:::

设置 `AUTO_REBOOT_ENABLED` 以启用或禁用自动备份（默认为禁用）。

`AUTO_REBOOT_CRON_EXPRESSION` 是一个cron表达式，在Cron表达式中，需要定义了运行作业的间隔。

:::tip
该镜像使用 Supercronic 进行 cron 作业。
请参阅 [supercronic](https://github.com/aptible/supercronic#crontab-format)
或 [Crontab Generator](https://crontab-generator.org).
:::

设置 `AUTO_REBOOT_CRON_EXPRESSION` 以更改时程， 默认为每天午夜，根据设置的时区进行调整。
