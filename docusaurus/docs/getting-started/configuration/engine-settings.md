---
sidebar_position: 3
title: Palworld Server Engine Settings
description: How to change the Palworld Engine Settings (Engine.ini file) using Docker Environment variables.
keywords: [Palworld, palworld dedicated server, Palworld Engine.ini, palworld engine settings]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Engine Settings
---
<!-- markdownlint-disable-next-line -->
# Palworld Server Engine Settings

How to change the Palworld Engine Settings (Engine.ini file) using Docker Environment variables.

## With Environment Variables

:::warning
These environment variables and settings are subject to change since the game is still in beta.
:::

To use these settings you must set `DISABLE_GENERATE_ENGINE: false`.

Converting engine settings to environment variables follow the same principles (with some exceptions):

* All capital letters
* Split words by inserting an underscore
* Remove the single letter if the setting starts with one (like 'b')

For example:

* LanServerMaxTickRate -> LAN_SERVER_MAX_TICK_RATE
* bUseFixedFrameRate -> USE_FIXED_FRAME_RATE
* NetClientTicksPerSecond -> NET_CLIENT_TICKS_PER_SECOND

| Variable                      | Description                                                                                                     | Default Value | Allowed Value      |
|-------------------------------|-----------------------------------------------------------------------------------------------------------------|---------------|--------------------|
| DISABLE_GENERATE_ENGINE       | Disable the generation of the Engine.ini                                                                        | true          | Boolean            |
| LAN_SERVER_MAX_TICK_RATE      | Sets maximum ticks per second for LAN servers, higher rates result in smoother gameplay.                        | 120           | Integer            |
| NET_SERVER_MAX_TICK_RATE      | Sets maximum ticks per second for Internet servers, similarly ensuring smoother online gameplay.                | 120           | Integer            |
| CONFIGURED_INTERNET_SPEED     | Sets the assumed player internet speed in bytes per second. High value reduces chances of bandwidth throttling. | 104857600     | Integer (in bytes) |
| CONFIGURED_LAN_SPEED          | Sets the LAN speed, ensuring LAN players can utilize maximum network capacity.                                  | 104857600     | Integer (in bytes) |
| MAX_CLIENT_RATE               | Maximum data transfer rate per client for all connections, set to a high value to prevent data capping.         | 104857600     | Integer (in bytes) |
| MAX_INTERNET_CLIENT_RATE      | Specifically targets internet clients, allowing for high-volume data transfer without restrictions.             | 104857600     | Integer (in bytes) |
| SMOOTH_FRAME_RATE             | Enables the game engine to smooth out frame rate fluctuations for a more consistent visual experience.          | true          | Boolean            |
| SMOOTH_FRAME_RATE_UPPER_LIMIT | Sets a max target frame rate range for smoothing.                                                               | 120.000000    | Float              |
| SMOOTH_FRAME_RATE_LOWER_LIMIT | Sets a min target frame rate range for smoothing.                                                               | 30.000000     | Float              |
| USE_FIXED_FRAME_RATE          | Enables the use of a fixed frame rate                                                                           | false         | Boolean            |
| FIXED_FRAME_RATE              | Fixed frame rate                                                                                                | 120.000000    | Float              |
| MIN_DESIRED_FRAME_RATE        | Specifies a minimum acceptable frame rate, ensuring the game runs smoothly at least at this frame rate.         | 60.000000     | Float              |
| NET_CLIENT_TICKS_PER_SECOND   | Increases the update frequency for clients, enhancing responsiveness and reducing lag.                          | 120           | Integer            |

:::tip
While setting the server tickrate above to 120 fps will make some gameplay aspect smoother,
it won't fix rubber-banding and will tax your hardware significantly more.
:::
