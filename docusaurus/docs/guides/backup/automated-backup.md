---
sidebar_position: 3
---

# Configure automated backups

The server is automatically backed up everynight at midnight according to the timezone set with TZ

Set BACKUP_ENABLED enable or disable automatic backups (Default is enabled)

BACKUP_CRON_EXPRESSION is a cron expression, in a Cron-Expression you define an interval for when to run jobs.

:::tip
This image uses Supercronic for crons
see [supercronic](https://github.com/aptible/supercronic#crontab-format)
or [Crontab Generator](https://crontab-generator.org).
:::

Set BACKUP_CRON_EXPRESSION to change the default schedule.

**Example Usage**: If BACKUP_CRON_EXPRESSION to `0 2 * * *`, the backup script will run every day at 2:00 AM.
