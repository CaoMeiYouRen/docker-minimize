# 阶段一：构建阶段
FROM caomeiyouren/alpine-nodejs:1.1.0 as builder

WORKDIR /home/app

COPY package.json .npmrc /home/app/

RUN pnpm i --production=false

COPY . /home/app

RUN pnpm run build

# 阶段二：生产阶段
FROM caomeiyouren/alpine-nodejs:1.1.0

WORKDIR /home/app

COPY --from=builder /home/app/package.json /home/app/.npmrc /home/app/
COPY --from=builder /home/app/dist /home/app/dist

RUN pnpm i --production=true

EXPOSE 3000

CMD ["pnpm", "run", "start"]
