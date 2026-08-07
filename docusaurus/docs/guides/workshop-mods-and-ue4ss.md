---
sidebar_position: 3
---

# Workshop Mods and UE4SS Setup

This guide provides a safe and repeatable workflow for running Workshop mods and UE4SS on the Windows server path.

## About `-nosteam` / `NOSTEAM`

This image can add `-nosteam` by setting `NOSTEAM=true`.

The official Palworld server documentation does not explicitly mention `-nosteam`.

It appears to be used when maintaining existing save data, though the details are unclear.

Because of that, treat `NOSTEAM` as an operational compatibility option and validate behavior
in your own environment when you enable it.

## Recommended base example

Start from the included example:

* [examples/mods/compose.yaml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/examples/mods/compose.yaml)

The example includes all mod-related environment variables.

## Choose mod source(s)

You can combine these methods:

A. Workshop IDs via environment variable
B. Workshop IDs via file
C. NativeMods folders under `/palworld/Mods/NativeMods`

### Method A: Workshop IDs in environment variable

Set a comma-separated list:

```yaml
environment:
  WORKSHOP_MOD_IDS: "3625280368,3625287786"
```

### Method B: Workshop IDs in file

Create `/palworld/workshop-mods.txt` and place one ID per line.

Example:

```text
3625280368
3625287786
```

If you manage IDs in file, leave `WORKSHOP_MOD_IDS` empty.

### Method C: NativeMods folders

Place extracted native mod folders under:

```text
/palworld/Mods/NativeMods/<mod_name>/...
```

At startup and periodic sync, mod files are deployed to the active runtime path.

## Install latest experimental UE4SS (optional)

To auto-download and deploy the experimental UE4SS package:

```yaml
environment:
  UE4SS_EXPERIMENTAL_INSTALL: true
  UE4SS_EXPERIMENTAL_URL: "https://github.com/Okaetsu/RE-UE4SS/releases/download/experimental-palworld/UE4SS-Palworld.zip"
  UE4SS_CLEANUP_LEGACY: true
```

## Secure Workshop authentication (no password env)

For paid/private Workshop items, do not put Steam password in compose or dotenv.

Use this flow:

1. Set `STEAM_USERNAME` in `compose.yaml`
2. run `steam-login` once to save the login credentials to the `/palworld` volume.
3. Restart the server.

Example:

```bash
cd examples/mods
./save-login-credential.sh
docker compose up -d
```

The helper stores account metadata in `.steam-login-user` under the `/palworld/.steam/`.
This file is managed automatically by the helper script and usually does not require manual edits.

## Automatic update checks

Configure periodic Workshop sync:

```yaml
environment:
  WORKSHOP_MOD_UPDATE_CRON: "0 */6 * * *"
```

Set empty string to disable periodic checks.

## Verify expected logs

Healthy sync typically includes:

* `Syncing workshop mods`
* `Logging in using cached credentials`
* `Success. Downloaded item ...`
* `Mod changes detected` (only when effective changes are found)

## Troubleshooting quick checks

1. Workshop download fails

    Check whether `/palworld` is persisted
    and whether one-time login was completed with `steam-login`.
    See `examples/mods/save-login-credential.sh`

2. Files downloaded but mod not active

    Confirm deployed files appear under `Pal/Binaries/Win64/ue4ss/Mods`.

3. Steam credentials prompts keep returning

    Re-run `steam-login` and complete Steam Guard approval,
    then restart the container.
    See `examples/mods/save-login-credential.sh`
