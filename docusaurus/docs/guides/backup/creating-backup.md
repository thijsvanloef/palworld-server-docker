---
sidebar_position: 1
---

# Creating a backup

To create a backup of the game's save at the current point in time, use the command:

```bash
docker exec palworld-server backup
```

This will create a backup at `/palworld/backups/`

The server will run a save before the backup if rcon is enabled.
