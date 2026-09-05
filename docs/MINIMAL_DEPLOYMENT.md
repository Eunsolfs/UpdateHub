# UpdateHub 精简版部署方案

## 🎯 部署方式说明

UpdateHub 现在使用 GitHub Actions 自动构建的预构建 Docker 镜像，服务器端不需要源代码和构建环境。

### 优势

- ⚡ **部署快速**：2-5分钟完成部署
- 💾 **资源节省**：服务器不需要构建环境
- 🌐 **网络节省**：只拉取镜像，不下载依赖
- 🎯 **构建标准化**：所有环境使用相同的预构建镜像
- 📦 **版本管理清晰**：支持基于 tag 的版本发布

## 📋 最小化部署需求

### 必需文件

精简版部署只需要以下文件：

```bash
/opt/UpdateHub/
└── docker/
    ├── docker-compose.1panel.yml    # Docker Compose 配置
    ├── .env                        # 环境变量配置
    └── nginx.conf                  # Nginx 配置
```

### 前置要求

- **操作系统**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **Docker**: 20.10+
- **Docker Compose**: 1.29+
- **网络**: 能访问 GitHub Container Registry

## 🚀 精简版部署步骤

### 步骤1：创建目录结构

```bash
# 创建项目目录
mkdir -p /opt/UpdateHub/docker
cd /opt/UpdateHub/docker
```

### 步骤2：获取配置文件

从 UpdateHub 项目仓库获取以下文件：

#### 方式1：从项目获取

```bash
# 克隆项目获取配置文件
git clone https://github.com/eunsolfs/UpdateHub.git /tmp/UpdateHub
cp /tmp/UpdateHub/docker/docker-compose.1panel.yml /opt/UpdateHub/docker/
cp /tmp/UpdateHub/docker/.env.example /opt/UpdateHub/docker/.env
cp /tmp/UpdateHub/docker/nginx.conf /opt/UpdateHub/docker/
rm -rf /tmp/UpdateHub
```

#### 方式2：手动创建

如果无法访问 GitHub，可以手动创建以下文件：

