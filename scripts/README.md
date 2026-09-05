# UpdateHub 自动化脚本使用指南

本指南详细说明 UpdateHub 提供的所有自动化脚本的使用方法。

## � 脚本列表

UpdateHub 提供以下自动化脚本：

### Linux 脚本
- `check_env.sh` - 环境检查脚本
- `deploy.sh` - 一键部署脚本（CI/CD版本）
- `update.sh` - 一键更新脚本（CI/CD版本）
- `backup.sh` - 自动备份脚本
- `ops.sh` - 运维管理脚本 ⭐

### Windows 脚本
- `check_env.ps1` - 环境检查脚本
- `deploy.ps1` - 一键部署脚本（CI/CD版本）
- `update.ps1` - 一键更新脚本（CI/CD版本）
- `backup.ps1` - 自动备份脚本
- `ops.ps1` - 运维管理脚本 ⭐

## 🚀 部署方式说明

所有脚本都已更新为使用 **CI/CD 预构建镜像** 方式。

### CI/CD 部署方式

UpdateHub 现在使用 GitHub Actions 自动构建 Docker 镜像，部署时只需拉取预构建的镜像。

**优势**：
- ⚡ 部署速度快（2-5分钟）
- 💾 服务器不需要构建环境
- 🌐 网络消耗小
- 🎯 构建环境标准化
- 📦 版本管理清晰

## 🔧 环境检查脚本

### Linux: check_env.sh

#### 使用方法
```bash
cd /opt/UpdateHub/scripts
./check_env.sh
```

#### 功能说明

脚本会检查以下内容：

1. **操作系统检查**
   - 操作系统类型
   - 操作系统版本
   - 内核版本

2. **系统资源检查**
   - CPU 核心数
   - 内存大小
   - 磁盘空间
   - 网络连接

3. **软件环境检查**
   - Docker 安装状态
   - Docker Compose 安装状态
   - Git 安装状态
   - Python 安装状态（可选）

4. **端口检查**
   - 80 端口占用情况
   - 8080 端口占用情况
   - 5432 端口占用情况
   - 6379 端口占用情况

5. **网络检查**
   - GitHub 连接性
   - GitHub Container Registry 连接性
   - 外网连接性

6. **文件权限检查**
   - 项目目录权限
   - 脚本执行权限
   - Docker 权限

#### 输出示例

```
========================================
  UpdateHub 环境检查
========================================

[INFO] 检查操作系统...
[SUCCESS] 操作系统: Ubuntu 22.04.3 LTS
[SUCCESS] 内核版本: 5.15.0-76-generic

[INFO] 检查系统资源...
[SUCCESS] CPU: 4 核
[SUCCESS] 内存: 8GB
[SUCCESS] 磁盘: 50GB 可用

[INFO] 检查软件环境...
[SUCCESS] Docker: 24.0.7
[SUCCESS] Docker Compose: 2.21.0
[SUCCESS] Git: 2.34.1

[INFO] 检查端口占用...
[SUCCESS] 80 端口: 未占用
[SUCCESS] 8080 端口: 未占用
[SUCCESS] 5432 端口: 未占用
[SUCCESS] 6379 端口: 未占用

[INFO] 检查网络连接...
[SUCCESS] GitHub: 可访问
[SUCCESS] GitHub Container Registry: 可访问

========================================
  检查报告
========================================
总检查项: 15
通过: 15
失败: 0
警告: 0

所有检查通过，环境满足部署要求！
```

#### 错误处理

如果检查失败，脚本会给出具体的解决建议：

```
[FAIL] Docker Compose 未安装
[INFO] 请安装 Docker Compose:
   Ubuntu/Debian: apt install -y docker-compose
   CentOS/RHEL: yum install -y docker-compose
```

### Windows: check_env.ps1

