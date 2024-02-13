---
sidebar_position: 1
---

# Palworld folder

Alles wat met de Palworld-gegevens te maken heeft, bevindt zich in de map `/palworld` in de container

## Folder structuur

![Folder Structure](../../../../../../docusaurus/docs/assets/folder_structure.jpg)

| Folder                       | Use                                                               |
|------------------------------|-------------------------------------------------------------------|
| palworld                     | Root folder met alle Palworld Server-bestanden                    |
| backups                      | Folder waar alle back-ups van het `backup`-commando worden opgeslagen |
| Pal/Saved/Config/LinuxServer | Folder met alle .ini-configuratiebestanden voor handmatige configuratie    |

## Gegevensdirectory aan hostbestandssysteem koppelen

De eenvoudigste manier om de palworld-folder aan uw hostsysteem te koppelen is
om het voorbeeld uit het docker-compose.yml-bestand te gebruiken:

```yml
      volumes:
         - ./palworld:/palworld/
```

Dit creëert een folder `palworld` in de huidige werkfolder en koppelt de folder `/palworld` van de container eraan.
