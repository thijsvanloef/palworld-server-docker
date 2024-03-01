---
sidebar_position: 3
---

# Engine-Einstellungen

Ändern der Engine-Einstellungen mit Umgebungsvariablen.

## Mit Umgebungsvariablen

:::warning
Diese Umgebungsvariablen und Einstellungen können sich ändern, da das Spiel sich noch in der Beta-Phase befindet.
:::

Um diese Einstellungen zu nutzen, musst du `DISABLE_GENERATE_ENGINE: false` setzen.

Um Engine-Einstellungen in Umgebungsvariablen zu konvertieren müssen folgende Regeln eingehalten werden:

* alle Buchstaben groß schreiben
* Wörter durch Einfügen eines Unterstrichs trennen
* falls die Einstellung mit einem einzelnen Buchstaben beginnt, muss dieser entfernt werden (z.B. 'b')

Beispiel:

* LanServerMaxTickRate -> LAN_SERVER_MAX_TICK_RATE
* bUseFixedFrameRate -> USE_FIXED_FRAME_RATE
* NetClientTicksPerSecond -> NET_CLIENT_TICKS_PER_SECOND

|           Variable            |                                                                        Beschreibung                                                                         | Standardwert |   Erlaubter Wert    |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ------------------- |
| DISABLE_GENERATE_ENGINE       | Deaktiviert die Generierung der Engine.ini                                                                                                                  | true         | Boolean             |
| LAN_SERVER_MAX_TICK_RATE      | Setzt die maximale Anzahl an Ticks pro Sekunde für LAN-Server. Höhere Raten sorgen für ein flüssigeres Gameplay.                                            | 120          | Integer             |
| NET_SERVER_MAX_TICK_RATE      | Setzt die maximale Anzahl an Ticks pro Sekunde für dedizierte Server, um ein ebenso flüssiges Online-Spiel zu gewährleisten.                                | 120          | Integer             |
| CONFIGURED_INTERNET_SPEED     | Setzt die angenommene Internetgeschwindigkeit der Spieler in Bytes pro Sekunde. Ein hoher Wert reduziert die Wahrscheinlichkeit von Bandbreiten-Drosselung. | 104857600    | Integer (in Bytes)  |
| CONFIGURED_LAN_SPEED          | Setzt die LAN-Geschwindigkeit, um sicherzustellen, dass LAN-Spieler die maximale Netzwerkkapazität nutzen können.                                           | 104857600    | GInteger (in Bytes) |
| MAX_CLIENT_RATE               | Maximale Datenübertragungsrate pro Client für alle Verbindungen, um eine Datenbeschränkung zu verhindern.                                                   | 104857600    | Integer (in Bytes)  |
| MAX_INTERNET_CLIENT_RATE      | Zielt speziell auf Internet-Clients ab, um eine uneingeschränkte Datenübertragung in großem Umfang zu ermöglichen.                                          | 104857600    | Integer (in Bytes)  |
| SMOOTH_FRAME_RATE             | Ermöglicht es der Spiel-Engine, Schwankungen der Bildrate auszugleichen, für ein konsistenteres visuelles Erlebnis.                                         | true         | Boolean             |
| SMOOTH_FRAME_RATE_UPPER_LIMIT | Setzt einen maximalen Ziel-Bildratenbereich für die Frame-Glättung fest.                                                                                    | 120.000000   | Float               |
| SMOOTH_FRAME_RATE_LOWER_LIMIT | Setzt einen minimalen Ziel-Bildratenbereich für die Frame-Glättung fest.                                                                                    | 30.000000    | Float               |
| USE_FIXED_FRAME_RATE          | Aktiviert die Verwendung einer festen Bildrate                                                                                                              | false        | Boolean             |
| FIXED_FRAME_RATE              | Feste Bildrate                                                                                                                                              | 120.000000   | Float               |
| MIN_DESIRED_FRAME_RATE        | Legt eine minimale akzeptable Bildrate fest, um sicherzustellen, dass das Spiel zumindest mit dieser Bildrate flüssig läuft.                                | 60.000000    | Float               |
| NET_CLIENT_TICKS_PER_SECOND   | Erhöht die Update-Frequenz für Clients, um die Reaktionsfähigkeit zu verbessern und die Verzögerung zu reduzieren.                                          | 120          | Integer             |

:::tip
Das Erhöhen der Server-Tickrate auf über 120 fps macht zwar einige Gameplay-Aspekte flüssiger,
behebt jedoch keine Ruckler und belastet deine Hardware erheblich mehr.
:::
