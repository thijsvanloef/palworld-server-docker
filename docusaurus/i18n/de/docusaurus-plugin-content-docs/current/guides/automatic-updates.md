---
sidebar_position: 5
---

# Automatische Updates

## Konfiguration von automatischen Updates mit Cron

Um automatische Updates mit diesem Server verwenden zu können, **müssen** die folgenden Umgebungsvariablen auf
`true` gesetzt werden:

* `RCON_ENABLED`
* `UPDATE_ON_BOOT`

:::warning
Wenn der Docker-Neustart nicht auf die Richtlinie `always` oder `unless-stopped` gesetzt ist, wird der Server
heruntergefahren und muss manuell neu gestartet werden.

Der Beispiel-Docker-Befehl und die Docker-Compose-Datei in
[der Schnellstartanleitung](https://palworld-server-docker.loef.dev/de/) verwenden bereits die benötigte Richtlinie.
:::

| Variable                    | Info                                                                                                                       | Standardwerte | Erlaubte Werte                                                                                                                                  |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| AUTO_UPDATE_CRON_EXPRESSION | Einstellung beeinflusst die Häufigkeit automatischer Updates.                                                              | 0 \* \* \* \*  | Erfordert einen Cron-Ausdruck - Siehe [Konfiguration automatischer Backups mit Cron](https://palworld-server-docker.loef.dev/de/guides/backup/automated-backup) |
| AUTO_UPDATE_ENABLED         | Aktiviert automatische Updates                                                                                            | false          | true/false                                                                                                                                      |
| AUTO_UPDATE_WARN_MINUTES    | Wie lange gewartet werden soll, bis der Server nach dem Informieren der Spieler aktualisiert wird. (Dies wird ignoriert, wenn keine Spieler verbunden sind) | 30             | !0                                                                                                                                              |
:::tip
Dieses Image verwendet Supercronic für Cron-Jobs.
Siehe [Supercronic](https://github.com/aptible/supercronic#crontab-format)
oder [Crontab Generator](https://crontab-generator.org).
:::

Setzen Sie `AUTO_UPDATE_CRON_EXPRESSION`, um den Standardzeitplan zu ändern.
