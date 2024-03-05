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

## Only ARM64 hosts with 4k page size is supported

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

Docker Desktop solves this by running its containers inside a VM (QEMU) with a compatible kernel.
However, if you're unable to use Docker Desktop, then try setting `ARM_COMPATIBILITY_MODE` to `true`.
This will switch the container from using Box86 to QEMU when running steamcmd.

## FAQ

[A useful FAQ that gets updated regularly](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
