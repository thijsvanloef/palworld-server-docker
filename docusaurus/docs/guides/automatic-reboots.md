---
sidebar_position: 4
---

# Automatic Reboots

## Configuring Automatic Reboots with Cron

To be able to use automatic reboots with this server `RCON_ENABLED` enabled.

:::warning

If docker restart is not set to policy `always` or `unless-stopped`
then the server will shutdown and will need to be manually restarted.

The example docker run command and docker compose file in [the Quicksetup](https://palworld-server-docker.loef.dev/)
already use the needed policy
:::

Set `AUTO_REBOOT_ENABLED` enable or disable automatic reboots (Default is disabled)

`AUTO_REBOOT_CRON_EXPRESSION` is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

:::tip
This image uses Supercronic for crons
see [supercronic](https://github.com/aptible/supercronic#crontab-format)
or [Crontab Generator](https://crontab-generator.org).
:::
Set `AUTO_REBOOT_CRON_EXPRESSION` to change the set the schedule, default is everynight at midnight according to the
timezone set with TZ
