---
sidebar_position: 1
---

# 创建备份

要在当前时间点创建游戏存档的备份，请使用以下命令：

```bash
docker exec palworld-server backup
```

这将在 `/palworld/backups/` 下创建一个备份。

如果启用了 rcon，服务器将在备份之前运行一次保存。
