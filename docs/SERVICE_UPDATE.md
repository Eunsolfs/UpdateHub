# UpdateHub 服务更新完整指南

本指南详细说明如何更新 UpdateHub 系统，使用预构建的 Docker 镜像（CI/CD 方式）。

## 🎯 更新方式说明

### CI/CD 更新方式

UpdateHub 现在使用 GitHub Actions 自动构建 Docker 镜像，更新时只需拉取新版本的预构建镜像。

**更新流程**：
```
GitHub 发布新版本
    ↓
GitHub Actions 自动构建镜像
    ↓
镜像推送到 GitHub Container Registry
    ↓
服务器拉取新镜像
    ↓
重启服务使用新镜像
```

**优势**：
- ⚡ 更新速度快（2-5分钟）
- 💾 服务器不需要构建环境
- 🌐 网络消耗小
- 🎯 构建环境标准化
- 📦 版本管理清晰
- 🔄 支持版本回滚

## 📋 更新前准备

### 1. 检查当前版本

#### 查看当前运行的镜像
```bash
docker images | grep updatehub

# 输出示例：
# ghcr.io/your-username/updatehub-backend   latest    abc123    2 days ago   150MB
# ghcr.io/your-username/updatehub-frontend  latest    def456    2 days ago   50MB
```

#### 查看当前容器状态
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml ps
```

#### 查看当前配置
```bash
cat /opt/UpdateHub/docker/.env
```

### 2. 备份数据

#### 使用自动化脚本备份
```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

#### 手动备份

**备份数据库**：
```bash
# 备份 PostgreSQL 数据
docker exec updatehub-postgres pg_dump -U updatehub updatehub > /opt/UpdateHub/backups/db_backup_$(date +%Y%m%d).sql
```

**备份上传文件**：
```bash
# 备份上传文件
tar -czf /opt/UpdateHub/backups/uploads_backup_$(date +%Y%m%d).tar.gz /opt/UpdateHub/backend/uploads
```

**备份配置文件**：
```bash
# 备份配置文件
cp /opt/UpdateHub/docker/.env /opt/UpdateHub/backups/env_backup_$(date +%Y%m%d)
```

### 3. 确认更新方式

选择更新方式：

- **方案A：自动化脚本更新**（推荐）- 最简单，全自动
- **方案B：手动更新** - 更灵活，适合高级用户
- **方案C：特定版本更新** - 更新到指定版本
- **方案D：版本回滚** - 回退到之前版本

## 🚀 方案A：自动化脚本更新（推荐）

### 使用一键更新脚本

#### 1. 运行更新脚本
```bash
cd /opt/UpdateHub/scripts
./update.sh
```

#### 2. 脚本执行流程

脚本会自动执行以下步骤：

```
========================================
  UpdateHub 一键更新脚本 (CI/CD版本)
========================================

[INFO] 检查环境...
[SUCCESS] Docker 已安装
[SUCCESS] Docker Compose 已安装
[SUCCESS] 项目目录存在
[SUCCESS] 环境检查完成

[INFO] 备份数据...
[INFO] 备份配置文件...
[SUCCESS] 配置文件备份完成
[INFO] 备份上传文件...
[SUCCESS] 上传文件备份完成
[INFO] 保存当前镜像信息...
[SUCCESS] 镜像信息保存完成
[SUCCESS] 数据备份完成

[INFO] 拉取新镜像...
[INFO] 拉取后端镜像: ghcr.io/your-username/updatehub-backend:latest
latest: Pulling from ghcr.io/your-username/updatehub-backend
sha256:abc123...: Pulling fs
...
[SUCCESS] 后端镜像拉取完成
[INFO] 拉取前端镜像: ghcr.io/your-username/updatehub-frontend:latest
latest: Pulling from ghcr.io/your-username/updatehub-frontend
sha256:def456...: Pulling fs
...
[SUCCESS] 前端镜像拉取完成
[SUCCESS] 镜像拉取完成

请选择更新方式:
1) 零停机更新 (推荐)
2) 完整停机更新
请输入选择 (1-2): 1

[INFO] 执行零停机更新...
[INFO] 拉取镜像...
Pulling backend ...
latest: Pulled
Pulling frontend ...
latest: Pulled
[INFO] 启动服务...
Creating updatehub-backend ... done
Creating updatehub-frontend ... done
[SUCCESS] 服务更新完成

[INFO] 等待服务启动...
[SUCCESS] 服务启动完成

[INFO] 检查容器状态...
NAME                      STATUS
updatehub-postgres         Up
updatehub-redis            Up  
updatehub-backend          Up
updatehub-frontend         Up
[SUCCESS] 容器状态正常

[INFO] 检查后端健康状态...
[SUCCESS] 后端服务正常

[INFO] 检查前端服务...
[SUCCESS] 前端服务正常
[SUCCESS] 验证完成

========================================
  更新信息
========================================

UpdateHub 已成功更新！

后端镜像: ghcr.io/your-username/updatehub-backend:latest
前端镜像: ghcr.io/your-username/updatehub-frontend:latest
更新时间: 2024-01-15 10:30:00
日志文件: /opt/UpdateHub/update.log
```

