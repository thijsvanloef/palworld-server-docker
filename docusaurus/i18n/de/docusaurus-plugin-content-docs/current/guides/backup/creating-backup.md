---
sidebar_position: 1
---

# Erstellen eines Backups

Um ein Backup des Spielstands zum aktuellen Zeitpunkt zu erstellen, verwenden Sie den folgenden Befehl:

```bash
docker exec palworld-server backup
```

Dies wird ein Backup unter `/palworld/backups/` erstellen.

Der Server führt vor dem Backup einen Speichervorgang aus, wenn RCON aktiviert ist.
