---
sidebar_position: 2
---

# Een back-up herstellen

## Interactief herstellen vanuit een back-up

Om te herstellen vanuit een back-up, gebruik het commando:

```bash
docker exec -it palworld-server restore
```

De `RCON_ENABLED` omgevingsvariabele moet ingesteld zijn op true om dit commando te gebruiken.

:::warning
Als docker restart niet is ingesteld op het beleid `always` of `unless-stopped`, zal de server worden afgesloten en
moet handmatig opnieuw worden gestart.
Het voorbeeld docker run commando en docker compose bestand in [de Snelle installatie](https://palworld-server-docker.loef.dev/)
gebruiken al het vereiste beleid.
:::

## Handmatig herstellen vanuit een back-up

Zoek de back-up die je wilt herstellen in `/palworld/backups/` en decomprimeer deze.
Moet de server stoppen voor de taak.

```bash
docker compose down
```

Verwijder de oude opgeslagen gegevensmap gelegen op `palworld/Pal/Saved/SaveGames/0/<oude_hash_waarde>`.

Kopieer de inhoud van de nieuw gedecomprimeerde opgeslagen gegevensmap `Saved/SaveGames/0/<nieuwe_hash_waarde>` naar `palworld/Pal/Saved/SaveGames/0/<nieuwe_hash_waarde>`.

Vervang de DedicatedServerName binnen `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` met de nieuwe mapnaam.

```ini
DedicatedServerName=<new_hash_value>  # Replace it with your folder name.
```

Start het spel opnieuw. (Als je Docker Compose gebruikt)

```bash
docker compose up -d
```
