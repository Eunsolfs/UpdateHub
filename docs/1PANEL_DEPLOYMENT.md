# UpdateHub 1Panel 部署教程

本教程将指导您如何在 1Panel 环境中部署 UpdateHub 软件更新管理系统。

## 📋 前置要求

### 1. 系统要求
- 已安装 1Panel 的 Linux 服务器
- 服务器至少 2GB RAM
- 至少 20GB 可用磁盘空间
- 具有管理员权限

### 2. 软件要求
- 1Panel 已安装并正常运行
- Docker 已安装（1Panel 会自动安装）
- 网络连接正常

## 🚀 部署方式

### 方式一：使用自动化脚本（推荐）⭐

这是最简单的方式，只需运行一个脚本即可完成所有部署步骤。

#### 1. 环境检查
```bash
cd /opt/UpdateHub/scripts
chmod +x check_env.sh
./check_env.sh
```

#### 2. 一键部署
```bash
./deploy.sh
```

脚本会自动：
- ✅ 检查环境依赖
- ✅ 交互式配置向导
- ✅ 创建目录结构
- ✅ 克隆项目代码
- ✅ 生成配置文件
- ✅ 构建 Docker 镜像
- ✅ 启动所有服务
- ✅ 验证部署结果

#### 3. 访问系统
部署完成后，脚本会显示访问信息：
```
UpdateHub 已成功安装！

访问地址:
  前端: http://your-server-ip
  后端: http://your-server-ip:8080
  健康检查: http://your-server-ip:8080/health

默认账户:
  用户名: admin
  密码: admin123
```

### 方式二：手动部署

如果您需要更多控制，可以选择手动部署。

#### 第一步：准备服务器环境

##### 1.1 登录 1Panel
```bash
# 通过浏览器访问 1Panel
http://your-server-ip:10086
```

##### 1.2 检查系统状态
- 确认 Docker 运行正常
- 确认有足够的磁盘空间
- 确认网络连接正常

##### 1.3 安装 Git（如果未安装）
```bash
# 在 1Panel 终端中执行
apt update && apt install -y git
# 或
yum install -y git
```

#### 第二步：获取项目代码

##### 2.1 克隆项目代码
```bash
# 在服务器上执行
cd /opt
git clone https://github.com/your-username/UpdateHub.git
cd UpdateHub
```

**注意**：请将 `https://github.com/your-username/UpdateHub.git` 替换为实际的仓库地址。

#### 第三步：配置环境变量

##### 3.1 创建环境变量文件
```bash
cd /opt/UpdateHub
cp docker/.env.example docker/.env
nano docker/.env
```

**重要配置修改**：

```bash
# 修改数据库密码（生产环境必须修改）
POSTGRES_PASSWORD=your_strong_password_here

# 修改 JWT 密钥
JWT_SECRET=your_jwt_secret_key_change_this_in_production

# 修改 Redis 密钥（可选）
REDIS_PASSWORD=your_redis_password_here
```

##### 3.2 使用 1Panel 专用配置
```bash
# 使用专为 1Panel 优化的配置文件
cp docker/docker-compose.1panel.yml docker/docker-compose.yml.backup
```

**1Panel 专用配置优势**：
- 支持环境变量配置
- 内置健康检查
- 优化的备份目录
- 生产环境模式预设

#### 第四步：创建必要的目录

```bash
# 在 1Panel 文件管理中创建目录
mkdir -p /opt/UpdateHub/backend/uploads
mkdir -p /opt/UpdateHub/backend/uploads/temp
mkdir -p /opt/UpdateHub/backend/configs
```

#### 第五步：构建和启动服务

##### 5.1 使用 Docker Compose 构建
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml build
```

##### 5.2 启动所有服务
```bash
docker-compose -f docker/docker-compose.1panel.yml up -d
```

##### 5.3 检查服务状态
```bash
docker-compose -f docker/docker-compose.1panel.yml ps
```

#### 第六步：配置 Nginx 反向代理（可选）

##### 6.1 在 1Panel 中创建网站
1. 进入 1Panel -> 网站 -> 创建网站
2. 选择反向代理
3. 填写域名和端口配置

##### 6.2 配置 SSL 证书（推荐）
1. 在 1Panel 中申请 Let's Encrypt 证书
2. 启用 HTTPS
3. 配置强制 HTTPS 重定向

#### 第七步：初始化数据库

##### 7.1 进入后端容器
```bash
docker exec -it updatehub-backend sh
```

##### 7.2 执行数据库迁移
```bash
# 如果有迁移脚本
./updatehub-server migrate
```

##### 7.3 创建默认管理员账户
```bash
# 通过 API 或直接在数据库中创建
# 默认账户：admin / admin123
```

#### 第八步：验证部署

##### 8.1 检查前端访问
```bash
# 访问前端
http://your-server-ip

# 应该看到 UpdateHub 登录页面
```

##### 8.2 检查后端 API
```bash
# 测试健康检查
curl http://your-server-ip:8080/health

