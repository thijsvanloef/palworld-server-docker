---
sidebar_position: 5
title: Palworld Dedicated Server - Bekannte Probleme
description: Die aktuellen bekannten Probleme des Palworld Dedicated Servers, umfassen S_API FAIL, Setting breakpad minidump AppID = 2394010 und mehr.
keywords: [Palworld, palworld dedicated server, Palworld dedicated server Bekannte Probleme, Palworld dedicated server Probleme]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Bekannte Probleme
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server - Bekannte Probleme

Bekannte Probleme bei der Verwendung dieses Docker-Images.
Die aktuellen bekannten Probleme des Palworld Dedicated Servers, umfassen S_API FAIL,
Setting breakpad minidump AppID = 2394010 und mehr.

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

## Nur ARM64-Hosts mit einer Seitengröße von 4k werden unterstützt

Dieser Fehler tritt auf, wenn der Container feststellt, dass der Host-Kernel keine Seitengröße von 4k hat,
die für die Emulation der ARM64-Architektur erforderlich ist. Der Container ist auf diese spezifische Seitengröße
für eine ordnungsgemäße Ausführung angewiesen.

Wenn der Host-Kernel keine Seitengröße von 4k hat, haben Sie ein paar Alternativen:

* **Serverdateien auf einem anderen Gerät herunterladen**: Die Beschränkung auf eine Seitengröße von 4k gilt nur für
die steamcmd ARM-Emulation. Sie können versuchen, den Container in einem vollständig unterstützten Gerät (AMD64 oder
ARM64 mit 4k-Seitengröße) zu initialisieren und ihm zu ermöglichen, die Serverdateien mit aktiviertem `UPDATE_ON_BOOT`
herunterzuladen. Stellen Sie sicher, dass Sie `UPDATE_ON_BOOT` in dem Problemgerät deaktivieren, um zu verhindern, dass
steamcmd ausgeführt wird.

* **Kernel ändern**: Sie können erwägen, den Kernel Ihres Host-Geräts gegen einen auszutauschen, der eine
Seitengröße von 4k unterstützt.

<!-- markdownlint-disable-next-line -->
* Der Raspberry Pi 5 mit Raspberry Pi OS bietet einen einfachen [Wechsel](https://github.com/raspberrypi/bookworm-feedback/issues/107#issuecomment-1773810662).

* **Betriebssystem wechseln**: Eine weitere Option ist der Wechsel des Betriebssystems zu solchen, die mit Kernen mit
4k-Seitengröße ausgeliefert werden.
  * Debian und Ubuntu sind bekannte Linux-Distributionen, die funktionieren.
* **In einer VM ausführen**: Eine weitere Option ist das Ausführen des Containers in einer virtuellen Maschine (VM),
die mit einem Kernel ausgestattet ist, der eine Seitengröße von 4k unterstützt. Auf diese Weise können Sie die
Kompatibilität und ordnungsgemäße Ausführung des Containers gewährleisten.

## /usr/local/bin/box86: cannot execute binary file: Exec format error (ARM64-Hosts)

Dies bedeutet, dass der Docker-Host ohne eine zusätzliche Kompatibilitätsschicht, wie im Fall von Apple Silicon, nicht
in der Lage ist, AArch32-Binärdateien wie Box86 auszuführen.

Docker Desktop löst dieses Problem, indem es seine Container in einer VM (QEMU) mit einem kompatiblen Kernel ausführt.
Wenn Sie jedoch Docker Desktop nicht verwenden können, versuchen Sie, `ARM_COMPATIBILITY_MODE` auf `true` zu setzen.
Dadurch wird der Container von der Verwendung von Box86 auf QEMU umgestellt, wenn steamcmd ausgeführt wird.

## FAQ

<!-- markdownlint-disable-next-line -->
[Eine nützliche FAQ, die regelmäßig aktualisiert wird](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
