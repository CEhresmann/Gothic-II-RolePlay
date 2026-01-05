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

**Prerequisites:**
*   **Git:** To clone this repository.
*   **Docker Desktop:** Must be installed and running. [Download here](https://www.docker.com/products/docker-desktop/).
*   **G2O Game Server:** You must download the latest server files from the [official source](https://gothic-online.com).

**Steps:**

1.  **Clone This Repository:**
    ```bash
    git clone https://github.com/your-repo/ARthii-auth_draft.git
    cd ARthii-auth_draft
    ```

2.  **Set Up the G2O Game Server:**
    *   Download the latest G2O server files.
    *   Create a folder named `g2o_server` in the root of this project.
    *   Extract the server files into the `g2o_server` folder.
    *   **Generate `data.xml`**: Run the server, join the game, open the console and type `generate data`. Copy the generated `data.xml` file into the `g2o_server` folder.

3.  **Create `.env` Configuration Files:**
    *   **API `.env`:** In `discord_bot_api/`, copy `.env.example` to `.env` and fill in the required variables like `API_KEY` and database credentials.
    *   **Bot `.env`:** In `discord_bot/`, copy `.env.example` to `.env` and provide your `DISCORD_TOKEN` and `API_KEY`.

4.  **Launch All Services:**
    *   From the project's root directory, run:
        ```bash
        docker-compose up --build -d
        ```
    *   This will build and start the G2O game server, database, API, and bot containers. You can monitor them with `docker-compose logs -f`.

---

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

**Требования:**
*   **Git:** Для клонирования репозитория.
*   **Docker Desktop:** Должен быть установлен и запущен. [Скачать здесь](https://www.docker.com/products/docker-desktop/).
*   **Игровой сервер G2O:**  Надо [скачать](https://gothic-online.com).

**Шаги:**

1.  **Клонируйте репозиторий:**
    ```bash
    git clone https://github.com/ваш-репозиторий/ARthii-auth_draft.git
    cd ARthii-auth_draft
    ```

2.  **Настройте игровой сервер G2O:**
    *   Скачайте последние файлы сервера G2O.
    *   Создайте папку `g2o_server` в корне этого проекта.
    *   Распакуйте файлы сервера в папку `g2o_server`.
    *   **Сгенерируйте `data.xml`**: Запустите сервер, зайдите в игру, откройте консоль и введите `generate data`. Скопируйте сгенерированный файл `data.xml` в папку `g2o_server`.

3.  **Создайте конфигурационные файлы `.env`:**
    *   **API `.env`:** В папке `discord_bot_api/` скопируйте `.env.example` в `.env` и заполните необходимые переменные, такие как `API_KEY` и данные для подключения к базе данных.
    *   **Бот `.env`:** В папке `discord_bot/` скопируйте `.env.example` в `.env` и укажите ваш `DISCORD_TOKEN` и `API_KEY`.

4.  **Запустите все сервисы:**
    *   Из корневой директории проекта выполните:
        ```bash
        docker-compose up --build -d
        ```
    *   Эта команда соберет и запустит контейнеры игрового сервера G2O, базы данных, API и бота. Вы можете следить за их состоянием с помощью `docker-compose logs -f`.

---

## ----- PL SECTION -----

*Ta sekcja została zachowana z oryginalnego pliku README i może zawierać nieaktualne informacje.*

# Open Roleplay 2.0

# Autor: [Artii](https://gitlab.com/harem3201/openroleplay2.0) #

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quarchodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.
