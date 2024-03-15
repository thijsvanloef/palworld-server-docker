---
sidebar_position: 4
title: Palworld Dedicated Serverbefehle (RCON)
description: Anleitung zur Verwendung von Palworld Dedicated Serverbefehlen zur Verwaltung Ihres Servers, einschließlich Kick, Ban und Teleport von Spielern.
keywords: [Palworld, palworld dedicated server, Palworld Serverbefehle, Palworld server Spieler bannen, Palworld server Spieler kicken]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Serverbefehle (RCON)
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Serverbefehle (RCON)

Anleitung zur Verwendung von Palworld Dedicated Serverbefehlen zur Verwaltung Ihres Servers,
einschließlich Kick, Ban und Teleport von Spielern.

## RCON

RCON ist standardmäßig für das palworld-server-docker-Image aktiviert.
Das Öffnen der RCON-CLI ist ziemlich einfach:

```bash
docker exec -it palworld-server rcon-cli "<Befehl> <Wert>"
```

Sie können beispielsweise eine Nachricht an alle im Server mit dem folgenden Befehl senden:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hallo zusammen"
```

Dies öffnet eine CLI, die RCON verwendet, um Befehle an den Palworld-Server zu senden.

### Liste der Serverbefehle

| Befehl                          | Info                                                            |
|---------------------------------|-----------------------------------------------------------------|
| Shutdown (Sekunden) (Text)      | Der Server wird nach der Anzahl der Sekunden heruntergefahren   |
| DoExit                          | Server erzwingt das Beenden.                                    |
| Broadcast                       | Senden Sie eine Nachricht an alle Spieler im Server             |
| KickPlayer (SteamID)            | Spieler vom Server kicken.                                      |
| BanPlayer (SteamID)             | Spieler vom Server verbannen.                                   |
| TeleportToPlayer (SteamID)      | Teleportieren Sie sich zur aktuellen Position des Zielspielers. |
| TeleportToMe (SteamID)          | Zielspieler teleportiert sich an Ihre aktuelle Position         |
| ShowPlayers                     | Zeigt Informationen zu allen verbundenen Spielern an.           |
| Info                            | Zeigt Serverinformationen an.                                   |
| Save                            | Speichern Sie die Weltendaten.                                  |

Für eine vollständige Liste der Befehle gehen Sie zu: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)
