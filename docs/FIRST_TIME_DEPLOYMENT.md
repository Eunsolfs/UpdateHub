# UpdateHub 第一次部署完整操作指南

本指南专为第一次部署 UpdateHub 的用户设计，提供从零开始的完整操作步骤。

## 🎯 适用人群

- 第一次使用 UpdateHub 的用户
- 不熟悉 Docker 和 Linux 命令的用户
- 希望在 1Panel 环境中部署的用户

## � 新的部署方式 (CI/CD)

UpdateHub 现在使用现代化的 CI/CD 部署方式：

### �📋 部署方式对比

#### ❌ 旧方式（服务器端构建）
- 服务器需要完整的构建环境
- 每次部署消耗服务器资源
- 网络带宽消耗大
- 构建时间不稳定

#### ✅ 新方式（预构建镜像）⭐
- 使用 GitHub Actions 自动构建镜像
- 服务器只负责运行，不负责构建
- 网络消耗小（只拉取镜像）
- 部署速度快且稳定

## 📋 部署前准备

### 1. 服务器要求

#### 硬件要求
- **CPU**: 2核心以上
- **内存**: 2GB以上（推荐4GB）
- **磁盘**: 20GB以上可用空间
- **网络**: 稳定的网络连接

#### 软件要求
- **操作系统**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **1Panel**: 已安装并正常运行
- **Docker**: 1Panel会自动安装
- **Docker Compose**: 需要单独安装
- **网络**: 能访问GitHub（用于拉取镜像）

### 2. 准备工作清单

在开始之前，请确认：

- [ ] 服务器已安装 1Panel
- [ ] 有服务器的root权限或sudo权限
- [ ] 服务器网络连接正常
- [ ] 服务器磁盘空间充足
- [ ] 已准备好访问 1Panel 的密码
- [ ] **GitHub Container Registry访问权限**（重要）

## 🚀 完整部署步骤

### 第一步：登录服务器

#### 1.1 使用SSH登录
```bash
# 使用SSH客户端登录服务器
ssh root@your-server-ip

# 或使用用户名登录
ssh your-username@your-server-ip
# 然后切换到root
sudo su -
```

#### 1.2 验证1Panel运行状态
```bash
# 检查1Panel是否运行
systemctl status 1panel

# 或者在浏览器中访问
http://your-server-ip:10086
```

### 第二步：安装必要工具

#### 2.1 更新系统包
```bash
# Ubuntu/Debian
apt update && apt upgrade -y

# CentOS/RHEL
yum update -y
```

#### 2.2 安装Docker Compose（重要！）
```bash
# Ubuntu/Debian
apt install -y docker-compose

# CentOS/RHEL
yum install -y docker-compose

# 或使用官方安装脚本
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2.3 验证安装
```bash
# 验证Docker
docker --version

# 验证Docker Compose
docker-compose --version

# 应该显示版本信息
```

#### 2.4 启用GitHub Container Registry访问
```bash
# 登录GitHub Container Registry（如果是私有仓库）
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 对于公开仓库，可能不需要登录
```

### 第三步：获取项目代码

#### 3.1 创建项目目录
```bash
# 创建标准的项目目录
mkdir -p /opt
cd /opt
```

#### 3.2 克隆项目代码
```bash
# 克隆UpdateHub项目（替换为实际的仓库地址）
git clone https://github.com/your-username/UpdateHub.git

# 进入项目目录
cd UpdateHub
```

#### 3.3 验证代码结构
```bash
# 查看项目结构
ls -la

# 应该看到以下目录：
# backend/  frontend/  docker/  docs/  scripts/  .github/
```

### 第四步：准备自动化脚本

#### 4.1 进入脚本目录
```bash
cd scripts
```

#### 4.2 赋予脚本执行权限
```bash
# 给所有shell脚本添加执行权限
chmod +x *.sh
```

#### 4.3 查看可用脚本
```bash
ls -la

