---
sidebar_position: 2
---

# Kubernetes

Alle Dateien die Sie benötigen, um diesen Container in Kubernetes bereitzustellen befinden sich im [k8s-Ordner](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

## Einrichten von Palworld in Kubernetes

Verwenden Sie die folgenden Befehle, um diesen Palworld-Container in Kubernetes einzurichten:

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## Verwendung des Helm-Charts

Das offizielle Helm-Chart befindet sich in einem separaten Repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