#### 3. 更新方式选择

**零停机更新（推荐）**：
- 不停止现有服务
- 拉取新镜像后立即启动
- 适合生产环境
- 有短暂的服务重叠

**完整停机更新**：
- 先停止所有服务
- 拉取新镜像
- 再启动服务
- 有短暂的服务中断
- 更新更彻底

## 🚀 方案B：手动更新

### 手动更新到最新版本

#### 1. 拉取新镜像
```bash
# 拉取后端镜像
docker pull ghcr.io/your-username/updatehub-backend:latest

# 拉取前端镜像
docker pull ghcr.io/your-username/updatehub-frontend:latest
```

#### 2. 查看新镜像
```bash
docker images | grep updatehub

# 应该看到新的镜像
```

#### 3. 停止旧服务
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

#### 4. 启动新服务
```bash
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 5. 验证更新
```bash
# 检查容器状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 检查后端健康
curl http://localhost:8080/health

# 检查前端访问
curl http://localhost/
```

## 🚀 方案C：更新到特定版本

### 更新到指定版本

#### 1. 确定目标版本

查看可用的版本标签：
```bash
# 查看后端版本标签
docker pull ghcr.io/your-username/updatehub-backend

# 查看前端版本标签
docker pull ghcr.io/your-username/updatehub-frontend
```

#### 2. 修改 .env 文件

编辑 `/opt/UpdateHub/docker/.env`：

```bash
# 修改镜像版本
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0.0
```

#### 3. 拉取指定版本镜像
```bash
docker pull ghcr.io/your-username/updatehub-backend:v1.0.0
docker pull ghcr.io/your-username/updatehub-frontend:v1.0.0
```

#### 4. 重启服务
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 5. 验证版本
```bash
# 查看运行的镜像
docker ps | grep updatehub

# 确认使用的是正确的版本
```

## 🚀 方案D：版本回滚

### 回退到之前的版本

#### 1. 查看历史镜像
```bash
docker images | grep updatehub

# 输出示例：
# ghcr.io/your-username/updatehub-backend   v1.0.0    abc123    5 days ago   150MB
# ghcr.io/your-username/updatehub-backend   v0.9.0     def456    10 days ago  145MB
# ghcr.io/your-username/updatehub-backend   latest     ghi789    2 days ago   150MB
```

#### 2. 修改 .env 文件

编辑 `/opt/UpdateHub/docker/.env`：

```bash
# 回退到之前的版本
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v0.9.0
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v0.9.0
```

#### 3. 拉取目标版本镜像（如果已存在可跳过）
```bash
docker pull ghcr.io/your-username/updatehub-backend:v0.9.0
docker pull ghcr.io/your-username/updatehub-frontend:v0.9.0
```

#### 4. 重启服务
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 5. 验证回滚
```bash
# 检查容器状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 检查后端健康
curl http://localhost:8080/health

# 确认功能正常
```

## 🔧 更新后验证

### 1. 检查容器状态
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml ps
```

所有容器应该显示为 **Up** 状态。

### 2. 检查后端健康
```bash
curl http://localhost:8080/health

# 应该返回：
# {"message":"UpdateHub server is running","status":"ok"}
```

### 3. 检查前端访问
```bash
curl http://localhost/

# 应该返回 HTML 内容
```

### 4. 检查服务日志
```bash
# 查看后端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f backend

# 查看前端日志
docker-compose -f docker/docker-compose.1panel.yml logs -f frontend
```

### 5. 功能测试

在浏览器中访问前端界面：
```
http://your-server-ip
```

测试基本功能：
- 登录
- 软件管理
- 版本发布
- 用户管理

## 🔧 在 1Panel 中更新

### 1. 登录 1Panel

在浏览器中访问：
```
http://your-server-ip:10086
```

### 2. 查看当前容器

进入 **容器** 页面，查看当前的 UpdateHub 容器。

### 3. 更新容器

#### 方法1：删除并重新创建（推荐）

1. 停止容器：
   - 选择容器
   - 点击 **停止**

2. 删除容器（保留数据卷）：
   - 选择容器
   - 点击 **删除**
   - **重要**：勾选 "保留数据卷"

3. SSH 登录服务器

4. 拉取新镜像：
   ```bash
   docker pull ghcr.io/your-username/updatehub-backend:latest
   docker pull ghcr.io/your-username/updatehub-frontend:latest
   ```