# 应该看到：
# check_env.sh    # 环境检查脚本
# deploy.sh       # 一键部署脚本 (CI/CD版本)
# update.sh       # 一键更新脚本 (CI/CD版本)
# backup.sh       # 自动备份脚本
```

### 第五步：环境检查

#### 5.1 运行环境检查脚本
```bash
./check_env.sh
```

#### 5.2 查看检查结果
脚本会检查以下内容：
- ✅ 操作系统版本
- ✅ 系统资源（内存、磁盘、CPU）
- ✅ Docker 安装状态
- ✅ Docker Compose 安装状态
- ✅ Git 安装状态
- ✅ 端口占用情况
- ✅ 网络连接状态
- ✅ 文件权限

#### 5.3 处理检查结果

**如果所有检查通过**：
```
========================================
  检查报告
========================================
总检查项: 15
通过: 15
失败: 0
所有检查通过，环境满足部署要求！
```
→ 继续下一步

**如果有检查失败**：
```
总检查项: 15
通过: 13
失败: 2
有 2 项检查失败，请解决后再部署。
```
→ 根据提示解决失败项，然后重新运行检查

### 第六步：执行一键部署

#### 6.1 运行部署脚本
```bash
./deploy.sh
```

#### 6.2 回答配置问题

脚本会询问以下配置问题，你可以按推荐回答：

```
========================================
  UpdateHub 一键部署脚本 (CI/CD版本)
========================================
[INFO] 检查环境...
[SUCCESS] Docker 已安装
[SUCCESS] Docker Compose 已安装
[SUCCESS] Git 已安装
[SUCCESS] 环境检查完成

========================================
  配置信息
========================================
安装目录 [/opt/UpdateHub]: 
```

**问题1：安装目录**
- **推荐回答**: 直接按回车（使用默认 `/opt/UpdateHub`）
- **自定义**: 输入你想要的目录，如 `/home/myapp/updatehub`

```
数据库密码 [updatehub]: 
```

**问题2：数据库密码**
- **推荐**: 输入一个强密码（不少于8位，包含字母和数字）
- **示例**: `MyStr0ngP@ssw0rd`
- **注意**: 这个密码很重要，请妥善保管

```
JWT 密钥 [your-secret-key-change-this]: 
```

**问题3：JWT密钥**
- **推荐**: 输入一个随机字符串（不少于16位）
- **示例**: `r@nd0mJWTk3y-2024`
- **注意**: 用于加密，请妥善保管

```
服务器端口 [8080]: 
```

**问题4：服务器端口**
- **推荐**: 直接按回车（使用默认 `8080`）
- **自定义**: 如果8080端口被占用，可以输入其他端口

```
后端镜像 [ghcr.io/your-username/updatehub-backend:latest]: 
```

**问题5：后端镜像地址**
- **推荐**: 直接按回车（使用官方预构建镜像）
- **自定义**: 如果有自定义镜像，可以输入完整地址

```
前端镜像 [ghcr.io/your-username/updatehub-frontend:latest]: 
```

**问题6：前端镜像地址**
- **推荐**: 直接按回车（使用官方预构建镜像）
- **自定义**: 如果有自定义镜像，可以输入完整地址

```
服务器模式 [release]: 
```

**问题7：服务器模式**
- **推荐**: 直接按回车（使用 `release` 生产模式）
- **自定义**: 测试环境可以使用 `debug` 模式

```
配置摘要:
  安装目录: /opt/UpdateHub
  数据库密码: MyStr0ngP@ssw0rd
  JWT 密钥: r@nd0mJWTk3y-2024
  服务器端口: 8080
  后端镜像: ghcr.io/your-username/updatehub-backend:latest
  前端镜像: ghcr.io/your-username/updatehub-frontend:latest
  服务器模式: release

