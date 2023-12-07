# 阶段一：构建阶段
FROM caomeiyouren/alpine-nodejs:1.1.0 as builder

WORKDIR /home/app

COPY package.json .npmrc /home/app/

RUN pnpm i --production=false

COPY . /home/app

RUN pnpm run build

# 阶段二：缩小阶段
FROM caomeiyouren/alpine-nodejs:1.1.0 as docker-minifier

WORKDIR /minifier

# COPY package.json .npmrc /minifier/

RUN pnpm add @vercel/nft@0.24.4 fs-extra@11.2.0 --save-prod

COPY --from=builder /home/app /home/app

RUN cp /home/app/scripts/minify-docker.js /minifier/ && \
    export PROJECT_ROOT=/home/app/ && \
    node /minifier/minify-docker.js && \
    rm -rf /home/app/node_modules /home/app/scripts && \
    mv /home/app/app-minimal/node_modules /home/app/ && \
    rm -rf /home/app/app-minimal

# 阶段三：生产阶段
# FROM alpine:latest
# FROM node:20-alpine
FROM caomeiyouren/alpine-nodejs:1.1.0
# 安装nodejs环境
# RUN echo "http://mirrors.aliyun.com/alpine/edge/main/" > /etc/apk/repositories \
#     && echo "http://mirrors.aliyun.com/alpine/edge/community/" >> /etc/apk/repositories \
#     && apk update \
#     && apk add --no-cache --update nodejs git \
#     && node -v && git --version

WORKDIR /home/app

# COPY --from=builder /home/app/package.json /home/app/.npmrc /home/app/
# COPY --from=builder /home/app/dist /home/app/dist
# COPY --from=docker-minifier /home/app/node_modules /home/app/node_modules

COPY --from=docker-minifier /home/app /home/app

EXPOSE 3000

# ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "dist/main"]
