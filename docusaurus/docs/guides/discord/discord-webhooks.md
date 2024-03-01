---
sidebar_position: 1
---

# Using discord webhooks

1. Generate a webhook url for your discord server in your discord's server settings.

2. Set the environment variable with the unique token at the end of the discord webhook url example: `https://discord.com/api/webhooks/1234567890/abcde`

send discord messages with docker run:

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
```

send discord messages with docker compose:

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Server is updating...
```

:::tip
You can mention people in the messages by adding `<@user_id>` in the message!
:::
