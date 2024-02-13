---
sidebar_position: 1
---

# 백업 만들기

현재 시점의 게임 세이브 백업을 생성하려면 다음 명령을 사용합니다:

```bash
docker exec palworld-server backup
```

다음 위치에 백업이 생성됩니다. `/palworld/backups/`

rcon이 활성화된 경우 서버는 백업 전에 저장을 실행합니다.
