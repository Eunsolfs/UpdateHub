# UpdateHub 服务更新教程

本教程将指导您如何将 UpdateHub 服务端程序更新到最新版本。

## 📋 更新前准备

### 1. 检查当前版本
```bash
# 查看当前运行的版本
docker exec -it updatehub-backend ./updatehub-server version

# 或查看 git 标签
cd /opt/UpdateHub
git describe --tags
```

### 2. 使用自动化脚本备份（推荐）⭐

```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

自动化备份脚本会自动：
- ✅ 备份数据库
- ✅ 备份上传文件
- ✅ 备份配置文件
- ✅ 备份版本信息
- ✅ 生成备份报告
- ✅ 自动清理旧备份

### 3. 手动备份

如果您需要手动备份，请参考以下步骤。

#### 2.1 备份数据库
```bash
# 备份 PostgreSQL 数据库
docker exec updatehub-postgres pg_dump -U updatehub updatehub > updatehub_backup_$(date +%Y%m%d_%H%M%S).sql

# 备份到安全位置
cp updatehub_backup_*.sql /backup/
```

#### 2.2 备份上传文件
```bash
# 备份上传的文件
tar -czf uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz /opt/UpdateHub/backend/uploads

# 备份到安全位置
cp uploads_backup_*.tar.gz /backup/
```

#### 2.3 备份配置文件
```bash
# 备份配置文件
cp /opt/UpdateHub/backend/configs/config.yaml /backup/config_backup_$(date +%Y%m%d_%H%M%S).yaml
cp /opt/UpdateHub/docker/docker-compose.yml /backup/docker-compose_backup_$(date +%Y%m%d_%H%M%S).yml
```

#### 2.4 使用 1Panel 备份功能
1. 进入 1Panel -> 备份
2. 创建手动备份
3. 选择所有相关容器和卷
4. 执行备份

### 4. 检查更新日志
```bash
# 查看最新更新内容
cd /opt/UpdateHub
git fetch origin
git log origin/main --oneline -10

# 查看版本更新说明
git tag -l --sort=-version:refname | head -5
```

### 5. 准备回滚方案
```bash
# 保存当前 git commit ID
cd /opt/UpdateHub
git rev-parse HEAD > /backup/current_commit.txt

# 记录当前运行的容器镜像
docker images | grep updatehub > /backup/current_images.txt
```

## 🚀 更新方式

### 方式一：使用自动化脚本（推荐）⭐

这是最简单的方式，只需运行一个脚本即可完成所有更新步骤。

#### 1. 环境检查
```bash
cd /opt/UpdateHub/scripts
./check_env.sh
```

#### 2. 一键更新
```bash
./update.sh
```

脚本会自动：
- ✅ 检查环境依赖
- ✅ 自动备份数据
- ✅ 拉取最新代码
- ✅ 选择更新版本
- ✅ 执行零停机更新
- ✅ 自动数据库迁移
- ✅ 验证更新结果
- ✅ 失败自动回滚
- ✅ 清理旧备份

#### 3. 更新方式选择

脚本会询问选择更新方式：
```
请选择更新方式:
1) 零停机更新 (推荐)
2) 完整停机更新
```

**零停机更新**（推荐）：
- 滚动更新后端服务
- 滚动更新前端服务
- 无服务中断
- 适合生产环境

**完整停机更新**：
- 停止所有服务
- 重新构建镜像
- 启动所有服务
- 有短暂停机
- 适合测试环境

### 方式二：手动更新

如果您需要更多控制，可以选择手动更新。

#### 方法一：零停机更新（推荐）

##### 1.1 准备新版本
```bash
cd /opt/UpdateHub

# 拉取最新代码
git fetch origin
git checkout origin/main

# 或者切换到特定版本标签
git checkout v1.2.0
```

##### 1.2 构建新版本镜像
```bash
# 构建新的镜像（不停止现有服务）
docker-compose -f docker/docker-compose.1panel.yml build backend
docker-compose -f docker/docker-compose.1panel.yml build frontend
```

##### 1.3 滚动更新后端
```bash
# 停止旧的后端容器
docker-compose -f docker/docker-compose.1panel.yml stop backend

# 启动新的后端容器
docker-compose -f docker/docker-compose.1panel.yml up -d backend

# 等待后端启动
sleep 10

# 检查后端状态
docker-compose -f docker/docker-compose.1panel.yml ps backend
curl http://localhost:8080/health
```

##### 1.4 滚动更新前端
```bash
# 停止旧的前端容器
docker-compose -f docker/docker-compose.1panel.yml stop frontend

