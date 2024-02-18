---
sidebar_position: 3
---

# Konfigurieren Sie automatische Backups

Der Server wird jede Nacht um Mitternacht automatisch gesichert, je nach der mit `TZ` festgelegten Zeitzone.

Setzen Sie `BACKUP_ENABLED`, um automatische Backups zu aktivieren oder zu deaktivieren (Standardmäßig aktiviert).

`BACKUP_CRON_EXPRESSION` ist ein Cron-Ausdruck. In einem Cron-Ausdruck definieren Sie ein Intervall, wann Aufgaben
ausgeführt werden sollen.

:::tip
Dieses Image verwendet Supercronic für Cron-Jobs.
Siehe [supercronic](https://github.com/aptible/supercronic#crontab-format)
oder [Crontab Generator](https://crontab-generator.org).
:::

Setzen Sie `BACKUP_CRON_EXPRESSION`, um den Standardzeitplan zu ändern.

**Beispielverwendung**: Wenn `BACKUP_CRON_EXPRESSION` auf `0 2 * * *` gesetzt ist, wird das Backup-Skript jeden Tag um
2:00 Uhr morgens ausgeführt.
