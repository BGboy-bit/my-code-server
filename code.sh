#!/bin/bash
set -e

GITHUB_BASE_URL="https://raw.githubusercontent.com/BGboy-bit/my-code-server/main"

# 在 /root 下创建 code-server 目录并进入目录
TARGET_DIR="/root/code-server"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# 下载 Dockerfile
curl -L -o Dockerfile "${GITHUB_BASE_URL}/Dockerfile" || { echo "下载 Dockerfile 失败"; exit 1; }

# 提示用户输入时区（TZ）、密码（PASSWORD）和代理域名（PROXY_DOMAIN），并设置默认值
read -p "请输入时区（例如 Asia/Shanghai） [Asia/Shanghai]: " USER_TZ
USER_TZ=${USER_TZ:-Asia/Shanghai}

read -p "请输入 PASSWORD [123456]: " USER_PASSWORD
USER_PASSWORD=${USER_PASSWORD:-123456}

read -p "请输入 PROXY_DOMAIN (留空则取消): " USER_PROXY_DOMAIN

# 构建 Docker 镜像
echo "正在构建 Docker 镜像..."
docker build -t my-code-server .

# 运行 Docker 容器，根据是否输入代理域名选择是否传递 PROXY_DOMAIN 参数
echo "正在启动 Docker 容器..."
if [ -n "$USER_PROXY_DOMAIN" ]; then
  docker run -d \
    -p 8080:8080 \
    -v "$(pwd)/config:/config" \
    -e PUID=0 \
    -e PGID=0 \
    -e TZ="${USER_TZ}" \
    -e PASSWORD="${USER_PASSWORD}" \
    -e PROXY_DOMAIN="${USER_PROXY_DOMAIN}" \
    --name code-server \
    my-code-server
else
  docker run -d \
    -p 8080:8080 \
    -v "$(pwd)/config:/config" \
    -e PUID=0 \
    -e PGID=0 \
    -e TZ="${USER_TZ}" \
    -e PASSWORD="${USER_PASSWORD}" \
    --name code-server \
    my-code-server
fi

echo "code-server正在启动，具体请看日志: docker logs code-server -f"
echo "启动成功后请访问: http://<你的服务器IP>:8080 或 http://域名:8080"
