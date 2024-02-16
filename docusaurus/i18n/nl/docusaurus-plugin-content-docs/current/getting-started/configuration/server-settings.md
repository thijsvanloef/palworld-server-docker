---
sidebar_position: 1
---

# Serverinstellingen

Serverinstellingen wijzigen met behulp van omgevingsvariabelen.

## Omgevingsvariabelen

Je kunt de volgende waarden gebruiken om de instellingen van de server bij het opstarten te wijzigen.
Het wordt sterk aanbevolen om de volgende omgevingswaarden in te stellen voordat je de server start:

* PLAYERS
* PORT
* PUID
* PGID

| Variable           | Info                                                                                                                                                                                                | Default Values | Allowed Values |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------------------------------------------------------------------------------------|
| TZ                 | Timezone used for time stamping backup server                                                                                                                                                       | UTC            | See [TZ Identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
| PLAYERS*           | Max amount of players that are able to join the server                                                                                                                                              | 16             | 1-32                                                                                                       |
| PORT*              | UDP port that the server will expose                                                                                                                                                                | 8211           | 1024-65535                                                                                                 |
| PUID*              | The uid of the user the server should run as                                                                                                                                                        | 1000           | !0                                                                                                         |
| PGID*              | The gid of the group the server should run as                                                                                                                                                       | 1000           | !0                                                                                                         |
| MULTITHREADING**   | Improves performance in multi-threaded CPU environments. It is effective up to a maximum of about 4 threads, and allocating more than this number of threads does not make much sense.              | false          | true/false                                                                                                 |
| COMMUNITY          | Whether or not the server shows up in the community server browser (USE WITH SERVER_PASSWORD)                                                                                                       | false          | true/false                                                                                                 |
| PUBLIC_IP          | You can manually specify the global IP address of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |                | x.x.x.x                                                                                                    |
| PUBLIC_PORT        | You can manually specify the port number of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration.       |                | 1024-65535                                                                                                 |
| SERVER_NAME        | A name for your server                                                                                                                                                                              |                | "string"                                                                                                   |
| SERVER_DESCRIPTION | Your server Description                                                                                                                                                                             |                | "string"                                                                                                   |
| SERVER_PASSWORD    | Secure your community server with a password                                                                                                                                                        |                | "string"                                                                                                   |
| ADMIN_PASSWORD     | Secure administration access in the server with a password                                                                                                                                          |                | "string"                                                                                                   |
| UPDATE_ON_BOOT**   | Update/Install the server when the docker container starts (THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER)                                                                            | true           | true/false                                                                                                 |
| RCON_ENABLED***    | Enable RCON for the Palworld server                                                                                                                                                                 | true           | true/false                                                                                                 |
| RCON_PORT          | RCON port to connect to                                                                                                                                                                             | 25575          | 1024-65535                                                                                                 |
| QUERY_PORT         | Query port used to communicate with Steam servers                                                                                                                                                   | 27015          | 1024-65535                                                                                                 |
| BACKUP_CRON_EXPRESSION  | Setting affects frequency of automatic backups. | 0 0 \* \* \* | Needs a Cron-Expression - See [Configuring Automatic Backups with Cron](https://palworld-server-docker.loef.dev/guides/backup/automated-backup) |
| BACKUP_ENABLED | Enables automatic backups | true | true/false |
| DELETE_OLD_BACKUPS | Delete backups after a certain number of days                                                                                                                                                       | false          | true/false                                                                                                 |
| OLD_BACKUP_DAYS    | How many days to keep backups                                                                                                                                                                       | 30             | any positive integer                                                                                       |
| AUTO_UPDATE_CRON_EXPRESSION  | Setting affects frequency of automatic updates. | 0 \* \* \* \* | Needs a Cron-Expression - See [Configuring Automatic Updates with Cron](https://palworld-server-docker.loef.dev/guides/automatic-reboots) |
| AUTO_UPDATE_ENABLED | Enables automatic updates | false | true/false |
| AUTO_UPDATE_WARN_MINUTES | How long to wait to update the server, after the player were informed. | 30 | !0 |
| AUTO_REBOOT_CRON_EXPRESSION  | Setting affects frequency of automatic updates. | 0 0 \* \* \* | Needs a Cron-Expression - See [Configuring Automatic Reboots with Cron](https://palworld-server-docker.loef.dev/guides/automatic-updates) |
| AUTO_REBOOT_ENABLED | Enables automatic reboots | false | true/false |
| AUTO_REBOOT_WARN_MINUTES | How long to wait to reboot the server, after the player were informed. | 5 | !0 |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Restart the Server even if there are players online. | false | true/false |
| DISCORD_WEBHOOK_URL | Discord webhook url found after creating a webhook on a discord server | | `https://discord.com/api/webhooks/<webhook_id>` |
| DISCORD_CONNECT_TIMEOUT | Discord command initial connection timeout | 30 | !0 |
| DISCORD_MAX_TIMEOUT | Discord total hook timeout | 30 | !0 |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE | Discord message sent when server begins updating | Server is updating... | "string" |
| DISCORD_POST_UPDATE_BOOT_MESSAGE | Discord message sent when server completes updating | Server update complete! | "string" |
| DISCORD_PRE_START_MESSAGE | Discord message sent when server begins to start | Server is started! | "string" |
| DISCORD_PRE_SHUTDOWN_MESSAGE | Discord message sent when server begins to shutdown | Server is shutting down... | "string" |
| DISCORD_POST_SHUTDOWN_MESSAGE | Discord message sent when server has stopped | Server is stopped! | "string" |

*Het is ten zeerste aanbevolen om in te stellen.

**Zorg ervoor dat je weet wat je doet wanneer je deze optie inschakelt.

***Vereist voor docker stop om de server op te slaan en op een correcte manier af te sluiten.

### Game Ports

De server heeft standaard de volgende poorten nodig.

| Port  | Info             |
|-------|------------------|
| 8211  | Game Port (UDP)  |
| 27015 | Query Port (UDP) |
| 25575 | RCON Port (TCP)  |
