---
sidebar_position: 2
title: Palworld Server Spieleinstellungen
description: Wie man die Palworld-Spieleinstellungen (PalWorldSettings.ini-Datei) mithilfe von Docker-Umgebungsvariablen ändert.
keywords: [Palworld, palworld dedicated server, Palworld PalWorldSettings.ini, palworld spiel einstellungen, PalWorldSettings.ini]
image: ../../assets/Palworld_Banner.jpg
sidebar_label: Spieleinstellungen
---
<!-- markdownlint-disable-next-line -->
# Palworld Server Spieleinstellungen

Wie man die Palworld-Spieleinstellungen (PalWorldSettings.ini-Datei) mithilfe von Docker-Umgebungsvariablen ändert.

## Mit Umgebungsvariablen

:::warning
Diese Umgebungsvariablen und Einstellungen können sich ändern, da das Spiel noch in der Beta-Phase ist.

Überprüfen Sie die [offizielle Webseite für unterstützte Parameter.](https://tech.palworldgame.com/optimize-game-balance)
:::

Um Servereinstellung in Umgebungsvariablen zu konvertieren müssen folgende Regeln eingehalten werden:

* alle Buchstaben groß schreiben
* Wörter durch Einfügen eines Unterstrichs trennen
* falls die Einstellung mit einem einzelnen Buchstaben beginnt, muss dieser entfernt werden (z.B. 'b')

Beispiele:

* Difficulty -> DIFFICULTY
* PalSpawnNumRate -> PAL_SPAWN_NUM_RATE
* bIsPvP -> IS_PVP

| Variable                                  | Beschreibung                                                   | Standardwert                                                                                 | Erlaubte Werte                         |
|-------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------|
| DIFFICULTY                                | Spiel-Schwierigkeitsgrad                                       | None                                                                                         | `None`,`Normal`,`Difficult`            |
| DAYTIME_SPEEDRATE                         | Tageszeit-Geschwindigkeit - Größerer Wert bedeutet kürzere Tage | 1.000000                                                                                     | Float                                  |
| NIGHTTIME_SPEEDRATE                       | Nachtszeit-Geschwindigkeit - Größerer Wert bedeutet kürzere Nächte | 1.000000                                                                                     | Float                                  |
| EXP_RATE                                  | EXP-Sammelrate                                                 | 1.000000                                                                                     | Float                                  |
| PAL_CAPTURE_RATE                          | Pal-Fangrate                                                  | 1.000000                                                                                     | Float                                  |
| PAL_SPAWN_NUM_RATE                        | Pal-Erscheinungsrate                                           | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_ATTACK                    | Schadensmultiplikator von Pals                                | 1.000000                                                                                     | Float                                  |
| PAL_DAMAGE_RATE_DEFENSE                   | Verteidigungsmultiplikator von Pals                                 | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_ATTACK                 | Schadensmultiplikator von Spielern                            | 1.000000                                                                                     | Float                                  |
| PLAYER_DAMAGE_RATE_DEFENSE                | Verteidigungsmultiplikator von Spielern                              | 1.000000                                                                                     | Float                                  |
| PLAYER_STOMACH_DECREASE_RATE              | Rate der Hungerabnahme von Spielern                           | 1.000000                                                                                     | Float                                  |
| PLAYER_STAMINA_DECREASE_RATE              | Rate der Ausdauerreduktion von Spielern                       | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE                 | Rate der automatischen HP-Regeneration von Spielern           | 1.000000                                                                                     | Float                                  |
| PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP        | Rate der Schlaf-HP-Regeneration von Spielern                  | 1.000000                                                                                     | Float                                  |
| PAL_STOMACH_DECREASE_RATE                 | Rate der Hungerabnahme von Pals                              | 1.000000                                                                                     | Float                                  |
| PAL_STAMINA_DECREASE_RATE                 | Rate der Ausdauerreduktion von Pals                          | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE                    | Rate der automatischen HP-Regeneration von Pals              | 1.000000                                                                                     | Float                                  |
| PAL_AUTO_HP_REGEN_RATE_IN_SLEEP           | Rate der Schlaf-HP-Regeneration von Pals (im Palbox)         | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DAMAGE_RATE                  | Schadensmultiplikator für Strukturen                         | 1.000000                                                                                     | Float                                  |
| BUILD_OBJECT_DETERIORATION_DAMAGE_RATE    | Strukturverschlechterungsrate                                 | 1.000000                                                                                     | Float                                  |
| COLLECTION_DROP_RATE                      | Multiplikator für sammelbare Gegenstände                      | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_HP_RATE                 | Multiplikator für HP sammelbarer Objekte                      | 1.000000                                                                                     | Float                                  |
| COLLECTION_OBJECT_RESPAWN_SPEED_RATE      | Respawn-Intervall sammelbarer Objekte - Je kleiner die Zahl, desto schneller die Regeneration | 1.000000                                                                                     | Float                                  |
| ENEMY_DROP_ITEM_RATE                      | Multiplikator für fallengelassene Gegenstände                 | 1.000000                                                                                     | Float                                  |
| DEATH_PENALTY                             | `None`: Keine `Item`: Wirft Gegenstände außer Ausrüstung ab `ItemAndEquipment`: Wirft alle Gegenstände ab `All`: Wirft alle PALs und alle Gegenstände ab.                                    | All                                                                                          | `None`,`Item`,`ItemAndEquipment`,`All` |
| ENABLE_PLAYER_TO_PLAYER_DAMAGE            | Erlaubt Spielern, anderen Spielern Schaden zuzufügen          | False                                                                                        | Boolean                                |
| ENABLE_FRIENDLY_FIRE                      | Erlaubt Friendly Fire                                    | False                                                                                        | Boolean                                |
| ENABLE_INVADER_ENEMY                      | Eindringlinge aktivieren                                      | True                                                                                         | Boolean                                |
| ACTIVE_UNKO                               | UNKO aktivieren (?)                                           | False                                                                                        | Boolean                                |
| ENABLE_AIM_ASSIST_PAD                     | Aktiviert Aim Assist für Controller                          | True                                                                                         | Boolean                                |
| ENABLE_AIM_ASSIST_KEYBOARD                | Aktiviert Aim Assist für Tastatur                             | False                                                                                        | Boolean                                |
| DROP_ITEM_MAX_NUM                         | Maximale Anzahl von Drops in der Welt                         | 3000                                                                                         | Integer                                |
| DROP_ITEM_MAX_NUM_UNKO                    | Maximale Anzahl von UNKO-Drops in der Welt                    | 100                                                                                          | Integer                                |
| BASE_CAMP_MAX_NUM                         | Maximale Anzahl von Basislagern                               | 128                                                                                          | Integer                                |
| BASE_CAMP_WORKER_MAX_NUM                  | Maximale Anzahl von Arbeitern                                 | 15                                                                                           | Integer                                |
| DROP_ITEM_ALIVE_MAX_HOURS                 | Zeit, bis Gegenstände in Stunden verschwinden                | 1.000000                                                                                     | Float                                  |
| AUTO_RESET_GUILD_NO_ONLINE_PLAYERS        | Gilde automatisch zurücksetzen, wenn keine Spieler online sind | False                                                                                        | Bool                                   |
| AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS   | Zeit zum automatischen Zurücksetzen der Gilde, wenn keine Spieler online sind | 72.000000                                                                                    | Float                                  |
| GUILD_PLAYER_MAX_NUM                      | Maximale Spieleranzahl der Gilde                              | 20                                                                                           | Integer                                |
| PAL_EGG_DEFAULT_HATCHING_TIME             | Zeit (h), um riesiges Ei auszubrüten                          | 72.000000                                                                                    | Float                                  |
| WORK_SPEED_RATE                           | Arbeitsgeschwindigkeitsmultiplikator                          | 1.000000                                                                                     | Float                                  |
| IS_MULTIPLAY                              | Mehrspieler aktivieren                                         | False                                                                                        | Boolean                                |
| IS_PVP                                    | PVP aktivieren                                                 | False                                                                                        | Boolean                                |
| CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP | Erlaubt Spielern anderer Gilden, Todesstrafe-Gegenstände aufzuheben | False                                                                                        | Boolean                                |
| ENABLE_NON_LOGIN_PENALTY                  | Nicht-Anmeldestrafe aktivieren                                | True                                                                                         | Boolean                                |
| ENABLE_FAST_TRAVEL                        | Schnellreisen aktivieren                                       | True                                                                                         | Boolean                                |
| IS_START_LOCATION_SELECT_BY_MAP           | Startposition per Karte auswählen                             | True                                                                                         | Boolean                                |
| EXIST_PLAYER_AFTER_LOGOUT                 | Spieler behalten nach dem Ausloggen umschalten                | False                                                                                        | Boolean                                |
| ENABLE_DEFENSE_OTHER_GUILD_PLAYER         | Verteidigung gegen Spieler anderer Gilden ermöglichen         | False                                                                                        | Boolean                                |
| COOP_PLAYER_MAX_NUM                       | Maximale Anzahl von Spielern in einer Gilde                    | 4                                                                                            | Integer                                |
| REGION                                    | Region                                                         |                                                                                              | String                                 |
| USEAUTH                                   | Authentifizierung verwenden                                    | True                                                                                         | Boolean                                |
| BAN_LIST_URL                              | Welche Sperrliste verwenden                                    | [https://api.palworldgame.com/api/banlist.txt](https://api.palworldgame.com/api/banlist.txt) | string                                 |
| SHOW_PLAYER_LIST                          | Aktiviert die Anzeige der Spieler                              | True                                                                                         | Boolean                                |
| TARGET_MANIFEST_ID | Legt die Spielversion entsprechend der Manifest-ID aus dem Steam-Download-Depot fest. | | Siehe [Manifest IDs](https://palworld-server-docker.loef.dev/de/guides/pinning-game-version) |
| ENABLE_PLAYER_LOGGING      | Aktiviert das Protokollieren und das Ankündigen, wenn Spieler dem Spiel beitreten und es verlassen. | true         | Boolean |
| PLAYER_LOGGING_POLL_PERIOD          | Abfrageintervall (in Sekunden), um zu überprüfen, ob Spieler dem Spiel beigetreten sind oder es verlassen haben. | 5                      | !0 |

### Manuell

Beim Start des Servers wird eine `PalWorldSettings.ini`-Datei im folgenden Pfad erstellt:
`<mount_folder>/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

Bitte beachten Sie, dass die ENV-Variablen immer die Änderungen an `PalWorldSettings.ini` überschreiben.

:::warning
Änderungen können nur an `PalWorldSettings.ini` vorgenommen werden, während der Server ausgeschaltet ist.

Alle Änderungen die vorgenommen werden, während der Server aktiv ist, werden überschrieben wenn der Server gestoppt wird.
:::

Für eine detailliertere Liste von Servereinstellungen gehen Sie zu: [Palworld Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini)

Für ausführlichere Erklärungen zu Servereinstellungen gehen Sie zu: [shockbyte](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html)
