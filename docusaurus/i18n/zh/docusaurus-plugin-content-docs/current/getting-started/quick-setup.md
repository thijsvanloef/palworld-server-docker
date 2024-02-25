---
sidebar_position: 1
slug: /
---

# 快速设置

让我们带你开始设置 Palworld 专用服务器吧！

:::warning
目前， Xbox Gamepass/Xbox 主机玩家无法加入专用服务器。

他们只能通过邀请码加入，并且最多允许 4 人游玩。
:::

## 计算机要求

| 资源 | 最低要求 | 推荐配置                              |
|----------|---------|------------------------------------------|
| CPU      | 4 cores | 4+ cores                                 |
| RAM      | 16GB    | 推荐超过 32GB 以保持稳定运行 |
| 存储  | 8GB     | 20GB                                     |

## Docker Compose

此存储库包含一个示例
[docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml)
文件，您可以使用它来设置专用服务器。

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest # 建议指定版本，不要选择 latest
      platform: linux/amd64 # 对于 arm64 主机，请使用 linux/arm64
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # 设置容器正常停止的等待时间
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         PUID: 1000
         PGID: 1000
         PORT: 8211 # 可选但建议
         PLAYERS: 16 # 可选但建议
         SERVER_PASSWORD: "worldofpals" # 可选但建议
         MULTITHREADING: true
         RCON_ENABLED: true
         RCON_PORT: 25575
         TZ: "UTC"
         ADMIN_PASSWORD: "adminPasswordHere"
         COMMUNITY: false  # 如果希望服务器出现在社区服务器选项中，请启用此选项，与 SERVER_PASSWORD 一起使用！
         SERVER_NAME: "palworld-server-docker by Thijs van Loef"
         SERVER_DESCRIPTION: "palworld-server-docker by Thijs van Loef"
      volumes:
         - ./palworld:/palworld/
```
<!-- markdownlint-disable-next-line -->
或者，可以将 [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) 文件复制到一个名为 **.env** 的新文件中。<!-- markdownlint-disable-next-line -->
根据需要进行修改，并查看 [环境变量](#/zh/入门/配置/服务器设置#环境变量) 部分以检查正确的 <!-- markdownlint-disable-next-line -->
值。将 [docker-compose.yml](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docker-compose.yml) 修改为以下内容：

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest # 建议指定版本，不要选择 latest
      platform: linux/amd64 # 对于 arm64 主机，请使用 linux/arm64
      restart: unless-stopped
      container_name: palworld-server
      stop_grace_period: 30s # 设置容器正常停止的等待时间
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      env_file:
         -  .env
      volumes:
         - ./palworld:/palworld/
```

## 启动服务器

使用 `docker compose up -d` 在后台启动服务器

## 停止服务器

使用 `docker compose stop` 停止服务器

使用 `docker compose down --rmi all` 停止并删除服务器，并从计算机中删除 Docker 镜像。

### Docker Run

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
    thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
```
<!-- markdownlint-disable-next-line -->
或者，可以将 [.env.example](https://github.com/thijsvanloef/palworld-server-docker/blob/main/.env.example) 文件复制到一个名为 **.env** 的新文件中。<!-- markdownlint-disable-next-line -->
根据需要进行修改，并查看 [环境变量](#/zh/入门/配置/服务器设置#环境变量) 部分以检查正确的值。
将 docker run 命令修改为以下内容：

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./palworld:/palworld/ \
    --env-file .env \
    --restart unless-stopped \
    --stop-timeout 30 \
    thijsvanloef/palworld-server-docker:latest # Use the latest-arm64 tag for arm64 hosts
```
