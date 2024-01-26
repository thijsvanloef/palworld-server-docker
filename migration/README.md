# Migrate From Existing Server

1. Find a directory which is named by game server name and contains all saved game data,
   usually it will at `~/Steam/steamapps/common/PalServer/Pal/Saved/SaveGames/0/`
3. Make sure `migration/migrate.sh`, saved game data directory and mounted volume (e.g. `palworld/`) are in the same directory. Like this:
   
    ```shell
    ubuntu@VM-4-5-ubuntu:~/test-pal-migrate$ ll
    total 24
    drwxrwxr-x  4 ubuntu ubuntu 4096 Jan 26 03:31 ./
    drwxr-x--- 12 ubuntu ubuntu 4096 Jan 26 03:31 ../
    drwxr-xr-x  2 ubuntu ubuntu 4096 Jan 26 03:30 74406BE1D7B54114AA5984CCF1236865/
    -rw-r--r--  1 ubuntu ubuntu  840 Jan 25 05:51 docker-compose.yml
    -rw-rw-r--  1 ubuntu ubuntu  848 Jan 26 03:31 migrate.sh
    drwxrwxr-x  7 ubuntu ubuntu 4096 Jan 26 03:31 palworld/
    ```

5. Run `migrate.sh` like this

    ```shell
    ./migrate.sh {CONTAINER_NAME} {SERVER_NAME}
    ```

   For example,

    ```shell
    ./migrate.sh test-pal-migrate 74406BE1D7B54114AA5984CCF1236865
    ```
