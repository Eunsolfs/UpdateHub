# UpdateHub 自动化脚本使用指南

本目录包含 UpdateHub 的自动化部署和管理脚本，让部署和更新变得简单易用。

## 📚 脚本列表

### Linux/1Panel 环境
- `check_env.sh` - 环境检查脚本
- `deploy.sh` - 一键部署脚本
- `update.sh` - 一键更新脚本
- `backup.sh` - 自动备份脚本

### Windows 环境
- `check_env.ps1` - 环境检查脚本
- `deploy.ps1` - 一键部署脚本
- `update.ps1` - 一键更新脚本
- `backup.ps1` - 自动备份脚本

## 🚀 快速开始

### Linux/1Panel 环境

#### 1. 环境检查
```bash
cd /opt/UpdateHub/scripts
chmod +x *.sh
./check_env.sh
```

#### 2. 一键部署
```bash
./deploy.sh
```

#### 3. 自动备份
```bash
./backup.sh
```

#### 4. 一键更新
```bash
./update.sh
```

### Windows 环境

#### 1. 环境检查
```powershell
cd Y:\sourcecode\UpdateHub\scripts
.\check_env.ps1
```

#### 2. 一键部署
```powershell
.\deploy.ps1
```

#### 3. 自动备份
```powershell
.\backup.ps1
```

#### 4. 一键更新
```powershell
.\update.ps1
```

## 📋 脚本详细说明

### 环境检查脚本 (check_env.sh / check_env.ps1)

**功能**：
- 检查操作系统版本和架构
- 检查系统资源（内存、磁盘、CPU）
- 检查 Docker 和 Docker Compose
- 检查 Git 安装
- 检查端口占用情况
- 检查网络连接
- 检查防火墙状态
- 检查文件权限
- 检查 1Panel（可选）

**使用场景**：
- 部署前环境检查
- 故障排查
- 系统健康检查

**输出示例**：
```
========================================
  UpdateHub 环境检查
========================================
[CHECK] 检查操作系统
[PASS] 操作系统: Ubuntu 22.04.3 LTS
[PASS] 系统架构: x86_64
...
========================================
  检查报告
========================================
总检查项: 15
通过: 15
失败: 0
所有检查通过，环境满足部署要求！
```

### 一键部署脚本 (deploy.sh / deploy.ps1)

**功能**：
- 自动环境检查
- 交互式配置输入
- 自动创建目录结构
- 克隆项目代码
- 生成环境变量文件
- 构建 Docker 镜像
- 启动所有服务
- 自动验证部署结果
- 显示访问信息和常用命令

**使用场景**：
- 首次部署 UpdateHub
- 快速搭建测试环境
- 标准化部署流程

**配置项**：
- 安装目录
- 数据库密码
- JWT 密钥
- 服务器端口
- Git 仓库地址

**输出示例**：
```
========================================
  UpdateHub 一键部署脚本
========================================
[INFO] 检查环境...
[SUCCESS] Docker 已安装
[SUCCESS] Docker Compose 已安装
...
[SUCCESS] 部署完成！

UpdateHub 已成功安装！

访问地址:
  前端: http://192.168.1.100
  后端: http://192.168.1.100:8080
  健康检查: http://192.168.1.100:8080/health

默认账户:
  用户名: admin
  密码: admin123
```

### 自动备份脚本 (backup.sh / backup.ps1)

**功能**：
- 自动备份数据库
- 备份上传文件
- 备份配置文件
- 备份版本信息
- 自动压缩备份文件
- 生成备份报告
- 自动清理旧备份（可配置保留天数）

**使用场景**：
- 定期数据备份
- 更新前备份
- 灾难恢复准备

**备份内容**：
- PostgreSQL 数据库
- 上传文件目录
- 配置文件（config.yaml, .env）
- Docker Compose 配置
- Git 版本信息

**备份目录结构**：
```
backups/
├── 20260905_185530/
│   ├── postgres/
│   │   └── updatehub_backup_20260905_185530.sql.gz
│   ├── uploads/
│   │   └── uploads_backup_20260905_185530.tar.gz
│   ├── configs/
│   │   ├── config_backup_20260905_185530.yaml
│   │   ├── env_backup_20260905_185530
│   │   └── docker-compose_backup_20260905_185530.yml
│   ├── current_commit.txt
│   ├── current_version.txt
│   └── backup_report.txt
```