#### 使用方法
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\check_env.ps1
```

#### 功能说明

与 Linux 版本功能相同，检查：
- 操作系统版本
- 系统资源
- Docker 安装状态
- Docker Compose 安装状态
- Git 安装状态
- 端口占用情况
- 网络连接状态

## 🚀 一键部署脚本

### Linux: deploy.sh

#### 使用方法
```bash
cd /opt/UpdateHub/scripts
./deploy.sh
```

#### 功能说明

脚本会自动执行以下步骤：

1. **环境检查**
   - 检查 Docker 是否安装
   - 检查 Docker Compose 是否安装
   - 检查 Git 是否安装
   - 检查系统资源

2. **配置向导**
   - 询问安装目录
   - 询问数据库密码
   - 询问 JWT 密钥
   - 询问服务器端口
   - 询问镜像地址
   - 询问服务器模式

3. **拉取预构建镜像**
   - 拉取后端 Docker 镜像
   - 拉取前端 Docker 镜像
   - 验证镜像拉取成功

4. **创建配置文件**
   - 创建 .env 文件
   - 配置环境变量
   - 配置镜像地址

5. **启动服务**
   - 使用 Docker Compose 启动服务
   - 等待服务启动完成

6. **验证部署**
   - 检查容器状态
   - 检查后端健康
   - 检查前端访问

#### 交互式配置

脚本会询问以下配置：

```
========================================
  UpdateHub 一键部署脚本 (CI/CD版本)
========================================

[INFO] 检查环境...
[SUCCESS] Docker 已安装
[SUCCESS] Docker Compose 已安装
[SUCCESS] 环境检查完成

========================================
  配置信息
========================================
安装目录 [/opt/UpdateHub]: 
数据库密码 [updatehub]: MyStr0ngP@ssw0rd
JWT 密钥 [your-secret-key-change-this]: r@nd0mJWTk3y-2024
服务器端口 [8080]: 
后端镜像 [ghcr.io/your-username/updatehub-backend:latest]: 
前端镜像 [ghcr.io/your-username/updatehub-frontend:latest]: 
服务器模式 [release]: 

配置摘要:
  安装目录: /opt/UpdateHub
  数据库密码: MyStr0ngP@ssw0rd
  JWT 密钥: r@nd0mJWTk3y-2024
  服务器端口: 8080
  后端镜像: ghcr.io/your-username/updatehub-backend:latest
  前端镜像: ghcr.io/your-username/updatehub-frontend:latest
  服务器模式: release

确认配置? (y/n): y
```

#### CI/CD 特性

新版本的部署脚本专门针对 CI/CD 优化：

```
[INFO] 拉取预构建的Docker镜像...
[INFO] 拉取后端镜像: ghcr.io/your-username/updatehub-backend:latest
latest: Pulling from ghcr.io/your-username/updatehub-backend
sha256:abc123...: Pulling fs
abc123...: Pulling complete
...
[SUCCESS] 后端镜像拉取完成
[INFO] 拉取前端镜像: ghcr.io/your-username/updatehub-frontend:latest
latest: Pulling from ghcr.io/your-username/updatehub-frontend
sha256:def456...: Pulling fs
def456...: Pulling complete
...
[SUCCESS] 前端镜像拉取完成
```

**优势**：
- 无需在服务器上构建
- 部署时间从 10-20 分钟缩短到 2-5 分钟
- 减少服务器资源消耗
- 减少网络带宽消耗

#### 输出示例

```
========================================
  验证安装...
========================================
[INFO] 检查容器状态...
NAME                      STATUS
updatehub-postgres         Up
updatehub-redis            Up  
updatehub-backend          Up
updatehub-frontend         Up

[INFO] 检查后端健康状态...
[SUCCESS] 后端服务正常
[INFO] 检查前端服务...
[SUCCESS] 前端服务正常
[SUCCESS] 验证完成

========================================
  安装信息
========================================

UpdateHub 已成功安装！

部署方式: 使用预构建Docker镜像 (CI/CD)