确认配置? (y/n): 
```

**问题8：确认配置**
- **输入**: `y` 确认配置
- **输入**: `n` 重新配置

#### 6.3 等待自动安装

确认配置后，脚本会自动执行以下操作：

```
[INFO] 创建安装目录...
[SUCCESS] 安装目录创建完成
[INFO] 克隆项目代码...
[SUCCESS] 项目代码克隆完成
[INFO] 创建环境变量文件...
[SUCCESS] 环境变量文件创建完成
[INFO] 拉取预构建的Docker镜像...
```

新版本的优势：
- ⚡ **速度快**：只需拉取镜像，无需构建
- 💾 **省资源**：服务器不消耗CPU和内存构建
- 🌐 **省网络**：只下载镜像，不下载依赖
- 🎯 **一致性好**：所有环境使用相同的镜像

这个过程通常只需要2-5分钟，取决于你的网络速度。

#### 6.4 查看安装进度

在安装过程中，你会看到类似这样的输出：

```
[INFO] 拉取预构建的Docker镜像...
latest: Pulling from ghcr.io/your-username/updatehub-backend
sha256:abc123...: Pulling fs
abc123...: Pulling complete
...
```

这是正常的Docker镜像拉取过程，请耐心等待。

### 第七步：验证部署结果

#### 7.1 等待安装完成

安装完成后，脚本会显示：

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
```

#### 7.2 查看访问信息

脚本会显示完整的访问信息：

```
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

#### 7.3 记录重要信息

请务必记录以下信息：

```
安装目录: /opt/UpdateHub
数据库密码: MyStr0ngP@ssw0rd
JWT 密钥: r@nd0mJWTk3y-2024
前端地址: http://your-server-ip
后端地址: http://your-server-ip:8080
后端镜像: ghcr.io/your-username/updatehub-backend:latest
前端镜像: ghcr.io/your-username/updatehub-frontend:latest
默认账户: admin / admin123
```

### 第八步：在1Panel中查看容器

#### 8.1 登录1Panel
在浏览器中访问：
```
http://your-server-ip:10086
```

#### 8.2 查看容器状态

1. 进入 **容器** 页面
2. 你会看到4个UpdateHub相关的容器：
   - `updatehub-postgres` - PostgreSQL数据库
   - `updatehub-redis` - Redis缓存
   - `updatehub-backend` - 后端服务
   - `updatehub-frontend` - 前端服务

3. 每个容器应该显示为 **运行中** 状态

#### 8.3 查看容器详情

点击任意容器可以查看：
- 容器日志
- 资源使用情况
- 端口映射
- 环境变量

### 第九步：访问UpdateHub系统

#### 9.1 访问前端界面

在浏览器中访问：
```
http://your-server-ip
```

你应该看到UpdateHub的登录界面。

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

### 第十步：测试基本功能

#### 10.1 测试软件管理

1. 点击左侧菜单的 **软件管理**
2. 点击 **新建软件**
3. 填写软件信息：
   - 标识符: `test-app`
   - 名称: `测试应用`
   - 描述: `这是一个测试应用`
4. 点击 **保存**

#### 10.2 测试版本发布

1. 选择刚创建的 software
2. 点击 **发布版本**
3. 填写版本信息：
   - 版本号: `1.0.0`
   - 发布说明: `第一个版本`
4. 上传一个测试文件
5. 点击 **发布`

#### 10.3 测试API接口

在服务器上测试API：

```bash
# 测试健康检查
curl http://localhost:8080/health

# 应该返回：
# {"message":"UpdateHub server is running","status":"ok"}

# 测试登录接口
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your-new-password"}'
```

## 🔧 CI/CD 部署的优势

### 与传统方式对比

#### 传统部署方式：
```
❌ 每次部署需要在服务器上构建
❌ 构建过程消耗服务器资源
❌ 网络带宽消耗大
❌ 构建时间不稳定
❌ 难以保证构建环境一致性
```

#### CI/CD部署方式：
```
✅ 镜像在GitHub Actions中构建
✅ 服务器只负责运行
✅ 部署速度快（2-5分钟）
✅ 资源消耗小
✅ 构建环境标准化
✅ 版本管理清晰
```

### 镜像版本管理

#### 镜像标签说明：
- `latest` - 最新版本
- `v1.0.0` - 具体版本号
- `v1.1.0` - 其他版本

#### 更新镜像：
```bash
# 拉取最新版本镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
docker pull ghcr.io/your-username/updatehub-frontend:latest

# 拉取特定版本镜像
docker pull ghcr.io/your-username/updatehub-backend:v1.0.0
docker pull ghcr.io/your-username/updatehub-frontend:v1.0.0
```

## 🔧 常见问题处理

### 问题1：Docker Compose 未安装

**现象**：
```
[FAIL] Docker Compose 未安装
```

