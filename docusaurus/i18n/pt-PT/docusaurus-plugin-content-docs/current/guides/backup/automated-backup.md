---
sidebar_position: 3
---

# Configurar cópias de segurança automáticas

O servidor é automaticamente copiado todas as noites à meia-noite, de acordo com o fuso horário definido com `TZ`

Definir `BACKUP_ENABLED` para ativar ou desativar as cópias de segurança automáticas (a predefinição é activada)

`BACKUP_CRON_EXPRESSION` é uma expressão cron, numa expressão cron define-se um intervalo para a execução de tarefas.

:::tip
Esta imagem usa o Supercronic para os crons.
Consultar [supercronic](https://github.com/aptible/supercronic#crontab-format)
ou [Crontab Generator](https://crontab-generator.org).
:::

Definir `BACKUP_CRON_EXPRESSION` para alterar o horário definido

**Exemplo**: Se `BACKUP_CRON_EXPRESSION` for `0 2 * * *`,
o script da cópia de segurança será executado todos os dias ás 2:00 AM
