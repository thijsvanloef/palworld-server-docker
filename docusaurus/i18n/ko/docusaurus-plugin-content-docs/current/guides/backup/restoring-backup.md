---
sidebar_position: 2
---

# Restoring a backup

## Interactively restore from a backup

To restore from a backup, use the command:

```bash
docker exec -it palworld-server restore
```

The `RCON_ENABLED` environment variable must be set to `true` to use this command.
:::warning
If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and
will need to be manually restarted.

The example docker run command and docker compose file in [the Quicksetup](https://palworld-server-docker.loef.dev/)
already uses the needed policy
:::

## Manually restore from a backup

Locate the backup you want to restore in `/palworld/backups/` and decompress it.
Need to stop the server before task.

```bash
docker compose down
```

Delete the old saved data folder located at `palworld/Pal/Saved/SaveGames/0/<old_hash_value>`.

Copy the contents of the newly decompressed saved data folder `Saved/SaveGames/0/<new_hash_value>` to `palworld/Pal/Saved/SaveGames/0/<new_hash_value>`.

Replace the DedicatedServerName inside `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` with the new folder name.

```ini
DedicatedServerName=<new_hash_value>  # Replace it with your folder name.
```

Restart the game. (If you are using Docker Compose)

```bash
docker compose up -d
```