**解决方法**：
```bash
# 安装 Docker Compose
sudo apt install -y docker-compose  # Ubuntu/Debian
sudo yum install -y docker-compose  # CentOS/RHEL

# 验证安装
docker-compose --version
```

### 问题2：无法拉取GitHub镜像

**现象**：
```
Error response from daemon: pull access denied
```

**解决方法**：
```bash
# 登录GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 或使用Docker Hub（如果镜像推送到Docker Hub）
docker login
```

### 问题3：镜像拉取速度慢

**现象**：
```
镜像拉取时间很长
```

**解决方法**：
```bash
# 使用镜像加速器（可选）
# 配置Docker镜像加速器
```

### 问题4：容器启动失败

**现象**：
```
容器启动失败
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

## 📊 部署后维护

### 查看服务状态

#### 方法1：使用脚本
```bash
cd /opt/UpdateHub/scripts
./check_env.sh
```

#### 方法2：使用Docker命令
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml ps
```

#### 方法3：使用1Panel
在1Panel的容器页面查看所有容器状态

### 查看服务日志

#### 方法1：使用脚本
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml logs -f
```

#### 方法2：使用1Panel
在1Panel中点击容器 -> 查看日志

### 重启服务

#### 方法1：使用脚本
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml restart
```

#### 方法2：使用1Panel
在1Panel中点击容器 -> 重启

### 停止服务

#### 方法1：使用脚本
```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

#### 方法2：使用1Panel
在1Panel中点击容器 -> 停止

## 🔄 更新系统（CI/CD方式）

### 更新到新版本

#### 使用自动化脚本更新
```bash
cd /opt/UpdateHub/scripts
./update.sh
```

脚本会自动：
- ✅ 备份当前配置
- ✅ 拉取新版本镜像
- ✅ 更新服务
- ✅ 验证更新结果

#### 手动更新镜像
```bash
# 1. 拉取新镜像
docker pull ghcr.io/your-username/updatehub-backend:latest
docker pull ghcr.io/your-username/updatehub-frontend:latest

# 2. 重启服务
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

#### 使用特定版本
```bash
# 1. 修改 .env 文件中的镜像版本
# BACKEND_IMAGE=ghcr.io/your-username/updatehub-backend:v1.0.0
# FRONTEND_IMAGE=ghcr.io/your-username/updatehub-frontend:v1.0

# 2. 重新启动服务
docker-compose -f docker/docker-compose.1panel.yml up -d
```

## 🎯 下一步操作

部署完成后，建议进行以下操作：

### 1. 安全加固
- [ ] 修改默认管理员密码
- [ ] 修改数据库密码
- [ ] 配置防火墙规则
- [ ] 启用SSL证书（推荐）

### 2. 功能配置
- [ ] 配置存储后端（本地/S3/COS）
- [ ] 配置邮件通知
- [ ] 配置备份策略
- [ ] 配置监控告警

### 3. 业务配置
- [ ] 创建第一个软件项目
- [ ] 发布第一个版本
- [ ] 配置客户端更新检查
- [ ] 测试完整的更新流程

### 4. 备份策略
- [ ] 设置自动备份
- [ ] 测试备份恢复
- [ ] 配置异地备份

## 📞 获取帮助

如果在部署过程中遇到问题：

1. **查看日志**：检查详细的错误信息
2. **运行环境检查**：`./check_env.sh`
3. **查看文档**：参考其他详细文档
4. **联系支持**：寻求技术支持

## 🎉 恭喜！

你已经成功完成了 UpdateHub 的第一次部署！

### 🚀 CI/CD部署的优势

现在你的系统享受以下优势：

- **部署快速**：2-5分钟完成部署
- **资源节省**：服务器不需要构建环境
- **网络节省**：只拉取镜像，不下载依赖
- **一致性高**：所有环境使用相同的预构建镜像
- **版本管理**：清晰的镜像版本标签

### 📝 现在你可以：

- 在浏览器中访问 http://your-server-ip 使用系统
- 在1Panel中管理Docker容器
- 使用自动化脚本进行快速更新
- 通过更改镜像版本来升级系统

记住：定期更新镜像版本，保持系统安全和功能最新！
