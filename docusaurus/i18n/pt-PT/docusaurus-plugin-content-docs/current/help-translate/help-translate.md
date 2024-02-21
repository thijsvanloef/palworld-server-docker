---
sidebar_position: 99
---

# Ajuda a traduzir

Precisamos sempre de pessoas para ajudar a traduzir a documentação para diferente linguagens.

Se quiseres ajudar esta página vai te ajudar a começar!

## Como traduzir

## Pré-requisitos

- `nodejs` instalado
- `npm` instalado
- `git` instalado

## Configurar i18n

<!-- markdownlint-disable-next-line -->

- Fork o repositório [https://github.com/thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker)
- Clonar o teu fork.
- Navegar até á diretoria `docusaurus`.<!-- markdownlint-disable-next-line -->
- Adicionar a tua linguagem á configuração i18n [docusaurus.config.js](https://github.com/thijsvanloef/palworld-server-docker/blob/main/docusaurus/docusaurus.config.js)
- Executar: `npm run write-translations -- --locale <locale code>`

:::info
Após executar `npm run write-translations -- --locale <locale code>` vai aparecer uma nova pasta na diretoria `i18n`
:::

- Remover a diretoria `docusaurus-plugin-content-blog`
- Criar a diretoria `current` dentro da diretoria `docusaurus-plugin-content-docs`
- Copiar o conteúdo de `docs` para a diretoria `current`
- Começar a traduzir!

## Testar a tradução

Se já acabaste de traduzir podes testar a versão do site fazendo o seguite:

- Navegar até á diretoria `docusaurus`
- Executar: `npm start -- --locale <locale code>`

## Abrir um PR (Pull Request)

<!-- markdownlint-disable-next-line -->

- Ir para [https://github.com/thijsvanloef/palworld-server-docker/compare](https://github.com/thijsvanloef/palworld-server-docker/compare)
- Selecionar o teu repositório/ramo
- Carregar em: `Create pull request`
