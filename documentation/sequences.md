# Диаграммы последовательности 

Этот документ содержит UML-диаграммы последовательности, которые детализируют взаимодействие компонентов в ключевых сценариях.

## 1. Сценарий: Успешная привязка Discord аккаунта

Эта диаграмма показывает шаги, которые выполняются при успешной привязке аккаунта.

```mermaid
sequenceDiagram
    participant Player as Игрок (в клиенте G2O)
    participant G2OServer as Игровой сервер G2O
    participant API as Discord Bot API
    participant DB as База данных
    participant Bot as Discord Bot
    participant Discord as Discord API

    Player->>G2OServer: Запрашивает привязку к Discord
    G2OServer->>API: POST /request-auth-code (player_id)
    API->>DB: INSERT INTO discord_auth_sessions (player_id, code, expires_at)
    DB-->>API: {id, code, ...}
    API-->>G2OServer: 200 OK {auth_code}
    G2OServer-->>Player: Отображает auth_code в интерфейсе

    Player->>Discord: Вводит команду /auth [auth_code]
    Discord->>Bot: InteractionCreate event
    Bot->>API: POST /verify-auth-code (discord_id, auth_code)
    API->>DB: SELECT * FROM discord_auth_sessions WHERE auth_code = ?
    DB-->>API: {session_data}
    API->>API: Валидация кода (срок жизни, статус)
    API->>DB: UPDATE player_accounts SET discord_id = ? WHERE id = ?
    DB-->>API: {update_status}
    API-->>Bot: 200 OK {success: true}
    Bot->>Discord: Отправляет сообщение "Успешно привязано"
    Discord-->>Player: Показывает подтверждение
```