5. 重新启动服务：
   ```bash
   cd /opt/UpdateHub
   docker-compose -f docker/docker-compose.1panel.yml up -d
   ```

#### 方法2：使用 Docker Compose 更新

直接在服务器上使用 Docker Compose 更新，1Panel 会自动同步容器状态。

## 🔧 常见问题处理

### 问题1：镜像拉取失败

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

### 问题2：更新后服务无法启动

**现象**：
```
容器启动后立即退出
```

**解决方法**：
```bash
# 查看容器日志
docker logs updatehub-backend

# 检查环境变量配置
cat /opt/UpdateHub/docker/.env

# 检查镜像是否正确拉取
docker images | grep updatehub

# 如果问题持续，回滚到之前的版本
```

### 问题3：更新后数据丢失

**现象**：
```
更新后发现数据丢失
```

**解决方法**：
```bash
# 检查数据卷是否保留
docker volume ls | grep updatehub

# 恢复备份数据
cd /opt/UpdateHub/backups
# 恢复数据库
docker exec -i updatehub-postgres psql -U updatehub updatehub < db_backup_YYYYMMDD.sql
# 恢复上传文件
tar -xzf uploads_backup_YYYYMMDD.tar.gz -C /
```

### 问题4：更新后功能异常

**现象**：
```
更新后某些功能无法正常使用
```

**解决方法**：
```bash
# 检查后端日志
docker logs updatehub-backend

# 检查数据库迁移
# 进入后端容器
docker exec -it updatehub-backend /bin/sh
# 检查数据库表结构
sqlite3 /app/data/updatehub.db ".schema"

# 如果是数据库结构变化，可能需要手动迁移
```

### 问题5：镜像拉取速度慢

**现象**：
```
镜像拉取时间很长
```

**解决方法**：
```bash
# 使用镜像加速器（可选）
# 配置 Docker 镜像加速器

# 或使用后台拉取
docker pull ghcr.io/your-username/updatehub-backend:latest &
docker pull ghcr.io/your-username/updatehub-frontend:latest &
```

## 📊 更新策略建议

### 1. 测试环境先行

在生产环境更新前，先在测试环境更新：
- 在测试环境拉取新镜像
- 运行完整的功能测试
- 确认无问题后再更新生产环境

### 2. 维护窗口

选择业务低峰期进行更新：
- 通常在凌晨或周末
- 提前通知用户
- 准备回滚方案

### 3. 滚动更新

对于多实例部署，使用滚动更新：
- 逐个更新实例
- 保持服务可用性
- 减少对用户的影响

### 4. 监控告警

更新后加强监控：
- 监控服务健康状态
- 监控错误日志
- 监控性能指标
- 设置告警规则

## 🔄 更新流程总结

### 标准更新流程

```
1. 备份数据
   ↓
2. 检查当前版本
   ↓
3. 拉取新镜像
   ↓
4. 停止旧服务
   ↓
5. 启动新服务
   ↓
6. 验证更新
   ↓
7. 监控运行
```

### 快速更新流程（使用脚本）

```
1. 运行 ./update.sh
   ↓
2. 选择更新方式
   ↓
3. 等待自动完成
   ↓
4. 验证更新结果
```

## 🎯 最佳实践

### 1. 定期更新

建议定期更新系统：
- 跟随官方发布节奏
- 及时获取安全修复
- 享受新功能

### 2. 版本跳跃

不建议跳过多个版本：
- 按顺序更新
- 避免数据库迁移问题
- 减少兼容性问题

### 3. 备份策略

每次更新前都要备份：
- 数据库备份
- 文件备份
- 配置备份
- 保留多个备份版本

### 4. 文档记录

记录每次更新：
- 更新时间
- 更新版本
- 更新内容
- 遇到的问题
- 解决方案

## 🎉 完成！

你已经了解了如何更新 UpdateHub 系统！

### 🚀 CI/CD 更新的优势

- **更新快速**：2-5分钟完成更新
- **资源节省**：服务器不需要构建环境
- **网络节省**：只拉取镜像，不下载依赖
- **一致性高**：所有环境使用相同的预构建镜像
- **版本管理**：清晰的镜像版本标签
- **易于回滚**：可以快速回退到之前版本

### 📝 下一步

- [ ] 定期检查新版本
- [ ] 制定更新计划
- [ ] 设置自动备份
- [ ] 配置监控告警
- [ ] 记录更新历史

### 📞 获取帮助

如果遇到问题，请参考：
- [第一次部署指南](FIRST_TIME_DEPLOYMENT.md)
- [1Panel 部署指南](1PANEL_DEPLOYMENT.md)
- [快速开始指南](QUICK_START.md)