访问地址:
  前端: http://192.168.1.100
  后端: http://192.168.1.100:8080
  健康检查: http://192.168.1.100:8080/health

使用的镜像:
  后端: ghcr.io/your-username/updatehub-backend:latest
  前端: ghcr.io/your-username/updatehub-frontend:latest

默认账户:
  用户名: admin
  密码: admin123

⚠️  重要: 请立即修改默认密码！

常用命令:
  查看日志: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml logs -f
  停止服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml down
  启动服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml up -d
  重启服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml restart
  更新镜像: docker pull ghcr.io/your-username/updatehub-backend:latest && docker pull ghcr.io/your-username/updatehub-frontend:latest

项目目录: /opt/UpdateHub
备份目录: /opt/UpdateHub/backups
```

### Windows: deploy.ps1

#### 使用方法
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\deploy.ps1
```

#### 功能说明

与 Linux 版本功能相同，支持：
- 环境检查
- 交互式配置
- 拉取预构建镜像
- 启动服务
- 验证部署

## 🔄 一键更新脚本

### Linux: update.sh

#### 使用方法
```bash
cd /opt/UpdateHub/scripts
./update.sh
```

#### 功能说明

脚本会自动执行以下步骤：

1. **环境检查**
   - 检查项目目录
   - 检查 Docker 安装
   - 检查 Docker Compose 安装

2. **备份数据**
   - 备份配置文件
   - 备份上传文件
   - 保存当前镜像信息

3. **拉取新镜像**
   - 拉取后端新镜像
   - 拉取前端新镜像

4. **更新服务**
   - 选择更新方式（零停机/完整停机）
   - 执行更新操作

5. **验证更新**
   - 检查容器状态
   - 检查后端健康
   - 检查前端访问

#### 更新方式选择

```
请选择更新方式:
1) 零停机更新 (推荐)
2) 完整停机更新
请输入选择 (1-2): 1
```

**零停机更新**：
- 不停止现有服务
- 拉取新镜像后立即启动
- 适合生产环境

**完整停机更新**：
- 先停止所有服务
- 拉取新镜像
- 再启动服务
- 更新更彻底

#### CI/CD 特性

新版本的更新脚本专门针对 CI/CD 优化：

```
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
```

**优势**：
- 只拉取镜像，不构建
- 更新时间从 10-20 分钟缩短到 2-5 分钟
- 减少服务器资源消耗
- 支持版本回滚

#### 输出示例

```
========================================
  验证更新...
========================================
[INFO] 检查容器状态...
NAME                      STATUS
updatehub-postgres         Up
updatehub-redis            Up  
updatehub-backend          Up
updatehub-frontend         Up

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

### Windows: update.ps1

#### 使用方法
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\update.ps1
```

#### 功能说明

与 Linux 版本功能相同，支持：
- 环境检查
- 数据备份
- 拉取新镜像
- 更新服务
- 验证更新

## 💾 自动备份脚本

### Linux: backup.sh

#### 使用方法
```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

#### 功能说明

脚本会自动执行以下备份操作：

1. **创建备份目录**
   - 创建 `/opt/UpdateHub/backups` 目录
   - 创建子目录（configs, uploads, database）

2. **备份配置文件**
   - 备份 `config.yaml`
   - 备份 `.env` 文件
   - 带时间戳命名

3. **备份数据库**
   - 导出 PostgreSQL 数据
   - 压缩备份文件
   - 带时间戳命名

4. **备份上传文件**
   - 打包上传目录
   - 压缩备份文件
   - 带时间戳命名

5. **清理旧备份**
   - 保留最近 7 天的备份
   - 删除旧备份文件

#### 输出示例

```
========================================
  UpdateHub 自动备份
========================================

[INFO] 创建备份目录...
[SUCCESS] 备份目录创建完成

