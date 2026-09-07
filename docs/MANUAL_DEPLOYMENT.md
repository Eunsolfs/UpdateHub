# UpdateHub 手动部署指南

## 🎯 适用人群

适合熟悉 Docker 和 Linux 的用户，希望了解部署细节或需要自定义部署过程。

---

## 📋 前置要求

### 硬件要求
- **CPU**: 2核心以上
- **内存**: 2GB以上（推荐4GB）
- **磁盘**: 20GB以上可用空间

### 软件要求
- **操作系统**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **Docker**: 20.10+
- **Docker Compose**: 1.29+
- **网络**: 能访问 GitHub Container Registry

---

## 🚀 手动部署步骤

### 步骤1：安装 Docker 和 Docker Compose

#### 安装 Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# CentOS/RHEL
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### 安装 Docker Compose

```bash
# 下载 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 步骤2：配置 Docker 镜像加速（可选但推荐）

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

### 步骤3：创建项目目录

```bash
# 创建主目录
sudo mkdir -p /opt/UpdateHub
cd /opt/UpdateHub

# 创建子目录
mkdir -p docker
mkdir -p backend/uploads
mkdir -p backend/configs
mkdir -p backups
```

### 步骤4：获取配置文件

```bash
# 克隆项目获取配置文件
git clone https://github.com/Eunsolfs/UpdateHub.git /tmp/UpdateHub

# 复制必要的配置文件
cp /tmp/UpdateHub/docker/docker-compose.1panel.yml docker/
cp /tmp/UpdateHub/docker/.env.example docker/.env
cp /tmp/UpdateHub/docker/nginx.conf docker/

# 清理临时文件
rm -rf /tmp/UpdateHub
```

### 步骤5：配置环境变量

```bash
# 编辑环境变量文件
nano docker/.env
```

**必须修改的配置**：

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

# Docker 镜像配置
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:latest
```

### 步骤6：拉取 Docker 镜像

```bash
cd /opt/UpdateHub/docker

# 拉取后端镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:latest

# 拉取前端镜像
docker pull ghcr.io/eunsolfs/updatehub-frontend:latest

# 拉取数据库镜像
docker pull postgres:15-alpine

# 拉取 Redis 镜像
docker pull redis:7-alpine
```

### 步骤7：启动服务

```bash
cd /opt/UpdateHub/docker

# 启动所有服务
docker-compose -f docker-compose.1panel.yml up -d

# 查看服务状态
docker-compose -f docker-compose.1panel.yml ps
```

### 步骤8：验证部署

```bash
# 检查后端健康状态
curl http://localhost:8080/health

# 检查前端访问
curl http://localhost/

# 查看服务日志
docker-compose -f docker-compose.1panel.yml logs -f
```

---

## 🎯 访问系统

- **前端界面**: http://localhost
- **后端 API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health
- **默认管理员账号**: admin / admin123

⚠️ **重要**: 首次登录后请立即修改默认密码！

---

## 🔧 常用运维命令

### 服务管理

```bash
cd /opt/UpdateHub/docker

# 启动服务
docker-compose -f docker-compose.1panel.yml up -d

# 停止服务
docker-compose -f docker-compose.1panel.yml down

# 重启服务
docker-compose -f docker-compose.1panel.yml restart

# 查看服务状态
docker-compose -f docker-compose.1panel.yml ps
```

### 日志查看

```bash
# 查看所有服务日志
docker-compose -f docker-compose.1panel.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.1panel.yml logs -f backend
docker-compose -f docker-compose.1panel.yml logs -f frontend
docker-compose -f docker-compose.1panel.yml logs -f postgres
```

### 镜像管理

```bash
# 拉取新镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:latest
docker pull ghcr.io/eunsolfs/updatehub-frontend:latest

# 查看本地镜像
docker images

# 清理未使用的镜像
docker image prune
```

### 数据库管理

```bash
# 进入数据库
docker exec -it updatehub-postgres psql -U updatehub -d updatehub

# 备份数据库
docker exec updatehub-postgres pg_dump -U updatehub updatehub > backup.sql

# 恢复数据库
docker exec -i updatehub-postgres psql -U updatehub updatehub < backup.sql
```

