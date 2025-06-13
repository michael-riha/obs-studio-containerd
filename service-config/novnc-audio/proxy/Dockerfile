FROM node:16-alpine

WORKDIR /app

COPY package.json .
RUN npm install

COPY ./src .

EXPOSE 8888
EXPOSE 1234/udp

CMD ["node", "proxy.js"]