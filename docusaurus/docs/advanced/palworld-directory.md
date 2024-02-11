---
sidebar_position: 1
---

# Palworld Directory

Everything related to the Palworld data is inside the `/palworld` folder inside the container

## Folder structure

![Folder Structure](../assets/folder_structure.jpg)

| Folder                       | Use                                                               |
|------------------------------|-------------------------------------------------------------------|
| palworld                     | Root folder with all the Palworld Server files                    |
| backups                      | Folder where all the backups from the `backup` command are stored |
| Pal/Saved/Config/LinuxServer | Folder with all the .ini configuration files for manual config    |

## Attaching data directory to host filesystem

The simplest way of attaching the palworld folder to your host system is
to use the example given in the docker-compose.yml file:

```yml
      volumes:
         - ./palworld:/palworld/
```

This creates a `palworld` folder in the current working directory and mounts the `/palworld` folder.