# 启动新的前端容器
docker-compose -f docker/docker-compose.1panel.yml up -d frontend

# 检查前端状态
docker-compose -f docker/docker-compose.1panel.yml ps frontend
curl http://localhost/
```

##### 1.5 执行数据库迁移（如果需要）
```bash
# 检查是否有新的迁移文件
ls -la /opt/UpdateHub/backend/migrations/

# 如果有迁移，执行迁移
docker exec -it updatehub-backend ./updatehub-server migrate

# 或者直接在数据库中执行 SQL 脚本
docker exec -i updatehub-postgres psql -U updatehub -d updatehub < /opt/UpdateHub/backend/migrations/upgrade_v1.2.0.sql
```

#### 方法二：完整停机更新

##### 2.1 停止所有服务
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

##### 2.2 拉取最新代码
```bash
cd /opt/UpdateHub
git fetch origin
git checkout origin/main

# 或者切换到特定版本
git checkout v1.2.0
```

##### 2.3 重新构建所有镜像
```bash
docker-compose -f docker/docker-compose.1panel.yml build --no-cache
```

##### 2.4 启动所有服务
```bash
docker-compose -f docker/docker-compose.1panel.yml up -d
```

##### 2.5 检查服务状态
```bash
# 查看所有容器状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 查看服务日志
docker-compose -f docker/docker-compose.1panel.yml logs -f
```

##### 2.6 执行数据库迁移
```bash
# 执行数据库迁移
docker exec -it updatehub-backend ./updatehub-server migrate
```

### 方法三：使用 1Panel 界面更新

#### 3.1 更新代码
1. 进入 1Panel -> 文件管理
2. 进入 `/opt/UpdateHub` 目录
3. 使用内置的 Git 工具拉取最新代码
4. 或手动上传新版本文件

#### 3.2 重新构建镜像
1. 进入 1Panel -> 容器
2. 停止 UpdateHub 相关容器
3. 删除旧镜像
4. 使用 Docker Compose 重新构建

#### 3.3 启动新服务
1. 启动所有 UpdateHub 容器
2. 检查容器状态
3. 查看日志确认正常

## 🔍 更新后验证

### 1. 检查服务状态
```bash
# 检查所有容器
docker-compose -f docker/docker-compose.1panel.yml ps

# 应该看到所有容器都是 "Up" 状态
```

### 2. 验证前端访问
```bash
# 访问前端
curl -I http://your-server-ip

# 应该返回 200 OK
```

### 3. 验证后端 API
```bash
# 测试健康检查
curl http://your-server-ip:8080/health

# 测试登录 API
curl -X POST http://your-server-ip:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}'
```

### 4. 验证数据库连接
```bash
# 测试数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub -c "SELECT version();"
```

### 5. 验证新功能
```bash
# 测试新添加的功能
# 根据更新日志测试具体的新功能
```

### 6. 检查日志
```bash
# 查看后端日志
docker logs updatehub-backend

# 查看前端日志
docker logs updatehub-frontend

# 查看数据库日志
docker logs updatehub-postgres
```

## 🔄 回滚方案

### 如果更新失败，按以下步骤回滚

#### 1. 停止当前服务
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

#### 2. 恢复之前的代码版本
```bash
cd /opt/UpdateHub
git checkout $(cat /backup/current_commit.txt)
```

#### 3. 恢复配置文件
```bash
cp /backup/config_backup_*.yaml /opt/UpdateHub/backend/configs/config.yaml
cp /backup/docker-compose_backup_*.yml /opt/UpdateHub/docker/docker-compose.yml
```

#### 4. 恢复数据库（如果需要）
```bash
# 恢复数据库备份
docker exec -i updatehub-postgres psql -U updatehub -d updatehub < /backup/updatehub_backup_YYYYMMDD_HHMMSS.sql
```

#### 5. 恢复上传文件（如果需要）
```bash
# 恢复上传文件
tar -xzf /backup/uploads_backup_YYYYMMDD_HHMMSS.tar.gz -C /
```

#### 6. 重新构建和启动
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml build
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 7. 验证回滚
```bash
# 检查服务状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 验证功能正常
curl http://your-server-ip:8080/health
```

## 📊 更新最佳实践

### 1. 定期更新
- 建议每月检查一次更新
- 优先更新安全补丁
- 在测试环境先测试新版本

### 2. 更新时间选择
- 选择业务低峰期进行更新
- 避免在工作时间进行重大更新
- 提前通知用户维护时间

### 3. 监控更新过程
- 实时监控日志输出
- 关注错误和警告信息
- 准备快速回滚方案

### 4. 记录更新过程
```bash
# 创建更新日志
echo "Update to v1.2.0 on $(date)" >> /opt/UpdateHub/update.log
echo "Backup completed" >> /opt/UpdateHub/update.log
echo "Migration executed" >> /opt/UpdateHub/update.log
echo "Update completed successfully" >> /opt/UpdateHub/update.log
```

## 🔧 常见更新问题

### 1. 数据库迁移失败
```bash
# 检查迁移文件
ls -la /opt/UpdateHub/backend/migrations/