**docker-compose.1panel.yml**:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: updatehub-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - updatehub-network

  redis:
    image: redis:7-alpine
    container_name: updatehub-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    networks:
      - updatehub-network

  backend:
    image: ${BACKEND_IMAGE}
    container_name: updatehub-backend
    environment:
      - SERVER_MODE=${SERVER_MODE}
      - SERVER_PORT=${SERVER_PORT}
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=${POSTGRES_USER}
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_NAME=${POSTGRES_DB}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=${REDIS_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - REFRESH_SECRET=${REFRESH_SECRET}
      - STORAGE_TYPE=${STORAGE_TYPE}
    volumes:
      - ../backend/uploads:/app/uploads
      - ../backend/configs:/app/configs
    ports:
      - "${SERVER_PORT}:8080"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - updatehub-network

  frontend:
    image: ${FRONTEND_IMAGE}
    container_name: updatehub-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - updatehub-network

volumes:
  postgres_data:
  redis_data:

networks:
  updatehub-network:
    driver: bridge
```

**.env**:
```bash
# 数据库配置
POSTGRES_DB=updatehub
POSTGRES_USER=updatehub
POSTGRES_PASSWORD=your_strong_password_here

# Redis 配置
REDIS_PASSWORD=your_redis_password_here

# JWT 配置
JWT_SECRET=your_jwt_secret_key_here
REFRESH_SECRET=your_refresh_secret_key_here

# 服务器配置
SERVER_MODE=production
SERVER_PORT=8080

# 存储配置
STORAGE_TYPE=local

# Docker 镜像配置（将 your-username 替换为你的 GitHub 用户名，必须小写）
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:latest
```

**nginx.conf**:
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;

    server {
        listen 80;
        server_name localhost;

        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }

        location /api {
            proxy_pass http://backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 步骤3：修改配置

编辑 `.env` 文件，修改关键配置：

```bash
nano /opt/UpdateHub/docker/.env
```

**必须修改的配置**：
```bash
# 修改为你的 GitHub 用户名（必须小写）
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:latest

# 修改数据库密码
POSTGRES_PASSWORD=your_strong_password_here

# 修改 Redis 密码
REDIS_PASSWORD=your_redis_password_here

# 修改 JWT 密钥
JWT_SECRET=your_jwt_secret_key_here
REFRESH_SECRET=your_refresh_secret_key_here
```

### 步骤4：拉取镜像

```bash
cd /opt/UpdateHub/docker

# 拉取后端镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:latest

# 拉取前端镜像
docker pull ghcr.io/eunsolfs/updatehub-frontend:latest
```

### 步骤5：创建必要目录

```bash
# 创建上传和配置目录
mkdir -p /opt/UpdateHub/backend/uploads
mkdir -p /opt/UpdateHub/backend/configs
```

### 步骤6：启动服务

```bash
cd /opt/UpdateHub/docker

# 启动服务
docker-compose -f docker-compose.1panel.yml up -d
```

### 步骤7：验证部署

```bash
# 检查容器状态
docker-compose -f docker-compose.1panel.yml ps

# 检查后端健康
curl http://localhost:8080/health

# 检查前端访问
curl http://localhost/
```

## 📍 访问系统

- **前端界面**: http://localhost
- **后端 API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health
- **默认管理员账号**: admin / admin123

⚠️ **重要**: 生产环境请立即修改默认密码！

## 🔧 常用运维命令

### 查看服务状态

```bash
cd /opt/UpdateHub/docker
docker-compose -f docker-compose.1panel.yml ps
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose -f docker-compose.1panel.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.1panel.yml logs -f backend
docker-compose -f docker-compose.1panel.yml logs -f frontend
```

### 重启服务

```bash
cd /opt/UpdateHub/docker
docker-compose -f docker-compose.1panel.yml restart
```

### 停止服务

```bash
cd /opt/UpdateHub/docker
docker-compose -f docker-compose.1panel.yml down
```

### 更新系统

```bash
cd /opt/UpdateHub/docker

# 1. 拉取新镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:latest
docker pull ghcr.io/eunsolfs/updatehub-frontend:latest

# 2. 重启服务
docker-compose -f docker-compose.1panel.yml up -d
```

### 版本回滚

```bash
# 1. 修改 .env 文件中的镜像版本
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0

# 2. 重启服务
docker-compose -f docker-compose.1panel.yml up -d
```

## 🔐 安全配置

### 修改默认密码

首次部署后，请立即修改默认管理员密码：

1. 访问 http://localhost
2. 使用 admin/admin123 登录
3. 进入系统设置 -> 用户管理
4. 修改管理员密码

### 配置防火墙

```bash
# 开放必要端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw enable
```

### 配置 HTTPS

推荐使用 Let's Encrypt 免费证书：

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📦 备份策略

### 数据库备份

```bash
# 备份数据库
docker exec updatehub-postgres pg_dump -U updatehub updatehub > backup.sql

# 恢复数据库
docker exec -i updatehub-postgres psql -U updatehub updatehub < backup.sql
```

### 配置文件备份

```bash
# 备份配置文件
tar -czf backup_config.tar.gz /opt/UpdateHub/docker/.env /opt/UpdateHub/docker/nginx.conf
```

### 定时备份

添加到 crontab：

```bash
# 每天凌晨2点备份数据库
0 2 * * * docker exec updatehub-postgres pg_dump -U updatehub updatehub > /backup/updatehub_$(date +\%Y\%m\%d).sql
```

## 🚀 使用运维脚本（可选但推荐）

虽然精简版部署只需要配置文件，但建议保留运维脚本以简化管理：

### 获取运维脚本

```bash
# 创建脚本目录
mkdir -p /opt/UpdateHub/scripts

# 从项目获取运维脚本
git clone https://github.com/eunsolfs/UpdateHub.git /tmp/UpdateHub
cp /tmp/UpdateHub/scripts/ops.sh /opt/UpdateHub/scripts/
cp /tmp/UpdateHub/scripts/update.sh /opt/UpdateHub/scripts/
cp /tmp/UpdateHub/scripts/backup.sh /opt/UpdateHub/scripts/
rm -rf /tmp/UpdateHub

# 添加执行权限
chmod +x /opt/UpdateHub/scripts/*.sh
```

### 使用运维脚本

```bash
cd /opt/UpdateHub/scripts

# 运维管理（修改配置、镜像加速等）
./ops.sh

# 系统更新
./update.sh

# 数据备份
./backup.sh
```

## 🔍 故障排除

### 镜像拉取失败

如果镜像拉取失败，可以配置 Docker 镜像加速：

```bash
# 创建 Docker 配置目录
sudo mkdir -p /etc/docker

# 配置镜像加速
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": ["https://mirror.ccs.tencentyun.com"],
  "features": {
    "registry-mirrors": true
  }
}
EOF

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 容器无法启动

```bash
# 查看容器日志
docker-compose -f docker-compose.1panel.yml logs

# 检查环境变量配置
cat /opt/UpdateHub/docker/.env
```

### 数据库连接失败

```bash
# 检查数据库容器
docker ps | grep postgres

# 测试数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

## 📚 相关文档

- [版本发布指南](./VERSION_RELEASE.md) - 基于 tag 的版本发布
- [完整部署指南](./FIRST_TIME_DEPLOYMENT.md) - 详细部署步骤
- [运维脚本使用指南](../scripts/README.md) - 自动化脚本说明
- [文档导航](./INDEX.md) - 更多文档

## 🎯 部署对比

### 精简版部署（本文档）
- ✅ 只需要配置文件
- ✅ 适合熟悉 Docker 的用户
- ✅ 部署速度快
- ❌ 需要手动执行运维命令

### 完整部署（使用脚本）
- ✅ 自动化程度高
- ✅ 适合新手用户
- ✅ 包含运维脚本
- ✅ 自动配置镜像加速
- ⏱️ 初次部署时间稍长

## ✅ 总结

精简版部署只需要：
1. **3个配置文件**：docker-compose.1panel.yml、.env、nginx.conf
2. **2个Docker镜像**：后端镜像、前端镜像
3. **Docker环境**：已安装 Docker 和 Docker Compose

不需要：
- ❌ 源代码
- ❌ 构建环境
- ❌ 依赖包
- ❌ 编译工具

建议保留运维脚本（ops.sh、update.sh、backup.sh）以简化日常管理。
