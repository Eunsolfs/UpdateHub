# UpdateHub 脚本一键部署指南 ⭐

## 🎯 推荐方式

这是 UpdateHub **最推荐**的部署方式，适合所有用户，特别是新手。

### 优势

- ✅ **最简单**：一个命令完成所有部署
- ✅ **最快速**：5-10分钟完成部署
- ✅ **最安全**：自动配置镜像加速和安全设置
- ✅ **最完善**：包含运维管理工具
- ✅ **可卸载**：支持一键卸载，可选择保留数据

---

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

### 检查环境

如果不确定环境是否满足要求，可以运行环境检查脚本：

```bash
# 从项目获取环境检查脚本
git clone https://github.com/Eunsolfs/UpdateHub.git /tmp/UpdateHub
cd /tmp/UpdateHub/scripts
chmod +x check_env.sh
./check_env.sh
```

---

## 🚀 一键安装（超级简单）⭐

### 最简单的安装方式

这是 UpdateHub **最简单**的安装方式，只需3个步骤：

#### 步骤1：下载安装脚本

```bash
# 在服务器上下载安装脚本
curl -fsSL https://raw.githubusercontent.com/Eunsolfs/UpdateHub/main/scripts/install.sh -o install.sh
```

#### 步骤2：添加执行权限

```bash
chmod +x install.sh
```

#### 步骤3：运行安装脚本

```bash
sudo ./install.sh
```

**就这么简单！** 脚本会自动完成：
- ✅ 检查基础环境
- ✅ 安装 Docker 和 Docker Compose
- ✅ 下载项目代码
- ✅ 执行自动化部署
- ✅ 配置镜像加速
- ✅ 启动所有服务

### 安装脚本说明

**`install.sh`** - 一键安装脚本
- 自动检测和安装依赖
- 自动下载项目代码
- 自动执行部署
- 超级简单，3步完成安装

---

## 🚀 标准一键部署

如果不想使用一键安装脚本，可以使用标准部署方式：

### 步骤1：获取部署脚本

```bash
# 克隆项目获取部署脚本
git clone https://github.com/Eunsolfs/UpdateHub.git /tmp/UpdateHub
cd /tmp/UpdateHub/scripts
chmod +x deploy.sh
```

### 步骤2：运行部署脚本

```bash
./deploy.sh
```

### 步骤3：按提示配置

脚本会引导你完成以下配置：

1. **安装目录**：默认 `/opt/UpdateHub`
2. **数据库密码**：设置强密码
3. **JWT 密钥**：设置 JWT 密钥
4. **服务器端口**：默认 8080
5. **镜像选择**：选择镜像源（latest 或特定版本）
6. **镜像加速**：选择是否配置 Docker 镜像加速

### 步骤4：确认部署

脚本会显示配置摘要，确认后开始自动部署：

```
========================================
  配置摘要
========================================
  安装目录: /opt/UpdateHub
  数据库密码: ********
  JWT 密钥: ********
  服务器端口: 8080
  后端镜像: ghcr.io/eunsolfs/updatehub-backend:latest
  前端镜像: ghcr.io/eunsolfs/updatehub-frontend:latest

确认配置? (y/n): y
```

### 步骤5：等待部署完成

脚本会自动完成以下步骤：

1. ✅ 检查环境
2. ✅ 配置 Docker 镜像加速
3. ✅ 克隆项目代码
4. ✅ 创建配置文件
5. ✅ 拉取 Docker 镜像
6. ✅ 启动所有服务
7. ✅ 验证部署结果

### 步骤6：访问系统

部署完成后，可以通过以下地址访问：

- **前端界面**: http://localhost
- **后端 API**: http://localhost:8080
- **健康检查**: http://localhost:8080/health
- **默认管理员账号**: admin / admin123

⚠️ **重要**: 首次登录后请立即修改默认密码！

---

## 🔧 脚本自动化内容

### 环境检查
- ✅ 操作系统版本检查
- ✅ 系统资源检查（CPU、内存、磁盘）
- ✅ Docker 安装状态检查
- ✅ Docker Compose 安装状态检查
- ✅ 端口占用检查
- ✅ 网络连接检查

### Docker 镜像加速
- ✅ 自动配置国内镜像加速
- ✅ 支持多个镜像源选择
- ✅ 自动重启 Docker 服务

### 镜像拉取
- ✅ 自动拉取后端镜像
- ✅ 自动拉取前端镜像
- ✅ 拉取失败自动重试

### 服务启动
- ✅ 自动创建必要的目录
- ✅ 自动配置环境变量
- ✅ 自动启动所有服务
- ✅ 自动验证服务状态

---

## 🎯 部署后验证

### 检查服务状态

```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml ps
```

应该看到所有服务都是 `Up` 状态。

### 检查健康状态

```bash
curl http://localhost:8080/health
```

应该返回健康检查结果。

### 检查日志

