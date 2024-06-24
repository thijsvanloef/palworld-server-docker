---
sidebar_position: 2
slug: /quick-setup-xbox
title: Palworld Dedicated server Quick Setup Xbox
description: This guide will help you get setup with hosting your Palworld Dedicated server for Xbox! This Palworld server quick setup will only take a couple of minutes and you'll have a working server.
keywords: [Palworld, palworld dedicated server, how to setup palworld dedicated server xbox, palworld server docker xbox, palworld docker, xbox]
image: ../assets/Palworld_Banner.jpg
sidebar_label: Quick Setup Xbox
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated server Xbox

:::warning
PLEASE NOT THAT CROSSPLAY BETWEEN XBOX-STEAM IS NOT YET SUPPORTED
:::

Servers set up using these steps will be able to accept connections from the Xbox Series X version, Xbox Series S version,
Xbox One version, and the Windows PC version downloaded from the Microsoft Store. [^1]

Setting up a dedicated server for Xbox is the same as deploying for Steam.
You would only need to change the following environment variable.

Change:

```yaml
ALLOW_CONNECT_PLATFORM: "Steam"
```

to:

```yaml
ALLOW_CONNECT_PLATFORM: "Xbox"
```

---

[^1]: [Official documentation](https://tech.palworldgame.com/getting-started/for-xbox-dedicated-server)
