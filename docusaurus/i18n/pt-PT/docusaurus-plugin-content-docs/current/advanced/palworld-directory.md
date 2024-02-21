---
sidebar_position: 1
---

# Diretorias Palworld

Tudo relacionado com os dados do Palworld pode ser encontrado na diretoria `/palworld`.

## Estrutura da diretoria

![Folder Structure](../assets/folder_structure.jpg)

| Diretoria                    | Uso                                                                    |
| ---------------------------- | ---------------------------------------------------------------------- |
| palworld                     | Raiz de todos os ficheiros do servidor Palworld                        |
| backups                      | Diretoria onde as cópias de segurança do comando `backup`são guardadas |
| Pal/Saved/Config/LinuxServer | Diretoria dos ficheiros de configuração .ini para configuração manual  |

## Anexar o diretório de dados ao sistema de ficheiros do anfitrião

A maneira mais fácil de anexar o diretório de dados ao sistema de ficheiros do anfitrião é usar o exemplo do [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml):

```yml
volumes:
  - ./palworld:/palworld/
```

Isto cria uma pasta `palworld` no diretório de trabalho atual e monta a pasta `/palworld`.
