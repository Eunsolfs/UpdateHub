# UpdateHub 1Panel 部署完整指南

本指南详细说明如何在 1Panel 环境中部署 UpdateHub，使用预构建的 Docker 镜像（CI/CD 方式）。

## 🎯 适用场景

- 已安装 1Panel 的服务器
- 希望通过 1Panel 管理 UpdateHub 容器
- 使用预构建镜像的快速部署

## 🚀 部署方式说明

### CI/CD 部署方式

UpdateHub 现在使用 GitHub Actions 自动构建 Docker 镜像，部署时只需拉取预构建的镜像。

**优势**：
- ⚡ 部署速度快（2-5分钟）
- 💾 服务器不需要构建环境
- 🌐 网络消耗小
- 🎯 构建环境标准化
- 📦 版本管理清晰

## 📋 部署前准备

### 1. 1Panel 要求

- **1Panel 版本**: 1.10.0 或更高
- **系统要求**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **硬件要求**: 
  - CPU: 2核心以上
  - 内存: 2GB以上（推荐4GB）
  - 磁盘: 20GB以上可用空间

### 2. 检查 1Panel 安装

#### 2.1 验证 1Panel 运行状态
```bash
# 检查 1Panel 服务状态
systemctl status 1panel

# 应该显示 active (running)
```

#### 2.2 访问 1Panel
在浏览器中访问：
```
http://your-server-ip:10086
```

### 3. 安装 Docker Compose

1Panel 自动安装 Docker，但需要单独安装 Docker Compose。

#### 3.1 安装 Docker Compose
```bash
# Ubuntu/Debian
apt install -y docker-compose

# CentOS/RHEL
yum install -y docker-compose

# 或使用官方安装脚本
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 3.2 验证安装
```bash
docker-compose --version
# 应该显示版本信息，如：docker-compose version 2.x.x
```

### 4. GitHub Container Registry 访问

#### 4.1 公开仓库（推荐）
如果 UpdateHub 镜像是公开的，无需特殊配置。

#### 4.2 私有仓库
如果镜像需要认证，需要配置 GitHub Token。

```bash
# 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
```

## 🚀 完整部署步骤

### 第一步：SSH登录服务器

```bash
# SSH 登录服务器
ssh root@your-server-ip

# 或使用用户名登录
ssh your-username@your-server-ip
sudo su -
```

### 第二步：获取项目代码

#### 2.1 创建项目目录
```bash
mkdir -p /opt
cd /opt
```

#### 2.2 克隆项目
```bash
# 克隆 UpdateHub 项目（替换为实际的仓库地址）
git clone https://github.com/your-username/UpdateHub.git

# 进入项目目录
cd UpdateHub
```

#### 2.3 验证项目结构
```bash
ls -la

