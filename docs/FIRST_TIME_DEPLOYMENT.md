# UpdateHub 第一次部署完整操作指南

本指南专为第一次部署 UpdateHub 的用户设计，提供从零开始的完整操作步骤。

## 🎯 适用人群

- 第一次使用 UpdateHub 的用户
- 不熟悉 Docker 和 Linux 命令的用户
- 希望在 1Panel 环境中部署的用户

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
- **网络**: 能访问GitHub（用于下载代码）

### 2. 准备工作清单

在开始之前，请确认：

- [ ] 服务器已安装 1Panel
- [ ] 有服务器的root权限或sudo权限
- [ ] 服务器网络连接正常
- [ ] 服务器磁盘空间充足
- [ ] 已准备好访问 1Panel 的密码

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

#### 2.2 安装Git
```bash
# Ubuntu/Debian
apt install -y git

# CentOS/RHEL
yum install -y git
```

#### 2.3 验证Git安装
```bash
git --version
# 应该显示类似：git version 2.x.x
```

### 第三步：获取UpdateHub代码

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
# backend/  frontend/  docker/  docs/  scripts/
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
# deploy.sh       # 一键部署脚本
# update.sh       # 一键更新脚本
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
  UpdateHub 一键部署脚本
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
Git 仓库地址 [https://github.com/your-username/UpdateHub.git]: 
```

**问题5：Git仓库地址**
- **推荐**: 直接按回车（使用项目中的地址）
- **自定义**: 如果有其他仓库地址，可以输入

```
配置摘要:
  安装目录: /opt/UpdateHub
  数据库密码: MyStr0ngP@ssw0rd
  JWT 密钥: r@nd0mJWTk3y-2024
  服务器端口: 8080
  Git 仓库: https://github.com/your-username/UpdateHub.git

确认配置? (y/n): 
```

**问题6：确认配置**
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
[INFO] 修改 Docker Compose 配置...
[SUCCESS] Docker Compose 配置修改完成
[INFO] 构建 Docker 镜像...
```

这个过程可能需要5-15分钟，取决于你的网络速度和服务器性能。

#### 6.4 查看安装进度

在安装过程中，你会看到类似这样的输出：

```
Step 1/8 : FROM golang:1.21-alpine
 ---> abc123def456
Step 2/8 : WORKDIR /app
 ---> Running in 789012345678
 ---> removed intermediate container 789012345678
 ---> fed456cba789
...
```

这是正常的Docker镜像构建过程，请耐心等待。

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

访问地址:
  前端: http://192.168.1.100
  后端: http://192.168.1.100:8080
  健康检查: http://192.168.1.100:8080/health

默认账户:
  用户名: admin
  密码: admin123

⚠️  重要: 请立即修改默认密码！

常用命令:
  查看日志: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml logs -f
  停止服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml down
  启动服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml up -d
  重启服务: docker-compose -f /opt/UpdateHub/docker/docker-compose.1panel.yml restart

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

1. 选择刚创建的软件
2. 点击 **发布版本**
3. 填写版本信息：
   - 版本号: `1.0.0`
   - 发布说明: `第一个版本`
4. 上传一个测试文件
5. 点击 **发布**

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

## 🔧 常见问题处理

### 问题1：端口占用

**现象**：
```
[WARNING] 端口 8080 已被占用
```

**解决方法**：
```bash
# 查看端口占用
netstat -tuln | grep 8080

# 如果被占用，在脚本中选择其他端口
# 或者停止占用端口的服务
```

### 问题2：Docker未安装

**现象**：
```
[ERROR] Docker 未安装
```

**解决方法**：
```bash
# 安装Docker
curl -fsSL https://get.docker.com | sh

# 启动Docker
systemctl start docker
systemctl enable docker
```

### 问题3：权限不足

**现象**：
```
Permission denied
```

**解决方法**：
```bash
# 使用sudo运行脚本
sudo ./deploy.sh

# 或者将用户添加到docker组
sudo usermod -aG docker $USER
newgrp docker
```

### 问题4：网络连接失败

**现象**：
```
Failed to connect to github.com
```

**解决方法**：
```bash
# 检查网络连接
ping github.com

# 如果无法访问GitHub，可以使用镜像
# 或手动下载代码后上传到服务器
```

### 问题5：容器启动失败

**现象**：
```
容器启动失败
```

**解决方法**：
```bash
# 查看容器日志
docker logs updatehub-backend

# 在1Panel中查看容器日志
# 进入容器页面 -> 点击容器 -> 查看日志
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

现在你可以：
- 在浏览器中访问 http://your-server-ip 使用系统
- 在1Panel中管理Docker容器
- 使用自动化脚本进行后续的更新和维护

记住：定期更新系统和备份数据，保证系统安全稳定运行！
