# Используем официальный образ Node.js.
# https://hub.docker.com/_/node
FROM node:18-alpine

# Устанавливаем рабочую директорию в контейнере
WORKDIR /usr/src/app

# Копируем файлы package.json и package-lock.json (если есть)
COPY package*.json ./

# Устанавливаем зависимости
# Используем --only=production для установки только production-зависимостей
RUN npm install --only=production

# Копируем исходный код приложения
COPY . .

# Открываем порт, на котором работает API
EXPOSE 3000

# Команда для запуска приложения
CMD [ "node", "index.js" ]
