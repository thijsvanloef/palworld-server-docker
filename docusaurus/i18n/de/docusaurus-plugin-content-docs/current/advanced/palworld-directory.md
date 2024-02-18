---
sidebar_position: 1
---

# Palworld-Verzeichnis

Alles was mit den Palworld-Dateien zusammenhängt, befindet sich im Ordner `/palworld` innerhalb des Containers.

## Ordnerstruktur

![Ordnerstruktur](../assets/folder_structure.jpg)

| Ordner                       | Verwendung                                                             |
|------------------------------|------------------------------------------------------------------------|
| palworld                     | Stammordner mit allen Dateien des Palworld-Servers                     |
| backups                      | Der Ordner, in dem alle Backups gespeichert werden                     |
| Pal/Saved/Config/LinuxServer | Ordner mit allen .ini-Konfigurationsdateien für manuelle Konfiguration |

## Datenverzeichnis an das Host-Dateisystem anbinden

Der einfachste Weg das Palworld-Verzeichnis an Ihr Host-System anzubinden, ist es, das mittels docker-compose.yml
bereitgestellte Beispiel zu verwenden:

```yml
      volumes:
         - ./palworld:/palworld/
```

Dies erstellt ein lokales `palworld`-Verzeichnis im aktuellen Arbeitsverzeichnis und bindet das `/palworld`-Verzeichnis
des Containers an.
