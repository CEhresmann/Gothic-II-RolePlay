# Open Roleplay 2.0 

This project is a significantly refactored and improved version of the **Open Roleplay 2.0** gamemode by **Artii**, which itself is an update to the classic **Gothic Roleplay** by **Quarchodron**.

---

## Game Mechanics

*   **Classes and Factions**
*   **Trading** 
*   **Crafting**
*   **Progression** 

---

## Full Project Setup Guide

### **Part 1: Setting Up the Backend (Database, API, Bot)**

**Prerequisites:**
*   **Git:** To clone this repository.
*   **Docker Desktop:** Must be installed and running. [Download here](https://www.docker.com/products/docker-desktop/).

**Steps:**

1.  **Clone This Repository:**
    ```bash
    git clone https://github.com/CEhresmann/Gothic-II-RolePlay.git
    cd Gothic-II-RolePlay
    ```

2.  **Create `.env` Configuration Files:**
    *   **Root `.env`:** In the project root, copy `.env.example` to `.env`. This file is used to initialize the database in Docker. The default values are fine for local setup.
    *   **API `.env`:** In `discord_bot_api/`, copy `.env.example` to `.env`. Open it and set a unique, secret `API_KEY` that you create yourself.
    *   **Bot `.env`:** In `discord_bot/`, copy `.env.example` to `.env`. Open it and provide your `DISCORD_TOKEN` (from the [Discord Developer Portal](https://discord.com/developers/applications)) and the same `API_KEY` you just created.

3.  **Launch Backend Services:**
    *   From the project's root directory, run:
        ```bash
        docker-compose up --build -d
        ```
    *   This will build and start the database, API, and bot containers. You can monitor them with `docker-compose logs -f`. At this point, all backend services are running.

---

### **Part 2: Setting Up the G2O Game Server**

**Prerequisites:**
*   **G2O Game Server:** You must download the latest server files from the official source.

**Steps:**

1.  **Download and Extract the G2O Server:**
    *   Get the server package from the official G2O website.
    *   Extract it into a dedicated folder on your machine.

2.  **Integrate the Gamemode:**
    *   Copy the `RP` folder from this repository into the `gamemodes` subfolder of your G2O server directory. The structure should be:
        ```
        g2o-server/
        ├── G2O_Server.exe
        ├── gamemodes/
        │   └── RP/   <-- Like here
        └── ...
        ```

3.  **Configure the Database Connection:**
    *   Inside the `RP/Modules/Mysql/` directory (the one you just copied), rename `db.conf.example` to `db.conf`.
    *   The default settings in this file are pre-configured to connect to the database running in Docker. No changes are needed if you used the default setup in Part 1.

4.  **Configure the Server:**
    *   In your G2O server's root directory, create or edit the `server.cfg` file (Note: older versions might use `config.xml`).
    *   Add or modify this line to load our gamemode:
        ```
        gamemode: RP
        ```
    *   For detailed server configuration (server name, slots, etc.), refer to the official G2O documentation that comes with the server or is available on their website.

5.  **Run the Game Server:**
    *   Execute `G2O_Server.exe`.

# Open Roleplay 2.0 

## О проекте

Проект представляет собой доработанную версию игрового мода **Open Roleplay 2.0** от **Artii**, который, в свою очередь, является обновлением классического **Gothic Roleplay** от **Quarchodron**.
форк нацелен на переработку кодовой базы, пока тут только авторизация по дс.

---

## Игровые механики

*   **Классы и фракции**
*   **Торговля**
*   **Крафт**
*   **Прокачка** 

---

## Полное руководство по настройке проекта
### **Настройка бэкенда (БД, API, Бот)**
**Требования:**
*   **Git:** Для клонирования репозитория.
*   **Docker Desktop:** Должен быть установлен и запущен. [Скачать здесь](https://www.docker.com/products/docker-desktop/).

**Шаги:**

1.  **Клонируйте репозиторий:**
    ```bash
    git clone https://github.com/CEhresmann/Gothic-II-RolePlay.git
    cd Gothic-II-RolePlay
    ```

2.  **Создайте конфигурационные файлы `.env`:**
    *   **Корневой `.env`:** В корне проекта скопируйте `.env.example` в `.env`. Этот файл используется для первоначальной настройки базы данных в Docker. Значений по умолчанию достаточно для локальной разработки.
    *   **API `.env`:** В папке `discord_bot_api/` скопируйте `.env.example` в `.env`. Откройте его и установите уникальный, секретный `API_KEY`, который вы должны придумать сами.
    *   **Бот `.env`:** В папке `discord_bot/` скопируйте `.env.example` в `.env`. Откройте его и укажите ваш `DISCORD_TOKEN` (полученный на [портале разработчиков Discord](https://discord.com/developers/applications)) и тот же самый `API_KEY`, который вы создали шагом ранее.

3.  **Запустите бэкенд-сервисы:**
    *   Вернитесь в корневую директорию проекта и выполните:
        ```bash
        docker-compose up --build -d
        ```
    *   Эта команда соберет и запустит контейнеры базы данных, API и бота. Вы можете следить за их состоянием с помощью `docker-compose logs -f`. На этом этапе все бэкенд-сервисы запущены.

---

### **Настройка игрового сервера G2O**
**Шаги:**

1.  **Скачайте и распакуйте сервер G2O:**
2.  **Интегрируйте игровой режим:**
    *   Скопируйте папку `RP` из этого репозитория в подпапку `gamemodes` вашего сервера G2O. Структура должна выглядеть так:
        ```
        g2o-server/
        ├── G2O_Server.exe
        ├── gamemodes/
        │   └── RP/   <-- Сюда
        └── ...
        ```

3.  **Настройте подключение к базе данных:**
    *   Внутри папки `RP/Modules/Mysql/` переименуйте файл `db.conf.example` в `db.conf`.
    *   Настройки по умолчанию в этом файле уже сконфигурированы для подключения к базе данных в Docker. Если вы использовали стандартные настройки в Части 1, ничего менять не нужно.

4.  **Сконфигурируйте сервер:**
    *   В корневой директории вашего сервера G2O создайте или отредактируйте файл `server.cfg` (Примечание: старые версии могли использовать `config.xml`).
    *   Добавьте или измените эту строку, чтобы сервер загружал наш игровой режим:
        ```
        gamemode: RP
        ```
    *   Для детальной настройки сервера (название, слоты и т.д.) обратитесь к официальной документации G2O, которая поставляется с сервером или доступна на их сайте.

5.  **Запустите игровой сервер:**
    *   Запустите файл `G2O_Server.exe`.

## ----- PL SECTION -----

*Ta sekcja została zachowana z oryginalnego pliku README i może zawierać nieaktualne informacje.*

# Open Roleplay 2.0

# Autor: [Artii](https://gitlab.com/harem3201/openroleplay2.0) #

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quarchodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.


