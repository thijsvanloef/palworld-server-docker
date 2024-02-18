---
sidebar_position: 4
---

# Automatische Neustarts

## Konfiguration von automatischen Neustarts mit Cron

Um automatische Neustarts mit diesem Server verwenden zu können, **müssen** die folgenden Umgebungsvariablen auf `true`
gesetzt werden:

* `RCON_ENABLED`

:::warning

Wenn der Docker-Neustart nicht auf die Richtlinie `always` oder `unless-stopped` gesetzt ist, wird der Server
heruntergefahren und muss manuell neu gestartet werden.
<!-- markdownlint-disable-next-line -->
Der Beispiel-Docker-Befehl und die Docker-Compose-Datei in [der Schnellstartanleitung](https://palworld-server-docker.loef.dev/de/) verwenden bereits die benötigte Richtlinie.
:::

| Variable                           | Info                                                                   | Standardwert | Erlaubte Werte                                                                                                    |
|------------------------------------|------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------|
| AUTO_REBOOT_CRON_EXPRESSION        | Einstellung beeinflusst die Häufigkeit automatischer Neustarts.        | 0 0 \* \* \*   | Erfordert einen Cron-Ausdruck - Siehe [Konfiguration automatischer Backups mit Cron](https://palworld-server-docker.loef.dev/de/guides/backup/automated-backup) |
| AUTO_REBOOT_ENABLED                | Aktiviert automatische Neustarts                                      | false          | true/false                                                                                                        |
| AUTO_REBOOT_WARN_MINUTES           | Wie lange gewartet werden soll, bis der Server nach dem Informieren der Spieler neu gestartet wird. | 5              | !0                                                                                                                |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Startet den Server neu, auch wenn Spieler online sind.                 | false          | true/false                                                                                                        |

:::tip
Dieses Image verwendet Supercronic für Cron-Jobs.
Siehe [Supercronic](https://github.com/aptible/supercronic#crontab-format)
oder [Crontab Generator](https://crontab-generator.org).
:::
Setzen Sie `AUTO_REBOOT_CRON_EXPRESSION`, um den Zeitplan zu ändern. Standardmäßig ist er auf jede Nacht um Mitternacht
gesetzt. (gemäß der mit TZ festgelegten Zeitzone)
