# UpdateHub 部署指南（CI/CD 预构建镜像版本）

## 🚀 部署方式说明

UpdateHub 现在使用现代化的 CI/CD 部署方式，使用 GitHub Actions 自动构建的预构建 Docker 镜像。

### CI/CD 部署优势

- ⚡ **部署快速**：2-5分钟完成部署
- 💾 **资源节省**：服务器不需要构建环境
- 🌐 **网络节省**：只拉取镜像，不下载依赖
- 🎯 **构建标准化**：所有环境使用相同的预构建镜像
- 📦 **版本管理清晰**：支持基于 tag 的版本发布

### 部署流程

```
GitHub 发布新版本/标签
    ↓
GitHub Actions 自动构建镜像
    ↓
镜像推送到 GitHub Container Registry
    ↓
服务器拉取预构建镜像
    ↓
Docker Compose 启动服务
```

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

### GitHub Container Registry 访问

**镜像命名规则**：GitHub Container Registry 要求镜像名称必须使用小写字母。

- ❌ 错误：`ghcr.io/MyUser/UpdateHub-backend`
- ✅ 正确：`ghcr.io/myuser/updatehub-backend`

## 🚀 快速部署

### 方法1：使用自动化脚本（推荐）⭐

#### Linux 脚本

```bash
cd /opt/UpdateHub/scripts
chmod +x *.sh
./check_env.sh      # 环境检查
./deploy.sh         # 一键部署（CI/CD版本）
```

#### Windows 脚本

```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\check_env.ps1     # 环境检查
.\deploy.ps1        # 一键部署（CI/CD版本）
```

脚本会自动：
- ✅ 检查环境
- ✅ 配置环境变量
- ✅ 拉取预构建镜像
- ✅ 启动服务
- ✅ 验证部署

### 方法2：手动部署

#### 1. 克隆项目

```bash
git clone https://github.com/your-username/UpdateHub.git
cd UpdateHub
```

#### 2. 配置环境变量

```bash
# 复制环境变量模板
cp docker/.env.example docker/.env

# 编辑环境变量
nano docker/.env
```

**关键配置**：
```bash
# Docker 镜像配置（将 your-username 替换为你的 GitHub 用户名，必须小写）
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:latest

# 数据库密码（必须修改）
POSTGRES_PASSWORD=your_strong_password_here

# JWT 密钥（必须修改）
JWT_SECRET=your_jwt_secret_key_here
```

#### 3. 拉取预构建镜像

```bash
# 拉取后端镜像
docker pull ghcr.io/your-username/updatehub-backend:latest

# 拉取前端镜像
docker pull ghcr.io/your-username/updatehub-frontend:latest
```

#### 4. 启动服务

```bash
# 使用 1Panel 优化配置
docker-compose -f docker/docker-compose.1panel.yml up -d

# 或使用标准配置
docker-compose -f docker/docker-compose.yml up -d
```

#### 5. 验证部署

```bash
# 检查容器状态
docker-compose -f docker/docker-compose.1panel.yml ps

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

## 🔧 配置说明

### 使用特定版本

编辑 `docker/.env`：

```bash
# 使用版本标签（推荐生产环境）
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0.0
```

然后重启服务：

```bash
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 数据库配置

在 `docker/.env` 中配置：

```bash
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=updatehub
POSTGRES_USER=updatehub
```

### JWT 配置

在 `docker/.env` 中配置：

```bash
JWT_SECRET=your_jwt_secret_key_here
REFRESH_SECRET=your_refresh_secret_key_here
```

### 存储配置

在 `docker/.env` 中配置：

```bash
STORAGE_TYPE=local  # local, s3, cos, minio
```

## 🔄 更新系统

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

### 手动更新

```bash
# 1. 拉取新镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
docker pull ghcr.io/your-username/updatehub-frontend:latest

# 2. 重启服务
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 版本回滚

```bash
# 1. 修改 .env 文件回退到之前版本
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0.0

# 2. 重启服务
docker-compose -f docker/docker-compose.1panel.yml up -d
```

## 🏗️ 生产环境部署建议

### 1. 使用 HTTPS

配置 SSL 证书，推荐使用 Let's Encrypt：

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 2. 配置防火墙

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. 使用固定版本

生产环境建议使用固定版本标签：

```bash
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0.0
```

这样可以：
- ✅ 避免自动更新导致的问题
- ✅ 确保环境稳定性
- ✅ 便于版本回滚

### 4. 设置自动备份

```bash
# 添加到 crontab
0 2 * * * /opt/UpdateHub/scripts/backup.sh
```

### 5. 监控日志

```bash
# 查看容器日志
docker-compose -f docker/docker-compose.1panel.yml logs -f backend
docker-compose -f docker/docker-compose.1panel.yml logs -f frontend
```

### 6. 资源限制

在 `docker/docker-compose.1panel.yml` 中添加资源限制：

```yaml
backend:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        cpus: '1'
        memory: 1G
```

## 🔧 故障排除

### 镜像拉取失败

```bash
# 登录 GitHub Container Registry（如果需要）
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 重新拉取镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
```

### 容器无法启动

```bash
# 查看容器日志
docker-compose -f docker/docker-compose.1panel.yml logs backend
docker-compose -f docker/docker-compose.1panel.yml logs postgres

# 检查环境变量配置
cat docker/.env
```

### 数据库连接失败

检查数据库配置是否正确，确保数据库容器正在运行：

```bash
docker-compose -f docker/docker-compose.1panel.yml ps
docker-compose -f docker/docker-compose.1panel.yml logs postgres
```

### 前端无法访问后端

检查后端服务状态：

```bash
docker-compose -f docker/docker-compose.1panel.yml logs backend
docker-compose -f docker/docker-compose.1panel.yml logs frontend
```

## 📚 相关文档

- [版本发布指南](./VERSION_RELEASE.md) - 基于 tag 的版本发布
- [第一次部署完整操作指南](./FIRST_TIME_DEPLOYMENT.md) - 详细部署步骤
- [1Panel 部署教程](./1PANEL_DEPLOYMENT.md) - 1Panel 环境部署
- [服务更新教程](./SERVICE_UPDATE.md) - 系统更新指南
- [快速开始指南](./QUICK_START.md) - 快速上手

## 🆘 获取帮助

- 查看 [版本发布指南](./VERSION_RELEASE.md) - 了解版本管理
- 查看 [文档导航](./INDEX.md) - 更多文档
- 查看 [GitHub Issues](https://github.com/your-username/UpdateHub/issues)
