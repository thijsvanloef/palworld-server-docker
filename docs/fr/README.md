# Palworld Serveur Dédié Docker

## ⚠️These docs will be deprecated and removed on March 31 2024⚠️

Please use the official docs: [https://palworld-server-docker.loef.dev/](https://palworld-server-docker.loef.dev/)

[![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)](https://github.com/thijsvanloef/palworld-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker/tags)
[![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)](https://discord.com/invite/UxBxStPAAE)

[![CodeFactor](https://www.codefactor.io/repository/github/thijsvanloef/palworld-server-docker/badge)](https://www.codefactor.io/repository/github/thijsvanloef/palworld-server-docker)
[![Release](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/release.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/release.yml)
[![Linting](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/linting.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/linting.yml)
[![Security](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/security.yml/badge.svg)](https://github.com/thijsvanloef/palworld-server-docker/actions/workflows/security.yml)

[![Docker Hub](https://img.shields.io/badge/Docker_Hub-palworld-blue?logo=docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![GHCR](https://img.shields.io/badge/GHCR-palworld-blue?logo=docker)](https://github.com/thijsvanloef/palworld-server-docker/pkgs/container/palworld-server-docker)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/palworld-server-chart)](https://artifacthub.io/packages/search?repo=palworld-server-chart)

[Discuter avec la communauté sur Discord](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md) | [简体中文](/docs/zh-CN/README.md) | [French](/docs/fr/README.md)

> [!TIP]
> Vous ne savez pas par où commencer ? Consultez [ce guide que j'ai écrit !](https://tice.tips/containerization/palworld-server-docker/)

Il s'agit d'un conteneur Docker pour vous aider à démarrer l'hébergement de votre propre serveur dédié [Palworld](https://store.steampowered.com/app/1623730/Palworld/).

Ce conteneur Docker a été testé et fonctionnera sur les systèmes d'exploitation suivants :

- Linux (Ubuntu/Debian)
- Windows 10, 11
- MacOS (y compris Apple Silicon M1/M2/M3).

Ce conteneur a également été testé et fonctionnera sur les architectures de processeur `x64` et `ARM64`.

> [!IMPORTANT]
> Pour le moment, les joueurs Xbox GamePass/Xbox Console ne pourront pas rejoindre un serveur dédié.
>
> Ils devront rejoindre les joueurs en utilisant le code d'invitation et sont limités à des sessions de 4 joueurs maximum.

## Sponsors

Un énorme merci aux sponsors suivants !

<p align="center"><!-- markdownlint-disable-line --><!-- markdownlint-disable-next-line -->
<!-- sponsors --><a href="https://github.com/doomhound188"><img src="https://github.com/doomhound188.png" width="50px" alt="doomhound188" /></a>&nbsp;&nbsp;<a href="https://github.com/AshishT112203"><img src="https://github.com/AshishT112203.png" width="50px" alt="AshishT112203" /></a>&nbsp;&nbsp;<a href="https://github.com/pabumake"><img src="https://github.com/pabumake.png" width="50px" alt="pabumake" /></a>&nbsp;&nbsp;<a href="https://github.com/stoprx"><img src="https://github.com/stoprx.png" width="50px" alt="stoprx" /></a>&nbsp;&nbsp;<a href="https://github.com/KiKoS0"><img src="https://github.com/KiKoS0.png" width="50px" alt="KiKoS0" /></a>&nbsp;&nbsp;<a href="https://github.com/inspired-by-nudes"><img src="https://github.com/inspired-by-nudes.png" width="50px" alt="inspired-by-nudes" /></a>&nbsp;&nbsp;<a href="https://github.com/PulsarFTW"><img src="https://github.com/PulsarFTW.png" width="50px" alt="PulsarFTW" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## Documentation Officielle

[![Documentation](https://github.com/thijsvanloef/palworld-server-docker/assets/58031337/b92d76d1-5efb-438d-9ffd-5385544a831b)](https://palworld-server-docker.loef.dev/)

## Configuration requise du serveur

| Ressource | Minimum | Recommandé                                               |
| --------- | ------- | -------------------------------------------------------- |
| CPU       | 4 cœurs | 4 cœurs ou plus                                          |
| RAM       | 16 Go   | Recommandé : plus de 32 Go pour un fonctionnement stable |
| Stockage  | 8 Go    | 20 Go                                                    |

## Comment utiliser

N'oubliez pas que vous devrez modifier les [variables d'environnement](#variables-d-environnement).

### Docker Compose

Ce référentiel comprend un exemple de fichier [docker-compose.yml](/docker-compose.yml)
que vous pouvez utiliser pour configurer votre serveur.

```yml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest
    restart: unless-stopped
    container_name: palworld-server
    stop_grace_period: 30s # Réglez selon le temps que vous êtes prêt à attendre pour l'arrêt gracieux du conteneur
    ports:
      - 8211:8211/udp
      - 27015:27015/udp
    environment:
      PUID: 1000
      PGID: 1000
      PORT: 8211 # Optionnel mais recommandé
      PLAYERS: 16 # Optionnel mais recommandé
      SERVER_PASSWORD: 'worldofpals' # Optionnel mais recommandé
      MULTITHREADING: true
      RCON_ENABLED: true
      RCON_PORT: 25575
      TZ: 'UTC'
      ADMIN_PASSWORD: 'adminPasswordHere'
      COMMUNITY: false # Activez ceci si vous souhaitez que votre serveur apparaisse dans l'onglet des serveurs communautaires, À UTILISER AVEC LE MOT DE PASSE DU SERVEUR !
      SERVER_NAME: 'palworld-server-docker par Thijs van Loef'
      SERVER_DESCRIPTION: 'palworld-server-docker par Thijs van Loef'
    volumes:
      - ./palworld:/palworld/
```

En alternative, vous pouvez copier le fichier [.env.example](.env.example) dans un nouveau fichier appelé **.env**.
Modifiez-le selon vos besoins, consultez la section [environment variables](#variables-d-environnement) pour vérifier les
valeurs correctes. Modifiez votre fichier [docker-compose.yml](docker-compose.yml) comme suit :

```yml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest
    restart: unless-stopped
    container_name: palworld-server
    stop_grace_period: 30s # Réglez selon le temps que vous êtes prêt à attendre pour l'arrêt gracieux du conteneur
    ports:
      - 8211:8211/udp
      - 27015:27015/udp
    env_file:
      - .env
    volumes:
      - ./palworld:/palworld/
```

### Docker Run

Changez chaque <> par votre propre configuration

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./palworld:/palworld/ \
    -e PUID=1000 \
    -e PGID=1000 \
    -e PORT=8211 \
    -e PLAYERS=16 \
    -e MULTITHREADING=true \
    -e RCON_ENABLED=true \
    -e RCON_PORT=25575 \
    -e TZ=UTC \
    -e ADMIN_PASSWORD="adminPasswordHere" \
    -e SERVER_PASSWORD="worldofpals" \
    -e COMMUNITY=false \
    -e SERVER_NAME="palworld-server-docker by Thijs van Loef" \
    -e SERVER_DESCRIPTION="palworld-server-docker by Thijs van Loef" \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```

En alternative, vous pouvez copier le fichier [.env.example](.env.example) dans un nouveau fichier appelé **.env**.
Modifiez-le selon vos besoins, consultez la section [environment variables](#variables-d-environnement) pour vérifier
les valeurs correctes. Modifiez votre commande docker run comme suit:

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./palworld:/palworld/ \
    --env-file .env \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest
```

### Kubernetes

Tous les fichiers dont vous aurez besoin pour déployer ce conteneur sur Kubernetes se trouvent dans le dossier [k8s](k8s/).

Suivez les étapes dans le [README.md ici](k8s/readme.md) pour le déployer.

### Exécution sans les droits root

Ceci est réservé aux utilisateurs avancés.

Il est possible d'exécuter ce conteneur et de [remplacer l'utilisateur par défaut](https://docs.docker.com/engine/reference/run/#user)
qui est root dans cette image.

Étant donné que vous spécifiez l'utilisateur et le groupe, `PUID` et `PGID` sont ignorés.

Si vous souhaitez trouver votre UID : `id -u`
Si vous souhaitez trouver votre GID : `id -g`

Vous devez définir l'utilisateur sur `UID_NUMÉRIQUE:GID_NUMÉRIQUE`

Ci-dessous, nous supposons que votre UID est 1000 et votre GID est 1001.

- Dans la commande docker run, ajoutez `--user 1000:1001 \` au-dessus de la dernière ligne.
- Dans le fichier docker-compose, ajoutez `user: 1000:1001` au-dessus des ports.

Si vous souhaitez l'exécuter avec un UID/GID différent du vôtre, vous devrez changer la
propriété du répertoire qui est monté : `chown UID:GID palworld/`
ou en changeant les permissions pour tous les autres : `chmod o=rwx palworld/`

#### Utilisation du chart Helm

Le chart Helm officiel peut être trouvé dans un dépôt séparé, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)

### Variables d environnement

Vous pouvez utiliser les valeurs suivantes pour modifier les paramètres du serveur au démarrage.
Il est fortement recommandé de définir les valeurs d'environnement suivantes avant de démarrer le serveur :

- PLAYERS
- PORT
- PUID
- PGID

| Variable                           | Info                                                                                                                                                                                                                             | Valeurs par défaut                        | Valeurs autorisées                                                                                                                                  |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| TZ                                 | Fuseau horaire utilisé pour dater la sauvegarde du serveur                                                                                                                                                                       | UTC                                       | Voir [Identifiants TZ](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations)                                        |
| PLAYERS\*                          | Nombre maximal de joueurs pouvant rejoindre le serveur                                                                                                                                                                           | 16                                        | 1-32                                                                                                                                                |
| PORT\*                             | Port UDP exposé par le serveur                                                                                                                                                                                                   | 8211                                      | 1024-65535                                                                                                                                          |
| PUID\*                             | UID de l'utilisateur sous lequel le serveur doit s'exécuter                                                                                                                                                                      | 1000                                      | !0                                                                                                                                                  |
| PGID\*                             | GID du groupe sous lequel le serveur doit s'exécuter                                                                                                                                                                             | 1000                                      | !0                                                                                                                                                  |
| MULTITHREADING\*\*                 | Améliore les performances dans les environnements CPU multi-threadés. Elle est efficace jusqu'à un maximum d'environ 4 threads, et allouer plus que ce nombre de threads n'a pas beaucoup de sens.                               | false                                     | true/false                                                                                                                                          |
| COMMUNITY                          | Si le serveur apparaît ou non dans le navigateur de serveurs communautaires (À UTILISER AVEC SERVER_PASSWORD)                                                                                                                    | false                                     | true/false                                                                                                                                          |
| PUBLIC_IP                          | Vous pouvez spécifier manuellement l'adresse IP globale du réseau sur lequel le serveur est en cours d'exécution. Sinon, elle sera détectée automatiquement. Si cela ne fonctionne pas bien, essayez une configuration manuelle. |                                           | x.x.x.x                                                                                                                                             |
| PUBLIC_PORT                        | Vous pouvez spécifier manuellement le numéro de port du réseau sur lequel le serveur est en cours d'exécution. Sinon, il sera détecté automatiquement. Si cela ne fonctionne pas bien, essayez une configuration manuelle.       |                                           | 1024-65535                                                                                                                                          |
| SERVER_NAME                        | Un nom pour votre serveur                                                                                                                                                                                                        |                                           | "chaîne"                                                                                                                                            |
| SERVER_DESCRIPTION                 | La description de votre serveur                                                                                                                                                                                                  |                                           | "chaîne"                                                                                                                                            |
| SERVER_PASSWORD                    | Sécurisez votre serveur communautaire avec un mot de passe                                                                                                                                                                       |                                           | "chaîne"                                                                                                                                            |
| ADMIN_PASSWORD                     | Sécurisez l'accès à l'administration du serveur avec un mot de passe                                                                                                                                                             |                                           | "chaîne"                                                                                                                                            |
| UPDATE_ON_BOOT\*\*                 | Mettre à jour/Installer le serveur lorsque le conteneur Docker démarre (CELÀ DOIT ÊTRE ACTIVÉ LA PREMIÈRE FOIS QUE VOUS EXÉCUTEZ LE CONTENEUR)                                                                                   | true                                      | true/false                                                                                                                                          |
| RCON_ENABLED\*\*\*                 | Activer RCON pour le serveur Palworld                                                                                                                                                                                            | true                                      | true/false                                                                                                                                          |
| RCON_PORT                          | Port RCON pour se connecter                                                                                                                                                                                                      | 25575                                     | 1024-65535                                                                                                                                          |
| QUERY_PORT                         | Port de requête utilisé pour communiquer avec les serveurs Steam                                                                                                                                                                 | 27015                                     | 1024-65535                                                                                                                                          |
| BACKUP_CRON_EXPRESSION             | Le paramètre affecte la fréquence des sauvegardes automatiques.                                                                                                                                                                  | 0 0 \* \* \*                              | Nécessite une expression Cron - Voir [Configuration des sauvegardes automatiques avec Cron](#configuration-des-sauvegardes-automatiques-avec-cron)  |
| BACKUP_ENABLED                     | Active les sauvegardes automatiques                                                                                                                                                                                              | true                                      | true/false                                                                                                                                          |
| DELETE_OLD_BACKUPS                 | Supprime les sauvegardes après un certain nombre de jours                                                                                                                                                                        | false                                     | true/false                                                                                                                                          |
| OLD_BACKUP_DAYS                    | Combien de jours conserver les sauvegardes                                                                                                                                                                                       | 30                                        | tout entier positif                                                                                                                                 |
| AUTO_UPDATE_CRON_EXPRESSION        | Le paramètre affecte la fréquence des mises à jour automatiques.                                                                                                                                                                 | 0 \* \* \* \*                             | Nécessite une expression Cron - Voir [Configuration des sauvegardes automatiques avec Cron](#configuration-des-sauvegardes-automatiques-avec-cron)  |
| AUTO_UPDATE_ENABLED                | Active les mises à jour automatiques                                                                                                                                                                                             | false                                     | true/false                                                                                                                                          |
| AUTO_UPDATE_WARN_MINUTES           | Temps d'attente avant de mettre à jour le serveur, après que les joueurs ont été informés. (Cela sera ignoré s'il n'y a pas de joueurs connectés)                                                                                | 30                                        | Entier                                                                                                                                              |
| AUTO_REBOOT_CRON_EXPRESSION        | Le paramètre affecte la fréquence des mises à jour automatiques.                                                                                                                                                                 | 0 0 \* \* \*                              | Nécessite une expression Cron - Voir [Configuration des sauvegardes automatiques avec Cron](#configuration-des-redémarrages-automatiques-avec-cron) |
| AUTO_REBOOT_ENABLED                | Active les redémarrages automatiques                                                                                                                                                                                             | false                                     | true/false                                                                                                                                          |
| AUTO_REBOOT_WARN_MINUTES           | Temps d'attente avant de redémarrer le serveur, après que les joueurs ont été informés.                                                                                                                                          | 5                                         | Entier                                                                                                                                              |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Redémarrez le serveur même s'il y a des joueurs en ligne.                                                                                                                                                                        | false                                     | true/false                                                                                                                                          |
| TARGET_MANIFEST_ID                 | Verrouille la version du jeu en correspondance avec l'ID de manifeste de Steam Download Depot.                                                                                                                                   |                                           | Voir [Tableau des ID de manifeste](#tableau-des-versions-vers-les-id-de-manifeste)                                                                  |
| DISCORD_WEBHOOK_URL                | URL du webhook Discord trouvée après la création d'un webhook sur un serveur Discord                                                                                                                                             |                                           | `https://discord.com/api/webhooks/<webhook_id>`                                                                                                     |
| DISCORD_CONNECT_TIMEOUT            | Délai de connexion initial de la commande Discord                                                                                                                                                                                | 30                                        | !0                                                                                                                                                  |
| DISCORD_MAX_TIMEOUT                | Délai total du webhook Discord                                                                                                                                                                                                   | 30                                        | !0                                                                                                                                                  |
| DISCORD_PRE_UPDATE_BOOT_MESSAGE    | Message Discord envoyé lorsque le serveur commence à se mettre à jour                                                                                                                                                            | Le serveur est en cours de mise à jour... | "chaîne"                                                                                                                                            |
| DISCORD_POST_UPDATE_BOOT_MESSAGE   | Message Discord envoyé lorsque le serveur a terminé de se mettre à jour                                                                                                                                                          | Mise à jour du serveur terminée !         | "chaîne"                                                                                                                                            |
| DISCORD_PRE_START_MESSAGE          | Message Discord envoyé lorsque le serveur commence à démarrer                                                                                                                                                                    | Le serveur est démarré !                  | "chaîne"                                                                                                                                            |
| DISCORD_PRE_SHUTDOWN_MESSAGE       | Message Discord envoyé lorsque le serveur commence à s'arrêter                                                                                                                                                                   | Le serveur est en cours d'arrêt...        | "chaîne"                                                                                                                                            |
| DISCORD_POST_SHUTDOWN_MESSAGE      | Message Discord envoyé lorsque le serveur s'est arrêté                                                                                                                                                                           | Le serveur est arrêté !                   | "chaîne"                                                                                                                                            |
| DISABLE_GENERATE_SETTINGS          | S'il faut générer automatiquement le fichier PalWorldSettings.ini                                                                                                                                                                | false                                     | true/false                                                                                                                                          |
| DISABLE_GENERATE_ENGINE            | S'il faut générer automatiquement le fichier Engine.ini                                                                                                                                                                          | true                                      | true/false                                                                                                                                          |
| ENABLE_PLAYER_LOGGING              | Active la journalisation et l'annonce des entrées et sorties de joueurs                                                                                                                                                          | true                                      | true/false                                                                                                                                          |
| PLAYER_LOGGING_POLL_PERIOD         | Période de sondage (en secondes) pour vérifier les joueurs qui ont rejoint ou quitté                                                                                                                                             | 5                                         | !0                                                                                                                                                  |

\* Hautement recommandé à définir

\*\* Assurez-vous de savoir ce que vous faites lorsque vous exécutez cette option activée

\*\*\* Nécessaire pour que `docker stop` enregistre et ferme gracieusement le serveur

### Ports du jeu

| Port  | Info                  |
| ----- | --------------------- |
| 8211  | Port du jeu (UDP)     |
| 27015 | Port de requête (UDP) |
| 25575 | Port RCON (TCP)       |

## Utilisation de RCON

RCON est activé par défaut pour l'image palworld-server-docker.
Ouvrir la CLI RCON est assez simple :

```bash
docker exec -it palworld-server rcon-cli "<commande> <valeur>"
```

Par exemple, vous pouvez diffuser un message à tout le monde dans le serveur avec la commande suivante :

```bash
docker exec -it palworld-server rcon-cli "Broadcast Bonjour à tous"
```

Cela ouvrira une interface en ligne de commande utilisant RCON pour envoyer des commandes au serveur Palworld.

### Liste des commandes du serveur

| Command                              | Info                                                      |
| ------------------------------------ | --------------------------------------------------------- |
| Shutdown {Secondes} {TexteDuMessage} | Le serveur s'arrête après le nombre de secondes spécifié  |
| DoExit                               | Arrêt forcé du serveur.                                   |
| Broadcast                            | Envoyer un message à tous les joueurs dans le serveur     |
| KickPlayer {SteamID}                 | Expulser un joueur du serveur.                            |
| BanPlayer {SteamID}                  | Bannir un joueur du serveur.                              |
| TeleportToPlayer {SteamID}           | Téléporter à l'emplacement actuel du joueur ciblé.        |
| TeleportToMe {SteamID}               | Téléporter le joueur ciblé à votre emplacement actuel     |
| ShowPlayers                          | Afficher les informations sur tous les joueurs connectés. |
| Info                                 | Afficher les informations du serveur.                     |
| Save                                 | Sauvegarder les données du monde.                         |

Pour une liste complète des commandes, consultez : [https://tech.palworldgame.com/server-commands](https://tech.palworldgame.com/server-commands)

## Création d'une sauvegarde

Pour créer une sauvegarde de la progression actuelle du jeu, utilisez la commande :

```bash
docker exec palworld-server backup
```

Cela créera une sauvegarde dans `/palworld/backups/`

Le serveur effectuera une sauvegarde avant la sauvegarde si RCON est activé.

## Restauration à partir d'une sauvegarde

Pour restaurer à partir d'une sauvegarde, utilisez la commande :

```bash
docker exec -it palworld-server restore
```

La variable d'environnement `RCON_ENABLED` doit être définie sur `true` pour utiliser cette commande.

> [!IMPORTANT]
> Si la redémarrage de Docker n'est pas configuré avec la politique `always` ou `unless-stopped`
> le serveur s'éteindra et devra être redémarré manuellement.
>
> La commande docker run exemple et le fichier docker-compose dans [Comment utiliser](#comment-utiliser)
> utilisent déjà la politique nécessaire

## Restauration manuelle à partir d'une sauvegarde

Localisez la sauvegarde que vous souhaitez restaurer dans `/palworld/backups/` et décompressez-la.
Vous devez arrêter le serveur avant de continuer.

```bash
docker compose down
```

Supprimez l'ancien dossier de données sauvegardées situé à `palworld/Pal/Saved/SaveGames/0/<ancienne_valeur_hash>`.

Copiez le contenu du nouveau dossier de données sauvegardées décompressé `Saved/SaveGames/0/<nouvelle_valeur_hash>` to `palworld/Pal/Saved/SaveGames/0/<nouvelle_valeur_hash>`.

Remplacez le nom DedicatedServerName à l'intérieur de `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini`
par le nouveau nom de dossier.

```ini
DedicatedServerName=<nouvelle_valeur_hash>  # Remplacez-le par votre nom de dossier.
```

Redémarrez le jeu. (Si vous utilisez Docker Compose)

```bash
docker compose up -d
```

## Configuration des Sauvegardes Automatiques avec Cron

Le serveur est automatiquement sauvegardé chaque nuit à minuit, selon le fuseau horaire défini avec TZ.

Définissez BACKUP_ENABLED pour activer ou désactiver les sauvegardes automatiques (par défaut, c'est activé).

BACKUP_CRON_EXPRESSION est une expression cron, où vous définissez un intervalle pour l'exécution des tâches.

> [!TIP]
> Cette image utilise Supercronic pour les tâches cron
> voir [supercronic](https://github.com/aptible/supercronic#crontab-format)
> ou
> [Crontab Generator](https://crontab-generator.org).

Définissez BACKUP_CRON_EXPRESSION pour changer la planification par défaut.
Exemple d'utilisation : Si BACKUP_CRON_EXPRESSION est défini sur `0 2 * * *`, le script de sauvegarde
s'exécutera tous les jours à 2h00 du matin.

## Configuration des Mises à Jour Automatiques avec Cron

Pour pouvoir utiliser les mises à jour automatiques avec ce serveur, les variables d'environnement
suivantes **doivent** être définies sur `true`:

- RCON_ENABLED
- UPDATE_ON_BOOT

> [!IMPORTANT]
>
> Si le redémarrage de Docker n'est pas configuré avec la politique `always` ou `unless-stopped`
> le serveur s'éteindra et devra être
> redémarré manuellement.
>
> La commande docker run exemple et le fichier docker-compose dans [Comment utiliser](#comment-utiliser)
> utilisent déjà la politique nécessaire

Définissez AUTO_UPDATE_ENABLED pour activer ou désactiver les mises à jour automatiques (par défaut, c'est désactivé).

AUTO_UPDATE_CRON_EXPRESSION est une expression cron, où vous définissez un intervalle pour l'exécution des tâches.

> [!TIP]
> Cette image utilise Supercronic pour les tâches cron
> voir [supercronic](https://github.com/aptible/supercronic#crontab-format)
> ou
> [Crontab Generator](https://crontab-generator.org).

Définissez AUTO_UPDATE_CRON_EXPRESSION pour changer la planification par défaut.

## Configuration des Redémarrages Automatiques avec Cron

Pour pouvoir utiliser les redémarrages automatiques avec ce serveur, RCON_ENABLED doit être activé.

> [!IMPORTANT]
>
> Si le redémarrage de Docker n'est pas configuré avec la politique `always` ou `unless-stopped`
> le serveur s'éteindra et devra être
> redémarré manuellement.
>
> La commande docker run exemple et le fichier docker-compose dans [Comment utiliser](#comment-utiliser)
> utilisent déjà la politique nécessaire

Définissez AUTO_REBOOT_ENABLED pour activer ou désactiver les redémarrages automatiques (par défaut, c'est désactivé).

AUTO_REBOOT_CRON_EXPRESSION est une expression cron, où vous définissez un intervalle pour l'exécution des tâches.

> [!TIP]
> Cette image utilise Supercronic pour les tâches cron
> voir [supercronic](https://github.com/aptible/supercronic#crontab-format)
> ou
> [Crontab Generator](https://crontab-generator.org).

Définissez AUTO_REBOOT_CRON_EXPRESSION pour changer la planification par défaut, qui est tous les soirs à minuit selon le
fuseau horaire défini avec TZ.

## Modification des paramètres du serveur

### Avec des variables d'environnement

> [!IMPORTANT]
>
> Ces variables d'environnement/paramètres sont susceptibles de changer car le jeu est encore en version bêta.
> Consultez la [page officielle pour les paramètres pris en charge.](https://tech.palworldgame.com/optimize-game-balance)

La conversion des paramètres du serveur en variables d'environnement suit les mêmes principes (avec quelques exceptions):

- toutes en majuscules
- séparation des mots par l'insertion d'un trait de soulignement
- suppression de la lettre unique si le paramètre commence par une (comme 'b')

Par exemple :

- Difficulty -> DIFFICULTY
- PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
- bIsPvP -> IS_PVP

| Variable                                  | Description                                                                                                                                                                                                | Valeur par défaut                                                                            | Valeur autorisée                               |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| DIFFICULTY                                | Difficulté du jeu                                                                                                                                                                                          | Aucune                                                                                       | `Aucune`, `Normal`, `Difficile`                |
| DAYTIME_SPEEDRATE                         | Vitesse du jour - Un nombre plus grand signifie des journées plus courtes                                                                                                                                  | 1,000000                                                                                     | Flottant                                       |
| NIGHTTIME_SPEEDRATE                       | Vitesse de la nuit - Un nombre plus grand signifie des nuits plus courtes                                                                                                                                  | 1,000000                                                                                     | Flottant                                       |
| EXP_RATE                                  | Taux de gain d'EXP                                                                                                                                                                                         | 1,000000                                                                                     | Flottant                                       |
| PAL_CAPTURE_RATE                          | Taux de capture de Pal                                                                                                                                                                                     | 1,000000                                                                                     | Flottant                                       |
| PAL_SPAWN_NUM_RATE                        | Taux d'apparition des Pals                                                                                                                                                                                 | 1,000000                                                                                     | Flottant                                       |
| PAL_DAMAGE_RATE_ATTACK                    | Multiplicateur des dégâts infligés par les Pals                                                                                                                                                            | 1,000000                                                                                     | Flottant                                       |
| PAL_DAMAGE_RATE_DEFENSE                   | Multiplicateur des dégâts subis par les Pals                                                                                                                                                               | 1,000000                                                                                     | Flottant                                       |
| PLAYER_DAMAGE_RATE_ATTACK                 | Multiplicateur des dégâts infligés par le joueur                                                                                                                                                           | 1,000000                                                                                     | Flottant                                       |
| PLAYER_DAMAGE_RATE_DEFENSE                | Multiplicateur des dégâts subis par le joueur                                                                                                                                                              | 1,000000                                                                                     | Flottant                                       |
| PLAYER_STOMACH_DECREASE_RATE              | Taux de déplétion de la faim du joueur                                                                                                                                                                     | 1,000000                                                                                     | Flottant                                       |
| PLAYER_STAMINA_DECREASE_RATE              | Taux de réduction de la stamina du joueur                                                                                                                                                                  | 1,000000                                                                                     | Flottant                                       |
| PLAYER_AUTO_HP_REGEN_RATE                 | Taux de régénération automatique des PV du joueur                                                                                                                                                          | 1,000000                                                                                     | Flottant                                       |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | Taux de régénération automatique des PV du joueur pendant le sommeil                                                                                                                                       | 1,000000                                                                                     | Flottant                                       |
| PAL_STOMACH_DECREASE_RATE                 | Taux de déplétion de la faim des Pals                                                                                                                                                                      | 1,000000                                                                                     | Flottant                                       |
| PAL_STAMINA_DECREASE_RATE                 | Taux de réduction de la stamina des Pals                                                                                                                                                                   | 1,000000                                                                                     | Flottant                                       |
| PAL_AUTO_HP_REGEN_RATE                    | Taux de régénération automatique des PV des Pals                                                                                                                                                           | 1,000000                                                                                     | Flottant                                       |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | Taux de régénération automatique de la santé des Pals (dans la Palbox)                                                                                                                                     | 1,000000                                                                                     | Flottant                                       |
| BUILD_OBJECT_DAMAGE_RATE                  | Multiplicateur des dégâts aux structures                                                                                                                                                                   | 1,000000                                                                                     | Flottant                                       |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | Taux de détermination de la structure                                                                                                                                                                      | 1,000000                                                                                     | Flottant                                       |
| COLLECTION_DROP_RATE                      | Multiplicateur d'objets collectables                                                                                                                                                                       | 1,000000                                                                                     | Flottant                                       |
| COLLECTION_OBJECT_HP_RATE                 | Multiplicateur de la santé des objets collectables                                                                                                                                                         | 1,000000                                                                                     | Flottant                                       |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | Taux d'intervalle de réapparition des objets collectables - Plus le nombre est petit, plus la régénération est rapide                                                                                      | 1,000000                                                                                     | Flottant                                       |
| ENEMY_DROP_ITEM_RATE                      | Multiplicateur d'objets abandonnés par les ennemis                                                                                                                                                         | 1,000000                                                                                     | Flottant                                       |
| DEATH_PENALTY                             | Pénalité de mort</br>Aucune : Pas de pénalité de mort</br>Objet : Lâche des objets autres que l'équipement</br>ObjetEtÉquipement : Lâche tous les objets</br>Tous : Lâche tous les Pals et tous les objets | Tous                                                                                         | `Aucune`, `Objet`, `ObjetEtÉquipement`, `Tous` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | Permet aux joueurs de causer des dégâts aux autres joueurs                                                                                                                                                 | Faux                                                                                         | Booléen                                        |
| ENABLE_FRIENDLY_FIRE                      | Autoriser les tirs amis                                                                                                                                                                                    | Faux                                                                                         | Booléen                                        |
| ENABLE_INVADER_ENEMY                      | Activer les envahisseurs                                                                                                                                                                                   | Vrai                                                                                         | Booléen                                        |
| ACTIVE_UNKO                               | Activer UNKO (?)                                                                                                                                                                                           | Faux                                                                                         | Booléen                                        |
| ENABLE_AIM_ASSIST_PAD                     | Activer l'assistance à la visée du contrôleur                                                                                                                                                              | Vrai                                                                                         | Booléen                                        |
| ENABLE_AIM_ASSIST_KEYBOARD                | Activer l'assistance à la visée du clavier                                                                                                                                                                 | Faux                                                                                         | Booléen                                        |
| DROP_ITEM_MAX_NUM                         | Nombre maximal de largages dans le monde                                                                                                                                                                   | 3000                                                                                         | Entier                                         |
| DROP_ITEM_MAX_NUM_UNKO                    | Nombre maximal de largages UNKO dans le monde                                                                                                                                                              | 100                                                                                          | Entier                                         |
| BASE_CAMP_MAX_NUM                         | Nombre maximal de camps de base                                                                                                                                                                            | 128                                                                                          | Entier                                         |
| BASE_CAMP_WORKER_MAX_NUM                  | Nombre maximal de travailleurs                                                                                                                                                                             | 15                                                                                           | Entier                                         |
| DROP_ITEM_ALIVE_MAX_HOURS                 | Temps avant la disparition des objets en heures                                                                                                                                                            | 1,000000                                                                                     | Flottant                                       |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | Réinitialiser automatiquement la guilde lorsqu'aucun joueur n'est en ligne                                                                                                                                 | Faux                                                                                         | Booléen                                        |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | Temps pour réinitialiser automatiquement la guilde lorsqu'aucun joueur n'est en ligne                                                                                                                      | 72,000000                                                                                    | Flottant                                       |
| GUILD_PLAYER_MAX_NUM                      | Nombre maximum de joueurs dans une guilde                                                                                                                                                                  | 20                                                                                           | Entier                                         |
| PAL_EGG_DEFAULT_HATCHING_TIME             | Temps (h) pour incuber un œuf massif                                                                                                                                                                       | 72,000000                                                                                    | Flottant                                       |
| WORK_SPEED_RATE                           | Multiplicateur de la vitesse de travail                                                                                                                                                                    | 1,000000                                                                                     | Flottant                                       |
| IS_MULTIPLAY                              | Activer le multijoueur                                                                                                                                                                                     | Faux                                                                                         | Booléen                                        |
| IS_PVP                                    | Activer le PVP                                                                                                                                                                                             | Faux                                                                                         | Booléen                                        |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | Autoriser les joueurs d'autres guildes à ramasser les objets de pénalité de mort                                                                                                                           | Faux                                                                                         | Booléen                                        |
| ENABLE_NON_LOGIN_PENALTY                  | Activer la pénalité hors connexion                                                                                                                                                                         | Vrai                                                                                         | Booléen                                        |
| ENABLE_FAST_TRAVEL                        | Activer le déplacement rapide                                                                                                                                                                              | Vrai                                                                                         | Booléen                                        |
| IS_START_LOCATION_SELECT_BY_MAP           | Activer la sélection de l'emplacement de départ                                                                                                                                                            | Vrai                                                                                         | Booléen                                        |
| EXIST_PLAYER_AFTER_LOGOUT                 | Bascule pour supprimer les joueurs lorsqu'ils se déconnectent                                                                                                                                              | Faux                                                                                         | Booléen                                        |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | Permet la défense contre les joueurs d'autres guildes                                                                                                                                                      | Faux                                                                                         | Booléen                                        |
| COOP_PLAYER_MAX_NUM                       | Nombre maximum de joueurs dans une guilde                                                                                                                                                                  | 4                                                                                            | Entier                                         |
| REGION                                    | Région                                                                                                                                                                                                     |                                                                                              | Chaîne de caractères                           |
| USEAUTH                                   | Utiliser l'authentification                                                                                                                                                                                | Vrai                                                                                         | Booléen                                        |
| BAN_LIST_URL                              | Liste des interdictions à utiliser                                                                                                                                                                         | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | Chaîne de caractères                           |
| SHOW_PLAYER_LIST                          | Activer l'affichage de la liste des joueurs                                                                                                                                                                | Vrai                                                                                         | Booléen                                        |

### Manuellement

Lorsque le serveur démarre, un fichier `PalWorldSettings.ini` sera créé à l'emplacement suivant : `<dossier_de_montage>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Veuillez noter que les variables d'environnement (ENV) écraseront toujours les modifications apportées à `PalWorldSettings.ini`.

> [!IMPORTANT]
> Les changements ne peuvent être apportés à `PalWorldSettings.ini` que lorsque le serveur est éteint.
>
> Toutes les modifications apportées pendant que le serveur est en cours d'exécution seront écrasées lors de l'arrêt du serveur.

Pour une liste plus détaillée des paramètres du serveur, consultez : [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

Pour des explications plus détaillées sur les paramètres du serveur, consultez : [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)

## Utilisation de webhooks Discord

1. Générez une URL de webhook pour votre serveur Discord dans les paramètres de votre serveur Discord.

2. Configurez la variable d'environnement avec le jeton unique à la fin de l'exemple d'URL de webhook Discord : `https://discord.com/api/webhooks/1234567890/abcde`

Envoyez des messages Discord avec docker run :

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Le serveur est en cours de mise à jour..." \

```

Envoyez des messages Discord avec docker compose :

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Le serveur est en cours de mise à jour...
```

## Verrouiller une Version Spécifique du Jeu

> [!WARNING]
> Rétrograder vers une version inférieure du jeu est possible, mais on ne sait pas quel impact
> cela aura sur les sauvegardes existantes.
>
> **Faites-le à vos propres risques !**

Si la variable d'environnement **TARGET_MANIFEST_ID** est définie, elle verrouillera la version
du serveur sur un manifeste spécifique.
Le manifeste correspond aux dates de sortie/mises à jour. Les manifestes peuvent être trouvés
à l'aide de SteamCMD ou de sites web comme [SteamDB](https://steamdb.info/depot/2394012/manifests/).

### Tableau des Versions Vers les ID de Manifeste

| Version | ID de Manifeste     |
| ------- | ------------------- |
| 1.3.0   | 1354752814336157338 |
| 1.4.0   | 4190579964382773830 |
| 1.4.1   | 6370735655629434989 |
| 1.5.0   | 3750364703337203431 |
| 1.5.1   | 2815085007637542021 |

## Signalement de Problèmes/Demandes de Fonctionnalités

Les problèmes/Demandes de fonctionnalités peuvent être soumis en utilisant [ce lien](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose).

### Problèmes Connus

Les problèmes connus sont répertoriés dans la [documentation](https://palworld-server-docker.loef.dev/known-issues/)
