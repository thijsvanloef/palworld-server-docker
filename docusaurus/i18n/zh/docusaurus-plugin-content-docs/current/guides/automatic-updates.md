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

设置 `AUTO_UPDATE_ENABLED` 以启用或禁用自动更新（默认为禁用）。

`AUTO_UPDATE_CRON_EXPRESSION` 是一个cron表达式，在Cron表达式中，需要定义了运行作业的间隔。

> [!TIP]
> 这个镜像使用 Supercronic 来执行 cron 任务。
> 查阅 [supercronic](https://github.com/aptible/supercronic#crontab-format)
> 或者
> [Crontab Generat](https://crontab-generator.org).

設置 `AUTO_UPDATE_CRON_EXPRESSION` 以更改默認时程。
