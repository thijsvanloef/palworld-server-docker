 # TODO List
> default-palworld-settings-json에 추가되야 하는 설정일 경우
> palworld_settings.py의 Functions 섹션을 확인한다.<br> 
> @see field `functions`<br>
> @see function `_createDefaultPalWorldSettingsJson`<br>

## Server 관리 기능

### serverBackupSchedule

```json
{
    ...
    "serverBackupSchedule": {
        "enable": true,
        "backupPeriod": "*/30 * * * *",
        "maxBackupDays": 30,
        "log": "예약된 서버 백업을 진행합니다."
    }
    ...
}
```

### autoRestartForMemoryLeak
```json
{
    ...
    "autoRestartForMemoryLeak": {
        "enable": false,
        "checkPeriod": "*/1 * * * *",
        "persentageOfMemory(%)": 80,
        "shutdownTime(s)": 60,
        "message": "서버 메모리가 임계치를 넘어서 자동으로 서버를 재시작합니다."
    }
    ...
}
```

### autoBroadcastMessage
```json
{
    ...
    "autoBroadcastMessage": {
        "enable": false,
        "sendPeriod": "0 0 * * *",
        "message": "자동으로 서버에 전체 메시지를 전송합니다.",
    }
    ...
}
```