# 应该返回
{"message":"UpdateHub server is running","status":"ok"}
```

##### 8.3 测试登录
```bash
# 使用默认账户登录
curl -X POST http://your-server-ip:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 🔧 高级配置

### 修改默认配置

#### 1. 后端配置文件
```bash
# 编辑后端配置
nano /opt/UpdateHub/backend/configs/config.yaml
```

#### 2. 修改 JWT 密钥
```yaml
jwt:
  secret: your_jwt_secret_key_here
  expire_hours: 24
```

#### 3. 修改存储配置
```yaml
storage:
  type: local  # 或 s3, cos, minio
  local:
    path: /root/uploads
```

### 配置外部存储

#### 1. 配置 S3 存储
```yaml
storage:
  type: s3
  s3:
    region: us-east-1
    access_key: your_access_key
    secret_key: your_secret_key
    bucket: your-bucket-name
```

#### 2. 配置腾讯云 COS
```yaml
storage:
  type: cos
  cos:
    region: ap-guangzhou
    secret_id: your_secret_id
    secret_key: your_secret_key
    bucket: your-bucket-name
```

### 配置邮件通知

#### 1. 修改配置文件
```yaml
email:
  enabled: true
  smtp:
    host: smtp.gmail.com
    port: 587
    username: your_email@gmail.com
    password: your_app_password
```

## 📊 监控和日志

### 查看服务日志

#### 1. 查看所有服务日志
```bash
docker-compose -f docker/docker-compose.1panel.yml logs -f
```

#### 2. 查看特定服务日志
```bash
# 后端日志
docker logs -f updatehub-backend

# 前端日志
docker logs -f updatehub-frontend

# 数据库日志
docker logs -f updatehub-postgres
```

### 监控服务状态

#### 1. 在 1Panel 中监控
- 进入 1Panel -> 容器
- 查看容器运行状态
- 查看资源使用情况

#### 2. 使用命令行监控
```bash
# 查看容器状态
docker ps

# 查看资源使用
docker stats
```

## 🔒 安全加固

### 1. 修改默认密码
```bash
# 登录后立即修改默认管理员密码
# 进入用户管理 -> 修改密码
```

### 2. 配置防火墙
```bash
# 在 1Panel 安全组中配置
# 只开放必要的端口
# 80 (HTTP)
# 443 (HTTPS)
# 22 (SSH)
```

### 3. 启用 SSL/TLS
```bash
# 在 1Panel 中配置 SSL 证书
# 启用 HTTPS
```

### 4. 定期备份
```bash
# 配置数据库自动备份
# 在 1Panel 备份计划中设置
```

## 🐛 故障排除

### 常见问题

#### 1. 容器启动失败
```bash
# 查看容器日志
docker logs updatehub-backend

# 检查端口占用
netstat -tulpn | grep 8080
```

#### 2. 数据库连接失败
```bash
# 检查数据库容器状态
docker ps | grep postgres

# 检查数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

#### 3. 前端无法访问后端
```bash
# 检查网络连接
docker exec -it updatehub-frontend ping updatehub-backend

# 检查 nginx 配置
docker exec -it updatehub-frontend cat /etc/nginx/nginx.conf
```

#### 4. 文件上传失败
```bash
# 检查上传目录权限
ls -la /opt/UpdateHub/backend/uploads

# 修改权限
chmod 755 /opt/UpdateHub/backend/uploads
```

### 日志分析

#### 1. 后端错误日志
```bash
docker logs updatehub-backend 2>&1 | grep ERROR
```

#### 2. 数据库慢查询
```bash
docker logs updatehub-postgres 2>&1 | grep "slow query"
```

## 📈 性能优化

### 1. 数据库优化
```sql
-- 在数据库中执行
VACUUM ANALYZE;
REINDEX DATABASE updatehub;
```

### 2. Redis 缓存配置
```yaml
# 修改 Redis 配置
maxmemory 256mb
maxmemory-policy allkeys-lru
```

### 3. Nginx 性能优化
```nginx
# 在 nginx.conf 中添加
worker_processes auto;
worker_connections 1024;
```

## 🔄 自动化脚本管理

### 自动备份
```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

### 自动更新
```bash
cd /opt/UpdateHub/scripts
./update.sh
```

### 环境检查
```bash
cd /opt/UpdateHub/scripts
./check_env.sh
```

## 🔄 部署后检查清单

- [ ] 所有容器正常运行
- [ ] 前端可以正常访问
- [ ] 后端 API 响应正常
- [ ] 数据库连接正常
- [ ] 文件上传功能正常
- [ ] WebSocket 连接正常
- [ ] 默认密码已修改
- [ ] SSL 证书已配置
- [ ] 备份计划已设置
- [ ] 监控告警已配置

## 📞 技术支持

如果遇到问题，请：
1. 查看日志文件
2. 检查配置文件
3. 参考 GitHub Issues
4. 联系技术支持

## 🎉 部署完成

恭喜！您已成功在 1Panel 中部署 UpdateHub。现在可以开始使用软件更新管理功能了。

### 下一步
- 配置第一个软件项目
- 发布第一个版本
- 配置客户端更新检查
- 设置自动备份
- 配置监控告警
