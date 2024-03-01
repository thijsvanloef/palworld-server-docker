---
sidebar_position: 3
---

# Serveropdrachten (RCON)

Hoe RCON te gebruiken om met de server te communiceren.

## RCON

RCON is standaard ingeschakeld voor de palworld-server-docker image.
Het openen van de RCON CLI is vrij eenvoudig:

```bash
docker exec -it palworld-server rcon-cli "<commando> <waarde>"
```

Bijvoorbeeld, je kunt een bericht naar iedereen in de server uitzenden met het volgende commando:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hallo iedereen"
```

Dit opent een CLI die RCON gebruikt om opdrachten naar de Palworld Server te schrijven.

## Lijst van serveropdrachten

| Command                          | Info                                                |
|----------------------------------|-----------------------------------------------------|
| Shutdown (Seconds) (MessageText) | De server wordt afgesloten na het aantal Seconden |
| DoExit                           | Forceer het stoppen van de server.                         |
| Broadcast                        | Stuur een bericht naar alle spelers in de server           |
| KickPlayer (SteamID)             | Speler uit de server schoppen.                      |
| BanPlayer (SteamID)              | Speler verbannen uit de server.                       |
| TeleportToPlayer (SteamID)       | Teleporteer naar de huidige locatie van de doelspeler.     |
| TeleportToMe (SteamID)           | Doelspeler teleporteren naar jouw huidige locatie.    |
| ShowPlayers                      | Toon informatie over alle verbonden spelers.       |
| Info                             | Toon serverinformatie.                            |
| Save                             | Sla de wereldgegevens op.                                |

Voor een volledige lijst met opdrachten ga naar: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)
