FROM node:20-alpine AS prod_deps

WORKDIR /app
# RUN git clone https://github.com/SnezhanaLukk/shri-infra-homework.git .

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

FROM node:20-alpine AS build_ui
WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

COPY . .

RUN npm run build

FROM node:20-alpine AS final
WORKDIR /app

COPY package.json ./
COPY --from=prod_deps /app/node_modules ./node_modules
COPY --from=build_ui /app/dist ./dist
COPY ./src/server/. ./src/server
COPY ./src/common/. ./src/common

ENV NODE_ENV=production
USER node
EXPOSE 3000

CMD ["npm", "start"]