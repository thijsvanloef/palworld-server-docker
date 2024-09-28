---
sidebar_position: 5
---

# 自动更新

## 使用 Cron 执行自动更新

如果要在伺服器上使用自动更新功能， **必须** 将以下环境变数设置为 `true`：

* `RCON_ENABLED`
* `UPDATE_ON_BOOT`

:::warning
如果 Docker 重启策略不是设为 `always` 或 `unless-stopped`，那麽伺服器将会关闭，需要手动重新启动。

在 [开始使用](https://palworld-server-docker.loef.dev/zh/) 中的示例 Docker run 命令和 Docker Compose 文件已經使用了所需的策略。
:::

| 变量                        | 信息                                                                                                                       | 默认值        | 允许的值                                                                                                                                    |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| AUTO_UPDATE_CRON_EXPRESSION | 设置影响自动更新的频率。                                                                                                  | 0 \* \* \* \* | 需要 Cron 表达式 - 请参见[使用 Cron 配置自动备份](https://palworld-server-docker.loef.dev/zh/guides/backup/automated-backup/)                   |
| AUTO_UPDATE_ENABLED         | 启用自动更新                                                                                                              | false        | true/false                                                                                                                                    |
| AUTO_UPDATE_WARN_MINUTES    | 在通知玩家后等待多长时间更新服务器（如果没有玩家连接，将忽略此设置）                                                      | 30           | !0                                                                                                                                            |

:::tip
这个镜像使用 Supercronic 来执行 cron 任务。
查阅 [supercronic](https://github.com/aptible/supercronic#crontab-format)
或者 [Crontab Generat](https://crontab-generator.org).
:::

設置 `AUTO_UPDATE_CRON_EXPRESSION` 以更改默認时程。