# 应该看到：
# backend/  frontend/  docker/  docs/  scripts/  .github/
```

### 第三步：准备脚本

#### 3.1 进入脚本目录
```bash
cd scripts
```

#### 3.2 赋予执行权限
```bash
chmod +x *.sh
```

#### 3.3 运行环境检查
```bash
./check_env.sh
```

确保所有检查通过后继续。

### 第四步：配置环境变量

#### 4.1 进入 docker 目录
```bash
cd /opt/UpdateHub/docker
```

#### 4.2 复制环境变量模板
```bash
cp .env.example .env
```

#### 4.3 编辑环境变量
```bash
nano .env
# 或使用 vim
vim .env
```

#### 4.4 配置关键变量

**数据库配置**：
```bash
# PostgreSQL 数据库
POSTGRES_DB=updatehub
POSTGRES_USER=updatehub
POSTGRES_PASSWORD=your-strong-password  # ⚠️ 修改为强密码
POSTGRES_HOST=updatehub-postgres
POSTGRES_PORT=5432
```

**Redis 配置**：
```bash
# Redis 配置
REDIS_HOST=updatehub-redis
REDIS_PORT=6379
REDIS_PASSWORD=                     # 如果需要密码，设置此项
```

**JWT 配置**：
```bash
# JWT 密钥（必须修改）
JWT_SECRET=your-random-jwt-secret-key-2024  # ⚠️ 修改为随机字符串
JWT_REFRESH_SECRET=your-refresh-secret-key-2024  # ⚠️ 修改为随机字符串
JWT_EXPIRE_HOURS=24
JWT_REFRESH_EXPIRE_HOURS=168
```

**镜像配置（CI/CD 核心）**：
```bash
# Docker 镜像配置
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:latest
UPDATEHUB_VERSION=latest
```

**服务配置**：
```bash
# 服务配置
SERVER_PORT=8080
SERVER_MODE=release
```

**存储配置**：
```bash
# 存储配置
STORAGE_TYPE=local
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE=1073741824
CHUNK_SIZE=5242880
```

**邮件配置（可选）**：
```bash
# 邮件配置
MAIL_ENABLED=false
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USER=noreply@example.com
MAIL_PASSWORD=your-mail-password
MAIL_FROM=UpdateHub <noreply@example.com>
```

#### 4.5 保存并退出

在 nano 中：
- 按 `Ctrl + O` 保存
- 按 `Ctrl + X` 退出

在 vim 中：
- 按 `:wq` 保存并退出

### 第五步：拉取预构建镜像

#### 5.1 拉取后端镜像
```bash
docker pull ghcr.io/your-username/updatehub-backend:latest
```

#### 5.2 拉取前端镜像
```bash
docker pull ghcr.io/your-username/updatehub-frontend:latest
```

#### 5.3 验证镜像拉取
```bash
docker images | grep updatehub

# 应该看到：
# ghcr.io/your-username/updatehub-backend   latest    abc123    2 days ago   150MB
# ghcr.io/your-username/updatehub-frontend  latest    def456    2 days ago   50MB
```

### 第六步：启动服务

#### 6.1 使用 Docker Compose 启动
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 6.2 查看容器状态
```bash
docker-compose -f docker/docker-compose.1panel.yml ps
```

应该看到4个容器都在运行：
```
NAME                      STATUS
updatehub-postgres         Up
updatehub-redis            Up  
updatehub-backend          Up
updatehub-frontend         Up
```

#### 6.3 查看启动日志
```bash
# 查看所有服务日志
docker-compose -f docker/docker-compose.1panel.yml logs -f

# 只查看后端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f backend

# 只查看前端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f frontend
```

### 第七步：验证部署

#### 7.1 检查后端健康
```bash
curl http://localhost:8080/health

# 应该返回：
# {"message":"UpdateHub server is running","status":"ok"}
```

#### 7.2 检查前端访问
```bash
curl http://localhost/

# 应该返回 HTML 内容
```

#### 7.3 检查数据库连接
```bash
# 进入后端容器
docker exec -it updatehub-backend /bin/sh

# 检查数据库表
sqlite3 /app/data/updatehub.db ".tables"

# 退出容器
exit
```

### 第八步：在 1Panel 中查看容器

#### 8.1 登录 1Panel
在浏览器中访问：
```
http://your-server-ip:10086
```

#### 8.2 查看容器列表

1. 点击左侧菜单的 **容器**
2. 你会看到 4 个 UpdateHub 相关的容器：
   - `updatehub-postgres` - PostgreSQL 数据库
   - `updatehub-redis` - Redis 缓存
   - `updatehub-backend` - 后端服务
   - `updatehub-frontend` - 前端服务

3. 每个容器应该显示 **运行中** 状态

#### 8.3 查看容器详情

点击任意容器可以查看：
- **容器日志**：实时查看容器日志
- **资源使用**：CPU、内存、网络使用情况
- **端口映射**：查看端口映射配置
- **环境变量**：查看环境变量配置
- **挂载卷**：查看数据卷挂载情况

#### 8.4 容器管理操作

在 1Panel 中可以对容器执行以下操作：
- ✅ **启动/停止/重启**：控制容器运行状态
- ✅ **查看日志**：实时查看容器日志
- ✅ **进入终端**：进入容器内部执行命令
- ✅ **查看详情**：查看容器详细信息
- ✅ **删除容器**：删除容器（数据卷保留）

### 第九步：访问 UpdateHub 系统

#### 9.1 访问前端界面

在浏览器中访问：
```
http://your-server-ip
```

你应该看到 UpdateHub 的登录界面。

#### 9.2 使用默认账户登录

使用以下默认账户登录：
- **用户名**: `admin`
- **密码**: `admin123`

#### 9.3 修改默认密码

登录后，**立即修改默认密码**：

1. 点击右上角的用户名
2. 选择 **修改密码**
3. 输入新密码并确认
4. 保存更改

## 🔧 使用自动化脚本部署

如果你想使用自动化脚本完成整个部署过程：

### 使用部署脚本

```bash
cd /opt/UpdateHub/scripts
./deploy.sh
```

脚本会自动：
- ✅ 检查环境
- ✅ 配置环境变量
- ✅ 拉取预构建镜像
- ✅ 启动服务
- ✅ 验证部署

详细说明请参考 [第一次部署指南](FIRST_TIME_DEPLOYMENT.md)。

## 📊 部署架构

### 容器架构

```
┌─────────────────────────────────────────┐
│            Nginx / 浏览器                │
└──────────────────┬──────────────────────┘
                   │
                   │ HTTP (80)
                   ▼
