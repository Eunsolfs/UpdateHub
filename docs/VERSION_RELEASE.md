# UpdateHub 版本发布和使用指南

## 📦 版本发布机制

### GitHub Actions 自动构建

UpdateHub 使用 GitHub Actions 自动构建和推送 Docker 镜像到 GitHub Container Registry (GHCR)。

### 触发条件

工作流在以下情况下触发：

1. **推送标签**（推荐用于版本发布）
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   - 会构建版本标签的镜像：`v1.0.0`
   - 会更新 `latest` 标签

2. **推送到 main 分支**
   ```bash
   git push origin main
   ```
   - 只会更新 `latest` 标签
   - 适合日常开发测试

3. **Pull Request**
   - 构建但不推送镜像
   - 用于测试构建是否成功

4. **手动触发**
   - 在 GitHub Actions 页面手动运行

### 镜像命名规则

镜像名称格式：
```
ghcr.io/{username}/updatehub-{type}:{tag}
```

**示例**：
- `ghcr.io/eunsolfs/updatehub-backend:latest`
- `ghcr.io/eunsolfs/updatehub-backend:v1.0.0`
- `ghcr.io/eunsolfs/updatehub-frontend:latest`
- `ghcr.io/eunsolfs/updatehub-frontend:v1.0.0`

**重要**：用户名必须是小写！

## 🚀 版本发布步骤

### 1. 准备发布

确保代码已经测试通过，并且：
- 后端代码没有错误
- 前端构建成功
- 所有功能正常工作

### 2. 创建版本标签

```bash
# 确保在 main 分支
git checkout main
git pull origin main

# 创建版本标签（语义化版本）
git tag v1.0.0

# 推送标签到 GitHub
git push origin v1.0.0
```

### 3. GitHub Actions 自动构建

推送标签后，GitHub Actions 会自动：
- ✅ 提取版本号（`v1.0.0` → `1.0.0`）
- ✅ 构建后端镜像并打标签（`latest` 和 `v1.0.0`）
- ✅ 构建前端镜像并打标签（`latest` 和 `v1.0.0`）
- ✅ 推送镜像到 GitHub Container Registry

### 4. 验证镜像

在 GitHub 仓库的 **Packages** 页面查看：
- 后端镜像：`updatehub-backend`
- 前端镜像：`updatehub-frontend`
- 版本标签：`latest`, `v1.0.0`

## 📥 使用指定版本

### 方法1：修改 .env 文件

编辑 `docker/.env` 文件：

```bash
# 使用最新版本
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:latest
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:latest

# 使用特定版本（推荐生产环境）
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0
```

### 方法2：修改 docker-compose 文件

直接在 `docker/docker-compose.1panel.yml` 中修改：

```yaml
services:
  backend:
    image: ghcr.io/eunsolfs/updatehub-backend:v1.0.0
  
  frontend:
    image: ghcr.io/eunsolfs/updatehub-frontend:v1.0.0
```

### 方法3：使用部署脚本

运行部署脚本时，脚本会询问镜像地址：

```bash
cd /opt/UpdateHub/scripts
./deploy.sh
```

按提示输入镜像地址，例如：
```
后端镜像 [ghcr.io/your-username/updatehub-backend:latest]: ghcr.io/eunsolfs/updatehub-backend:v1.0.0
前端镜像 [ghcr.io/your-username/updatehub-frontend:latest]: ghcr.io/eunsolfs/updatehub-frontend:v1.0.0
```

## 🔄 版本更新

### 更新到最新版本

```bash
cd /opt/UpdateHub/scripts
./update.sh
```

脚本会自动拉取 `latest` 标签的镜像。

### 更新到特定版本

```bash
# 1. 修改 .env 文件
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.1.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.1.0

# 2. 重启服务
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

### 版本回滚

```bash
# 1. 修改 .env 文件回退到之前版本
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0

