---
sidebar_position: 99
---

# Help translate the docs

I'm always looking for people to translate the documentation into different languages.
If you want to help use this guide to help you get started!

## How to translate

## Prerequisites

* `nodejs` installed
* `npm` installed
* `git` installed

## Setup i18n

<!-- markdownlint-disable-next-line -->
* Fork the [https://github.com/thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker) repository
* Clone your created fork.
* Navigate to the `docusaurus` folder.<!-- markdownlint-disable-next-line -->
* Add your locale to the i18n config on line in the [docusaurus.config.js](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docusaurus/docusaurus.config.js)
* Run: `npm run write-translations -- --locale <locale code>`

:::info
After running `npm run write-translations -- --locale <locale code>` a new folder will be created in the `i18n` folder
:::

* Remove the `docusaurus-plugin-content-blog` folder
* Create a `current` folder inside `docusaurus-plugin-content-docs`
* Copy the contents of `docs` to the `current` folder
* Start translating!

## Testing the translation

If you are done translating you can test that version of the site by doing the following:

* Navigate to the `docusaurus` folder
* Run: `npm start -- --locale <locale code>`

## Opening a Pull request
<!-- markdownlint-disable-next-line -->
* Go to [https://github.com/thijsvanloef/palworld-server-docker/compare](https://github.com/thijsvanloef/palworld-server-docker/compare)
* Select your repository/branch
* Press: `Create pull request`