┌─────────────────────────────────────────┐
│         updatehub-frontend              │
│         (Vue 3 + Element Plus)         │
└──────────────────┬──────────────────────┘
                   │
                   │ HTTP (8080)
                   ▼
┌─────────────────────────────────────────┐
│         updatehub-backend               │
│         (Go + Gin + GORM)               │
└────────┬──────────────────┬─────────────┘
         │                  │
         │                  │
         ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│updatehub-postgres│  │ updatehub-redis │
│   (PostgreSQL)   │  │    (Redis)      │
└─────────────────┘  └─────────────────┘
```

### 数据持久化

所有重要数据都通过 Docker 卷持久化：

- **PostgreSQL 数据**: `updatehub-postgres-data`
- **Redis 数据**: `updatehub-redis-data`
- **上传文件**: `updatehub-uploads`
- **配置文件**: `updatehub-configs`

这些数据在容器删除后仍然保留。

## 🔄 更新系统（CI/CD 方式）

### 使用自动化脚本更新

```bash
cd /opt/UpdateHub/scripts
./update.sh
```

脚本会自动：
- ✅ 备份当前配置
- ✅ 拉取新版本镜像
- ✅ 更新服务
- ✅ 验证更新结果

### 手动更新镜像

#### 更新到最新版本
```bash
# 1. 拉取新镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
docker pull ghcr.io/your-username/updatehub-frontend:latest

# 2. 重启服务
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 更新到特定版本
```bash
# 1. 修改 .env 文件中的镜像版本
# BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
# FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0.0

# 2. 拉取新镜像
docker pull ghcr.io/your-username/updatehub-backend:v1.0.0
docker pull ghcr.io/your-username/updatehub-frontend:v1.0.0

# 3. 重启服务
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 在 1Panel 中更新

1. 进入 1Panel 的容器页面
2. 选择要更新的容器（后端或前端）
3. 点击 **删除**（注意：勾选 "保留数据卷"）
4. SSH 登录服务器
5. 拉取新镜像
6. 重新启动服务

## 🔧 常见运维操作

### 查看服务状态

#### 方法1：使用 Docker Compose
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml ps
```

#### 方法2：使用 1Panel
在 1Panel 的容器页面查看所有容器状态

### 查看服务日志

#### 方法1：使用 Docker Compose
```bash
# 查看所有服务日志
docker-compose -f docker/docker-compose.1panel.yml logs -f

# 只查看后端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f backend

# 只查看前端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f frontend
```

#### 方法2：使用 1Panel
在 1Panel 中点击容器 -> 查看日志

### 重启服务

#### 方法1：使用 Docker Compose
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml restart
```

#### 方法2：使用 1Panel
在 1Panel 中点击容器 -> 重启

### 停止服务

#### 方法1：使用 Docker Compose
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

#### 方法2：使用 1Panel
在 1Panel 中点击容器 -> 停止

### 启动服务

#### 方法1：使用 Docker Compose
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 方法2：使用 1Panel
在 1Panel 中点击容器 -> 启动

## 🔧 备份与恢复

### 自动备份

```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

