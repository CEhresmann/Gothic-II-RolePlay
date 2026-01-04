# Архитектура системы

Этот документ описывает высокоуровневую архитектуру (High-Level Design) проекта.

## 1. Диаграмма компонентов (HLD)

Диаграмма ниже иллюстрирует основные компоненты системы и их взаимодействие.

```mermaid
graph TD
    subgraph "Игровая среда"
        G2O_Client[Клиент Gothic 2 Online]
        G2O_Server[Игровой сервер G2O]
    end

    subgraph "Бэкенд-сервисы (Docker)"
        DiscordBotAPI[Discord Bot API ]
        DiscordBot[Discord Bot]
        Database[MySQL DB]
    end

    subgraph "Внешние системы"
        DiscordAPI[Discord API]
    end

    G2O_Client -- Игровой протокол --> G2O_Server
    
    G2O_Server -- SQL Query (через ORM) --> Database
    G2O_Server -- HTTP/S Request (только для Discord Auth) --> DiscordBotAPI

    DiscordBotAPI -- SQL Query --> Database
    DiscordBot -- HTTP/S Request --> DiscordBotAPI
    DiscordBot -- Discord API --> DiscordAPI

    style G2O_Client fill:#f9f,stroke:#333,stroke-width:2px
    style G2O_Server fill:#ccf,stroke:#333,stroke-width:2px
    style DiscordBotAPI fill:#9cf,stroke:#333,stroke-width:2px
    style DiscordBot fill:#9cf,stroke:#333,stroke-width:2px
    style Database fill:#f99,stroke:#333,stroke-width:2px
```

## 2. Описание компонентов

*   **Клиент Gothic 2 Online (G2O_Client):** Игровой клиент, на котором пользователи играют. Взаимодействует только с игровым сервером.
*   **Игровой сервер G2O (G2O_Server):** Основа игрового мода. Обрабатывает всю игровую логику на языке Squirrel. **Напрямую взаимодействует с базой данных** через встроенный ORM-модуль для всех игровых операций (сохранение персонажей, инвентаря, логов и т.д.). Для процесса аутентификации через Discord он также выступает в роли клиента для Discord Bot API.
*   **Discord Bot API:** Сервер-посредник, который предоставляет HTTP-интерфейс, используемый игровым сервером **только для аутентификации через Discord**. Он инкапсулирует логику работы с сессиями аутентификации.
*   **Discord Bot:** Бот, который "живет" в Discord. Он обрабатывает slash-команды от пользователей и общается с Discord Bot API для выполнения их запросов.
*   **База данных (MySQL DB):** Центральное хранилище данных. Хранит всю информацию об аккаунтах, персонажах, игровом мире, логах, а также сессиях аутентификации.
*   **Discord API:** Внешний сервис, с которым взаимодействует Discord-бот для отправки сообщений и регистрации команд.


