---
sidebar_position: 3
title: Linux UE4SS Mod Support
description: Enable experimental Linux UE4SS on the Palworld dedicated server Docker image.
keywords: [Palworld, UE4SS, mods, Linux, Docker, ENABLE_UE4SS]
---

# Linux UE4SS Mod Support

Palworld gameplay mods that need [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) traditionally require the Windows dedicated server. This image can inject an experimental native Linux build of UE4SS ([XarminaEu/ue4ss-linux](https://github.com/XarminaEu/ue4ss-linux)) into the Linux server process.

This addresses the Linux-side of [issue #885](https://github.com/thijsvanloef/palworld-server-docker/issues/885) / [issue #906](https://github.com/thijsvanloef/palworld-server-docker/issues/906).

:::warning Experimental
Linux UE4SS is community-maintained and can break after game updates. Official Steam Workshop / `PalModSettings.ini` server mods remain Windows-only.
:::

## Requirements

* `amd64` host (not supported on `arm64`)
* Persistent `/palworld` volume
* `ENABLE_UE4SS=true`

## Enable UE4SS

```yaml
environment:
  ENABLE_UE4SS: true
```

On boot the container will:

1. Copy `libUE4SS.so` into `Pal/Binaries/Linux/`
2. Create default `UE4SS-settings.ini` and `Mods/mods.txt` if missing
3. Sync mods from the volume paths below
4. Start the server with `LD_PRELOAD=.../libUE4SS.so`

## Where to put mods

Keep source files under `/palworld/Mods/` so they survive Steam validate / update cycles. They are synced into the runtime folders every boot.

| Host / volume path | Runtime destination | Contents |
|--------------------|---------------------|----------|
| `palworld/Mods/NativeMods/<ModName>/` | `Pal/Binaries/Linux/Mods/<ModName>/` | Lua mods (`scripts/main.lua`) or Linux C++ mods (`libs/main.so`) |
| `palworld/Mods/Paks/` | `Pal/Content/Paks/~Mods/` | `.pak` / `.ucas` / `.utoc` files |
| `palworld/Mods/UE4SS-settings.ini` | `Pal/Binaries/Linux/UE4SS-settings.ini` | Optional override of UE4SS settings |

Enable each mod in `Pal/Binaries/Linux/Mods/mods.txt`:

```text
PalSchema : 1
QualityOfLife : 1
```

## Lua vs C++ mods

| Type | Works on Linux UE4SS? | Notes |
|------|------------------------|-------|
| Lua (`scripts/main.lua`) | Yes | Same files as Windows |
| Pak files | Yes | Place under `Mods/Paks/` |
| C++ (`.dll`) | No | Needs a Linux `libs/main.so` rebuild — renaming `.dll` does not work |

Many popular mods (including [PalSchema](https://github.com/Okaetsu/PalSchema)) only ship Windows `.dll` files today. Those C++ pieces will not load on Linux UE4SS until the mod author publishes a Linux build.

## QualityOfLife example

[QualityOfLife](https://steamcommunity.com/sharedfiles/filedetails/?id=3761921027) needs UE4SS. Some features are Lua (for example base range / work efficiency); others require PalSchema (C++).

Expected partial setup on this image:

1. Set `ENABLE_UE4SS=true` and restart once so folders are created.
2. Stop the server.
3. Extract the QualityOfLife **Lua** folder into `palworld/Mods/NativeMods/QualityOfLife/`.
4. Copy both QualityOfLife `.pak` files into `palworld/Mods/Paks/`.
5. Add `QualityOfLife : 1` to `Pal/Binaries/Linux/Mods/mods.txt` (after first sync you can also edit the copy under `NativeMods` and reboot).
6. Start the server and check for `[UE4SS]` / `[QualityOfLife]` lines in the logs / `UE4SS.log`.

PalSchema-dependent options (passive-skill weights, Capture Power statue costs, expedition time) will not work until a Linux `libs/main.so` for PalSchema exists. For full Windows-mod compatibility today, use a Wine/Proton Windows dedicated server instead.

## Verify

Look for:

* Container log: `UE4SS enabled via LD_PRELOAD=...`
* `palworld/Pal/Binaries/Linux/UE4SS.log` after the server has started

If the server segfaults after enabling UE4SS, set hooks to `false` in `UE4SS-settings.ini` (under `[Hooks]`) and re-enable them gradually.

## Related

* [XarminaEu/ue4ss-linux](https://github.com/XarminaEu/ue4ss-linux)
* [Palworld Modding Docs — Dedicated Server](https://pwmodding.wiki/docs/users/ue4ss/installation-server)