### 手动备份

#### 备份数据库
```bash
# 备份 PostgreSQL 数据
docker exec updatehub-postgres pg_dump -U updatehub updatehub > backup.sql
```

#### 备份上传文件
```bash
# 备份上传文件
tar -czf uploads_backup.tar.gz /opt/UpdateHub/backend/uploads
```

#### 备份配置文件
```bash
# 备份配置文件
cp /opt/UpdateHub/docker/.env /opt/UpdateHub/backups/env_backup_$(date +%Y%m%d)
```

### 恢复数据

#### 恢复数据库
```bash
# 恢复 PostgreSQL 数据
docker exec -i updatehub-postgres psql -U updatehub updatehub < backup.sql
```

#### 恢复上传文件
```bash
# 恢复上传文件
tar -xzf uploads_backup.tar.gz -C /
```

## 🔧 常见问题处理

### 问题1：容器无法启动

**现象**：
```
docker-compose up -d 后容器立即退出
```

**解决方法**：
```bash
# 查看容器日志
docker logs updatehub-backend

# 检查环境变量配置
cat /opt/UpdateHub/docker/.env

# 检查镜像是否正确拉取
docker images | grep updatehub
```

### 问题2：无法拉取 GitHub 镜像

**现象**：
```
Error response from daemon: pull access denied
```

**解决方法**：
```bash
# 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 重新拉取镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
```

### 问题3：容器在 1Panel 中不显示

**现象**：
```
Docker 容器运行正常，但在 1Panel 中看不到
```

**解决方法**：
```bash
# 重启 1Panel 服务
systemctl restart 1panel

# 清除 1Panel 缓存
rm -rf /opt/1panel/data/container/*
systemctl restart 1panel
```

### 问题4：端口冲突

**现象**：
```
Error: bind: address already in use
```

**解决方法**：
```bash
# 检查端口占用
netstat -tlnp | grep 8080

# 修改 .env 文件中的端口配置
SERVER_PORT=8081

# 重新启动服务
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 问题5：数据库连接失败

**现象**：
```
后端日志显示数据库连接错误
```

**解决方法**：
```bash
# 检查 PostgreSQL 容器状态
docker ps | grep postgres

# 检查数据库密码配置
cat /opt/UpdateHub/docker/.env | grep POSTGRES_PASSWORD

# 进入 PostgreSQL 容器测试连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

## 🎯 性能优化

### 资源限制

编辑 `docker/docker-compose.1panel.yml`，添加资源限制：

```yaml
services:
  backend:
    image: ${BACKEND_IMAGE}
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### 日志限制

防止日志文件过大：

```yaml
services:
  backend:
    image: ${BACKEND_IMAGE}
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 📊 监控与告警

### 使用 1Panel 监控

1Panel 提供内置的监控功能：

1. 进入 1Panel 的 **监控** 页面
2. 查看容器资源使用情况
3. 设置告警规则

### 自定义监控

可以使用 Prometheus + Grafana 进行更详细的监控。

## 🎉 完成！

你已经成功在 1Panel 环境中部署了 UpdateHub！

### 🚀 CI/CD 部署的优势

- **部署快速**：2-5分钟完成部署
- **资源节省**：服务器不需要构建环境
- **网络节省**：只拉取镜像，不下载依赖
- **一致性高**：所有环境使用相同的预构建镜像
- **版本管理**：清晰的镜像版本标签

### 📝 下一步

- [ ] 修改默认密码
- [ ] 配置存储后端
- [ ] 配置邮件通知
- [ ] 设置自动备份
- [ ] 配置监控告警
- [ ] 创建第一个软件项目

### 📞 获取帮助

如果遇到问题，请参考：
- [第一次部署指南](FIRST_TIME_DEPLOYMENT.md)
- [服务更新指南](SERVICE_UPDATE.md)
- [快速开始指南](QUICK_START.md)
