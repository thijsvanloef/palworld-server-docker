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
| API_PROXY_ENABLED           | Enable the cached REST API proxy service. Requires REST API, AutoPause, and a non-empty `ADMIN_PASSWORD`.                                                                     | false          | true/false     |
| API_PROXY_PORT              | Port for the cached REST API proxy; use a separate, private port.                                                                                                          | 8213           | 1-65535        |

If you want timestamps in the container logs for auto-pause events,
either run `docker logs -t palworld-server` or set
`LOG_FORMAT_TYPE=plain` or `LOG_FORMAT_TYPE=colored`.

`AUTO_PAUSE_LOG` messages go through the shared container logger,
so `LOG_FILTER_ENABLED` and `LOG_FORMAT_TYPE` apply to them too.

### Cached REST API proxy

When `API_PROXY_ENABLED` is set to `true`, the proxy service starts and listens on `API_PROXY_PORT`.
When it is `false`, the proxy is not used, and REST API requests connect directly to `REST_API_PORT`.

The proxy uses `API_PROXY_PORT` (default: `8213`).
Use a different port from `REST_API_PORT`.

Authenticated requests to the proxy use the following cacheable endpoints. While the server is paused, a cached response is returned from memory without waking the server:

   GET /v1/api/players
   GET /v1/api/game-data
   GET /v1/api/metrics
   GET /v1/api/info
   GET /v1/api/settings
   POST /v1/api/save

If no cached response is available for a cacheable endpoint, the proxy resumes the server, forwards the request to the REST API, caches a successful response, and returns it.
Authenticated requests to other endpoints, or requests received while the server is not paused, are forwarded directly to the REST API.

After requesting a resume, the proxy waits up to five seconds for the REST API to become available. If it does not become available in time, or the REST API is unreachable when the request is forwarded, the proxy returns HTTP 503.

The container startup script waits for the PalServer process and stops the proxy when the server exits. Because the cache is held in memory, it is lost when the proxy stops.

Before pausing the server, AUTO PAUSE calls the cacheable APIs to refresh their cached responses.

```yaml
#port:
#   - "127.0.0.1:8213:8213/tcp"
environment:
   API_PROXY_ENABLED: true
   API_PROXY_PORT: 8213
```

For Kubernetes, enable `API_PROXY_ENABLED` in the ConfigMap and apply the optional ClusterIP Service:

```shell
kubectl apply -f kubernetes/api-proxy-service.yaml
#kubectl port-forward service/palworld-api-proxy 8213:8213
```

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
If NFLOG setup fails at startup, the system will automatically fall back to knockd.
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

### Check status

Show the current auto-pause state with:

```shell
docker exec -it palworld-server autopause status
```

The comma-separated output can include these states:

- `enabled`: `AUTO_PAUSE_ENABLED` is enabled and Player Logging is enabled.
- `disabled`: auto-pause or Player Logging is disabled.
- `paused`: the `/palworld/.paused` file exists.
- `sleeping`: the PalServer process is stopped.
- `force_disabled`: the `/palworld/.autopause-disabled` file exists.

Multiple states can be reported at the same time. Pass an optional `grep -E` regular
expression to make the command return `0` when the output matches and `1` when it does not:

```shell
docker exec -it palworld-server autopause status 'paused|sleeping'
```

Without a filter, the command returns `0`.

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
