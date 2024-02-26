---
sidebar_position: 5
---

# Known Issues

Known issues of using this Docker image.

## PalWorldSettings.ini keeps resetting

If the `PalworldSettings.ini` keeps resettings after you have changed the file and rebooted the server.
Please make sure you have `DISABLE_GENERATE_SETTINGS` set to `true`.

If this is not the case, your setting will be overwritten by the settings set via [the environment variables](https://palworld-server-docker.loef.dev/getting-started/configuration/game-settings).

:::tip
It is recommended you use the environment variables to set your game settings, instead of manually changing the `PalWorldSettings.ini`

If you do want to change the file manually, please make sure the server is off when you make the changes.
:::

## Broadcast command can only send 1 word

When using Broadcast among RCON's functions, only one word is transmitted.

As an example, if I use:

`docker exec -it palworld-server rcon-cli Broadcast "Hello world"`

only Hello is transmitted.

## XBox GamePass players unable to join

At the moment, Xbox Gamepass/Xbox Console players will not be able to join a dedicated server.

They will need to join players using the invite code and are limited to sessions of 4 players max.

## [S_API FAIL]

The server will sometimes output the following error:

```bash
[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
```

This can safely be ignored and will not impact the server.

## Setting breakpad minidump AppID = 2394010

This means that the server is up and running, if you still can't connect to it,
it means that you'll need to look at the following:

* Firewall settings, make sure that you allow port 8211/udp and 27015/udp through your firewall
* Make sure you've correctly port forwarded your 8211/udp 27015/udp

## FAQ

[A useful FAQ that gets updated regularly](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
