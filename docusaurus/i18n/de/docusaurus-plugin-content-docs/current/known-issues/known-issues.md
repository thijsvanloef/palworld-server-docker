---
sidebar_position: 5
---

# Bekannte Probleme

Bekannte Probleme bei der Verwendung dieses Docker-Images.

## PalWorldSettings.ini wird immer zurückgesetzt

Wenn die `PalworldSettings.ini` zurückgesetzt wird, nachdem du die Datei geändert und den Server neu gestartet hast,
dann stelle sicher, dass `DISABLE_GENERATE_SETTINGS` auf `true` gesetzt ist.
<!-- markdownlint-disable-next-line -->
Falls das nicht der Fall ist, werden deine Einstellungen von den über die [Umgebungsvariablen gesetzten Einstellungen](https://palworld-server-docker.loef.dev/getting-started/configuration/game-settings) überschrieben.

:::tip
Es wird empfohlen, die Umgebungsvariablen zu verwenden, um deine Spiel-Einstellungen festzulegen, anstatt
die `PalWorldSettings.ini` manuell zu ändern.

Wenn du die Datei dennoch manuell ändern möchtest, stelle sicher, dass der Server ausgeschaltet ist, wenn du die
Änderungen vornimmst.
:::

## Broadcast-Befehl kann nur 1 Wort senden

Beim Verwenden eines Broadcasts über RCON wird nur ein Wort gesendet.

Beispiel:

`docker exec -it palworld-server rcon-cli Broadcast "Hallo Welt"`

Es wird nur "Hallo" übertragen.

## XBox GamePass-Spieler können nicht beitreten

Derzeit können Xbox Gamepass/Xbox-Konsolenspieler einem dedizierten Server nicht beitreten.

Sie müssen sich Spielern mit einem Einladungscode anschließen und sind auf Sitzungen mit maximal 4 Spielern beschränkt.

## [S_API FAIL]

Manchmal gibt der Server den folgenden Fehler aus:

```bash
[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
```

Dies kann ignoriert werden und hat keinen Einfluss auf den Server.

## Setting breakpad minidump AppID = 2394010

Dies bedeutet, dass der Server läuft. Wenn Sie immer noch keine Verbindung herstellen können, überprüfen Sie bitte Folgendes:

* Firewall-Einstellungen: Stellen Sie sicher, dass Sie den Port 8211/udp und 27015/udp in Ihrer Firewall zulassen.
* Stellen Sie sicher, dass Sie Ihre Portweiterleitung für 8211/udp und 27015/udp korrekt eingerichtet haben.

## FAQ

[Eine nützliche FAQ, die regelmäßig aktualisiert wird](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
