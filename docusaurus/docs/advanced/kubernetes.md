---
sidebar_position: 2
---

# Kubernetes

All files you will need to deploy this container to kubernetes are located in the [k8s folder](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

## Setup Palworld in kubernetes

Use the following commands to setup this Palworld container in Kubernetes:

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## Using helm chart

The official helm chart can be found in a seperate repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
