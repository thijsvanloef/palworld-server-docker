---
sidebar_position: 2
---

# 透过备份恢復数据

## 透过脚本恢復数据

要从备份中恢复，请使用以下命令：

```bash
docker exec -it palworld-server restore
```

必须将 `RCON_ENABLED` 环境变量设置为 `true` 以使用此命令。

:::warning
如果 Docker 重启策略不是设为 `always` 或 `unless-stopped`，那麽伺服器将会关闭，需要手动重新启动。

在 [开始使用](https://palworld-server-docker.loef.dev/zh/) 中的示例 Docker run 命令和 Docker Compose 文件已經使用了所需的策略。
:::

## 手动从备份中恢复数据

在 `/palworld/backups/` 中找到要恢复的备份并解压缩它。
在执行任务之前需要停止服务器。

```bash
docker compose down
```

删除位于 `/palworld/Pal/Saved/SaveGames/0/<old_hash_value>` 的旧保存数据文件夹。

将新解压缩的保存数据文件夹 `Saved/SaveGames/0/<new_hash_value>` 的内容复制到 `palworld/Pal/Saved/SaveGames/0/<new_hash_value>` 。

将 `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` 中的 `DedicatedServerName` 替换为新文件夹名称。

```ini
DedicatedServerName=<new_hash_value>  # 替换为新的保存数据文件夹名称
```

重新启动游戏。（如果您正在使用 Docker Compose）

```bash
docker compose up -d
```
