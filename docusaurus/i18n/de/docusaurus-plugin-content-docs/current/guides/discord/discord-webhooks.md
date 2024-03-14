---
sidebar_position: 1
title: Palworld Server Discord webhooks
description: Wie man die Palworld Dedicated Server Discord Webhook-Integration verwendet, um benachrichtigt zu werden, wenn Ihr Server startet, stoppt und aktualisiert wird!
keywords: [Palworld, palworld dedicated server, Palworld dedicated server Discord Webhooks, Palworld Discord Webhooks]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Using Discord Webhooks
---
<!-- markdownlint-disable-next-line -->
# Verwendung von Discord-Webhooks

Wie man die Palworld Dedicated Server Discord Webhook-Integration verwendet, um benachrichtigt zu werden,
wenn Ihr Server startet, stoppt und aktualisiert wird!

## Los geht's

1. Generieren Sie eine Webhook-URL für Ihren Discord-Server in den Servereinstellungen Ihres Discords.

2. Setze die Umgebungsvariable wie bei dem Discord-Webhook-Beispiel auf diesen eindeutigen Token:
   `https://discord.com/api/webhooks/1234567890/abcde`

Senden Sie Discord-Nachrichten mit `docker run`:

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Der Server wird aktualisiert..." \
```

Senden Sie Discord-Nachrichten mit `docker-compose`:

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Der Server wird aktualisiert...
```

:::tip
Du kannst Personen in den Nachrichten erwähnen, indem du `<@user_id>` in die Nachricht einfügst!
:::
