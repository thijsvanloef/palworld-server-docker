---
sidebar_position: 4
---

# 自动重启

## 使用 Cron 配置自动重启

要使用此服务器的自动重启功能，必须将以下环境变量设置为 `true`：

* `RCON_ENABLED`

:::warning

如果 docker 重启未设置为策略 `always` 或 `unless-stopped`，
则服务器将关闭并需要手动重新启动。

[快速设置](https://palworld-server-docker.loef.dev/zh/)中的示例 docker run 命令和 docker-compose 文件已使用所需的策略。
:::

| 变量                              | 信息                                                                       | 默认值          | 允许的值                                                                                                            |
|-----------------------------------|----------------------------------------------------------------------------|----------------|-----------------------------------------------------------------------------------------------------------------------|
| AUTO_REBOOT_CRON_EXPRESSION        | 设置影响自动更新的频率。                                                  | 0 0 \* \* \*   | 需要 Cron 表达式 - 请参见 [使用 Cron 配置自动备份](https://palworld-server-docker.loef.dev/zh/guides/backup/automated-backup/)                              |
| AUTO_REBOOT_ENABLED                | 启用自动重启                                                               | false          | true/false                                                                                                            |
| AUTO_REBOOT_WARN_MINUTES           | 在通知玩家后等待多长时间重启服务器                                       | 5              | !0                                                                                                                    |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | 即使有玩家在线，也重新启动服务器                                           | false          | true/false                                                                                                            |

:::tip
该镜像使用 Supercronic 进行 cron 作业。
请参阅 [supercronic](https://github.com/aptible/supercronic#crontab-format)
或 [Crontab Generator](https://crontab-generator.org).
:::

设置 `AUTO_REBOOT_CRON_EXPRESSION` 以更改时程， 默认为每天午夜，根据设置的时区进行调整。
