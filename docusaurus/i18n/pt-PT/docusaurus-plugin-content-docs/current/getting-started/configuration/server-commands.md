---
sidebar_position: 3
---

# Comandos Servidor (RCON)

Como utilizar o RCON para interagir com o servidor.

## RCON

Por defeito, o RCON é ativado com a imagem do palworld-server-docker.
Abrir o RCON CLI é bastante fácil:

```bash
docker exec -it palworld-server rcon-cli "<command> <value>"
```

Por exemplo, pode transmitir uma mensagem para todos os utilizadores do servidor com o seguinte comando:

```bash
docker exec -it palworld-server rcon-cli "Broadcast Hello everyone"
```

Isso abrirá uma CLI que usa o RCON para escrever comandos no Servidor Palworld.

### Lista de comandos do servidor

| Comando                             | Descrição                                                  |
| ----------------------------------- | ---------------------------------------------------------- |
| Shutdown (Segundos) (MensagemTexto) | O servidor é encerrado após o número de segundos           |
| DoExit                              | Forçar a paragem do servidor.                              |
| Broadcast                           | Enviar mensagem a todos os jogadores do servidor           |
| KickPlayer (SteamID)                | Expulsar o jogador do servidor.                            |
| BanPlayer (SteamID)                 | Banir o jogador do servidor.                               |
| TeleportToPlayer (SteamID)          | Teletransportar para a localização atual do jogador alvo.  |
| TeleportToMe (SteamID)              | Teletransportar jogador alvo para a sua localização atual. |
| ShowPlayers                         | Mostrar informações sobre todos os jogadores ligados.      |
| Info                                | Mostrar informações do servidor.                           |
| Save                                | Salvar os dados do mundo.                                  |

Para obter uma lista completa de comandos, consulte: [https://tech.palworldgame.com/settings-and-operation/commands](https://tech.palworldgame.com/settings-and-operation/commands)
