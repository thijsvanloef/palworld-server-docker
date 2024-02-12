---
sidebar_position: 1
---

# 使用 discord webhooks

1. 在 Discord 的服务器设置中为你的 Discord 服务器生成一个 Webhook URL。

2. 使用 Discord Webhook URL 的範例，將唯一的令牌設置為環境變數，附在 URL 的末尾，如下所示：`https://discord.com/api/webhooks/1234567890/abcde`

使用 Docker run 命令发送 Discord 消息：

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
```

使用 Docker Compose 命令發送 Discord 消息：

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Server is updating...
```
