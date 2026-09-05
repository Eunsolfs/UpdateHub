# UpdateHub 快速开始指南

本指南帮助您快速开始使用 UpdateHub（基于 CI/CD 预构建镜像部署）。

## 📚 文档导航

**第一次使用？** → 查看 [第一次部署完整操作指南](./FIRST_TIME_DEPLOYMENT.md) ⭐

**需要详细文档？** → 查看 [文档导航](./INDEX.md)

**了解版本管理？** → 查看 [版本发布指南](./VERSION_RELEASE.md) ⭐

## 🚀 CI/CD 部署方式（推荐）⭐

UpdateHub 现在使用现代化的 CI/CD 部署方式：

### 优势

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

## 🎯 快速部署步骤

### 1. 准备服务器

确保服务器满足要求：
- **操作系统**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **Docker**: 已安装
- **Docker Compose**: 已安装
- **网络**: 能访问 GitHub Container Registry

### 2. 获取项目代码

```bash
# 克隆项目
git clone https://github.com/your-username/UpdateHub.git
cd UpdateHub
```

### 3. 配置环境变量

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

### 4. 拉取预构建镜像

```bash
# 拉取后端镜像
docker pull ghcr.io/your-username/updatehub-backend:latest

# 拉取前端镜像
docker pull ghcr.io/your-username/updatehub-frontend:latest
```

### 5. 启动服务

```bash
# 使用 1Panel 优化配置
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 6. 验证部署

```bash
# 检查容器状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 检查后端健康
curl http://localhost:8080/health

# 检查前端访问
curl http://localhost/
```

## 🚀 使用自动化脚本（更简单）⭐

### Linux 脚本

```bash
cd /opt/UpdateHub/scripts
chmod +x *.sh
./check_env.sh      # 环境检查
./deploy.sh         # 一键部署（CI/CD版本）
```

### Windows 脚本

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

## 📍 默认访问地址

- **前端**: http://localhost
- **后端 API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health

## 🔑 默认账户

- **用户名**: admin
- **密码**: admin123

⚠️ **重要**: 生产环境请立即修改默认密码！

## 🔧 基础配置

### 修改数据库密码

编辑 `docker/.env`：

```bash
POSTGRES_PASSWORD=your_strong_password_here
```

### 修改 JWT 密钥

编辑 `docker/.env`：

```bash
JWT_SECRET=your_jwt_secret_key_here
```

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

## 📱 客户端对接

### C++ 客户端

完整的 C++ 客户端库位于 `UpdateHub-Client/` 目录。

查看 C++ 客户端文档：
```bash
cd UpdateHub-Client
cat README.md
```

### API 对接示例

```bash
# 检查更新
curl -X POST http://localhost:8080/api/v1/check-update \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "my-app",
    "current_version": "1.0.0",
    "platform": "windows"
  }'

# 获取下载 Token
curl -X POST http://localhost:8080/api/v1/download/token \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "my-app",
    "current_version": "1.0.0",
    "platform": "windows"
  }'
```

## 🔍 常见问题

### 镜像拉取失败

```bash
# 登录 GitHub Container Registry（如果需要）
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 重新拉取镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
```

### 容器无法启动

```bash
# 查看日志
docker-compose -f docker/docker-compose.1panel.yml logs

# 检查环境变量配置
cat docker/.env
```

### 数据库连接失败

```bash
# 检查数据库容器
docker ps | grep postgres

# 测试数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

### 前端无法访问

```bash
# 检查前端容器
docker ps | grep frontend

# 检查 nginx 配置
docker exec -it updatehub-frontend cat /etc/nginx/nginx.conf
```

## 📞 获取帮助

- 查看 [版本发布指南](./VERSION_RELEASE.md) - 了解版本管理
- 查看 [第一次部署完整操作指南](./FIRST_TIME_DEPLOYMENT.md) - 详细部署步骤
- 查看 [文档导航](./INDEX.md) - 更多文档
- 查看 [GitHub Issues](https://github.com/your-username/UpdateHub/issues)

## 🎯 下一步

1. 配置第一个软件项目
2. 发布第一个版本
3. 配置客户端更新检查
4. 设置定时备份
5. 配置监控告警
6. 了解版本发布管理

## 📖 更多资源

- [版本发布指南](./VERSION_RELEASE.md) - 基于 tag 的版本发布
- [第一次部署完整操作指南](./FIRST_TIME_DEPLOYMENT.md) - 详细部署步骤
- [1Panel 部署教程](./1PANEL_DEPLOYMENT.md) - 1Panel 环境部署
- [服务更新教程](./SERVICE_UPDATE.md) - 系统更新指南
