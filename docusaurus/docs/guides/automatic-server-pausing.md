---
sidebar_position: 8
---

# Automatic pause the server when no players are connected

## Configuring Automatic Pause

The AUTO_PAUSE feature puts the PalServer process to sleep when there are no online players.

It saves data before going to sleep.

It wakes up when it detects a client connection.

When in paused state, the world time stops.

This feature can be enabled by setting the environment variable `AUTO_PAUSE_ENABLED` to "true".

| Variable               | Info                                                                                                                                     | Default Values | Allowed Values |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------|
| AUTO_PAUSE_ENABLED     | Enables automatic pause (Puts the server to sleep to save power when there are no online players)                                        | false          | true/false     |
| AUTO_PAUSE_TIMEOUT_EST | default 180 (seconds) describes the time between the last client disconnect and the pausing of the process (read as timeout established) | 180            | Integer        |
| AUTO_PAUSE_LOG         | Enable auto-pause logging                                                                                                                | true           | true/false     |
| AUTO_PAUSE_DEBUG       | Enable auto-pause debug logging                                                                                                          | false          | true/false     |

### Resume manually

A file called `.paused` is created in `/palworld` directory when the server is paused and removed when the server is resumed.

Other services may check for this file's existence before waking the server.

Alternatively, resume with the following command:

```shell
docker exec -it palworld-server autopause resume
```

### Service control manually

A `.autopause-disabled` file can be created in the `/palworld` directory to make the server skip autopausing,
for as long as the file is present.

Alternatively, you can control with the following command:

```shell
docker exec -it palworld-server autopause stop
docker exec -it palworld-server autopause continue
```

This `autopause stop` command is also used during automatic reboots, automatic updates, and container stops.
It is also used to shutdown command via REST API/RCON.

### With Community Server

If the environment variable `COMMUNITY` is true, A proxy server is started within the container to
maintain registration on the community server list.

The proxy server captures communication with `api.palworldgames.com`.

The auto-pause service will replay captured data in the paused state.
