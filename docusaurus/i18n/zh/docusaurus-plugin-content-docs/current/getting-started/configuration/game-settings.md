---
sidebar_position: 2
---

# 游戏设置

## 环境变量

:::warning
由于游戏仍处于测试阶段，这些环境变量和设置可能会发生变化。

请查看 [官方网页以获取支持的参数](https://tech.palworldgame.com/optimize-game-balance)。
:::

将服务器设置转换为环境变量遵循相同的原则（有一些例外情况）：

* 所有大写字母
* 通过插入下划线来拆分单词
* 如果设置以单个字母开头，则删除该字母（如 'b'）

例如：

* Difficulty -> DIFFICULTY
* PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
* bIsPvP -> IS_PVP

| 环境变量                                      | 描述                                                                                       | 默认值                                                                                          | 可用值                                    |
|-------------------------------------------|------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | 游戏难度                                                                                     | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | 白天流逝速度 - 更小的值代表更快的白天                                                                     | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | 夜晚流逝速度 - 更小的值代表更快的夜晚                                                                     | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | 经验值获取比率                                                                                  | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | 帕鲁捕捉比率                                                                                   | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | 帕鲁刷新比率                                                                                   | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | 多人游戏中来自帕鲁的伤害比率                                                                           | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | 多人游戏中对帕鲁的伤害比率                                                                            | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | 多人游戏中来自玩家的伤害比率                                                                           | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | 多人游戏中对玩家的伤害比率                                                                            | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | 玩家饱食度流逝比率                                                                                | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | 玩家体力减少比率                                                                                 | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | 玩家生命值自动恢复比率                                                                              | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | 玩家睡眠时生命值自动恢复比率                                                                           | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | 帕鲁饱食度流逝比率                                                                                | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | 帕鲁体力减少比率                                                                                 | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | 帕鲁生命值自动恢复比率                                                                              | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | 帕鲁生命值自动恢复比率（在终端盒中）                                                                       | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | 多人游戏中对建筑结构的伤害比率                                                                          | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | 建筑结构的自然劣化比率                                                                              | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | 多人游戏中道具掉落比率                                                                              | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | 多人游戏中对象生命比率                                                                              | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | 可获取对象的刷新速度 - 更小的值代表更快的刷新速度                                                               | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | 多人游戏中敌人掉落道具的比率                                                                           | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | 死亡惩罚 None: 没有死亡惩罚 Item: 更高几率掉落道具 ItemAndEquipment: 掉落所有道具 All: 掉落所有道具和帕鲁 | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | 允许 PVP 伤害                                                                                | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | 允许队友伤害                                                                                   | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | 启用营地入侵                                                                                   | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | 启用 UNKO (?)                                                                              | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | 启用控制器辅助瞄准                                                                                | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | 启用键盘辅助瞄准                                                                                 | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | 世界中最大掉落物品数量                                                                              | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | 世界中最大 UNKO 掉落数量                                                                          | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | 最大营地数量                                                                                   | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAX_NUM                  | 营地最大工位数量                                                                                 | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | 掉落物品移除时间                                                                                 | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | 无玩家在线时自动重置公会                                                                             | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | 无玩家在线时自动重置公会的时间                                                                          | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | 公会最大成员数量                                                                                 | 20                                                                                           | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | 孵化巨大型帕鲁蛋所需消耗时间（小时）                                                                       | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | 多人游戏中的工作速度比率                                                                             | 1.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | 启用多人游戏                                                                                   | False                                                                                        | Boolean                                |
| IS_PVP                                    | 启用 PVP                                                                                   | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | 允许玩家拾取其他公会玩家的掉落物品或死亡惩罚                                                                   | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | 启用无登录惩罚                                                                                  | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | 启用快速旅行                                                                                   | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | 启用出生地选择                                                                                  | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | 玩家注销时是否删除玩家                                                                              | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | 允许防御其他公会玩家                                                                               | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | 工会中的最大玩家数量                                                                               | 4                                                                                            | Integer                                |
| REGION                                    | 地区                                                                                       |                                                                                              | String                                 |
| USEAUTH                                   | 使用授权验证                                                                                   | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | 使用禁用列表                                                                                   | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |

### 手动设置

当服务器启动时，将在以下位置创建一个 `PalWorldSettings.ini` 文件： `<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

请注意，环境变量始终会覆盖对 `PalWorldSettings.ini` 的更改。

:::warning
只有在服务器关闭时才能对 `PalWorldSettings.ini` 进行更改。

如果在服务器正在运行时进行任何更改，则在服务器停止时将被覆盖。
:::

要获取更详细的服务器设置列表，请访问： [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

要获取更详细的服务器设置解释，请访问： [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)
