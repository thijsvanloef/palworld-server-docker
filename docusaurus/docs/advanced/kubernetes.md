---
sidebar_position: 2
title: Palworld Dedicated Server on Kubernetes
description: How to run Palworld Dedicated server on Kubernetes.
keywords: [Palworld, palworld dedicated server, Palworld Dedicated server kubernetes]
image: ../assets/Palworld_Banner.jpg
sidebar_label: Kubernetes
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server on Kubernetes

How to run Palworld Dedicared server on Kubernetes.

## Setup Palworld in kubernetes

All files you will need to deploy this container to kubernetes are located in the [k8s folder](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

Use the following commands to setup this Palworld container in Kubernetes:

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## Using helm chart

The official helm chart can be found in a seperate repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
