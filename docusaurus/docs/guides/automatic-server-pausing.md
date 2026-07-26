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

:::info
This feature requires `ENABLE_PLAYER_LOGGING=true` and `REST_API_ENABLED=true` to be set.
:::

| Variable                    | Info                                                                                                                                                                    | Default Values | Allowed Values |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------|
| AUTO_PAUSE_ENABLED          | Enables automatic pause (Puts the server to sleep to save power when there are no online players). Requires `ENABLE_PLAYER_LOGGING=true` and `REST_API_ENABLED=true`.   | false          | true/false     |
| AUTO_PAUSE_TIMEOUT_EST      | default 180 (seconds) describes the time between the last client disconnect and the pausing of the process (read as timeout established)                                | 180            | Integer        |
| AUTO_PAUSE_LOG              | Enable auto-pause logging                                                                                                                                               | true           | true/false     |
| AUTO_PAUSE_DEBUG            | Enable auto-pause debug logging                                                                                                                                         | false          | true/false     |
| AUTO_PAUSE_KNOCKD_IF        | Network interfaces to listen for connection knocks. Use `auto` (default) for automatic detection of active interfaces, or specify interfaces explicitly.                | auto           | auto/"eth0 lo" |

If you want timestamps in the container logs for auto-pause events,
either run `docker logs -t palworld-server` or set
`LOG_FORMAT_TYPE=plain` or `LOG_FORMAT_TYPE=colored`.

`AUTO_PAUSE_LOG` messages go through the shared container logger,
so `LOG_FILTER_ENABLED` and `LOG_FORMAT_TYPE` apply to them too.

### Network Interface Configuration

#### Automatic Detection (Default)

When `AUTO_PAUSE_KNOCKD_IF=auto` (default), the system automatically detects active network interfaces.

This is ideal for most Docker deployments where interface names are stable.

#### Explicit Interface Specification

For dynamic environments (e.g., `docker run --network host` and WSL2 with `networkingMode=Mirrored`),
you can explicitly specify interfaces:

```bash
# Example: With WSL2 Mirrored networking
docker run --network host -e AUTO_PAUSE_KNOCKD_IF="eth0 lo loopback0"
```

#### Why This Matters

When using `network_mode=host` in Docker or Podman, the container shares the host's network namespace.
Interface names may vary depending on:

- Host operating system
- Virtual machine configuration (e.g., WSL2 settings)
- Network changes at runtime

Explicit configuration ensures the selected packet monitor filters the correct interfaces even when the network topology changes.

:::note
When using **Podman**, you must add the `--cap-add=NET_RAW` option to the `run` or `create` command.
AUTO_PAUSE prefers an NFLOG packet monitor when available.
If NFLOG setup fails at startup/runtime, it automatically falls back to knockd.
Add the following capability only when you want to use NFLOG monitoring:
`--cap-add=NET_ADMIN`
Alternatively, add the following `cap_add:` to your `compose.yaml`:

```yaml
services:
  palworld:
    cap_add:
      - NET_RAW
      - NET_ADMIN
```

:::

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

### Troubleshooting

#### No usable interfaces detected

**Error message:**

```text
[WARN] AUTO_PAUSE_KNOCKD_IF=auto did not resolve any usable interfaces.
```

**Causes:**

- Running in an unusual network environment where standard interface detection fails
- `/proc/net/route` not available or malformed (rare in Linux containers)
- Network interfaces not accessible in the container

**Solutions:**

1. **Verify interfaces are available:**

   ```bash
   docker exec -it palworld-server sh -c "ip link show"
   docker exec -it palworld-server sh -c "cat /proc/net/route"
   ```

2. **Explicitly specify interfaces:**

   ```bash
   # Replace with your actual interface names from the above commands
   docker run -e AUTO_PAUSE_KNOCKD_IF="eth0" ...
   ```

3. **Enable debug logging to see detection details:**

   ```bash
   docker run -e AUTO_PAUSE_DEBUG=true -e AUTO_PAUSE_KNOCKD_IF="auto" ...
   ```

#### "any" keyword is ignored in knockd backend

If `AUTO_PAUSE_KNOCKD_IF` contains `any`, knockd cannot use it as an interface name.
The value is ignored and a warning is logged:

```text
[WARN] AUTO_PAUSE_KNOCKD_IF contains 'any', but knockd backend does not support it. Ignoring 'any'. Use 'auto' for automatic detection.
```

#### Server not waking up from pause

**Possible causes:**

- Selected packet monitor is filtering wrong interfaces
- Client connection port doesn't match configured port
- NFLOG rule setup failed, causing fallback to knockd

**Diagnostics:**

```bash
# Check which monitor process is running (tcpdump or knockd)
docker exec -it palworld-server ps aux | grep -E "tcpdump|knockd"

# Check NFLOG/AutoPause logs
docker logs -f palworld-server | grep -Ei "nflog|AUTO_PAUSE"

# Verify autopause configuration
docker exec -it palworld-server env | grep AUTO_PAUSE
```

**Solution:**

Ensure `AUTO_PAUSE_KNOCKD_IF` includes the correct network interfaces and enable
`AUTO_PAUSE_DEBUG=true` for detailed logging. If you want NFLOG mode, also ensure
`NET_ADMIN` is granted.

### With Community Server

If the environment variable `COMMUNITY` is true, a proxy server is started within the container
to maintain registration on the community server list.

The proxy server captures communication with `api.palworldgames.com`.

The auto-pause service will replay captured data in the paused state.
