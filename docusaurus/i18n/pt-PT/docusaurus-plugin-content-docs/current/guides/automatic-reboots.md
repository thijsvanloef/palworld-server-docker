---
sidebar_position: 4
---

# Reínicio Automático

## Configurar reinício servidor automático com CRON

Para poder utilizar os reinícios automáticos com este servidor,
as seguintes variáveis de ambiente **têm** de ser definidas como `true`:

- `RCON_ENABLED`

:::warning

Se a reinicialização do docker não estiver definida como `always` ou `unless-stopped`,
o servidor será desligado e precisará ser reiniciado manualmente.

Os ficheiros de exemplo docker run command e docker compose em [Configuração rápida](/pt-PT/) utilizam esta definição.

:::

| Variável                           | Descrição                                                                   | Valor Predefinido | Valores Aceites                                                                                                  |
| ---------------------------------- | --------------------------------------------------------------------------- | ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| AUTO_REBOOT_CRON_EXPRESSION        | Frequência de reinicio de servidor automático                               | 0 0 \* \* \*      | Precisa de uma expressão do CRON. Ver - [Configurar reinício servidor com CRON](/pt-PT/guides/automatic-reboots) |
| AUTO_REBOOT_ENABLED                | Permite reiniciar servidor automaticamente                                  | false             | true/false                                                                                                       |
| AUTO_REBOOT_WARN_MINUTES           | Tempo de espera para reiniciar o servidor, depois de informar os jogadores. | 5                 | !0                                                                                                               |
| AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE | Reiniciar servidor mesmo que hajam jogadores online.                        | false             | true/false                                                                                                       |

:::tip
Esta imagem usa o Supercronic para os crons.
Consultar [supercronic](https://github.com/aptible/supercronic#crontab-format)
ou [Crontab Generator](https://crontab-generator.org).
:::

Definir `AUTO_REBOOT_CRON_EXPRESSION` para alterar o horário definido,
por defeito é todas as noites à meia-noite de acordo com o fuso horário definido com `TZ`
