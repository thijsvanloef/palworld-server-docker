---
sidebar_position: 2
---

# Kubernetes

Todos os ficheiros necessários para implementar o contentor Kubernetes estão localizados na diretoria [k8s](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s).

## Configurar o Palworld no kubernetes

Use os seguintes comandos para configurar o contentor Kubernetes:

- `kubectl apply -f pvc.yaml`
- `kubectl apply -f configmap.yaml`
- `kubectl apply -f secret.yaml`
- `kubectl apply -f service.yaml`
- `kubectl apply -f deployment.yaml`

## Utilizando Helm Chart

A documentação oficial do helm chart pode ser encontrado no seguinte repositório: [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
