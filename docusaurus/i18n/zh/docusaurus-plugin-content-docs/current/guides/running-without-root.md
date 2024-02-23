---
sidebar_position: 6
---

# 无需使用 root 用户运行

这仅适用于高级用户

可以运行此容器并[覆盖默认用户](https://docs.docker.com/engine/reference/run/#user)，默认用户是此镜像中的 root 用户。

由于您正在指定用户和组，`PUID` 和 `PGID` 将被忽略。

如果要查找您的 UID：`id -u`
如果要查找您的 GID：`id -g`

您必须将用户设置为 `NUMBERICAL_UID:NUMBERICAL_GID`

以下假设您的 UID 为 1000，GID 为 1001

* 在 docker run 中添加 `--user 1000:1001 \` 到最后一行上方。
* 在 docker-compose 中添加 `user: 1000:1001` 到端口上方。

如果希望使用与您自己不同的 UID/GID 运行它，您需要更改正在绑定的目录的所有权：`chown UID:GID palworld/`
或通过更改所有其他用户的权限：`chmod o=rwx palworld/`
