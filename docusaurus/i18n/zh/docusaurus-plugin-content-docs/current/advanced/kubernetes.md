---
sidebar_position: 1
---

# Kubernetes

部署此容器到 Kubernetes 所需的所有文件都位于 [k8s folder](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s)。

## 在 Kubernetes 中设置 Palworld

使用以下命令在 Kubernetes 中设置 Palworld 容器：

* `kubectl apply -f pvc.yaml`
* `kubectl apply -f configmap.yaml`
* `kubectl apply -f secret.yaml`
* `kubectl apply -f service.yaml`
* `kubectl apply -f deployment.yaml`

## 使用 Helm Chart

官方 Helm Chart 可在单独的存储库, [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart) 找到。
