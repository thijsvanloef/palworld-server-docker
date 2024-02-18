---
sidebar_position: 2
---

# Wiederherstellen eines Backups

## Interaktiv aus einem Backup wiederherstellen

Um aus einem Backup wiederherzustellen, verwenden Sie den Befehl:

```bash
docker exec -it palworld-server restore
```

Die Umgebungsvariable `RCON_ENABLED` muss auf `true` gesetzt sein, um diesen Befehl zu verwenden.
:::warning
Wenn der Docker-Neustart nicht auf die Richtlinie `always` oder `unless-stopped` eingestellt ist, wird der Server
heruntergefahren und muss manuell neu gestartet werden.
<!-- markdownlint-disable-next-line -->
Das Beispiel für den Docker-Befehl und die Docker-Compose-Datei in [der Schnellinstallation](https://palworld-server-docker.loef.dev/de/) verwendet bereits die benötigte Richtlinie.
:::

## Manuell aus einem Backup wiederherstellen

Lokalisieren Sie das Backup, das Sie wiederherstellen möchten, in `/palworld/backups/` und dekomprimieren Sie es.
Vor der Aufgabe muss der Server gestoppt werden.

```bash
docker compose down
```

Löschen Sie den alten Ordner unter `palworld/Pal/Saved/SaveGames/0/<old_hash_value>`.
<!-- markdownlint-disable-next-line -->
Kopieren Sie den Inhalt des neu dekomprimierten Ordner `Saved/SaveGames/0/<new_hash_value>` nach `palworld/Pal/Saved/SaveGames/0/<new_hash_value>`.

Ersetzen Sie den Wert von DedicatedServerName in `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` durch den
neuen Ordnernamen.

```ini
DedicatedServerName=<new_hash_value>  # Ersetzen Sie ihn durch Ihren Ordnernamen.
```

Starten Sie das Spiel neu. (Wenn Sie Docker Compose verwenden)

```bash
docker compose up -d
```
