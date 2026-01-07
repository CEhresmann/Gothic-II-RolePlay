FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install && apk add --no-cache curl netcat-openbsd bash && \
    curl -sS https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /usr/local/bin/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh 

COPY . .

EXPOSE 3000

CMD [ "node", "index.js" ]
