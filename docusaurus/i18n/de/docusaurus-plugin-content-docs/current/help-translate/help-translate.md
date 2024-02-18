---
sidebar_position: 99
---

# Hilfe bei der Übersetzung der Dokumentation

Ich bin immer auf der Suche nach Personen, die die Dokumentation in verschiedene Sprachen übersetzen möchten. Wenn Sie
helfen möchten, verwenden Sie diese Anleitung, um loszulegen!

## So können Sie helfen

## Voraussetzungen

* `nodejs` installiert
* `npm` installiert
* `git` installiert

## Einrichten von i18n

<!-- markdownlint-disable-next-line -->
* Forken Sie das [https://github.com/thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker)-Repository
* Klonen Sie Ihren erstellten Fork.
* Navigieren Sie zum `docusaurus`-Ordner.<!-- markdownlint-disable-next-line -->
* Fügen Sie Ihre Sprache zur i18n-Konfiguration ab Zeile 34 im [docusaurus.config.js](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docusaurus/docusaurus.config.js) hinzu.
* Führen Sie folgenden Befehl aus: `npm run write-translations -- --locale <locale code>`

:::info
Nach Ausführung von `npm run write-translations -- --locale <locale code>` wird ein neuer Ordner im `i18n`-Ordner erstellt.
:::

* Entfernen Sie den Ordner `docusaurus-plugin-content-blog`
* Erstellen Sie einen Ordner `current` im `docusaurus-plugin-content-docs`
* Kopieren Sie den Inhalt von `docs` in den Ordner `current`
* Beginnen Sie mit der Übersetzung!

## Testen der Übersetzung

Wenn Sie mit der Übersetzung fertig sind, können Sie diese testen, indem Sie Folgendes tun:

* Navigieren Sie zum `docusaurus`-Ordner
* Führen Sie folgenden Befehl aus: `npm start -- --locale <locale code>`

## Einreichung eines Pull-Requests
<!-- markdownlint-disable-next-line -->
* Gehen Sie zu [https://github.com/thijsvanloef/palworld-server-docker/compare](https://github.com/thijsvanloef/palworld-server-docker/compare)
* Wählen Sie Ihr Repository/Ihren Branch aus
* Drücken Sie: `Pull-Request erstellen`
