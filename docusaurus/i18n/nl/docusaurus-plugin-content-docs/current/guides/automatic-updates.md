---
sidebar_position: 5
---

# Automatische Updates

## Configuratie van Automatische Updates met Cron

Om automatische updates met deze server te kunnen gebruiken, moeten de volgende omgevingsvariabelen worden ingesteld op true:

* RCON_ENABLED
* UPDATE_ON_BOOT

:::warning
Als docker restart niet is ingesteld op het beleid always of unless-stopped,
dan zal de server afsluiten en moet handmatig opnieuw worden gestart.

Het voorbeeld docker run commando en docker compose bestand in de [de Snelle installatie](https://palworld-server-docker.loef.dev/)
gebruiken al het vereiste beleid.
:::

| Variable                    | Info                                                                                                                       | Default Values | Allowed Values                                                                                                                                  |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| AUTO_UPDATE_CRON_EXPRESSION | De instelling beïnvloedt de frequentie van automatische updates.                                                                            | 0 \* \* \* \*  | Heeft een Cron expressie nodig - Zie [Configuring Automatic Backups with Cron](https://palworld-server-docker.loef.dev/nl/guides/backup/automated-backup) |
| AUTO_UPDATE_ENABLED         | Schakelt automatische updates in.                                                                                                  | false          | true/false                                                                                                                                      |
| AUTO_UPDATE_WARN_MINUTES    | Hoe lang moet er gewacht worden voordat de server wordt bijgewerkt | 30             | !0                                                                                                                                              |

:::tip
Deze image gebruikt Supercronic voor cron-jobs.
zie [supercronic](https://github.com/aptible/supercronic#crontab-format)
of [Crontab Generator](https://crontab-generator.org).
:::

Stel `AUTO_UPDATE_CRON_EXPRESSION` in om het standaardschema te wijzigen.
