# Open Roleplay 2.0 

This project is a significantly refactored and improved version of the **Open Roleplay 2.0** gamemode by **Artii**, which itself is an update to the classic **Gothic Roleplay** by **Quarchodron**.

This fork aims to overhaul the codebase to achieve maximum modularity, stability, and extensibility.

---

## Game Mechanics

*   **Classes and Factions:** Players can join factions and acquire classes, unlocking new abilities.
*   **Trading:** Secure item exchange between players.
*   **Crafting:** Create new items from materials using recipes.
*   **Progression:** Character development through experience and skill improvement.

---

## Deployment with Docker (Recommended)

This is the easiest way to get the entire project running.

**Prerequisites:**
*   [Docker](https://www.docker.com/get-started) and [Docker Compose](https://docs.docker.com/compose/install/) installed.

**Steps:**

1.  **Create Environment Files:**
    *   Copy `.env.example` to `.env` in the root directory and fill in the database credentials.
    *   Copy `discord_bot_api/.env.example` to `discord_bot_api/.env` and fill in your `API_KEY`.
    *   Copy `discord_bot/.env.example` to `discord_bot/.env` and fill in your `DISCORD_TOKEN` and the same `API_KEY`.

2.  **Run Docker Compose:**
    Open a terminal in the project root and run:
    ```bash
    docker-compose up --build -d
    ```
    This command will build the images for the API and the bot, and start all services (database, API, bot) in the background.

3.  **Check the Status:**
    You can check the logs to make sure everything is running correctly:
    ```bash
    docker-compose logs -f
    ```

4.  **Launch the Game Server:**
    *   For now, the G2O game server must still be run manually on your host machine.
    *   Make sure to configure `RP/Modules/Mysql/Connector.nut` to connect to the database running in Docker (host: `127.0.0.1`, port: `3306`, and the user/password from your `.env` file).

---

## Getting Started

### 1. Database Setup

*   **Install MySQL:** Make sure you have a MySQL server installed and running.
*   **Import the Schema:** Use a tool like MySQL Workbench or the command line to import the database structure from `RP/Modules/Mysql/GothicRoleplay2-0.sql`. This will create all the necessary tables.
*   **Configure the Connection:** Open the file `RP/Modules/Mysql/Connector.nut` and find the line `ORM.MySQL(...)`. Replace `"host"`, `"user"`, `"password"`, and `"database_name"` with your actual database credentials.

### 2. Discord Bot & API Setup

*   **Navigate to `discord_bot_api/`:**
    *   Create a `.env` file from the `.env.example`.
    *   Fill in your database details and create a secret `API_KEY`.
    *   Run `npm install` to download dependencies.
    *   Run `node index.js` to start the API server.
*   **Navigate to `discord_bot/`:**
    *   Create a `.env` file from the `.env.example`.
    *   Fill in your Discord Bot Token, the API URL (from the previous step), and the same `API_KEY`.
    *   Run `npm install`.
    *   Run `node index.js` to start the bot.

### 3. Launch the Game Server

*   Simply start your G2O server. The scripts will load automatically. Players can now connect, and they will be prompted to authenticate via Discord.

---
---

# Open Roleplay 2.0 

## О проекте

Этот проект представляет собой доработанную версию игрового мода **Open Roleplay 2.0** от **Artii**, который, в свою очередь, является обновлением классического **Gothic Roleplay** от **Quarchodron**.

форк нацелен на переработку кодовой базы с применением для модульности, стабильности и расширяемости.

---

## Игровые механики

*   **Классы и фракции:** Игроки могут присоединяться к фракциям и получать классы, открывая новые возможности.
*   **Торговля:** Безопасный обмен предметами между игроками.
*   **Крафт:** Создание новых предметов из материалов по рецептам.
*   **Прокачка:** Развитие персонажа через получение опыта и улучшение навыков.

---

## Развертывание с помощью Docker (Рекомендуется)


**Требования:**
*   Установленные [Docker](https://www.docker.com/get-started) и [Docker Compose](https://docs.docker.com/compose/install/).

**Шаги:**

1.  **Создайте файлы окружения:**
    *   Скопируйте `.env.example` в `.env` в корневой папке проекта и заполните данные для подключения к БД.
    *   Скопируйте `discord_bot_api/.env.example` в `discord_bot_api/.env` и укажите ваш `API_KEY`.
    *   Скопируйте `discord_bot/.env.example` в `discord_bot/.env` и укажите ваш `DISCORD_TOKEN` и тот же `API_KEY`.

2.  **Запустите Docker Compose:**
    Откройте терминал в корне проекта и выполните команду:
    ```bash
    docker-compose up --build -d
    ```
    Эта команда соберет образы для API и бота и запустит все сервисы (базу данных, API, бот) в фоновом режиме.

3.  **Проверьте статус:**
    Вы можете проверить логи, чтобы убедиться, что все работает корректно:
    ```bash
    docker-compose logs -f
    ```

4.  **Запустите игровой сервер:**
    *   На данный момент игровой сервер G2O все еще нужно запускать вручную на вашем компьютере.
    *   Убедитесь, что вы настроили `RP/Modules/Mysql/Connector.nut` для подключения к базе данных, запущенной в Docker (хост: `127.0.0.1`, порт: `3306`, и пользователь/пароль из вашего `.env` файла).

---

## Руководство по запуску

### 1. Настройка базы данных

*   **Установите MySQL:** Убедитесь, что у вас установлен и запущен MySQL сервер.
*   **Импортируйте схему:** Используя инструмент вроде MySQL Workbench или командную строку, импортируйте структуру базы данных из файла `RP/Modules/Mysql/GothicRoleplay2-0.sql`. Это создаст все необходимые таблицы.
*   **Настройте подключение:** Откройте файл `RP/Modules/Mysql/Connector.nut` и найдите строку `ORM.MySQL(...)`. Замените `"host"`, `"user"`, `"password"` и `"database_name"` на ваши реальные данные для подключения к БД.

### 2. Настройка Discord-бота и API

Это необходимо для входа игроков на сервер.

*   **Перейдите в `discord_bot_api/`:**
    *   Создайте файл `.env` из `.env.example`.
    *   Заполните данные вашей БД и придумайте секретный `API_KEY`.
    *   Выполните `npm install` для установки зависимостей.
    *   Выполните `node index.js` для запуска API сервера.
*   **Перейдите в `discord_bot/`:**
    *   Создайте файл `.env` из `.env.example`.
    *   Укажите токен вашего Discord-бота, URL API (из предыдущего шага) и тот же самый `API_KEY`.
    *   Выполните `npm install`.
    *   Выполните `node index.js` для запуска бота.

### 3. Запуск игрового сервера

*   Просто запустите ваш сервер G2O. Скрипты загрузятся автоматически. Теперь игроки могут подключаться и проходить аутентификацию через Discord.

---
---

## ----- PL SECTION -----

*Ta sekcja została zachowana z oryginalnego pliku README i może zawierać nieaktualne informacje.*

# Open Roleplay 2.0

# Autor: Artii #

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quarchodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.
