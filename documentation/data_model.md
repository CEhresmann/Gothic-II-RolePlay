# Модель данных

Этот документ описывает структуру данных, используемых в системе, и отношения между сущностями. 

## 1. ER-диаграмма 

Диаграмма ниже представляет основные сущности базы данных и связи между ними.

```mermaid
erDiagram
    PLAYER_ACCOUNTS {
        int id PK "Primary Key"
        varchar name "Unique"
        varchar password
        varchar discord_id "Nullable, Unique"
        int class_id
        int fraction_id
        int strength
        int dexterity
        int hp
        int hp_max
        int mana
        int mana_max
        -- и много других полей --
    }

    PLAYER_POSITIONS {
        int player_id PK, FK "Foreign Key to PLAYER_ACCOUNTS"
        float pos_x
        float pos_y
        float pos_z
        float angle
    }

    PLAYER_SKILLS {
        int player_id PK, FK "Foreign Key to PLAYER_ACCOUNTS"
        int weapon_1h
        int weapon_2h
        int weapon_bow
        int weapon_crossbow
    }

    PLAYER_ITEMS {
        int id PK "Primary Key"
        int player_id FK "Foreign Key to PLAYER_ACCOUNTS"
        varchar item_instance
        int amount
        bool equipped
    }

    DISCORD_AUTH_SESSIONS {
        int id PK "Primary Key"
        int player_id FK "Foreign Key to PLAYER_ACCOUNTS"
        varchar auth_code "Unique auth code"
        bigint expires_at "Timestamp of expiration"
    }

    PLAYER_ACCOUNTS ||--o| PLAYER_POSITIONS : "has one"
    PLAYER_ACCOUNTS ||--o| PLAYER_SKILLS : "has one"
    PLAYER_ACCOUNTS ||--o| PLAYER_ITEMS : "has many"
    PLAYER_ACCOUNTS ||--o| DISCORD_AUTH_SESSIONS : "has many"
```

## 2. Описание таблиц

### `player_accounts`

Хранит основную и самую обширную информацию об игровых аккаунтах.

| Поле | Тип | Описание |
|---|---|---|
| `id` | INTEGER | Уникальный идентификатор аккаунта (PK) |
| `name` | VARCHAR | Имя пользователя в игре. |
| `password` | VARCHAR | Хэш пароля. |
| `discord_id` | VARCHAR | Уникальный ID Discord пользователя (Nullable). |
| `class_id` | INTEGER | ID класса (ранга) внутри фракции. |
| `fraction_id` | INTEGER | ID фракции. |
| `strength`, `dexterity` | INTEGER | Основные характеристики. |
| `hp`, `hp_max` | INTEGER | Текущее и максимальное здоровье. |
| `mana`, `mana_max` | INTEGER | Текущая и максимальная мана. |
| `learning_points` | INTEGER | Очки обучения. |
| `description` | TEXT | Описание персонажа. |
| `walk_style` | VARCHAR | Стиль ходьбы. |
| `body_model`, `head_model` | VARCHAR | Названия моделей тела и головы. |
| `profession_*` | INTEGER | Множество полей для уровней профессий. |
| ... | ... | И другие поля. |

### `player_positions`

Хранит последнюю известную позицию игрока в мире.

| Поле | Тип | Описание |
|---|---|---|
| `player_id` | INTEGER | Идентификатор игрока (PK, FK to `player_accounts.id`). |
| `pos_x`, `pos_y`, `pos_z` | FLOAT | Координаты в мире. |
| `angle` | FLOAT | Угол поворота персонажа. |

### `player_skills`

Хранит навыки владения оружием.

| Поле | Тип | Описание |
|---|---|---|
| `player_id` | INTEGER | Идентификатор игрока (PK, FK to `player_accounts.id`). |
| `weapon_1h`, `weapon_2h` | INTEGER | Навык владения одноручным и двуручным оружием. |
| `weapon_bow`, `weapon_crossbow` | INTEGER | Навык владения луком и арбалетом. |

### `player_items`

Хранит инвентарь игрока.

| Поле | Тип | Описание |
|---|---|---|
| `id` | INTEGER | Уникальный идентификатор записи (PK). |
| `player_id` | INTEGER | Идентификатор игрока (FK to `player_accounts.id`). |
| `item_instance` | VARCHAR | Имя экземпляра предмета (например, "ITMW_1H_SWORD"). |
| `amount` | INTEGER | Количество предметов в стаке. |
| `equipped` | BOOLEAN | Флаг, показывающий, экипирован ли предмет. |

### `discord_auth_sessions`

Хранит временные сессии для привязки Discord аккаунтов.

| Поле | Тип | Описание |
|---|---|---|
| `id` | INTEGER | Уникальный идентификатор сессии (PK). |
| `player_id` | INTEGER | Идентификатор игрового аккаунта (FK to `player_accounts.id`). |
| `auth_code` | VARCHAR | Уникальный, короткоживущий код. |
| `expires_at` | BIGINT | Unix timestamp, после которого сессия недействительна. |