---

## 🔄 系统更新

### 更新到最新版本

```bash
cd /opt/UpdateHub/docker

# 1. 拉取新镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:latest
docker pull ghcr.io/eunsolfs/updatehub-frontend:latest

# 2. 重启服务
docker-compose -f docker-compose.1panel.yml up -d

# 3. 验证更新
curl http://localhost:8080/health
```

### 更新到特定版本

```bash
# 1. 修改 .env 文件中的镜像版本
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0

# 2. 拉取指定版本镜像
docker pull ghcr.io/eunsolfs/updatehub-backend:v1.0.0
docker pull ghcr.io/eunsolfs/updatehub-frontend:v1.0.0

# 3. 重启服务
docker-compose -f docker-compose.1panel.yml up -d
```

### 版本回滚

```bash
# 1. 修改 .env 文件回退到之前版本
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0

# 2. 重启服务
docker-compose -f docker-compose.1panel.yml up -d
```

---

## 🗑️ 手动卸载

### 保留数据的卸载

```bash
cd /opt/UpdateHub/docker

# 停止服务
docker-compose -f docker-compose.1panel.yml down

# 清理容器（保留数据卷）
docker-compose -f docker-compose.1panel.yml rm -f
```

**保留内容**：
- ✅ 数据库数据（Docker 卷）
- ✅ 配置文件
- ✅ 上传文件
- ✅ Docker 镜像

### 完全卸载

```bash
cd /opt/UpdateHub/docker

# 停止服务并删除数据卷
docker-compose -f docker-compose.1panel.yml down -v

# 清理相关镜像
docker rmi ghcr.io/eunsolfs/updatehub-backend:latest
docker rmi ghcr.io/eunsolfs/updatehub-frontend:latest
docker rmi postgres:15-alpine
docker rmi redis:7-alpine

# 清理系统
docker system prune -a

# 删除项目目录
cd /opt
sudo rm -rf UpdateHub
```

**删除内容**：
- ❌ 所有服务
- ❌ 所有数据
- ❌ 所有镜像
- ❌ 项目文件

---

## 🔐 安全配置

### 修改默认密码

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

```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取免费证书
sudo certbot --nginx -d your-domain.com
```

---

## 🔍 故障排除

### 镜像拉取失败

```bash
# 检查网络连接
ping github.com

# 检查 Docker 镜像加速配置
cat /etc/docker/daemon.json

# 重启 Docker
sudo systemctl restart docker
```

### 容器无法启动

```bash
# 查看容器日志
docker-compose -f docker/docker-compose.1panel.yml logs

# 检查环境变量配置
cat docker/.env

# 检查端口占用
netstat -tulpn | grep 8080
```

### 数据库连接失败

```bash
# 检查数据库容器
docker ps | grep postgres

# 测试数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub

# 检查数据库配置
cat docker/.env | grep POSTGRES
```

---

## 📚 相关文档

- [部署方式选择指南](./DEPLOYMENT_CHOICE.md) - 选择合适的部署方式
- [脚本一键部署指南](./SCRIPT_DEPLOYMENT.md) - 推荐的自动化部署
- [精简版部署指南](./MINIMAL_DEPLOYMENT.md) - 精简版部署
- [版本发布指南](./VERSION_RELEASE.md) - 版本管理

---

## 🎯 总结

### 手动部署的优势

1. **灵活性高**：可以自定义每个步骤
2. **透明度高**：了解每个操作的作用
3. **可定制性强**：适合特殊需求
4. **学习价值**：理解部署原理

### 适用场景

- ✅ 需要深度定制部署过程
- ✅ 需要完全控制每个步骤
- ✅ 特殊的网络环境限制
- ✅ 学习和了解部署原理

### 不适用场景

- ❌ 新手用户
- ❌ 需要快速部署
- ❌ 不了解 Docker 操作

---

**如果你是新手，建议使用[脚本一键部署](./SCRIPT_DEPLOYMENT.md)更简单快捷！** 🚀