[INFO] 备份配置文件...
[SUCCESS] 配置文件备份完成
  文件: /opt/UpdateHub/backups/configs/config_backup_20240115_103000.yaml
  文件: /opt/UpdateHub/backups/configs/env_backup_20240115_103000

[INFO] 备份数据库...
[SUCCESS] 数据库备份完成
  文件: /opt/UpdateHub/backups/database/db_backup_20240115_103000.sql.gz

[INFO] 备份上传文件...
[SUCCESS] 上传文件备份完成
  文件: /opt/UpdateHub/backups/uploads/uploads_backup_20240115_103000.tar.gz

[INFO] 清理旧备份...
[SUCCESS] 清理完成，保留最近 7 天的备份

========================================
  备份完成
========================================

备份时间: 2024-01-15 10:30:00
备份目录: /opt/UpdateHub/backups
备份文件:
  - configs/config_backup_20240115_103000.yaml
  - configs/env_backup_20240115_103000
  - database/db_backup_20240115_103000.sql.gz
  - uploads/uploads_backup_20240115_103000.tar.gz
```

### Windows: backup.ps1

#### 使用方法
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\backup.ps1
```

#### 功能说明

与 Linux 版本功能相同，支持：
- 配置文件备份
- 数据库备份
- 上传文件备份
- 清理旧备份

## 🔧 运维管理脚本 ⭐

### Linux: ops.sh

#### 使用方法
```bash
cd /opt/UpdateHub/scripts
chmod +x ops.sh
./ops.sh
```

#### 功能说明

运维管理脚本提供交互式菜单，支持以下操作：

1. **修改管理员密码**
   - 通过 Web 界面修改（推荐）
   - 通过数据库直接修改

2. **修改端口号**
   - 修改后端服务端口
   - 自动备份配置
   - 提示重启服务

3. **修改镜像源**
   - 使用 latest 标签（最新版本）
   - 使用特定版本标签（如 v1.0.0）
   - 自定义镜像地址
   - 自动备份配置

4. **修改数据库密码**
   - 自动备份数据库
   - 停止服务
   - 重新创建数据库
   - 重启服务

5. **修改 JWT 密钥**
   - 生成随机密钥
   - 自动备份配置
   - 提示用户重新登录

6. **配置 Docker 镜像加速** ⭐
   - 支持多个国内镜像源
   - 腾讯云镜像加速
   - 阿里云镜像加速
   - 中科大镜像加速
   - 网易镜像加速
   - 显著提高镜像下载速度

7. **重启服务**
   - 停止所有服务
   - 启动所有服务
   - 检查服务状态

8. **查看当前配置**
   - 显示环境变量配置
   - 显示容器状态

#### Docker 镜像加速说明

**为什么需要镜像加速？**

国内服务器直接从 Docker Hub 下载镜像速度很慢，配置国内镜像源可以显著提高下载速度。

**支持的镜像源**：
- 腾讯云镜像加速：`https://mirror.ccs.tencentyun.com`
- 阿里云镜像加速：`https://registry.cn-hangzhou.aliyuncs.com`
- 中科大镜像加速：`https://docker.mirrors.ustc.edu.cn`
- 网易镜像加速：`https://hub-mirror.c.163.com`

**加速效果**：
- 下载速度提升 5-10 倍
- 部署时间从 10-20 分钟缩短到 2-5 分钟

### Windows: ops.ps1

#### 使用方法
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\ops.ps1
```

#### 功能说明

与 Linux 版本功能相同，支持：
- 修改端口号
- 修改镜像源
- 修改数据库密码
- 修改 JWT 密钥
- 配置 Docker 镜像加速
- 重启服务
- 查看当前配置

## 🔧 脚本配置

### 环境变量配置

所有脚本都使用 `.env` 文件中的配置：

```bash
# .env 文件位置
/opt/UpdateHub/docker/.env

