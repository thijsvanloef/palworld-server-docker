# Example CronJob to Reboot Server Daily (9:30am UTC)

Use the following commands to setup the cron job in the namespace palworld:

* `kubectl apply -f cm.yaml`
* `kubectl apply -f role.yaml`
* `kubectl apply -f rolebinding.yaml`
* `kubectl apply -f serviceaccount.yaml`
* `kubectl apply -f cronjob.yaml`
