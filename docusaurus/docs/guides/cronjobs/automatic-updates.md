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

The example docker run command and docker compose file in [the Quicksetup](https://palworld-server-docker.loef.dev/)
already use the needed policy
:::

| Variable                    | Info                                                                                                                       | Default Values | Allowed Values                                                                                                                                  |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| AUTO_UPDATE_CRON_EXPRESSION | Setting affects frequency of automatic updates.                                                                            | 0 \* \* \* \*  | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](https://palworld-server-docker.loef.dev/guides/backup/automated-backup) |
| AUTO_UPDATE_ENABLED         | Enables automatic updates                                                                                                  | false          | true/false                                                                                                                                      |
| AUTO_UPDATE_WARN_MINUTES    | How long to wait to update the server, after the player were informed. (This will be ignored, if no Players are connected) | 30             | !0                                                                                                                                              |
:::tip
This image uses Supercronic for crons
see [supercronic](https://github.com/aptible/supercronic#crontab-format)
or [Crontab Generator](https://crontab-generator.org).
:::

Set `AUTO_UPDATE_CRON_EXPRESSION` to change the default schedule.
