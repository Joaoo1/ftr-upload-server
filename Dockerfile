FROM node:22.14 AS base

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

FROM base AS build
WORKDIR /usr/src/app

COPY . .

RUN npm run build
RUN npm prune --production

# FROM cgr.dev/chainguard/node:latest AS deploy
# FROM gcr.io/distroless/nodejs22-debian12 AS deploy
FROM node:22.14-alpine3.21 AS deploy

USER 1000

WORKDIR /usr/src/app
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

EXPOSE 3333

CMD ["dist/infra/http/server.js"]