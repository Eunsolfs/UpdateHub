# UpdateHub 快速开始指南

本指南帮助您快速开始使用 UpdateHub。

## 📚 文档索引

1. **[1Panel 部署教程](./1PANEL_DEPLOYMENT.md)** - 在 1Panel 环境中部署 UpdateHub
2. **[服务更新教程](./SERVICE_UPDATE.md)** - 更新 UpdateHub 到最新版本
3. **[API 文档](./API.md)** - API 接口文档
4. **[开发文档](./DEVELOPMENT.md)** - 开发者指南
5. **[部署文档](./DEPLOYMENT.md)** - 通用部署指南

## 🚀 快速部署

### 使用 Docker Compose（推荐）

```bash
# 克隆项目
git clone https://github.com/your-username/UpdateHub.git
cd UpdateHub

# 使用 1Panel 优化配置
docker-compose -f docker/docker-compose.1panel.yml up -d

# 或使用标准配置
docker-compose -f docker/docker-compose.yml up -d
```

### 默认访问地址

- **前端**: http://localhost
- **后端 API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health

### 默认账户

- **用户名**: admin
- **密码**: admin123

⚠️ **重要**: 生产环境请立即修改默认密码！

## 🔧 基础配置

### 修改数据库密码

编辑 `docker/docker-compose.1panel.yml`:

```yaml
environment:
  POSTGRES_PASSWORD: your_strong_password_here
```

### 修改 JWT 密钥

编辑 `backend/configs/config.yaml`:

```yaml
jwt:
  secret: your_jwt_secret_key_here
```

### 配置存储

编辑 `backend/configs/config.yaml`:

```yaml
storage:
  default: local  # 或 s3, cos, minio
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

### 容器无法启动

```bash
# 查看日志
docker-compose -f docker/docker-compose.1panel.yml logs

# 检查端口占用
netstat -tulpn | grep 8080
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

- 查看 [GitHub Issues](https://github.com/your-username/UpdateHub/issues)
- 参考 [API 文档](./API.md)
- 联系技术支持

## 🎯 下一步

1. 配置第一个软件项目
2. 发布第一个版本
3. 配置客户端更新检查
4. 设置定时备份
5. 配置监控告警

## 📖 更多资源

- [官网文档](https://updatehub.example.com)
- [社区论坛](https://forum.updatehub.example.com)
- [视频教程](https://youtube.com/updatehub)
