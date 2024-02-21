---
sidebar_position: 2
---

# Restaurar cópia de segurança

## Restaurar cópia de segurança interactivamente

Para restaurar a partir de uma cópia de segurança, utilize o comando:

```bash
docker exec -it palworld-server restore
```

A variável de ambiente `RCON_ENABLED` deve ser definida como `true` para utilizar este comando.

:::warning

Se a reinicialização do docker não estiver definida como `always` ou `unless-stopped`,
o servidor será desligado e precisará ser reiniciado manualmente.

Os ficheiros de exemplo docker run command e docker compose em [Configuração rápida](/pt-PT/) utilizam esta definição.

:::

## Restaurar cópia de segurança manualmente

Localize a cópia de segurança que pretende restaurar em `/palworld/backups/` e descomprimir.
É necessário parar o servidor antes da tarefa.

```bash
docker compose down
```

Elimina a antiga diretoria do save localizada em `palworld/Pal/Saved/SaveGames/0/<old_hash_value>`.

Copiar o conteúdo da diretoria descomprimida `Saved/SaveGames/0/<new_hash_value>` para `palworld/Pal/Saved/SaveGames/0/<new_hash_value>`.

Substitua o DedicatedServerName dentro de `palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini`
com o novo nome da diretoria.

```ini
DedicatedServerName=<new_hash_value>  # Substitua-o pelo nome da diretoria.
```

Reinicie o jogo. (Se estiver a utilizar o Docker Compose)

```bash
docker compose up -d
```
