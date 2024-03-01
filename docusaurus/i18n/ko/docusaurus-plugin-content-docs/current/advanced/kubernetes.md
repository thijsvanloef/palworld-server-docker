---
sidebar_position: 2
---

# 쿠버네티스

쿠버네티스에서 이 컨테이너를 배포하는 데 필요한 모든 파일은 [k8s 폴더](https://github.com/thijsvanloef/palworld-server-docker/tree/main/k8s)에 있습니다.

## 쿠버네티스에서 Palworld 설정하기

다음 명령어를 사용하여 쿠버네티스에서 Palworld 컨테이너를 설정합니다:

- `kubectl apply -f pvc.yaml`
- `kubectl apply -f configmap.yaml`
- `kubectl apply -f secret.yaml`
- `kubectl apply -f service.yaml`
- `kubectl apply -f deployment.yaml`

## Helm 차트 사용하기

공식 Helm 차트는 별도의 저장소에서 찾을 수 있습니다: [palworld-server-chart](https://github.com/Twinki14/palworld-server-chart)
