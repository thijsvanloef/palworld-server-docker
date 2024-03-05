---
sidebar_position: 3
---

# 服务器命令（RCON）

如何使用 RCON 与服务器进行交互。

## RCON

默认情况下，palworld-server-docker 映像已启用RCON。
打开RCON CLI 非常简单：

```bash
docker exec -it palworld-server rcon-cli "<命令> <数值>"
```

例如，可以使用以下命令向服务器中的所有人广播消息：

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hello everyone"
```

这将打开一个使用 RCON 将命令写入 Palworld 服务器的CLI。

:::warning
目前不支援非 ASCII 的字元，以及使用空白时，只会显示第一个字串。
:::

### 服务器命令列表

| 命令                         | 信息             |
|----------------------------|----------------|
| Shutdown (秒) (信息)          | 服务器将在(秒)后关闭    |
| DoExit                     | 强制关闭服务器。       |
| Broadcast                  | 向服务器中所有玩家发送消息。 |
| KickPlayer (SteamID)       | 从服务器中踢出玩家。     |
| BanPlayer (SteamID)        | 从服务器中封禁玩家。     |
| TeleportToPlayer (SteamID) | 传送到目标玩家。       |
| TeleportToMe (SteamID)     | 将目标玩家传送到身边。    |
| ShowPlayers                | 显示所有已连接玩家信息。   |
| Info                       | 显示服务器信息。       |
| Save                       | 保存游戏。          |

请查看 [官方文档](https://tech.palworldgame.com/settings-and-operation/commands) 以获取所有命令。
