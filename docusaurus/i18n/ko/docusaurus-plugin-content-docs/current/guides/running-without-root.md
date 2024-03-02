---
sidebar_position: 6
---

# 루트권한 없이 실행하기

해당 항목은 고급사용자를 위한 항목입니다.

해당 컨테이너는 [기본사용자 덮어씌우기](https://docs.docker.com/engine/reference/run/#user)가 가능합니다. 해당 이미지의 기본사용자는 루트입니다.

사용자가 유저와 그룹을 설정하기 떄문에 `PUID`와 `PGID`가 무시됩니다.

UID를 찾으려면: `id -u`를 사용합니다.
GID를 찾으려면: `id -g`를 사용합니다.

반드시 유저를 `NUMBERICAL_UID:NUMBERICAL_GID`와 같이 설정하셔야합니다.

아래는 UID를 1000으로 GID를 1001로 가정해 작성된 예제문입니다.

* docker run에서 `--user 1000:1001 \`를 마지막 줄위에 추가하세요.
* docker compose에서 `user: 1000:1001`를 포트설정위에 추가하세요.

만약 다른 UID/GID를 사용해 실행하려면 디렉토리의 소유권을 변경해야합니다: `chown UID:GID palworld/` 또는 모든 계정의 권한를 수정하셔야합니다: `chmod o=rwx palworld/`
