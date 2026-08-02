---
sidebar_position: 2
---

# Modding

This image supports two types of Palworld mods: **resource `.pak` mods** and **UE4SS Lua/LogicMod mods**.

## Resource `.pak` mods

Resource `.pak` mods replace or add cooked assets (textures, models, audio, data tables).
They load via Palworld's native pak system and **do not require UE4SS**.

Mount your `.pak` files at `/palworld/Pal/Content/Paks/~mods`:

```yaml
volumes:
  - ./paks:/palworld/Pal/Content/Paks/~mods
```

Drop `.pak` files into the `./paks` directory. If the mod ships `.ucas` and `.utoc`
companion files alongside the `.pak`, keep all three together — splitting them breaks
the package.

:::tip
Resource `.pak` mods are the simplest to install. No loader or framework required.
:::

### Known resource `.pak` mods

| Mod | Description |
|-----|-------------|
| [MapUnlocker](https://www.nexusmods.com/palworld/mods/16) | Unlocks the full map (~592k downloads) |
| [2x-5x-10x-100x Palsphere & Ammo Crafting](https://www.nexusmods.com/palworld/mods/3132) | Multiplies craft output — pick one variant only |
| [Enhanced Palworld Visuals](https://www.nexusmods.com/palworld/mods/) | Disables/enables post-processing effects |

## UE4SS mods

This image bundles the x86-64 Linux build of [UE4SS](https://github.com/XarminaEu/ue4ss-linux).
Enable it with `UE4SS_ENABLED=true` on an amd64 host. ARM64 support requires a patched Box64 build which is currently in progress.

Mount your mods at `/palworld/Pal/Binaries/Linux/Mods`. The included Compose example uses `./mods`:

```yaml
environment:
  UE4SS_ENABLED: true
volumes:
  - ./palworld:/palworld/
  - ./mods:/palworld/Pal/Binaries/Linux/Mods
```

UE4SS reads `mods.txt` and each Lua mod must be placed at
`Mods/<mod-name>/scripts/main.lua`; directory names are case-sensitive. A minimal mod is:

```text
mods/
├── mods.txt
└── MyMod/
    └── scripts/
        └── main.lua
```

```text
MyMod : 1
```

At startup, the container logs that UE4SS is enabled and the loader writes its `[UE4SS]` messages to the server log.

### LogicMods

LogicMods are Blueprint-based mods packaged as `.pak` files. They **require UE4SS** with
LogicMod support. Place them at:

```
Pal/Content/Paks/LogicMods/YourMod.pak
```

:::tip
A file ending in `.pak` is not always a resource mod. Check the mod author's description —
if it says "LogicMod", it needs UE4SS.
:::

### PalSchema mods

Some mods use [PalSchema](https://www.nexusmods.com/palworld/mods/) for data-driven
changes (stats, recipes, passive skills). These require UE4SS + PalSchema and install to:

```
Pal/Binaries/Linux/Mods/PalSchema/Mods/<ModName>/
```

### Known UE4SS mods

| Mod | Type | Description |
|-----|------|-------------|
| [Mounted Overhaul](https://www.nexusmods.com/palworld/mods/2317) | PalSchema + Pak | Reworks mount stats, adds new mounts |
| [Complete Game Rebalance](https://www.nexusmods.com/palworld/mods/2166) | PalSchema | Full gameplay overhaul |
| [New Skill Fruits](https://www.nexusmods.com/palworld/mods/2309) | PalSchema | Plantable skill fruits from vendors |
| [RakLogistics](https://www.nexusmods.com/palworld/mods/1225) | LogicMod | Logistics optimization, FPS boost |
| [BasicMiniMap](https://www.nexusmods.com/palworld/mods/336) | LogicMod | Configurable mini-map overlay |

::::warning
Only Lua mods and Linux-native C++ `.so` mods are supported. Windows `.dll` mods cannot load.
::::

## General modding notes

- **Always restart** the server after adding, removing, or updating mods. Palworld only scans at startup.
- **Client sync:** Most `.pak` mods must be installed on **both server and every client**.
  Mismatched mods cause invisible objects, missing textures, or connection failures.
- **Don't stack conflicting mods** — two resource `.pak` files replacing the same asset
  will silently conflict. One wins, or both fail.
- **`-NoMods`** launch flag disables all mods without removing files — useful for debugging.
- **Palworld 1.0** broke most mod loaders. Use the
  [Palworld-specific RE-UE4SS build](https://github.com/Okaetsu/re-ue4ss/releases)
  (Okaetsu fork), not the generic UE4SS release.
