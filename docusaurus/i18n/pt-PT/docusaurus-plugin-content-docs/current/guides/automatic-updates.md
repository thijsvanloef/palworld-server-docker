---
sidebar_position: 5
---

# Atualizações Automáticas

## Configurar atualização servidor automática com o CRON

Para poder utilizar os reinícios automáticos com este servidor,
as seguintes variáveis de ambiente **têm** de ser definidas como `true`:

- `RCON_ENABLED`
- `UPDATE_ON_BOOT`

:::warning

Se a reinicialização do docker não estiver definida como `always` ou `unless-stopped`,
o servidor será desligado e precisará ser reiniciado manualmente.

Os ficheiros de exemplo docker run command e docker compose em [Configuração rápida](/pt-PT/) utilizam esta definição.

:::

| Variable                    | Info                                                                        | Default Values | Allowed Values                                                                                                    |
| --------------------------- | --------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------- |
| AUTO_UPDATE_CRON_EXPRESSION | Frequência dos updates automáticos                                          | 0 \* \* \* \*  | Precisa de uma expressão do CRON. Ver [Configurar atualização servidor com CRON](/pt-PT/guides/automatic-updates) |
| AUTO_UPDATE_ENABLED         | Permite cópias de segurança automáticas                                     | false          | true/false                                                                                                        |
| AUTO_UPDATE_WARN_MINUTES    | Tempo de espera para atualizar o servidor, depois de informar os jogadores. | 30             | !0                                                                                                                |

:::tip
Esta imagem usa o Supercronic para os crons.
Consultar [supercronic](https://github.com/aptible/supercronic#crontab-format)
ou [Crontab Generator](https://crontab-generator.org).
:::

Definir `AUTO_UPDATE_CRON_EXPRESSION` para alterar o horário definido,
por defeito é todas as noites à meia-noite de acordo com o fuso horário definido com `TZ`
