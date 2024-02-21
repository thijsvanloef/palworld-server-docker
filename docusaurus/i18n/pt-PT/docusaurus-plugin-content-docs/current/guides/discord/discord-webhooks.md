---
sidebar_position: 1
---

# Utilizar webhooks do discord

1. Gerar um webhook para o servidor discord nas definicões do servidor do discord

2. Definir a variável de ambiente `DISCORD_WEBHOOK_URL` com o token único no final do URL do webhook do Discord,
   por exemplo: `https://discord.com/api/webhooks/1234567890/abcde`

Definir mensagens Discord com docker run:

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
```

Definir mensagens Discord com docker compose:

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Server is updating...
```
