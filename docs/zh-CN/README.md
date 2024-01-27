# Palworld Dedicated Server Docker

[![Release](https://img.shields.io/github/v/release/thijsvanloef/palworld-server-docker)](https://github.com/thijsvanloef/palworld-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Docker Stars](https://img.shields.io/docker/stars/thijsvanloef/palworld-server-docker)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/thijsvanloef/palworld-server-docker/latest)](https://hub.docker.com/r/thijsvanloef/palworld-server-docker/tags)
[![Discord](https://img.shields.io/discord/1200397673329594459?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FUxBxStPAAE)](https://discord.com/invite/UxBxStPAAE)
[![Static Badge](https://img.shields.io/badge/README-0.16.0-blue?link=https%3A%2F%2Fgithub.com%2Fthijsvanloef%2Fpalworld-server-docker%2Fblob%2Fmain%2FREADME.md)](https://github.com/thijsvanloef/palworld-server-docker?tab=readme-ov-file#palworld-dedicated-server-docker)

在 [Docker Hub](https://hub.docker.com/r/thijsvanloef/palworld-server-docker) 查看

加入我们的 [Discord](https://discord.gg/UxBxStPAAE)

[English](/README.md) | [한국어](/docs/kr/README.md) | [简体中文](/docs/zh-CN/README.md)

> [!TIP]
> 不知道从何开始？ [看看这里吧！](https://tice.tips/containerization/palworld-server-docker/)

这是一个 [Docker](https://docs.docker.com/engine/install/) 容器，可帮助您创建自己的
[幻兽帕鲁](https://store.steampowered.com/app/1623730/Palworld/) 服务器

此容器经测试可正常在 (Ubuntu/Debian) 和 Windows 10 上运行

> [!IMPORTANT]
> 目前, Xbox Game Pass/Xbox 主机玩家无法加入服务器
>
> 他们只能通过邀请码加入，并且最多允许4人游玩

## 服务器配置需求

| 资源 | 最小 | 推荐                              |
|----------|---------|------------------------------------------|
| CPU      | 4 核 | 4+ 核以上                                 |
| 内存      | 16GB    | 推荐 32GB 以上以稳定运行 |
| 存储空间  | 4GB     | 12GB                                     |

## 开始使用

注意，您需要配置 [环境变量](#环境变量).

### Docker Compose

您可以直接使用 [docker-compose.yml](/docker-compose.yml) 来配置您的服务器

```yml
services:
   palworld:
      image: thijsvanloef/palworld-server-docker:latest
      restart: unless-stopped
      container_name: palworld-server
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         - PUID=1000
         - PGID=1000
         - PORT=8211 # 可选但推荐
         - PLAYERS=16 # 可选但推荐
         - SERVER_PASSWORD="worldofpals" # 可选但推荐
         - MULTITHREADING=true
         - RCON_ENABLED=true
         - RCON_PORT=25575
         - TZ=Asia/Shanghai
         - ADMIN_PASSWORD="adminPasswordHere"
         - COMMUNITY=false  # 如果您希望服务器显示在社区服务器页中，请启用此选项（注意配置SERVER_PASSWORD!）
         - SERVER_NAME="World of Pals"
      volumes:
         - ./palworld:/palworld/
```

### Docker Run

将`<palworld-folder>`修改为您自己的路径

```bash
docker run -d \
    --name palworld-server \
    -p 8211:8211/udp \
    -p 27015:27015/udp \
    -v ./<palworld-folder>:/palworld/ \
    -e PUID=1000 \
    -e PGID=1000 \
    -e PORT=8211 \
    -e PLAYERS=16 \
    -e MULTITHREADING=true \
    -e RCON_ENABLED=true \
    -e RCON_PORT=25575 \
    -e TZ=Asia/Shanghai \
    -e ADMIN_PASSWORD="adminPasswordHere" \
    -e SERVER_PASSWORD="worldofpals" \
    -e COMMUNITY=false \
    -e SERVER_NAME="World of Pals" \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker:latest

```

### Kubernetes

将此容器部署到 Kubernetes 的所有文件都位于[此文件夹中](k8s/).

请按照 [此处](k8s/readme.md) 进行部署

#### 使用 helm 部署

请按照 [此处](./chart/README.md) 进行部署

### 环境变量

您可以使用以下值来修改服务器设置  
强烈建议您在启动服务器之前设置以下变量：

* PLAYERS
* PORT
* PUID
* PGID

| 变量         | 信息                                                                                                                                                                                               | 默认值 | 允许值                                                                                             |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------|
| TZ               | 备份服务器时所使用的时间戳                                                                                                                                                      | UTC            | 参见 [时区列表](https://zh.wikipedia.org/wiki/%E6%97%B6%E5%8C%BA%E5%88%97%E8%A1%A8) |
| PLAYERS*         | 可同加入服务器的最大玩家数                                                                                                                                             | 16             | 1-32                                                                                                       |
| PORT*            | 服务器将开放的 UDP 端口                                                                                                                                                               | 8211           | 1024-65535                                                                                                 |
| PUID*            | 服务器运行时的用户的 UID                                                                                                                                                       | 1000           | !0                                                                                                         |
| PGID*            | 服务器运行时的组的 GID                                                                                                                                                      | 1000           | !0                                                                                                         |
| MULTITHREADING** | 提高多线程 CPU 环境下的性能。它最多对 4 个线程有效，分配超过这个数量的线程没有太大意义             | false          | true/false                                                                                                 |
| COMMUNITY        | 服务器是否显示在社区服务器页中（建议设置SERVER_PASSWORD）                                                                                                      | false          | true/false                                                                                                 |
| PUBLIC_IP        | 您可以手动指定服务器 IP 地址。若未指定，将自动检测 |                | x.x.x.x                                                                                                    |
| PUBLIC_PORT      | 您可以手动指定服务器端口。若未指定，将自动检测       |                | 1024-65535                                                                                                 |
| SERVER_NAME      | 服务器名称               |                | "string"                                                                                                   |
| SERVER_PASSWORD  | 为服务器设置密码                                                                                                                                                       |                | "string"                                                                                                   |
| ADMIN_PASSWORD   | 为服务器设置管理员密码                                                                                                                                         |                | "string"                                                                                                   |
| UPDATE_ON_BOOT** | 在启动 Docker 容器时更新/安装服务器（需要在第一次运行时启用）                                                                           | true           | true/false                                                                                                 |
| RCON_ENABLED***  | 为服务器启用 RCON                                                                                                                                                                | true           | true/false                                                                                                 |
| RCON_PORT        | RCON 连接端口                                                                                                                                                                            | 25575          | 1024-65535                                                                                                 |
| QUERY_PORT       | 用于与 Steam 服务器通信的查询端口                                                                                                                                                  | 27015          | 1024-65535                                                                                                 |

*强烈建议设置

** 启用该选项时，请确保您知道自己在做什么

*** 是使用docker命令保存并关闭服务器的必要条件

> [!IMPORTANT]
> 环境变量中使用的布尔值区分大小写，因为它们是在 shell 脚本中使用的
>
> 必须准确使用 `true` 或 `false` 设置它们，选项才能生效

### Game Ports

| 端口  | 信息             |
|-------|------------------|
| 8211  | 游戏端口 (UDP)  |
| 27015 | 查询端口 (UDP) |
| 25575 | RCON 端口 (TCP)  |

## 使用 RCON

RCON 已在此项目中默认开启
使用 RCON CLI 非常简单:

```bash
docker exec -it palworld-server rcon-cli
```

这将打开一个 CLI，使用 RCON 使用服务器命令

### 命令列表

| 命令                          | 信息                                                |
|----------------------------------|-----------------------------------------------------|
| Shutdown {秒} {信息} | 服务器将在{秒}后关闭 |
| DoExit                           | 强制关闭服务器                              |
| Broadcast                        | 向服务器中所有玩家发送消息            |
| KickPlayer {SteamID}             | 从服务器中踢出玩家                       |
| BanPlayer {SteamID}              | 从服务器中封禁玩家                         |
| TeleportToPlayer {SteamID}       | 传送到目标玩家      |
| TeleportToMe {SteamID}           | 将目标玩家传送到身边    |
| ShowPlayers                      | 显示所有已连接玩家信息          |
| Info                             | 显示服务器信息                            |
| Save                             | 保存游戏                                |

请查看 [官方文档](https://tech.palworldgame.com/server-commands) 以获取所有命令

## 创建备份

To create a backup of the game's save at the current point in time, use the command:

```bash
docker exec palworld-server backup
```

执行后将在 `/palworld/backups/` 文件夹中生成备份

若启用了 RCON，服务器将在备份前进行保存

## 修改服务器设置

服务器启动时， `PalWorldSettings.ini` 文件将在 `<mount_folder>/Pal/Saved/Config/LinuxServer` 文件夹中生成

所有更改将在服务器下次启动时生效

请注意，环境变量将始终覆盖对 `PalWorldSettings.ini` 所做的更改

服务器配置文件参数相关说明，请在
[shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html) 中查看

## 报告问题/功能请求

可通过 [此链接](https://github.com/thijsvanloef/palworld-server-docker/issues/new/choose) 报告问题/功能请求

### 已知问题

已知问题已在 [Wiki](https://github.com/thijsvanloef/palworld-server-docker/wiki/Known-Issues) 中列出
