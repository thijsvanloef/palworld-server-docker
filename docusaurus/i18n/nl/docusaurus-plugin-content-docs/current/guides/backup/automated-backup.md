---
sidebar_position: 3
---

# Configureer geautomatiseerde back-ups

De server wordt automatisch elke nacht om middernacht geback-upt volgens de tijdzone ingesteld met TZ.

Stel `BACKUP_ENABLED` in om automatische back-ups in of uit te schakelen (standaard is ingeschakeld).

`BACKUP_CRON_EXPRESSION` is een cron-uitdrukking,
in een Cron-uitdrukking definieer je een interval voor wanneer taken moeten worden uitgevoerd.

:::tip
Deze image gebruikt Supercronic voor cron-jobs.
zie [supercronic](https://github.com/aptible/supercronic#crontab-format)
of [Crontab Generator](https://crontab-generator.org).
:::

Stel `BACKUP_CRON_EXPRESSION` in om het standaardschema te wijzigen.

**Voorbeeldgebruik**: Als BACKUP_CRON_EXPRESSION is ingesteld op `0 2 * * *`,
wordt het back-upscript elke dag om 2:00 uur 's ochtends uitgevoerd.
