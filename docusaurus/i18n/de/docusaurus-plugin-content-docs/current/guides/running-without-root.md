---
sidebar_position: 6
---

# Ausführen ohne Root-Rechte

Dieser Beitrag richtet sich nur an fortgeschrittene Benutzer!
<!-- markdownlint-disable-next-line -->
Sie können diesen Container ausführen und den Standardbenutzer (root) [überschreiben](https://docs.docker.com/engine/reference/run/#user).

Wenn der Benutzer und die Gruppe angegeben werden, werden `PUID`  und `PGID` ignoriert.

Wie Sie die GID bzw. die UID herausfinden: `id -u` / `id -g`

Um den Standardbenutzer zu überschreiben muss der Benutzer auf `NUMERISCHE_UID:NUMERISCHE_GID` gesetzt werden.

Im Folgenden gehen wir davon aus, dass Ihre UID 1000 und Ihre GID 1001 ist:

* Mit `docker run` fügen Sie `--user 1000:1001 \` über der letzten Zeile des Beispiels hinzu.
* Mit `docker compose` fügen Sie `user: 1000:1001` in die `docker-compose.yml` unter den Ports hinzu.

Wenn Sie den Container mit einer anderen UID/GID als Ihrer eigenen ausführen möchten, müssen Sie den Besitz des
Verzeichnisses ändern, das eingebunden wird: `chown UID:GID palworld/` oder die Berechtigungen ändern:
`chmod o=rwx palworld/`
