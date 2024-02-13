---
sidebar_position: 1
---

# 服务器设置

本部分将解释如何配置服务器。

## 环境变量

您可以在启动服务器前使用以下值更改服务器的设置。
在启动服务器之前强烈建议设置以下环境变量：

* PLAYERS
* PORT
* PUID
* PGID

| 变量               | 信息                                               | 默认值   | 允许值                                                                           |
|------------------|--------------------------------------------------|-------|-------------------------------------------------------------------------------|
| TZ               | 备份服务器时所使用的时间戳。                                   | UTC   | 参见 [时区列表](https://zh.wikipedia.org/wiki/%E6%97%B6%E5%8C%BA%E5%88%97%E8%A1%A8) |
| PLAYERS*         | 可同加入服务器的最大玩家数。                                   | 16    | 1-32                                                                          |
| PORT*            | 服务器将开放的 UDP 端口。                                  | 8211  | 1024-65535                                                                    |
| PUID*            | 服务器运行时的用户的 UID。                                  | 1000  | !0                                                                            |
| PGID*            | 服务器运行时的组的 GID。                                   | 1000  | !0                                                                            |
| MULTITHREADING** | 提高多线程 CPU 环境下的性能。它最多对 4 个线程有效，分配超过这个数量的线程没有太大意义。 | false | true/false                                                                    |
| COMMUNITY        | 服务器是否显示在社区服务器页中（建议设置SERVER_PASSWORD）。            | false | true/false                                                                    |
| PUBLIC_IP        | 您可以手动指定服务器 IP 地址。若未指定，将自动检测。                     |       | x.x.x.x                                                                       |
| PUBLIC_PORT      | 您可以手动指定服务器端口。若未指定，将自动检测。                         |       | 1024-65535                                                                    |
| SERVER_NAME      | 服务器名称。                                           |       | "string"                                                                      |
| SERVER_PASSWORD  | 为服务器设置密码。                                        |       | "string"                                                                      |
| ADMIN_PASSWORD   | 为服务器设置管理员密码。                                     |       | "string"                                                                      |
| UPDATE_ON_BOOT** | 在启动 Docker 容器时更新/安装服务器（需要在第一次运行时启用）。             | true  | true/false                                                                    |
| RCON_ENABLED***  | 为服务器启用 RCON。                                     | true  | true/false                                                                    |
| RCON_PORT        | RCON 连接端口。                                       | 25575 | 1024-65535                                                                    |
| QUERY_PORT       | 用于与 Steam 服务器通信的查询端口。                            | 27015 | 1024-65535                                                                    |
| BACKUP_CRON_EXPRESSION  | 自动备份的频率。 | 0 0 \* \* \* | 需要一个Cron表达式 - 参见 [使用 Cron 执行自动备份](https://palworld-server-docker.loef.dev/zh/guides/backup/automated-backup/)。 |
| BACKUP_ENABLED | 启用自动备份。 | true | true/false |
| DELETE_OLD_BACKUPS | 在一定天数后删除备份。     | false          | true/false                                                                                                 |
| OLD_BACKUP_DAYS    | 保留备份的天数。                      | 30             | 任何正整数                                                                                       |
| AUTO_UPDATE_CRON_EXPRESSION  | 自动更新的频率。 | 0 \* \* \* \* | 需要一个Cron表达式 - 参见 [使用 Cron 执行自动更新](https://palworld-server-docker.loef.dev/zh/guides/automatic-updates)。 |
| AUTO_UPDATE_ENABLED | 启用自动更新。 | false | true/false |
| AUTO_UPDATE_WARN_MINUTES | 在通知玩家后等待多长时间更新服务器。 | 30 | !0 |
| AUTO_REBOOT_CRON_EXPRESSION  | 设置自动重启的频率。 | 0 0 \* \* \* | 需要一个Cron表达式 - 参见 [使用 Cron 执行自动重启](https://palworld-server-docker.loef.dev/zh/guides/automatic-reboots)。 |
| AUTO_REBOOT_ENABLED | 启用自动重启 | false | true/false |
| AUTO_REBOOT_WARN_MINUTES | 在通知玩家后等待多长时间重启服务器。 | 5 | !0 |
| DISCORD_WEBHOOK_URL | Discord 服务器上创建 Webhook 后的 Discord Webhook URL | | `https://discord.com/api/webhooks/<webhook_id>` |
| DISCORD_CONNECT_TIMEOUT | Discord 命令初始连接超时 | 30 | !0 |
| DISCORD_MAX_TIMEOUT | Discord 超时时间 | 30 | !0 |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE | 服务器开始更新时发送到 Discord 的消息 | Server is updating... | "string" |
| DISCORD_POST_UPDATE_BOOT_MESSAGE | 服务器完成更新时发送到 Discord 的消息 | Server update complete! | "string" |
| DISCORD_PRE_START_MESSAGE | 服务器启动时发送到 Discord 的消息 | Server is started! | "string" |
| DISCORD_PRE_SHUTDOWN_MESSAGE | 服务器关闭时发送到 Discord 的消息 | Server is shutting down... | "string" |
| DISCORD_POST_SHUTDOWN_MESSAGE | 服务器停止时发送到 Discord 的消息 | Server is stopped! | "string" |

* 强烈建议设置

** 在运行此选项时，请确保您知道自己在做什么

*** 使用docker stop 命令以保存并优雅地关闭服务器。

### 游戏端口

服务器默认需要以下端口。

| 端口  | 信息             |
|-------|------------------|
| 8211  | 游戏端口 (UDP)  |
| 27015 | 查询端口 (UDP) |
| 25575 | RCON 端口 (TCP)  |
