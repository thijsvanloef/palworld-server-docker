# Setup Palworld in kubernetes

Please make sure to configure the configmap.yaml and secret.yaml files to your needs before applying the configuration.

[Read more about the configuration options here.](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings)

Files:

* pvc.yaml
* configmap.yaml
* secret.yaml
* service.yaml
* statefulset.yaml

Use the following command to setup this Palworld container in Kubernetes:

`kubectl apply -f .`
