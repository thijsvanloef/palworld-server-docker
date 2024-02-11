---
sidebar_position: 5
---

# Automatic Updates

## Configuring Automatic Updates with Cron

To be able to use automatic Updates with this Server the following environment variables **have** to be set to `true`:

* `RCON_ENABLED`
* `UPDATE_ON_BOOT`

:::warning
If docker restart is not set to policy `always` or `unless-stopped`
then the server will shutdown and will need to be manually restarted.

The example docker run command and docker compose file in [How to Use](#how-to-use)
already use the needed policy
:::

Set `AUTO_UPDATE_ENABLED` enable or disable automatic updates (Default is disabled)

`AUTO_UPDATE_CRON_EXPRESSION` is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

:::tip
This image uses Supercronic for crons
see [supercronic](https://github.com/aptible/supercronic#crontab-format)
or [Crontab Generator](https://crontab-generator.org).
:::

Set `AUTO_UPDATE_CRON_EXPRESSION` to change the default schedule.