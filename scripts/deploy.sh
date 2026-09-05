#!/bin/bash

# UpdateHub 部署脚本

set -e

echo "开始部署 UpdateHub..."

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 进入 docker 目录
cd "$(dirname "$0")/../docker"

# 停止并删除旧容器
echo "停止旧容器..."
docker-compose down

# 构建并启动服务
echo "构建并启动服务..."
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

echo "部署完成！"
echo "前端访问地址: http://localhost"
echo "后端 API 地址: http://localhost:8080"
echo "数据库端口: 5432"
echo "Redis 端口: 6379"
