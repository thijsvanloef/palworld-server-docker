---
sidebar_position: 4
---

# Automatische herstarts

## Configuratie van automatische herstarts met Cron

Om automatische herstarts met deze Server te kunnen gebruiken,
moeten de volgende omgevingsvariabelen worden ingesteld op `true`:

* RCON_ENABLED

:::warning

Als docker restart niet is ingesteld op het beleid `always` of `unless-stopped`,
dan zal de server afsluiten en moet handmatig opnieuw worden gestart.

Het voorbeeld docker run commando en docker compose bestand in de [de Snelle installatie](https://palworld-server-docker.loef.dev/)
gebruiken al het vereiste beleid.
:::

| Variable                           | Info                                                                   | Default Values | Allowed Values                                                                                                    |
|------------------------------------|------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------|
| AUTO_REBOOT_CRON_EXPRESSION        | De instelling beïnvloedt de frequentie van automatische updates.                      | 0 0 \* \* \*   | Heeft een Cron expressie nodig - Zie [Configuring Automatic Backups with Cron](https://palworld-server-docker.loef.dev/nl/guides/backup/automated-backup) |
| AUTO_REBOOT_ENABLED                | Schakelt automatische herstarts in.                                              | false          | true/false                                                                                                        |
| AUTO_REBOOT_WARN_MINUTES           | Hoe lang moet er gewacht worden voordat de server wordt herstart. | 5              | !0                                                                                                                |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Herstart de server zelfs als er spelers online zijn.                   | false          | true/false                                                                                                        |

:::tip
Deze image gebruikt Supercronic voor cron-jobs.
zie [supercronic](https://github.com/aptible/supercronic#crontab-format)
of [Crontab Generator](https://crontab-generator.org).
:::

Stel `AUTO_REBOOT_CRON_EXPRESSION` in om het schema te wijzigen,
standaard is elke nacht om middernacht volgens de tijdzone ingesteld met TZ.