# 手动执行 SQL
docker exec -i updatehub-postgres psql -U updatehub -d updatehub < migration_file.sql

# 检查数据库状态
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

### 2. 容器启动失败
```bash
# 查看容器日志
docker logs updatehub-backend

# 检查配置文件
cat /opt/UpdateHub/backend/configs/config.yaml

# 检查端口占用
netstat -tulpn | grep 8080
```

### 3. 前端显示异常
```bash
# 清除浏览器缓存
# 检查 nginx 配置
docker exec -it updatehub-frontend cat /etc/nginx/nginx.conf

# 重新构建前端
docker-compose -f docker/docker-compose.1panel.yml build frontend
docker-compose -f docker/docker-compose.1panel.yml up -d frontend
```

### 4. 依赖冲突
```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建
docker-compose -f docker/docker-compose.1panel.yml build --no-cache
```

## 📝 更新检查清单

更新前：
- [ ] 已备份数据库
- [ ] 已备份上传文件
- [ ] 已备份配置文件
- [ ] 已检查更新日志
- [ ] 已准备回滚方案
- [ ] 已通知用户维护时间
- [ ] 已选择合适的更新时间

更新中：
- [ ] 已停止旧服务
- [ ] 已拉取最新代码
- [ ] 已重新构建镜像
- [ ] 已启动新服务
- [ ] 已执行数据库迁移
- [ ] 已检查服务状态

更新后：
- [ ] 所有容器正常运行
- [ ] 前端访问正常
- [ ] 后端 API 响应正常
- [ ] 数据库连接正常
- [ ] 新功能测试通过
- [ ] 日志无错误信息
- [ ] 性能指标正常
- [ ] 已记录更新日志

## 🎯 自动化脚本管理

### 环境检查
```bash
cd /opt/UpdateHub/scripts
./check_env.sh
```

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

## 🎯 自动化更新脚本

### 创建自动化更新脚本
```bash
#!/bin/bash
# update.sh - UpdateHub 自动更新脚本

set -e

BACKUP_DIR="/backup"
PROJECT_DIR="/opt/UpdateHub"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting UpdateHub update process..."

# 1. 备份数据
echo "Backing up data..."
docker exec updatehub-postgres pg_dump -U updatehub updatehub > $BACKUP_DIR/updatehub_backup_$DATE.sql
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz $PROJECT_DIR/backend/uploads
cp $PROJECT_DIR/backend/configs/config.yaml $BACKUP_DIR/config_backup_$DATE.yaml

# 2. 拉取最新代码
echo "Pulling latest code..."
cd $PROJECT_DIR
git fetch origin
git checkout origin/main

# 3. 重新构建
echo "Building new images..."
docker-compose -f docker/docker-compose.1panel.yml build backend
docker-compose -f docker/docker-compose.1panel.yml build frontend

# 4. 滚动更新
echo "Rolling update..."
docker-compose -f docker/docker-compose.1panel.yml stop backend
docker-compose -f docker/docker-compose.1panel.yml up -d backend
sleep 10

docker-compose -f docker/docker-compose.1panel.yml stop frontend
docker-compose -f docker/docker-compose.1panel.yml up -d frontend

# 5. 执行迁移
echo "Running migrations..."
docker exec -it updatehub-backend ./updatehub-server migrate

# 6. 验证
echo "Verifying update..."
curl -f http://localhost:8080/health || exit 1

echo "Update completed successfully!"
```

### 使用自动化脚本
```bash
# 设置执行权限
chmod +x update.sh

# 执行更新
./update.sh
```

## 📞 技术支持

如果更新过程中遇到问题：
1. 查看详细的错误日志
2. 检查备份文件是否完整
3. 执行回滚操作
4. 联系技术支持

## 🎉 更新完成

恭喜！您已成功将 UpdateHub 更新到最新版本。建议定期检查更新并及时升级以获得最新功能和安全补丁。
