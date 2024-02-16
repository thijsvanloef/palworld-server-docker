---
sidebar_position: 1
---

# Palworld 디렉터리

Palworld 데이터와 관련된 모든 것은 컨테이너 내부의 `/palworld` 폴더에 있습니다.

## 폴더 구조

![Folder Structure](../../../../../../docusaurus/docs/assets/folder_structure.jpg)

| 폴더                       | 용도                                                               |
|------------------------------|-------------------------------------------------------------------|
| palworld                     | 모든 Palworld 서버 파일이 있는 루트 폴더                    |
| backups                      | `backup` 명령어로 생성된 모든 백업이 저장되는 폴더 |
| Pal/Saved/Config/LinuxServer | 수동 설정을 위한 모든 .ini 구성 파일이 있는 폴더    |

## 호스트의 파일 시스템에 데이터 디렉터리 연결

Palworld 폴더를 호스트 시스템에 연결하는 가장 간단한 방법은 아래의 docker-compose.yml 파일 예시를 사용하는 것입니다:

```yml
      volumes:
         - ./palworld:/palworld/
```

이렇게 하면 현재 작업 디렉터리에 `palworld` 폴더가 생성되고 `/palworld` 폴더가 마운트됩니다.
