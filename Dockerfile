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

ENV PORT=3333
ENV NODE_ENV=test
ENV DATABASE_URL="postgresql://docker:docker@localhost:5432/upload_test"
ENV CLOUDFLARE_ACCOUNT_ID="d8d839c8555dcd7ce86052d498b659d0"
ENV CLOUDFLARE_ACCESS_KEY_ID="ec8a403336c3c3ec009248ea87dc9da8"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="d39ac4e59080efee21385ce53319fd627b17abf0d36b510ec284c7a98715a660"
ENV CLOUDFLARE_BUCKET="upload-server"
ENV CLOUDFLARE_PUBLIC_URL="https://pub-fc7b5d360e924c6394964914d942bc18.r2.dev"

CMD ["dist/infra/http/server.js"]