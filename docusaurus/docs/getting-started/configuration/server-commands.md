---
sidebar_position: 4
title: Palworld Dedicated Server Commands (RCON)
description: How to use Palworld Dedicated server commands to manage your server, including Kicking, Banning and teleporting players.
keywords: [Palworld, palworld dedicated server, Palworld Server Commands, Palworld server how to ban player, Palworld server how to kick player]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Server Commands (RCON)
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server Commands (RCON)

How to use Palworld Dedicated server commands to manage your server,
including Kicking, Banning and teleporting players.

## RCON

RCON is enabled by default for the palworld-server-docker image.
Opening the RCON CLI is quite easy:

```bash
docker exec -it palworld-server rcon-cli "<command> <value>"
```

For example, you can broadcast a message to everyone in the server with the following command:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hello everyone"
```

This will open a CLI that uses RCON to write commands to the Palworld Server.

### List of server commands

| Command                          | Info                                                |
|----------------------------------|-----------------------------------------------------|
| Shutdown (Seconds) (MessageText) | The server is shut down after the number of Seconds |
| DoExit                           | Force stop the server.                              |
| Broadcast                        | Send message to all player in the server            |
| KickPlayer (SteamID)             | Kick player from the server..                       |
| BanPlayer (SteamID)              | BAN player from the server.                         |
| TeleportToPlayer (SteamID)       | Teleport to current location of target player.      |
| TeleportToMe (SteamID)           | Target player teleport to your current location     |
| ShowPlayers                      | Show information on all connected players.          |
| Info                             | Show server information.                            |
| Save                             | Save the world data.                                |
| UnBanPlayer (SteamID)            | Unban player (SteamID) from the server.             |

For a full list of commands go to: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)
