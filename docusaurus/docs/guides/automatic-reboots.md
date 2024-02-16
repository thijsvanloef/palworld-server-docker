---
sidebar_position: 4
---

# Automatic Reboots

## Configuring Automatic Reboots with Cron

To be able to use automatic reboots with this Server the following environment variables **have** to be set to `true`:

* `RCON_ENABLED`

:::warning

If docker restart is not set to policy `always` or `unless-stopped`
then the server will shutdown and will need to be manually restarted.

The example docker run command and docker compose file in [the Quicksetup](https://palworld-server-docker.loef.dev/)
already use the needed policy
:::

| Variable                           | Info                                                                   | Default Values | Allowed Values                                                                                                    |
|------------------------------------|------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------|
| AUTO_REBOOT_CRON_EXPRESSION        | Setting affects frequency of automatic updates.                        | 0 0 \* \* \*   | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](#configuring-automatic-reboots-with-cron) |
| AUTO_REBOOT_ENABLED                | Enables automatic reboots                                              | false          | true/false                                                                                                        |
| AUTO_REBOOT_WARN_MINUTES           | How long to wait to reboot the server, after the player were informed. | 5              | !0                                                                                                                |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Restart the Server even if there are players online.                   | false          | true/false                                                                                                        |

:::tip
This image uses Supercronic for crons
see [supercronic](https://github.com/aptible/supercronic#crontab-format)
or [Crontab Generator](https://crontab-generator.org).
:::
Set `AUTO_REBOOT_CRON_EXPRESSION` to change the set the schedule, default is everynight at midnight according to the
timezone set with TZ
