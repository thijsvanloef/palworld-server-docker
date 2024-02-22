---
sidebar_position: 5
---

# Problemas conhecidos

Problemas conhecidos de usar esta imagem Docker

## Comando 'Broadcast' só envia uma palavra

Quando se usa o comando RCON `Broadcast`. só uma palavra é enviado.

Por exemplo:

`docker exec -it palworld-server rcon-cli Broadcast "Hello world"`

Só é transmitido "Hello"

## Jogadores XBox GamePass não podem-se juntar

De momento, os jogadores Xbox Gamepass/Xbox Console não podem entrar nos servidores dedicados.

Eles podem se juntar a outros jogadores com códigos de convite e estão limitados a 4 jogadores.

## [S_API FAIL]

Por vezes, o servidor apresenta o seguinte erro:

```bash
[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
```

Este facto pode ser ignorado com segurança e não terá impacto no servidor.

## Setting breakpad minidump AppID = 2394010

Isto significa que o servidor está a funcionar. Se continuar a não conseguir ligar-se a ele,
isso significa que terá de verificar o seguinte:

- Opções de firewall, verificar que as portas 8211/udp e 27015/udp estão desbloqueadas
- Garantir que o port forward está correctamente configurado para 8211/udp e 27015/udp

## FAQ (Perguntas frequentes)

[FAQ que é atualizado frequentemente](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
