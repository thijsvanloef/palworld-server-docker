---
sidebar_position: 5
---

# Bekende Problemen

Bekende problemen bij het gebruik van deze Docker image.

## Broadcast-opdracht kan slechts 1 woord verzenden

Bij het gebruik van Broadcast onder de RCON-functies wordt slechts één woord verzonden.

Als voorbeeld, als ik gebruik:

docker exec -it palworld-server rcon-cli Broadcast "Hallo wereld"

wordt alleen Hallo verzonden.

## Xbox GamePass spelers kunnen niet meedoen

Op dit moment kunnen Xbox Gamepass/Xbox Console spelers niet deelnemen aan een dedicated server.

Ze moeten deelnemen met behulp van de uitnodigingscode en zijn beperkt tot sessies van maximaal 4 spelers.

## [S_API FAIL]

De server zal soms de volgende foutmelding weergeven:

```bash
[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
```

Dit kan veilig worden genegeerd en zal geen invloed hebben op de server.

## Setting breakpad minidump AppID = 2394010

Dit betekent dat de server actief is en draait. Als je nog steeds geen verbinding kunt maken,
betekent dit dat je het volgende moet controleren:

* Firewall-instellingen: zorg ervoor dat je poort 8211/udp en 27015/udp toestaat in je firewall.
* Zorg ervoor dat je de port forward correct hebt ingesteld voor 8211/udp en 27015/udp.

## FAQ

[A useful FAQ that gets updated regularly](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
