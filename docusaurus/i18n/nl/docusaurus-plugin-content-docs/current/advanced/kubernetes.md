---
sidebar_position: 2
---

# Kubernetes

Alle bestanden die u nodig hebt om deze container in Kubernetes te starten, bevinden zich in de [k8s folder](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

## Installeer Palworld in Kubernetes

Gebruik de volgende commando's om deze Palworld-container in Kubernetes in te stellen:

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## De helm chart gebruiken

De officiële helm chart is te vinden in een aparte repository, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
