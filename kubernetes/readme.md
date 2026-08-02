# Setup Palworld in kubernetes

Please make sure to configure the configmap.yaml and secret.yaml files to your needs before applying the configuration.

The default manifests create separate persistent volumes for Palworld data, UE4SS mods, and `.pak` mods.
To use UE4SS, set `UE4SS_ENABLED: "true"` in `configmap.yaml` on an amd64 node, then add `mods.txt` and mod folders to the mods PVC.
Drop `.pak` files into the paks PVC for resource mods that don't need UE4SS.

[Read more about the configuration options here.](https://palworld-server-docker.loef.dev/getting-started/configuration/server-settings)

Files:

* pvc.yaml
* configmap.yaml
* secret.yaml
* service.yaml
* statefulset.yaml

Use the following command to setup this Palworld container in Kubernetes:

`kubectl apply -f .`
