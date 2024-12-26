---
sidebar_position: 7
---

# Pinning a Game Version

:::warning
Downgrading to a lower game version is possible, but it is unknown what impact it will have on existing saves.
This requires you to set STEAM_USERNAME and STEAM_PASSWORD to a Steam account that owns the game.
Accounts with Steam Guard enabled are currently not supported.
**Please do so at your own risk!**
:::

If **TARGET_MANIFEST_ID** environment variable is set, will lock server version to specific manifest.
The manifest corresponds to the release date/update versions. Manifests can be found using SteamCMD or websites like [SteamDB](https://steamdb.info/depot/2394012/manifests/).

## Version To Manifest ID Table

| Version | Manifest ID         |
|---------|---------------------|
| 0.1.3.0 | 1354752814336157338 |
| 0.1.4.0 | 4190579964382773830 |
| 0.1.4.1 | 6370735655629434989 |
| 0.1.5.0 | 3750364703337203431 |
| 0.1.5.1 | 2815085007637542021 |
| 0.2.0.6 | 1677469329840659324 |
| 0.2.1.0 | 8977386334474359538 |
| 0.2.2.0 | 3713294686782778004 |
| 0.2.3.0 | 5441332432956841998 |
| 0.2.4.0 | 3872500952532478729 |
| 0.3.1   | 4278745071359475598 |
| 0.3.2   | 7197559707261547198 |
| 0.3.3   | 8939748203712584968 |
| 0.3.4   | 2579525995905578621 |
| 0.3.5   | 6538676263384401448 |
| 0.3.6   | 7750307484972290423 |
| 0.3.7   | 2342038768084482228 |
| 0.3.8   | 8676441150170012909 |
| 0.3.9   | 7493245879597781625 |
| 0.3.10  | 752220234171168889  |
