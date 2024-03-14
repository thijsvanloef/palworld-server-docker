---
sidebar_position: 2
title: Palworld Dedicated Server in Kubernetes
description: Wie man den Palworld Dedicated Server mit Kubernetes betreibt.
keywords: [Palworld, palworld dedicated server, Palworld Dedicated server kubernetes]
image: ../assets/Palworld_Banner.jpg
sidebar_label: Kubernetes
---
<!-- markdownlint-disable-next-line -->
# Palworld Dedicated Server in Kubernetes

Wie man den Palworld Dedicated Server mit Kubernetes betreibt.

## Einrichten von Palworld in Kubernetes

Alle Dateien die Sie benötigen, um diesen Container mit Kubernetes bereitzustellen befinden sich im [k8s-Ordner](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

Verwenden Sie die folgenden Befehle, um diesen Palworld-Container in Kubernetes einzurichten:

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## Verwendung des Helm-Charts

Das offizielle Helm-Chart befindet sich in einem separaten Repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
