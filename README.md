# UpdateHub

一个基于Linux服务器的软件自动更新管理系统，支持多软件版本的集中式发布与分发管理。

## 🚀 超级简单安装 ⭐

### 一键安装（推荐）

只需 3 个步骤即可完成安装：

```bash
# 步骤1：下载安装脚本
curl -fsSL https://raw.githubusercontent.com/Eunsolfs/UpdateHub/main/scripts/install.sh -o install.sh

# 步骤2：添加执行权限
chmod +x install.sh

# 步骤3：运行安装脚本
sudo ./install.sh
```

就这么简单！脚本会自动完成：
- ✅ 检查基础环境
- ✅ 安装 Docker 和 Docker Compose
- ✅ 下载项目代码
- ✅ 执行自动化部署
- ✅ 配置镜像加速
- ✅ 启动所有服务

## 📋 部署方式选择

如果你需要选择其他部署方式，请查看 [部署方式选择指南](docs/DEPLOYMENT_CHOICE.md)。

### 可用部署方式

- **脚本一键部署** - 最推荐，自动化程度高
- **手动部署** - 适合有经验的用户
- **精简版部署** - 只需要配置文件和镜像

## 🎯 核心特性

### 部署特性
- ⚡ **CI/CD 部署**：使用 GitHub Actions 自动构建预构建镜像
- 🚀 **一键安装**：超级简单的安装方式，3步完成
- 🔧 **自动化运维**：完整的运维脚本体系
- 🗑️ **安全卸载**：支持保留数据或完全卸载
- 📦 **版本管理**：基于 Git tag 的版本发布和回滚

### 功能特性
- **多软件管理**: 支持管理多个软件项目的版本发布
- **版本控制**: 完整的版本发布、回滚、下架功能
- **客户端API**: 提供HTTP接口供客户端检查更新
- **可视化管理**: Web端后台界面，操作简单直观
- **易于部署**: 支持Docker容器化，适配1panel一键部署
- **安全可靠**: JWT认证、RBAC权限控制、文件校验、操作日志

## 📦 镜像信息

### 预构建镜像

UpdateHub 使用 GitHub Container Registry 托管预构建的 Docker 镜像：

- **后端镜像**: `ghcr.io/eunsolfs/updatehub-backend`
- **前端镜像**: `ghcr.io/eunsolfs/updatehub-frontend`

### 镜像标签

- `latest` - 最新版本
- `v1.0.0` - 具体版本号（基于 Git tag）

## 🛠️ 运维管理

### 一键运维脚本

安装完成后，可以使用运维脚本进行日常管理：

```bash
cd /opt/UpdateHub/scripts

# 运维管理（修改配置、镜像加速等）
./ops.sh

# 系统更新
./update.sh

# 数据备份
./backup.sh

# 卸载系统
./uninstall.sh
```

### 运维脚本功能

**ops.sh - 运维管理脚本**
- 修改管理员密码
- 修改端口号
- 修改镜像源（切换版本）
- 修改数据库密码
- 修改 JWT 密钥
- 配置 Docker 镜像加速
- 重启服务
- 查看当前配置

**uninstall.sh - 卸载脚本**
- 保留数据，只删除服务
- 清除所有数据和服务
- 选择性清理

## 📚 文档

### 部署文档
- [部署方式选择指南](docs/DEPLOYMENT_CHOICE.md) - 选择合适的部署方式
- [脚本一键部署指南](docs/SCRIPT_DEPLOYMENT.md) - 脚本自动化部署
- [手动部署指南](docs/MANUAL_DEPLOYMENT.md) - 手动部署步骤
- [精简版部署指南](docs/MINIMAL_DEPLOYMENT.md) - 最小化部署
- [1Panel 部署指南](docs/1PANEL_DEPLOYMENT.md) - 1Panel 环境部署

### 运维文档
- [服务更新指南](docs/SERVICE_UPDATE.md) - 系统更新
- [版本发布指南](docs/VERSION_RELEASE.md) - 版本管理
- [脚本使用指南](scripts/README.md) - 自动化脚本说明
- [文档导航](docs/INDEX.md) - 完整文档导航

### 其他文档
- [API 文档](docs/API.md) - API 接口文档
- [开发指南](docs/DEVELOPMENT.md) - 开发环境搭建
- [GHCR 权限设置](docs/GHCR_PERMISSION_SETUP.md) - GitHub Container Registry 权限配置

## 🏗️ 技术栈

### 后端
- Go 1.21+ - 高性能、易部署
- Gin - Web框架
- GORM - ORM框架
- PostgreSQL 15+ - 关系型数据库
- JWT - 身份认证
- Gorilla WebSocket - WebSocket库
- Redis - 缓存和限流

### 前端
- Vue 3 + TypeScript - 现代化前端框架
- Element Plus - UI组件库
- Vite - 构建工具
- Pinia - 状态管理
- Axios - HTTP客户端
- Vue Router - 路由管理
- ECharts - 数据可视化

### 部署
- Docker + Docker Compose - 容器化部署
- Nginx - 反向代理
- GitHub Actions - CI/CD 自动构建
- GitHub Container Registry - 镜像仓库

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发起 Pull Request
- 发送邮件

## 📄 许可证

MIT License

---

**UpdateHub - 让软件更新管理变得简单！** 🚀