# 2. 重启服务
cd /opt/UpdateHub
docker-compose -f docker/docker-compose.1panel.yml up -d
```

## 📋 版本管理最佳实践

### 语义化版本号

推荐使用语义化版本号（Semantic Versioning）：

- `v1.0.0` - 主版本.次版本.修订版本
- 主版本：不兼容的 API 修改
- 次版本：向下兼容的功能性新增
- 修订版本：向下兼容的问题修正

### 版本发布流程

1. **开发阶段**
   - 在 main 分支开发
   - 提交代码会自动更新 `latest` 镜像

2. **测试阶段**
   - 使用 `latest` 镜像进行测试
   - 确保功能正常

3. **发布阶段**
   - 创建版本标签 `v1.0.0`
   - GitHub Actions 自动构建版本镜像
   - 标记为稳定版本

4. **维护阶段**
   - 后续修复使用 `v1.0.1`, `v1.0.2` 等
   - 新功能使用 `v1.1.0`, `v1.2.0` 等
   - 重大变更使用 `v2.0.0`, `v3.0.0` 等

### 版本锁定

生产环境建议锁定到特定版本：

```bash
# 生产环境
BACKEND_IMAGE=ghcr.io/eunsolfs/updatehub-backend:v1.0.0
FRONTEND_IMAGE=ghcr.io/eunsolfs/updatehub-frontend:v1.0.0
```

这样可以：
- ✅ 避免自动更新导致的问题
- ✅ 确保环境稳定性
- ✅ 便于版本回滚

### 定期更新

定期检查新版本并更新：

```bash
# 查看可用版本
docker pull ghcr.io/eunsolfs/updatehub-backend
docker pull ghcr.io/eunsolfs/updatehub-frontend

# 测试新版本
# 在测试环境中先部署测试

# 生产环境更新
# 修改 .env 文件并重启服务
```

## 🔍 查看可用版本

### 方法1：GitHub Packages 页面

1. 访问 GitHub 仓库
2. 点击 **Packages** 标签
3. 选择对应的包（`updatehub-backend` 或 `updatehub-frontend`）
4. 查看所有版本标签

### 方法2：Docker 命令

```bash
# 查看后端镜像的所有标签
docker pull ghcr.io/eunsolfs/updatehub-backend
docker images | grep updatehub-backend

# 查看前端镜像的所有标签
docker pull ghcr.io/eunsolfs/updatehub-frontend
docker images | grep updatehub-frontend
```

### 方法3：GitHub API

```bash
# 使用 GitHub API 查看版本标签
curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/eunsolfs/UpdateHub/tags
```

## 🎯 当前状态

### 已发布的镜像

当前可用的镜像：

- **后端**：`ghcr.io/eunsolfs/updatehub-backend:latest`
- **前端**：`ghcr.io/eunsolfs/updatehub-frontend:latest`

### 下一步

1. **创建第一个正式版本标签**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **验证版本镜像**
   - 检查 GitHub Packages 页面
   - 验证镜像可以正常拉取

3. **在生产环境使用版本镜像**
   - 修改 `.env` 文件使用 `v1.0.0` 标签
   - 重启服务验证

## 📞 常见问题

### Q: 为什么标签需要用 v 开头？

A: 这是 GitHub Actions 的配置要求，用于识别版本标签。格式为 `v*`，例如 `v1.0.0`, `v2.0.0`。

### Q: latest 标签会不会自动更新？

A: 是的，每次推送到 main 分支或创建新标签时，`latest` 标签都会更新到最新版本。

### Q: 如何删除旧版本？

A: 在 GitHub Packages 页面可以删除不需要的版本标签，但不建议删除最新版本。

### Q: 如何回退到之前的版本？

A: 修改 `.env` 文件中的镜像标签为之前的版本，然后重启服务即可。

### Q: 镜像大小是多少？

A: 后端镜像约 150MB，前端镜像约 50MB。使用国内镜像可以加速下载。

### Q: 如何加速镜像拉取？

A: 可以配置 Docker 镜像加速器，或使用代理服务器。
