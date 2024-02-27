---
sidebar_position: 4
---

# Server Commands (RCON)

How to use RCON to interact with the server.

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

For a full list of commands go to: [https://tech.palworldgame.com/server-commands](https://tech.palworldgame.com/server-commands)
