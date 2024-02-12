---
sidebar_position: 1
---

# 디스코드 웹훅 사용하기

1. 디스코드의 서버 설정 창에서 웹훅 url을 생성하세요.
2. 끝 부분에 고유 토큰이 있는 디스코드 웹훅 url을 환경 변수로 설정하세요.  
(예시: `https://discord.com/api/webhooks/1234567890/abcde`)

docker run으로 디스코드 메시지 보내기:

```sh
-e DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1234567890/abcde" \
-e DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
```

docker compose로 디스코드 메시지 보내기:

```yaml
- DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1234567890/abcde
- DISCORD_PRE_UPDATE_BOOT_MESSAGE=Server is updating...
```
