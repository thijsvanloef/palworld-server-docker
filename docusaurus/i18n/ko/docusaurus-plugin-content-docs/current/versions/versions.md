---
sidebar_position: 4
---

# 버전

이 페이지는 Docker 이미지 태그의 버전 관리 방법을 보여줍니다.

## 버전 구성 방식

`latest` 이미지와 `dev` 이미지를 제외한 모든 이미지는 [Semver](https://semver.org/)에 따라 태그가 지정됩니다.

- `latest`: Always the latest release
- `dev`: Latest in progress version (Used only for testing)
- `vX`: Latest Major version
- `vX.X`: Latest Minor version
- `vX.X.X`: Specific Version
