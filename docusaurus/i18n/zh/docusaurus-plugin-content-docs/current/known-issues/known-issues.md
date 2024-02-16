---
sidebar_position: 4
---

# 已知问题

## Broadcast 命令只能发送一个单词

在使用 RCON 的 Broadcast 功能时，只能传递一个单词。

例如，如果我使用：

`docker exec -it palworld-server rcon-cli Broadcast "Hello world"`

只有 Hello 会被传递。

## Xbox GamePass 玩家无法加入

目前，Xbox GamePass/Xbox 主机玩家无法加入专用服务器。

他们需要使用邀请代码加入，且最多限制为 4 名玩家。

## [S_API FAIL]

服务器有时会输出以下错误：

```bash
[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
[S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
```

这可以安全地忽略，不会影响服务器。

## Setting breakpad minidump AppID = 2394010

这表示服务器正在运行，如果仍然无法连接到它，说明您需要检查以下事项：

* 防火墙设置，请确保通过防火墙允许端口 8211/udp 和 27015/udp
* 确保您正确地设置了端口转发，8211/udp 27015/udp

## FAQ

[一个经常更新的有用 FAQ](https://gist.github.com/Toakan/3c78a577c21a21fcc5fa917f3021d70e#file-palworld-server-faq-community-md)