# 关键配置项
POSTGRES_PASSWORD=your-password
JWT_SECRET=your-jwt-secret
BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:latest
```

### 自定义安装目录

可以在脚本运行时指定安装目录：

```bash
# Linux
export INSTALL_DIR=/custom/path
./deploy.sh

# Windows
$env:INSTALL_DIR="C:\custom\path"
.\deploy.ps1
```

### 日志文件

所有脚本都会生成日志文件：

```bash
# Linux 日志位置
/opt/UpdateHub/deploy.log
/opt/UpdateHub/update.log
/opt/UpdateHub/backup.log

# Windows 日志位置
Y:\sourcecode\UpdateHub\deploy.log
Y:\sourcecode\UpdateHub\update.log
Y:\sourcecode\UpdateHub\backup.log
```

## � 常见问题处理

### 问题1：脚本执行权限不足

**现象**：
```
bash: ./deploy.sh: Permission denied
```

**解决方法**：
```bash
# 添加执行权限
chmod +x deploy.sh
chmod +x update.sh
chmod +x backup.sh
chmod +x check_env.sh
```

### 问题2：Docker Compose 未找到

**现象**：
```
docker-compose: command not found
```

**解决方法**：
```bash
# 安装 Docker Compose
sudo apt install -y docker-compose  # Ubuntu/Debian
sudo yum install -y docker-compose  # CentOS/RHEL
```

### 问题3：镜像拉取失败

**现象**：
```
Error response from daemon: pull access denied
```

**解决方法**：
```bash
# 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
```

### 问题4：端口已被占用

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
```

## 📊 脚本使用建议

### 1. 首次部署

使用 `deploy.sh` 脚本进行首次部署：
```bash
./check_env.sh  # 先检查环境
./deploy.sh     # 然后部署
```

### 2. 日常更新

使用 `update.sh` 脚本进行更新：
```bash
./update.sh  # 自动更新
```

### 3. 定期备份

设置定时任务定期备份：
```bash
# 添加到 crontab
0 2 * * * /opt/UpdateHub/scripts/backup.sh
```

### 4. 环境检查

定期运行环境检查：
```bash
./check_env.sh
```

## 🎯 CI/CD 脚本优势总结

### 与传统脚本对比

#### 传统脚本（服务器端构建）：
```
❌ 需要在服务器上安装构建环境
❌ 每次部署消耗服务器资源
❌ 网络带宽消耗大
❌ 构建时间不稳定
❌ 难以保证构建环境一致性
```

#### CI/CD 脚本（预构建镜像）：
```
✅ 镜像在 GitHub Actions 中构建
✅ 服务器只负责运行
✅ 部署速度快（2-5分钟）
✅ 资源消耗小
✅ 构建环境标准化
✅ 版本管理清晰
```

### 脚本优化

新版本的脚本针对 CI/CD 进行了优化：

1. **镜像拉取**：使用 `docker pull` 替代 `docker build`
2. **版本管理**：支持镜像标签选择
3. **快速部署**：部署时间从 10-20 分钟缩短到 2-5 分钟
4. **资源节省**：减少服务器 CPU 和内存消耗
5. **网络节省**：只下载镜像，不下载依赖

## 🎉 完成！

你已经了解了所有 UpdateHub 自动化脚本的使用方法！

### 🚀 快速开始

```bash
# 1. 检查环境
./check_env.sh

# 2. 部署系统
./deploy.sh

# 3. 更新系统
./update.sh

# 4. 备份数据
./backup.sh
```

### 📝 下一步

- [ ] 根据需求选择合适的脚本
- [ ] 配置环境变量
- [ ] 设置定时备份
- [ ] 监控脚本执行日志

### 📞 获取帮助

如果遇到问题，请参考：
- [第一次部署指南](FIRST_TIME_DEPLOYMENT.md)
- [1Panel 部署指南](1PANEL_DEPLOYMENT.md)
- [服务更新指南](SERVICE_UPDATE.md)

