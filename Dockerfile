FROM node:18 AS build
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine
COPY --from=build /app/build /app/
EXPOSE 3000
CMD ["node", "server.js"]
