# GitHub Container Registry 权限配置指南

## 问题

构建成功但推送失败，错误信息：
```
ERROR: failed to push ghcr.io/eunsolfs/updatehub-backend:latest: denied: installation not allowed to Create organization package
```

## 解决方案

### 方法1：在仓库设置中启用包功能

1. 进入 GitHub 仓库页面
2. 点击 **Settings** 标签
3. 在左侧菜单中找到 **Actions** → **General**
4. 滚动到 **Workflow permissions** 部分
5. 选择 **Read and write permissions**
6. 勾选 **Enable GitHub Actions to create and approve pull requests**
7. 点击 **Save**

### 方法2：在仓库设置中启用包设置

1. 进入 GitHub 仓库页面
2. 点击 **Settings** 标签
3. 在左侧菜单中找到 **Actions** → **General**
4. 找到 **Package access** 部分
5. 选择 **Allow all actions** 或 **Allow specific actions**
6. 保存设置

### 方法3：检查包设置

1. 进入 GitHub 仓库页面
2. 点击 **Settings** 标签
3. 在左侧菜单中找到 **Packages**
4. 确保 **Package registry** 已启用
5. 确保 **Container registry** 已启用

### 方法4：使用个人账户而非组织

如果你的仓库在组织下，可能需要：

1. 将仓库转移到个人账户
2. 或者在组织设置中配置包权限

## 验证设置

配置完成后，重新运行 GitHub Actions workflow。

## 临时解决方案

如果上述方法不适用，可以考虑：

1. 使用 Docker Hub 替代 GitHub Container Registry
2. 修改工作流以推送到 Docker Hub

### 推送到 Docker Hub 的配置

```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

- name: Build and push backend image
  uses: docker/build-push-action@v6
  with:
    context: .
    file: ./docker/Dockerfile.backend
    push: true
    tags: |
      docker.io/${{ secrets.DOCKER_USERNAME }}/updatehub-backend:latest
      docker.io/${{ secrets.DOCKER_USERNAME }}/updatehub-backend:${{ github.ref_name }}
```

在 GitHub Secrets 中添加：
- `DOCKER_USERNAME`: Docker Hub 用户名
- `DOCKER_PASSWORD`: Docker Hub 密码或访问令牌
