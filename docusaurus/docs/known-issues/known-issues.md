---
sidebar_position: 5
title: Palworld Dedicated Server Known Issues
description: The current known issues of the Palworld Dedicated server running on Docker, including S_API FAIL, Setting breakpad minidump AppID = 2394010 and more.
keywords: [Palworld, palworld dedicated server, Palworld dedicated server known issues, Palworld dedicated server issues]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Known issues
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server Known Issues

The current know issues of the Palworld Dedicated server running on Docker,
including S_API FAIL, Setting breakpad minidump AppID = 2394010 and more.

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

:::note info
Using REST API solves it.

`docker exec -it palworld-server rest-cli announce "Hello world"`
:::

## XBox Dedicated servers

:::tip
Setup your Xbox dedicated server [following these steps](https://palworld-server-docker.loef.dev/quick-setup-xbox).
:::

At the moment, Xbox Gamepass/Xbox Console players will not be able to join Steam players on a dedicated server.

Dedicated servers are only for Xbox players or only for Steam players and cross-play is not possible at this time.

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

## Only ARM64 hosts with 4k page size is supported

:::tip
This issue should not occur anymore after the addition of `USE_DEPOT_DOWNLOADER`. Instead, it should ask you to set the
said configuration to `true`.
:::

This error occurs when the container detects that the host kernel does not have a 4k page size,
which is required for the emulation used for ARM64 architecture. The container relies on this specific page
size for proper execution.

If the host kernel does not have a 4k page size, you have a couple of alternatives:

* **Download server files in a different machine**: The 4k page size limitation is only applicable for steamcmd
ARM emulation. You may try initializing the container in a fully supported machine (AMD64 or ARM64 with 4k page size)
and let it download the server files with `UPDATE_ON_BOOT` enabled. Make sure to disable `UPDATE_ON_BOOT` in the
problematic machine to prevent steamcmd from executing.

* **Change/Modify Kernel**: You can consider changing the kernel of your host machine to one that supports a 4k page size.
  * The Raspberry Pi 5 with Raspberry Pi OS has an easy [switch](https://github.com/raspberrypi/bookworm-feedback/issues/107#issuecomment-1773810662).

* **Switch OS**: Another option is to switch OS to ones shipped with 4k page size kernels.
  * Debian and Ubuntu are known working Linux distros.

* **Run within a VM**: Another option is to run the container within a virtual machine (VM) that is configured
  with a kernel supporting a 4k page size. By doing so, you can ensure compatibility and proper execution of the
  container.

## /usr/local/bin/box86: cannot execute binary file: Exec format error (ARM64 hosts)

This means that the Docker host is unable to run AArch32 binaries such as Box86 without an additional
compatibility layer which is the case for Apple Silicon.

Try setting `USE_DEPOT_DOWNLOADER` to `true`. This will switch the container from using steamcmd to
DepotDownloader instead. This should avoid the need for any AArch32 emulation.

## Server keeps on crashing randomly! (ARM64 hosts)

For ARM64 hosts, emulation of the server binaries and libraries is required. As such, huge updates can cause Box64
(the emulator we use) to crash due to many reasons. Box64 has a lot of configuration options to tweak the emulator
for specific binaries. We will try to set appropriate defaults for these configs as we receive more reports. In general,
setting the following environment variables will give you the best chance of stability in exchange for performance:

* `BOX64_DYNAREC_BIGBLOCK=0` (Default: 1)
* `BOX64_DYNAREC_SAFEFLAGS=2` (Default: 1)
* `BOX64_DYNAREC_STRONGMEM=3` (Default: 1)
* `BOX64_DYNAREC_FASTROUND=0` (Default: 1)
* `BOX64_DYNAREC_FASTNAN=0` (Default: 1)
* `BOX64_DYNAREC_X87DOUBLE=1` (Default: 0)

See [Box64 usage documentation](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md) for more info.

Also, the container should have multiple Box64 variants for different host devices. This can be set using the `ARM64_DEVICE`
environment variable.

:::tip
For best compatibility with **Apple Silicon**, set `ARM64_DEVICE` to `m1`.
For best compatibility with **Oracle ARM**, set `ARM64_DEVICE` to  `adlink`.
For best compatibility with **Raspberry Pi 5**, set `ARM64_DEVICE` to  `rpi5`.
:::

These builds are from the [ARM64 base image](https://github.com/sonroyaalmerol/steamcmd-arm64). If your device is not listed
above, consider creating an issue on the base image's repository.

## FAQ

[A useful FAQ that gets updated regularly](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
