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

## Full Project Setup Guide

This guide covers the complete setup process, integrating this project's services (database, API, bot) with the official G2O game server.

### **Part 1: Setting Up the Backend (Database, API, Bot)**

This part uses Docker to simplify the setup of all web services.

**Prerequisites:**
*   **Git:** To clone this repository.
*   **Docker Desktop:** Must be installed and running. [Download here](https://www.docker.com/products/docker-desktop/).

**Steps:**

1.  **Clone This Repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
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

This part involves downloading the official G2O server and connecting it to our backend.

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

The server will now launch, load the `RP` gamemode, and successfully connect to the backend services running in Docker. Your project is fully operational.

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

## Полное руководство по настройке проекта


### **Настройка бэкенда (БД, API, Бот)**

**Требования:**
*   **Git:** Для клонирования репозитория.
*   **Docker Desktop:** Должен быть установлен и запущен. [Скачать здесь](https://www.docker.com/products/docker-desktop/).

**Шаги:**

1.  **Клонируйте репозиторий:**
    ```bash
    git clone <ссылка-на-ваш-репозиторий>
    cd <папка-репозитория>
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
    *   Получите архив с сервером с официального сайта G2O.
    *   Распакуйте его в отдельную папку на вашем компьютере.

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

Теперь сервер запустится, загрузит игровой режим `RP` и успешно подключится к бэкенд-сервисам, работающим в Docker. Ваш проект полностью готов к работе.

## ----- PL SECTION -----

*Ta sekcja została zachowana z oryginalnego pliku README i może zawierać nieaktualne informacje.*

# Open Roleplay 2.0

# Autor: Artii #

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quarchodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.