```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml logs -f
```

---

## 🛠️ 运维管理

部署完成后，可以使用运维脚本进行日常管理：

### 运维管理脚本

```bash
cd /opt/UpdateHub/scripts
./ops.sh
```

运维脚本提供以下功能：

1. **修改管理员密码**
2. **修改端口号**
3. **修改镜像源**（切换版本）
4. **修改数据库密码**
5. **修改 JWT 密钥**
6. **配置 Docker 镜像加速**
7. **重启服务**
8. **查看当前配置**

### 系统更新

```bash
cd /opt/UpdateHub/scripts
./update.sh
```

更新脚本会自动：
- ✅ 备份当前配置
- ✅ 拉取新版本镜像
- ✅ 更新服务
- ✅ 验证更新结果

### 数据备份

```bash
cd /opt/UpdateHub/scripts
./backup.sh
```

备份脚本会自动：
- ✅ 备份数据库
- ✅ 备份配置文件
- ✅ 备份上传文件
- ✅ 清理旧备份

---

## 🗑️ 卸载 UpdateHub

### 一键卸载脚本

如果使用脚本一键部署，可以使用卸载脚本：

```bash
cd /opt/UpdateHub/scripts
./uninstall.sh
```

### 卸载选项

卸载脚本会提供以下选项：

#### 选项1：保留数据，只删除服务

**说明**：只删除 Docker 容器和镜像，保留所有数据和配置文件

**保留内容**：
- ✅ 数据库数据
- ✅ 配置文件
- ✅ 上传文件
- ✅ 项目代码

**删除内容**：
- ❌ Docker 容器
- ❌ Docker 镜像
- ❌ 运行时服务

**适用场景**：计划重新部署，需要保留数据

#### 选项2：清除所有数据和服务

**说明**：删除所有内容，包括数据、配置、容器、镜像

**删除内容**：
- ❌ 数据库数据
- ❌ 配置文件
- ❌ 上传文件
- ❌ Docker 容器
- ❌ Docker 镜像
- ❌ 项目代码

**适用场景**：完全卸载，不保留任何数据

#### 选项3：选择性清理

**说明**：可以选择性清理不同部分

**可选项**：
- 清理 Docker 容器
- 清理 Docker 镜像
- 清理数据库数据
- 清理配置文件
- 清理上传文件
- 清理项目代码

**适用场景**：部分清理，保留需要的内容

### 手动卸载

如果卸载脚本不可用，可以手动执行：

#### 保留数据的卸载

```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down
```

#### 完全卸载

```bash
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml down -v
docker system prune -a
rm -rf /opt/UpdateHub
```

---

## 🔍 故障排除

### 部署失败

#### 环境检查失败
```bash
# 检查 Docker 是否安装
docker --version

# 检查 Docker Compose 是否安装
docker-compose --version

# 安装缺失的组件
```

#### 镜像拉取失败
```bash
# 检查网络连接
ping github.com

# 检查 Docker 镜像加速配置
cat /etc/docker/daemon.json

# 手动拉取镜像测试
docker pull ghcr.io/eunsolfs/updatehub-backend:latest
```

#### 服务启动失败
```bash
# 查看服务日志
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml logs

# 检查环境变量配置
cat docker/.env
```

### 运行时问题

#### 服务无法访问
```bash
# 检查服务状态
docker-compose -f docker/docker-compose.1panel.yml ps

# 检查端口占用
netstat -tulpn | grep 8080

# 检查防火墙
sudo ufw status
```

#### 数据库连接失败
```bash
# 检查数据库容器
docker ps | grep postgres

# 测试数据库连接
docker exec -it updatehub-postgres psql -U updatehub -d updatehub
```

---

## 📚 相关文档

- [部署方式选择指南](./DEPLOYMENT_CHOICE.md) - 选择合适的部署方式
- [手动部署指南](./MANUAL_DEPLOYMENT.md) - 手动部署步骤
- [精简版部署指南](./MINIMAL_DEPLOYMENT.md) - 精简版部署
- [版本发布指南](./VERSION_RELEASE.md) - 版本管理
- [运维脚本使用指南](../scripts/README.md) - 运维脚本说明

---

## 🎯 总结

### 脚本一键部署的优势

1. **最简单**：一个命令完成所有部署
2. **最快速**：5-10分钟完成部署
3. **最安全**：自动配置所有安全设置
4. **最完善**：包含完整的运维工具
5. **可卸载**：支持灵活的卸载选项

### 适用场景

- ✅ 新手用户快速上手
- ✅ 生产环境快速部署
- ✅ 测试环境快速搭建
- ✅ 需要运维管理工具的环境

### 不适用场景

- ❌ 需要深度定制部署过程
- ❌ 需要完全控制每个步骤
- ❌ 特殊的网络环境限制

---

**开始使用脚本一键部署，5分钟内完成 UpdateHub 部署！** 🚀
