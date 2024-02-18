---
sidebar_position: 6
---

# Running without root

This is only for advanced users

It is possible to run this container and
[override the default user](https://docs.docker.com/engine/reference/run/#user) which is root in this image.

Because you are specifiying the user and group `PUID` and `PGID` are ignored.

If you want to find your UID: `id -u`
If you want to find your GID: `id -g`

You must set user to `NUMBERICAL_UID:NUMBERICAL_GID`

Below we assume your UID is 1000 and your GID is 1001

* In docker run add `--user 1000:1001 \` above the last line.
* In docker compose add `user: 1000:1001` above ports.

If you wish to run it with a different UID/GID than your own you will need to change the ownership of the directory that
is being bind: `chown UID:GID palworld/`
or by changing the permissions for all other: `chmod o=rwx palworld/`
