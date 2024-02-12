---
sidebar_position: 2
---

# 백업 복원하기

## 명령어로 백업 복원하기

백업을 복원하려면 다음 명령을 사용합니다:

```bash
docker exec -it palworld-server restore
```

복원 명령어를 사용하려면 `RCON_ENABLED` 환경 변수가 `true`여야 합니다.

:::warning
도커 `restart` 정책이 `always` 또는 `unless-stopped`로 설정 되어있지 않다면 복원 이후 컨테이너가 종료되므로 수동으로 재시작 해야 합니다.

[빠른 설정](https://palworld-server-docker.loef.dev/ko/)에서 제공된 Docker 실행 명령어와 Docker Compose 파일 예시는 이미 필요한 정책을 적용하고 있습니다.
:::

## 수동으로 백업 복원하기

L`/palworld/backups/`에서 복원하고자 하는 백업을 찾아서 압축을 풉니다.
작업을 시작하기 전에 서버를 중지해야 합니다.

```bash
docker compose down
```

`palworld/Pal/Saved/SaveGames/0/<old_hash_value>`에 위치한 기존 저장 데이터 폴더를 삭제합니다.

새롭게 압축 해제된 저장 데이터 폴더 `Saved/SaveGames/0/<new_hash_value>`의 내용을 `palworld/Pal/Saved/SaveGames/0/<new_hash_value>`로 복사합니다.

`palworld/Pal/Saved/Config/LinuxServer/GameUserSettings.ini` 안의 DedicatedServerName을 새 폴더 이름으로 교체합니다.

```ini
DedicatedServerName=<new_hash_value>  # 폴더 이름으로 교체하세요.
```

게임을 재시작합니다. (Docker Compose를 사용하는 경우)

```bash
docker compose up -d
```
