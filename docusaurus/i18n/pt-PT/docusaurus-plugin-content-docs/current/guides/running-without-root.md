---
sidebar_position: 8
---

# Executar sem permissões root

Isto é apenas para utilizadores avançados

É possível executar este contentor e
[substituir o utilizador predefinido](https://docs.docker.com/engine/reference/run/#user) que é o root nesta imagem.

Se especificares o user e o grupo, `PUID` e `PGID` são ignorados.

Se quiseres encontrar o teu UID: `id -u`
Se quiseres encontrar o teu PGID: `id -g`

Tens que definir `NÚMERO_UID:NÚMERO_GID`

Vamos assumir que o teu UID é 1000 e GID é 1001

- No docker run adicionar `--user 1000:1001 \` por cima da última linha
- No docker compose adicionar `user: 1000:1001` por cima das Ports.

Se desejar executá-lo com um UID/GID diferente do seu, terá de alterar a propriedade do diretório que
está associado: `chown UID:GID palworld/`
ou alterando as permissões de todos os outros: `chmod o=rwx palworld/`