**配置项**：
- 备份目录
- 保留天数（默认7天）

### 一键更新脚本 (update.sh / update.ps1)

**功能**：
- 自动环境检查
- 完整数据备份
- 拉取最新代码
- 选择更新版本
- 两种更新方式：
  - 零停机更新（推荐）
  - 完整停机更新
- 自动数据库迁移
- 自动验证更新结果
- 失败自动回滚
- 清理旧备份
- 生成更新日志

**使用场景**：
- 升级到新版本
- 功能更新
- 安全补丁更新

**更新方式**：

#### 零停机更新（推荐）
- 滚动更新后端服务
- 滚动更新前端服务
- 无服务中断
- 适合生产环境

#### 完整停机更新
- 停止所有服务
- 重新构建镜像
- 启动所有服务
- 有短暂停机
- 适合测试环境

**安全特性**：
- 更新前自动备份
- 失败自动回滚
- 详细日志记录
- 更新验证检查

## 🔧 脚本配置

### 环境变量配置

编辑 `docker/.env` 文件：

```bash
# 数据库配置
POSTGRES_PASSWORD=your_strong_password
POSTGRES_DB=updatehub
POSTGRES_USER=updatehub

# JWT 配置
JWT_SECRET=your_jwt_secret_key
REFRESH_SECRET=your_refresh_secret_key

# 服务器配置
SERVER_MODE=release
SERVER_PORT=8080

# 存储配置
STORAGE_TYPE=local
```

### 备份配置

修改脚本中的配置变量：

```bash
# backup.sh / backup.ps1
RETENTION_DAYS=7  # 保留天数
BACKUP_DIR="/opt/UpdateHub/backups"  # 备份目录
```

## 📊 使用示例

### 完整部署流程

```bash
# 1. 环境检查
./check_env.sh

# 2. 执行部署
./deploy.sh

# 3. 验证部署
curl http://localhost:8080/health

# 4. 访问前端
# 浏览器打开 http://your-server-ip
```

### 更新流程

```bash
# 1. 备份当前版本
./backup.sh

# 2. 执行更新
./update.sh

# 3. 验证更新
curl http://localhost:8080/health
```

### 定期备份

```bash
# 手动备份
./backup.sh

# 或设置定时任务（crontab）
# 每天凌晨2点备份
0 2 * * * /opt/UpdateHub/scripts/backup.sh
```

## 🛠️ 故障排除

### 脚本权限问题
```bash
# Linux: 添加执行权限
chmod +x scripts/*.sh

# Windows: PowerShell 执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Docker 权限问题
```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

### 端口占用问题
```bash
# 检查端口占用
netstat -tuln | grep 8080

# 修改配置文件中的端口
nano docker/docker-compose.1panel.yml
```

### 内存不足
```bash
# 增加 Docker 内存限制
# 或使用 swap 分区
```

## 📝 日志文件

脚本会生成以下日志文件：

- `update.log` - 更新日志
- `backup_report.txt` - 备份报告（在备份目录中）

## 🔒 安全建议

1. **修改默认密码**：部署后立即修改数据库和管理员密码
2. **使用强密码**：数据库密码和 JWT 密钥使用复杂密码
3. **定期备份**：设置自动备份任务
4. **限制访问**：配置防火墙规则
5. **启用 SSL**：在生产环境启用 HTTPS
6. **监控日志**：定期检查系统日志

## 🎯 最佳实践

1. **先测试后部署**：在测试环境先验证脚本
2. **定期检查环境**：定期运行环境检查脚本
3. **备份策略**：根据业务需求调整备份频率
4. **更新时机**：选择业务低峰期进行更新
5. **文档记录**：记录每次部署和更新的重要信息

## 📞 技术支持

如果脚本执行遇到问题：

1. 查看脚本输出的错误信息
2. 检查日志文件
3. 运行环境检查脚本
4. 参考故障排除指南
5. 联系技术支持

## 🎉 优势

使用这些自动化脚本的优势：

- **简单易用**：一键完成复杂操作
- **安全可靠**：自动备份和回滚机制
- **标准化**：统一的部署和更新流程
- **节省时间**：自动化减少人工操作
- **减少错误**：避免手动操作失误
- **可追溯**：详细的日志记录
- **跨平台**：支持 Linux 和 Windows

现在你可以像傻瓜一样简单地部署和管理 UpdateHub 了！
