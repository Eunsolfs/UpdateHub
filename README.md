# UpdateHub

一个基于Linux服务器的软件自动更新管理系统，支持多软件版本的集中式发布与分发管理。

## 🚀 快速开始

### 第一次使用？
→ 查看 [docs/FIRST_TIME_DEPLOYMENT.md](docs/FIRST_TIME_DEPLOYMENT.md) **第一次部署完整操作指南** ⭐

**手把手教你从零开始部署 UpdateHub，适合所有用户！**

### 快速部署

## 功能特性

### 核心功能
- **多软件管理**: 支持管理多个软件项目的版本发布
- **版本控制**: 完整的版本发布、回滚、下架功能
- **客户端API**: 提供HTTP接口供客户端检查更新
- **可视化管理**: Web端后台界面，操作简单直观
- **易于部署**: 支持Docker容器化，适配1panel一键部署
- **安全可靠**: JWT认证、RBAC权限控制、文件校验、操作日志

### 高级功能
- **断点续传**: 支持大文件上传中断后继续上传
- **分片上传**: 大文件分片上传，提高上传成功率
- **出错回滚**: 上传失败自动清理临时文件，支持版本回滚
- **多存储支持**: 支持本地存储、AWS S3、腾讯云COS等多种存储后端
- **增量更新**: 支持bsdiff等增量更新算法，减少下载流量
- **全量更新**: 支持完整版本包下载
- **登录鉴权**: 完善的用户认证和权限管理系统
- **版本存档**: 自动保存最近10个历史版本，支持快速切换
- **自动校验**: 上传文件自动生成MD5/SHA256校验值
- **热更新推送**: 支持WebSocket实时推送更新通知
- **客户端管理**: 跟踪在线客户端状态，支持定向推送
- **API限流**: 支持接口访问频率限制，防止滥用
- **Webhook集成**: 支持事件触发Webhook通知，集成第三方系统
- **CDN加速**: 支持CDN分发，提升下载速度
- **多语言支持**: 支持国际化，多语言界面
- **系统监控**: 完善的健康检查和性能监控
- **防盗刷鉴权**: 多重防护机制防止流量盗刷和恶意下载

## 技术栈

### 后端
- Go 1.21+ - 高性能、易部署
- Gin - Web框架
- GORM - ORM框架
- PostgreSQL 15+ - 关系型数据库
- JWT - 身份认证
- AWS SDK for Go - S3存储支持
- Tencent COS SDK - 腾讯云COS支持
- MinIO Client - 对象存储兼容接口
- WebSocket - 实时推送支持
- Gorilla WebSocket - WebSocket库
- Redis - 缓存和限流
- golang.org/x/time - 限流算法
- Swagger - API文档生成

### 前端
- Vue 3 + TypeScript - 现代化前端框架
- Element Plus - UI组件库
- Vite - 构建工具
- Pinia - 状态管理
- Axios - HTTP客户端
- Vue Router - 路由管理
- ECharts - 数据可视化
- Day.js - 日期处理
- VueUse - Vue组合式工具库
- Vue I18n - 国际化支持

### 部署
- Docker + Docker Compose - 容器化部署
- Nginx - 反向代理
- 1panel - 服务器管理面板
- Redis - 缓存和会话存储（可选）
- Redis Pub/Sub - WebSocket消息分发（可选）

## 项目结构

```
lfs-update-server/
├── backend/                 # Go后端
│   ├── cmd/
│   │   └── server/
│   │       └── main.go
│   ├── internal/
│   │   ├── api/            # API路由
│   │   ├── model/          # 数据模型
│   │   ├── service/        # 业务逻辑
│   │   ├── repository/     # 数据访问
│   │   └── middleware/     # 中间件
│   ├── pkg/                # 公共包
│   │   ├── storage/        # 存储抽象层
│   │   ├── upload/         # 分片上传处理
│   │   └── diff/           # 增量更新算法
│   ├── configs/            # 配置文件
│   ├── uploads/            # 上传文件存储
│   ├── go.mod
│   └── go.sum
├── frontend/               # Vue前端
│   ├── src/
│   │   ├── api/           # API调用
│   │   ├── views/         # 页面
│   │   │   ├── dashboard/    # 仪表盘
│   │   │   ├── software/     # 软件管理
│   │   │   ├── version/      # 版本管理
│   │   │   ├── upload/       # 上传管理
│   │   │   ├── storage/      # 存储配置
│   │   │   ├── user/         # 用户管理
│   │   │   ├── role/         # 角色管理
│   │   │   ├── log/          # 操作日志
│   │   │   └── settings/     # 系统设置
│   │   ├── components/    # 组件
│   │   │   ├── layout/       # 布局组件
│   │   │   ├── common/       # 通用组件
│   │   │   └── charts/       # 图表组件
│   │   ├── router/        # 路由
│   │   ├── stores/        # 状态管理
│   │   └── utils/         # 工具函数
│   ├── package.json
│   └── vite.config.ts
├── docker/                 # Docker配置
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yml
├── scripts/                # 部署脚本
│   └── deploy.sh
└── docs/                   # 文档
```

## API接口

### 客户端接口

#### 检查更新
```
GET /api/v1/check-update
```

**请求参数:**
```json
{
  "identifier": "your-software-id",
  "current_version": "1.0.0",
  "platform": "windows"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "has_update": true,
    "latest_version": "1.1.0",
    "release_notes": "更新内容",
    "download_url": "https://your-domain.com/api/v1/download/xxx",
    "file_size": 1024000,
    "file_hash": "md5-hash",
    "force_update": false)
  }
}
```

### 管理接口

#### 管理员登录
```
POST /api/v1/auth/login
```

**请求参数:**
```json
{
  "username": "admin",
  "password": "password"
}
```

#### 软件管理
- `GET /api/v1/software` - 获取软件列表
- `POST /api/v1/software` - 创建软件项目
- `PUT /api/v1/software/:id` - 更新软件信息
- `DELETE /api/v1/software/:id` - 删除软件项目

#### 版本管理
- `POST /api/v1/version` - 发布新版本
- `GET /api/v1/version/:id` - 获取版本详情
- `PUT /api/v1/version/:id/status` - 版本状态管理
- `POST /api/v1/version/:id/rollback` - 版本回滚
- `GET /api/v1/version/:id/history` - 获取版本历史列表
- `POST /api/v1/version/:id/switch` - 切换到指定版本
- `DELETE /api/v1/version/:id` - 删除版本（仅限非发布版本）

#### 文件上传接口
- `POST /api/v1/upload/init` - 初始化分片上传
- `POST /api/v1/upload/chunk` - 上传分片
- `POST /api/v1/upload/complete` - 完成上传合并
- `POST /api/v1/upload/cancel` - 取消上传
- `GET /api/v1/upload/status/:taskId` - 查询上传状态

#### 存储管理接口
- `GET /api/v1/storage/config` - 获取存储配置
- `PUT /api/v1/storage/config` - 更新存储配置
- `POST /api/v1/storage/test` - 测试存储连接

#### 增量更新接口
- `POST /api/v1/diff/generate` - 生成增量更新包
- `GET /api/v1/diff/:versionId` - 获取增量更新包

#### 认证授权接口
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/logout` - 用户登出
- `POST /api/v1/auth/refresh` - 刷新Token
- `GET /api/v1/auth/user` - 获取当前用户信息
- `PUT /api/v1/auth/password` - 修改密码
- `GET /api/v1/users` - 获取用户列表（管理员）
- `POST /api/v1/users` - 创建用户（管理员）
- `PUT /api/v1/users/:id` - 更新用户（管理员）
- `DELETE /api/v1/users/:id` - 删除用户（管理员）
- `GET /api/v1/roles` - 获取角色列表（管理员）
- `POST /api/v1/roles` - 创建角色（管理员）
- `PUT /api/v1/roles/:id` - 更新角色权限（管理员）

#### WebSocket接口
- `WS /api/v1/ws/client` - 客户端WebSocket连接（接收更新推送）
- `WS /api/v1/ws/admin` - 管理后台WebSocket连接（实时监控）

#### 客户端管理接口
- `POST /api/v1/client/register` - 客户端注册
- `POST /api/v1/client/heartbeat` - 客户端心跳上报
- `GET /api/v1/client/list` - 获取在线客户端列表
- `POST /api/v1/client/push` - 向指定客户端推送更新通知
- `GET /api/v1/client/:id/status` - 获取客户端状态
- `DELETE /api/v1/client/:id` - 删除客户端记录

#### Webhook接口
- `GET /api/v1/webhooks` - 获取Webhook列表
- `POST /api/v1/webhooks` - 创建Webhook
- `PUT /api/v1/webhooks/:id` - 更新Webhook
- `DELETE /api/v1/webhooks/:id` - 删除Webhook
- `POST /api/v1/webhooks/:id/test` - 测试Webhook

#### 系统监控接口
- `GET /api/v1/health` - 健康检查
- `GET /api/v1/metrics` - 系统指标（Prometheus格式）
- `GET /api/v1/stats` - 统计数据
- `GET /api/v1/logs` - 系统日志查询

#### 限流配置接口
- `GET /api/v1/rate-limit/config` - 获取限流配置
- `PUT /api/v1/rate-limit/config` - 更新限流配置

#### 防盗刷鉴权接口
- `POST /api/v1/download/token` - 获取下载Token
- `GET /api/v1/download/verify` - 验证下载链接
- `GET /api/v1/security/ip-whitelist` - 获取IP白名单
- `POST /api/v1/security/ip-whitelist` - 添加IP白名单
- `DELETE /api/v1/security/ip-whitelist/:id` - 删除IP白名单
- `GET /api/v1/security/ip-blacklist` - 获取IP黑名单
- `POST /api/v1/security/ip-blacklist` - 添加IP黑名单
- `DELETE /api/v1/security/ip-blacklist/:id` - 删除IP黑名单
- `GET /api/v1/security/download-logs` - 获取下载安全日志

## 高级功能详解

### 分片上传与断点续传

#### 工作原理

1. **初始化上传**: 客户端调用 `POST /api/v1/upload/init`，服务器返回 `taskId`
2. **分片上传**: 客户端将文件分割为多个分片，逐个上传到 `POST /api/v1/upload/chunk`
3. **断点续传**: 如果上传中断，客户端可以查询已上传的分片，继续上传剩余分片
4. **完成上传**: 所有分片上传完成后，调用 `POST /api/v1/upload/complete` 合并文件
5. **取消上传**: 可以随时调用 `POST /api/v1/upload/cancel` 取消上传并清理临时文件

#### API接口详解

**初始化上传**
```http
POST /api/v1/upload/init
```

**请求参数:**
```json
{
  "file_name": "software-v1.0.0.exe",
  "file_size": 104857600,
  "file_hash": "md5-hash-of-entire-file",
  "chunk_size": 5242880,
  "mime_type": "application/octet-stream"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "task_id": "upload-task-uuid",
    "chunk_size": 5242880,
    "total_chunks": 20,
    "expires_at": "2024-01-01T12:00:00Z"
  }
}
```

**上传分片**
```http
POST /api/v1/upload/chunk
```

**请求参数 (multipart/form-data):**
- `task_id`: 任务ID
- `chunk_index`: 分片索引（从0开始）
- `chunk`: 分片文件数据
- `chunk_hash`: 分片MD5值

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "uploaded_chunks": 5,
    "total_chunks": 20
  }
}
```

**完成上传**
```http
POST /api/v1/upload/complete
```

**请求参数:**
```json
{
  "task_id": "upload-task-uuid",
  "file_hash": "md5-hash-of-entire-file"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "file_id": "file-uuid",
    "file_path": "/uploads/software-v1.0.0.exe",
    "file_size": 104857600,
    "file_hash": "md5-hash-of-entire-file"
  }
}
```

**查询上传状态**
```http
GET /api/v1/upload/status/:taskId
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "task_id": "upload-task-uuid",
    "status": "uploading",
    "uploaded_chunks": 15,
    "total_chunks": 20,
    "progress": 75
  }
}
```

### 多存储支持

#### 存储类型

**本地存储**
- 默认存储方式
- 文件保存在服务器本地磁盘
- 适合小规模部署

**AWS S3**
- 支持AWS S3及兼容服务
- 高可用、可扩展
- 适合大规模部署

**腾讯云COS**
- 腾讯云对象存储
- 国内访问速度快
- 支持CDN加速

**阿里云OSS**
- 阿里云对象存储
- 国内访问速度快
- 支持CDN加速

#### 存储配置示例

**本地存储配置**
```json
{
  "type": "local",
  "config": {
    "base_path": "/opt/lfs-update-server/uploads",
    "url_prefix": "https://update.yourdomain.com/uploads"
  }
}
```

**AWS S3配置**
```json
{
  "type": "s3",
  "config": {
    "access_key_id": "your-access-key",
    "secret_access_key": "your-secret-key",
    "region": "us-east-1",
    "bucket": "your-bucket-name",
    "endpoint": "https://s3.amazonaws.com",
    "url_prefix": "https://your-bucket.s3.amazonaws.com"
  }
}
```

**腾讯云COS配置**
```json
{
  "type": "cos",
  "config": {
    "secret_id": "your-secret-id",
    "secret_key": "your-secret-key",
    "region": "ap-guangzhou",
    "bucket": "your-bucket-1234567890",
    "url_prefix": "https://your-bucket.cos.ap-guangzhou.myqcloud.com"
  }
}
```

#### 存储切换

在管理后台可以配置多个存储后端，并设置默认存储。发布版本时可以选择使用的存储类型。

### 增量更新

#### 工作原理

增量更新使用bsdiff算法计算两个版本之间的差异，只传输差异部分，大幅减少下载流量。

**流程:**
1. 上传新版本完整包
2. 系统自动生成与指定基础版本的差异包
3. 客户端下载差异包
4. 客户端使用bspatch工具将差异包应用到本地文件

#### API接口

**生成增量更新包**
```http
POST /api/v1/diff/generate
```

**请求参数:**
```json
{
  "new_version_id": 123,
  "base_version_id": 122,
  "platform": "windows"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "diff_id": "diff-uuid",
    "diff_size": 524288,
    "compression_ratio": 0.05,
    "download_url": "https://update.yourdomain.com/api/v1/diff/diff-uuid"
  }
}
```

**获取增量更新包**
```http
GET /api/v1/diff/:versionId
```

**请求参数:**
- `base_version`: 基础版本号
- `platform`: 平台类型

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "has_diff": true,
    "diff_size": 524288,
    "full_size": 104857600,
    "download_url": "https://update.yourdomain.com/api/v1/diff/diff-uuid",
    "diff_hash": "md5-hash"
  }
}
```

### 版本回滚

#### 回滚机制

1. **软回滚**: 仅修改数据库状态，将指定版本设为最新发布版本
2. **硬回滚**: 删除新版本，恢复到指定版本

#### API接口

**版本回滚**
```http
POST /api/v1/version/:id/rollback
```

**请求参数:**
```json
{
  "rollback_type": "soft", // soft/hard
  "reason": "版本存在严重bug"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "version_id": 122,
    "version_number": "1.0.0",
    "status": "published"
  }
}
```

### 认证授权

#### JWT认证

使用JWT (JSON Web Token) 进行用户认证，Token包含用户信息和权限。

**Token结构:**
```json
{
  "user_id": 1,
  "username": "admin",
  "role_id": 1,
  "permissions": ["software:create", "version:publish", "user:manage"],
  "exp": 1704067200
}
```

#### RBAC权限控制

基于角色的访问控制 (RBAC)，支持细粒度权限管理。

**权限定义:**
- `software:view` - 查看软件列表
- `software:create` - 创建软件
- `software:update` - 更新软件信息
- `software:delete` - 删除软件
- `version:view` - 查看版本
- `version:create` - 发布版本
- `version:update` - 更新版本
- `version:delete` - 删除版本
- `version:rollback` - 版本回滚
- `user:view` - 查看用户
- `user:create` - 更新用户
- `user:update` - 更新用户
- `user:delete` - 删除用户
- `storage:manage` - 管理存储配置
- `system:config` - 系统配置

**角色预设:**
- **超级管理员**: 拥有所有权限
- **管理员**: 拥有软件和版本管理权限
- **操作员**: 拥有版本发布权限
- **只读用户**: 仅拥有查看权限

#### 登录流程

1. 用户提交用户名和密码
2. 服务器验证密码哈希
3. 生成JWT Token
4. 返回Token和用户信息
5. 客户端在后续请求中携带Token

**登录接口响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "role": {
        "id": 1,
        "name": "超级管理员",
        "permissions": ["*"]
      }
    }
  }
}
```

## 版本存档与自动校验

### 版本存档机制

#### 自动存档策略

- **最大保存版本数**: 每个软件最多保存最近10个历史版本
- **自动清理**: 超过10个版本时，自动删除最早的版本（非发布状态）
- **发布版本保护**: 当前发布的版本不会被自动删除
- **手动清理**: 管理员可以手动删除指定版本

#### 版本状态流转

```
draft (草稿) → published (发布) → archived (存档) → deleted (删除)
```

**状态说明:**
- `draft`: 草稿状态，可以编辑和删除
- `published`: 发布状态，客户端可见，不可删除
- `archived`: 存档状态，客户端不可见，可以恢复
- `deleted`: 删除状态，物理删除文件和数据

#### 版本切换

**快速切换到历史版本:**

```http
POST /api/v1/version/:id/switch
```

**请求参数:**
```json
{
  "target_version_id": 122,
  "reason": "回滚到稳定版本"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "current_version_id": 122,
    "version_number": "1.0.0",
    "status": "published",
    "switched_at": "2024-01-01T12:00:00Z"
  }
}
```

#### 版本历史查询

```http
GET /api/v1/version/:id/history
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "software_id": 1,
    "software_name": "MyApp",
    "versions": [
      {
        "id": 125,
        "version_number": "1.3.0",
        "status": "published",
        "created_at": "2024-01-15T10:00:00Z",
        "is_current": true
      },
      {
        "id": 124,
        "version_number": "1.2.0",
        "status": "archived",
        "created_at": "2024-01-10T10:00:00Z",
        "is_current": false
      },
      {
        "id": 123,
        "version_number": "1.1.0",
        "status": "archived",
        "created_at": "2024-01-05T10:00:00Z",
        "is_current": false
      }
    ],
    "total": 3,
    "max_versions": 10
  }
}
```

### 自动校验机制

#### MD5/SHA256 自动生成

**上传时自动校验流程:**

1. **分片上传阶段**: 每个分片上传时计算分片MD5
2. **合并阶段**: 合并完成后计算完整文件MD5和SHA256
3. **校验阶段**: 对比客户端上传的文件哈希值
4. **存储阶段**: 将校验结果存入数据库

**发布版本接口增强:**

```http
POST /api/v1/version
```

**请求参数:**
```json
{
  "software_id": 1,
  "version_number": "1.3.0",
  "release_notes": "修复已知问题，优化性能",
  "file_id": "file-uuid-from-upload",
  "update_type": "full",
  "force_update": false,
  "platform": "windows"
}
```

**响应（包含自动生成的校验值）:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "version_id": 125,
    "version_number": "1.3.0",
    "file_info": {
      "file_path": "/uploads/software-v1.3.0.exe",
      "file_size": 104857600,
      "md5": "d41d8cd98f00b204e9800998ecf8427e",
      "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "upload_time": "2024-01-15T10:00:00Z"
    },
    "status": "published",
    "created_at": "2024-01-15T10:00:00Z"
  }
}
```

#### 客户端校验

**下载后校验流程:**

1. 客户端下载更新包
2. 计算本地文件的MD5/SHA256
3. 与服务器返回的校验值对比
4. 校验失败则重新下载
5. 校验成功则执行更新

## 热更新推送

### WebSocket 实时推送

#### 工作原理

**推送架构:**
```
管理后台发布版本 → 服务器检测到新版本 → 通过WebSocket推送到在线客户端 → 客户端收到通知 → 用户选择更新
```

#### 客户端WebSocket连接

**连接地址:**
```
ws://your-domain.com/api/v1/ws/client?token=xxx&software_id=1&client_id=xxx
```

**连接参数:**
- `token`: 客户端认证Token
- `software_id`: 软件ID
- `client_id`: 客户端唯一标识
- `current_version`: 当前版本号（可选）

**连接流程:**

1. 客户端启动时建立WebSocket连接
2. 发送注册消息
3. 保持连接，定期发送心跳
4. 收到更新通知后提示用户
5. 用户确认后下载更新包

**注册消息:**
```json
{
  "type": "register",
  "data": {
    "client_id": "client-uuid",
    "software_id": 1,
    "software_identifier": "my-app",
    "current_version": "1.2.0",
    "platform": "windows",
    "os_version": "Windows 10",
    "device_info": {
      "cpu": "Intel Core i7",
      "memory": "16GB",
      "disk": "512GB SSD"
    }
  }
}
```

**服务器响应:**
```json
{
  "type": "register_ack",
  "data": {
    "client_id": "client-uuid",
    "registered_at": "2024-01-15T10:00:00Z",
    "heartbeat_interval": 30
  }
}
```

#### 更新推送消息

**服务器推送更新通知:**
```json
{
  "type": "update_available",
  "data": {
    "software_id": 1,
    "software_name": "MyApp",
    "current_version": "1.2.0",
    "new_version": "1.3.0",
    "release_notes": "修复已知问题，优化性能",
    "update_type": "full",
    "file_size": 104857600,
    "download_url": "https://your-domain.com/api/v1/download/xxx",
    "md5": "d41d8cd98f00b204e9800998ecf8427e",
    "force_update": false,
    "published_at": "2024-01-15T10:00:00Z"
  }
}
```

**客户端响应:**
```json
{
  "type": "update_response",
  "data": {
    "client_id": "client-uuid",
    "version_id": 125,
    "action": "accept", // accept/defer/ignore
    "responded_at": "2024-01-15T10:01:00Z"
  }
}
```

#### 心跳机制

**客户端心跳消息:**
```json
{
  "type": "heartbeat",
  "data": {
    "client_id": "client-uuid",
    "timestamp": "2024-01-15T10:00:00Z",
    "current_version": "1.2.0",
    "status": "running"
  }
}
```

**服务器心跳响应:**
```json
{
  "type": "heartbeat_ack",
  "data": {
    "timestamp": "2024-01-15T10:00:00Z",
    "server_time": "2024-01-15T10:00:00Z"
  }
}
```

### 客户端管理

#### 客户端注册

```http
POST /api/v1/client/register
```

**请求参数:**
```json
{
  "client_id": "client-uuid",
  "software_id": 1,
  "software_identifier": "my-app",
  "current_version": "1.2.0",
  "platform": "windows",
  "os_version": "Windows 10",
  "device_info": {
    "cpu": "Intel Core i7",
    "memory": "16GB",
    "disk": "512GB SSD"
  }
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "client_id": "client-uuid",
    "access_token": "client-access-token",
    "websocket_url": "ws://your-domain.com/api/v1/ws/client",
    "heartbeat_interval": 30,
    "registered_at": "2024-01-15T10:00:00Z"
  }
}
```

#### 客户端心跳上报

```http
POST /api/v1/client/heartbeat
```

**请求参数:**
```json
{
  "client_id": "client-uuid",
  "current_version": "1.2.0",
  "status": "running",
  "last_check_update": "2024-01-15T09:00:00Z"
}
```

#### 获取在线客户端列表

```http
GET /api/v1/client/list?software_id=1&status=online
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "software_id": 1,
    "software_name": "MyApp",
    "clients": [
      {
        "client_id": "client-uuid-1",
        "current_version": "1.2.0",
        "platform": "windows",
        "os_version": "Windows 10",
        "status": "online",
        "last_heartbeat": "2024-01-15T10:00:00Z",
        "registered_at": "2024-01-01T10:00:00Z"
      },
      {
        "client_id": "client-uuid-2",
        "current_version": "1.3.0",
        "platform": "macos",
        "os_version": "macOS 14",
        "status": "online",
        "last_heartbeat": "2024-01-15T10:00:00Z",
        "registered_at": "2024-01-05T10:00:00Z"
      }
    ],
    "total": 2,
    "online": 2,
    "offline": 0
  }
}
```

#### 定向推送更新通知

```http
POST /api/v1/client/push
```

**请求参数:**
```json
{
  "target_clients": ["client-uuid-1", "client-uuid-2"],
  "version_id": 125,
  "message": "重要安全更新，请立即升级",
  "force_notify": true
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "push_id": "push-uuid",
    "target_count": 2,
    "success_count": 2,
    "failed_count": 0,
    "pushed_at": "2024-01-15T10:00:00Z"
  }
}
```

#### 获取客户端状态

```http
GET /api/v1/client/:id/status
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "client_id": "client-uuid",
    "software_id": 1,
    "software_name": "MyApp",
    "current_version": "1.2.0",
    "platform": "windows",
    "os_version": "Windows 10",
    "status": "online",
    "last_heartbeat": "2024-01-15T10:00:00Z",
    "last_check_update": "2024-01-15T09:00:00Z",
    "registered_at": "2024-01-01T10:00:00Z",
    "update_history": [
      {
        "version": "1.2.0",
        "updated_at": "2024-01-10T10:00:00Z",
        "update_duration": 120
      }
    ]
  }
}
```

### 管理后台实时监控

#### 管理后台WebSocket连接

**连接地址:**
```
ws://your-domain.com/api/v1/ws/admin?token=xxx
```

**实时监控数据:**

```json
{
  "type": "stats_update",
  "data": {
    "timestamp": "2024-01-15T10:00:00Z",
    "online_clients": 150,
    "total_downloads": 1250,
    "active_uploads": 3,
    "server_status": "healthy"
  }
}
```

**客户端上线通知:**
```json
{
  "type": "client_online",
  "data": {
    "client_id": "client-uuid",
    "software_name": "MyApp",
    "version": "1.2.0",
    "platform": "windows",
    "online_at": "2024-01-15T10:00:00Z"
  }
```

**客户端下线通知:**
```json
{
  "type": "client_offline",
  "data": {
    "client_id": "client-uuid",
    "software_name": "MyApp",
    "offline_at": "2024-01-15T10:00:00Z",
    "offline_duration": 300
  }
}
```

## 系统监控与限流

### API限流

#### 限流策略

**限流级别:**
- **全局限流**: 整体API访问频率限制
- **接口限流**: 特定接口的访问频率限制
- **用户限流**: 每个用户的访问频率限制
- **IP限流**: 每个IP地址的访问频率限制

**限流算法:**
- **令牌桶算法**: 适用于突发流量
- **漏桶算法**: 适用于平滑流量
- **滑动窗口算法**: 精确统计时间窗口内请求数

#### 限流配置

**默认限流规则:**
```json
{
  "global": {
    "requests_per_minute": 1000,
    "requests_per_hour": 10000,
    "requests_per_day": 100000
  },
  "endpoints": {
    "/api/v1/check-update": {
      "requests_per_minute": 100,
      "requests_per_hour": 1000
    },
    "/api/v1/upload/init": {
      "requests_per_minute": 10,
      "requests_per_hour": 50
    },
    "/api/v1/auth/login": {
      "requests_per_minute": 5,
      "requests_per_hour": 20
    }
  },
  "clients": {
    "requests_per_minute": 60,
    "requests_per_hour": 1000
  }
}
```

**限流响应:**
```json
{
  "code": 429,
  "message": "Too Many Requests",
  "data": {
    "retry_after": 60,
    "limit": 1000,
    "remaining": 0,
    "reset": 1704067200
  }
}
```

### Webhook集成

#### Webhook事件

**支持的事件类型:**
- `version:published` - 版本发布
- `version:archived` - 版本存档
- `client:online` - 客户端上线
- `client:offline` - 客户端下线
- `download:completed` - 下载完成
- `system:alert` - 系统告警

#### Webhook配置

**创建Webhook:**
```http
POST /api/v1/webhooks
```

**请求参数:**
```json
{
  "name": "钉钉通知",
  "url": "https://oapi.dingtalk.com/robot/send?access_token=xxx",
  "events": ["version:published", "system:alert"],
  "secret": "SECxxx",
  "enabled": true
}
```

**Webhook Payload示例:**
```json
{
  "event": "version:published",
  "timestamp": "2024-01-15T10:00:00Z",
  "data": {
    "software_id": 1,
    "software_name": "MyApp",
    "version": "1.3.0",
    "release_notes": "修复已知问题，优化性能",
    "published_by": "admin"
  }
}
```

### 系统监控

#### 健康检查

```http
GET /api/v1/health
```

**响应:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:00:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "storage": "healthy"
  },
  "uptime": 86400
}
```

#### 系统指标

```http
GET /api/v1/metrics
```

**Prometheus格式输出:**
```
# HELP lfs_online_clients Total number of online clients
# TYPE lfs_online_clients gauge
lfs_online_clients 150

# HELP lfs_total_downloads Total number of downloads
# TYPE lfs_total_downloads counter
lfs_total_downloads 1250

# HELP lfs_upload_duration Upload duration in seconds
# TYPE lfs_upload_duration histogram
lfs_upload_duration_bucket{le="0.1"} 10
lfs_upload_duration_bucket{le="0.5"} 50
lfs_upload_duration_bucket{le="1"} 100
lfs_upload_duration_bucket{le="+Inf"} 120
```

#### 统计数据

```http
GET /api/v1/stats
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "overview": {
      "total_software": 10,
      "total_versions": 50,
      "online_clients": 150,
      "total_downloads": 1250
    },
    "storage": {
      "total_size": 10737418240,
      "used_size": 5368709120,
      "free_size": 5368709120,
      "usage_percent": 50
    },
    "downloads": {
      "today": 50,
      "this_week": 300,
      "this_month": 1200
    },
    "clients": {
      "online": 150,
      "offline": 850,
      "total": 1000
    }
  }
}
```

### CDN加速

#### CDN配置

**支持的CDN服务商:**
- Cloudflare
- 阿里云CDN
- 腾讯云CDN
- CloudFront

**CDN配置示例:**
```json
{
  "enabled": true,
  "provider": "cloudflare",
  "domain": "cdn.yourdomain.com",
  "zone_id": "your-zone-id",
  "api_token": "your-api-token",
  "cache_rules": [
    {
      "pattern": "/uploads/*",
      "ttl": 86400
    },
    {
      "pattern": "/api/v1/download/*",
      "ttl": 3600
    }
  ]
}
```

#### CDN缓存刷新

**发布版本时自动刷新CDN缓存:**
```http
POST /api/v1/cdn/refresh
```

**请求参数:**
```json
{
  "urls": [
    "https://cdn.yourdomain.com/uploads/software-v1.3.0.exe"
  ]
}
```

### 多语言支持

#### 支持的语言

- 中文（简体）
- 中文（繁体）
- English
- 日本語
- 한국어

#### 国际化配置

**前端i18n配置:**
```javascript
// src/i18n/index.ts
import { createI18n } from 'vue-i18n'
import zhCN from './locales/zh-CN.json'
import enUS from './locales/en-US.json'

const i18n = createI18n({
  locale: 'zh-CN',
  fallbackLocale: 'en-US',
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS
  }
})
```

**语言切换:**
```javascript
// 切换语言
i18n.global.locale.value = 'en-US'
```

## 防盗刷鉴权机制

### 多重防护策略

为了防止流量盗刷和恶意下载，系统采用多重防护机制：

#### 1. 下载Token机制

**工作原理:**
- 客户端检查更新时获取临时下载Token
- Token包含版本信息、客户端信息、时间戳、签名
- Token有时效性，过期自动失效
- 下载时验证Token有效性

**获取下载Token:**
```http
POST /api/v1/download/token
```

**请求参数:**
```json
{
  "client_id": "client-uuid",
  "software_id": 1,
  "current_version": "1.2.0",
  "platform": "windows"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "download_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "download_url": "https://your-domain.com/api/v1/download/xxx?token=xxx",
    "expires_at": "2024-01-15T11:00:00Z",
    "expires_in": 3600
  }
}
```

**Token结构:**
```json
{
  "client_id": "client-uuid",
  "software_id": 1,
  "version_id": 125,
  "ip_address": "192.168.1.100",
  "user_agent": "MyApp/1.2.0 (Windows)",
  "issued_at": "2024-01-15T10:00:00Z",
  "expires_at": "2024-01-15T11:00:00Z",
  "signature": "HMAC-SHA256"
}
```

#### 2. IP白名单/黑名单

**IP白名单:**
- 仅允许白名单IP访问下载接口
- 支持单个IP和CIDR网段
- 适用于内网部署或特定用户群体

**IP黑名单:**
- 禁止黑名单IP访问所有接口
- 自动封禁异常IP
- 支持临时封禁和永久封禁

**添加IP白名单:**
```http
POST /api/v1/security/ip-whitelist
```

**请求参数:**
```json
{
  "ip_address": "192.168.1.0/24",
  "description": "公司内网",
  "enabled": true
}
```

**添加IP黑名单:**
```http
POST /api/v1/security/ip-blacklist
```

**请求参数:**
```json
{
  "ip_address": "1.2.3.4",
  "reason": "恶意下载",
  "ban_type": "permanent", // permanent/temporary
  "expires_at": "2024-01-20T00:00:00Z"
}
```

#### 3. Referer检查

**检查机制:**
- 验证HTTP Referer头
- 仅允许来自指定域名的请求
- 防止第三方网站盗链

**配置示例:**
```json
{
  "referer_check": {
    "enabled": true,
    "allowed_domains": [
      "yourdomain.com",
      "app.yourdomain.com"
    ],
    "allow_empty": false
  }
}
```

#### 4. User-Agent验证

**验证机制:**
- 验证客户端User-Agent
- 仅允许合法的客户端User-Agent
- 识别爬虫和恶意工具

**配置示例:**
```json
{
  "user_agent_check": {
    "enabled": true,
    "allowed_patterns": [
      "MyApp/*",
      "YourApp/*"
    ],
    "blocked_patterns": [
      "curl",
      "wget",
      "python-requests"
    ]
  }
}
```

#### 5. 时间限制下载链接

**机制:**
- 下载链接包含过期时间戳
- 超时后链接自动失效
- 防止链接被长期滥用

**生成临时链接:**
```http
GET /api/v1/download/:versionId?expires=3600&signature=xxx
```

**参数说明:**
- `expires`: 链接有效期（秒）
- `signature`: 签名（HMAC-SHA256）

#### 6. 签名验证

**签名算法:**
```
signature = HMAC-SHA256(secret_key, version_id + client_id + expires_at)
```

**验证流程:**
1. 客户端生成签名
2. 服务器验证签名正确性
3. 验证时间戳是否过期
4. 验证客户端ID是否匹配

**签名示例:**
```go
// 生成签名
func GenerateSignature(versionID, clientID, expiresAt, secretKey string) string {
    data := versionID + clientID + expiresAt
    h := hmac.New(sha256.New, []byte(secretKey))
    h.Write([]byte(data))
    return hex.EncodeToString(h.Sum(nil))
}
```

#### 7. 地理位置限制

**机制:**
- 根据IP地址判断地理位置
- 仅允许特定地区访问
- 拒绝来自高风险地区的请求

**配置示例:**
```json
{
  "geo_restriction": {
    "enabled": true,
    "allowed_countries": ["CN", "US", "JP"],
    "blocked_countries": ["XX"],
    "block_unknown": false
  }
}
```

#### 8. 设备绑定

**机制:**
- 客户端注册时绑定设备指纹
- 下载时验证设备指纹
- 防止Token被跨设备使用

**设备指纹生成:**
```javascript
// 客户端生成设备指纹
function generateDeviceFingerprint() {
  const components = [
    navigator.userAgent,
    navigator.language,
    screen.colorDepth,
    new Date().getTimezoneOffset(),
    !!window.sessionStorage,
    !!window.localStorage
  ];
  return sha256(components.join('||'));
}
```

### 安全配置

**环境变量配置:**
```env
# 防盗刷配置
ANTI_ABUSE_ENABLED=true
DOWNLOAD_TOKEN_EXPIRE_HOURS=1
REFERER_CHECK_ENABLED=true
USER_AGENT_CHECK_ENABLED=true
IP_WHITELIST_ENABLED=false
IP_BLACKLIST_ENABLED=true
GEO_RESTRICTION_ENABLED=false

# 签名密钥
DOWNLOAD_SECRET_KEY=your-secret-key-change-this

# 限流配置
DOWNLOAD_RATE_LIMIT_PER_MINUTE=10
DOWNLOAD_RATE_LIMIT_PER_HOUR=50
DOWNLOAD_RATE_LIMIT_PER_DAY=200
```

### 安全日志

**记录内容:**
- 下载请求IP地址
- User-Agent信息
- Referer信息
- Token验证结果
- 签名验证结果
- 地理位置信息
- 异常行为标记

**查询安全日志:**
```http
GET /api/v1/security/download-logs?start_date=2024-01-01&end_date=2024-01-15
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 1000,
    "suspicious": 50,
    "blocked": 20,
    "logs": [
      {
        "id": 1,
        "ip_address": "1.2.3.4",
        "user_agent": "curl/7.68.0",
        "referer": "",
        "download_url": "https://your-domain.com/api/v1/download/xxx",
        "token_valid": false,
        "signature_valid": false,
        "country": "Unknown",
        "blocked_reason": "Invalid User-Agent",
        "timestamp": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

### 异常检测与自动封禁

**异常行为检测:**
- 短时间内大量下载请求
- 使用不同User-Agent下载同一文件
- 来自不同地理位置的下载请求
- Token验证失败次数过多

**自动封禁规则:**
```json
{
  "auto_ban": {
    "enabled": true,
    "rules": [
      {
        "condition": "download_count > 100 in 1 minute",
        "action": "ban_ip",
        "duration": "1 hour"
      },
      {
        "condition": "token_fail_count > 10 in 5 minutes",
        "action": "ban_ip",
        "duration": "24 hours"
      },
      {
        "condition": "different_user_agents > 5 for same ip",
        "action": "ban_ip",
        "duration": "permanent"
      }
    ]
  }
}
```

### 客户端集成示例

**Go客户端示例:**
```go
package main

import (
    "crypto/hmac"
    "crypto/sha256"
    "encoding/hex"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "time"
)

// 获取下载Token
func getDownloadToken(clientID, softwareID, currentVersion, platform string) (string, error) {
    payload := map[string]interface{}{
        "client_id":       clientID,
        "software_id":     softwareID,
        "current_version": currentVersion,
        "platform":        platform,
    }
    
    resp, err := http.Post("https://your-domain.com/api/v1/download/token", "application/json", payload)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()
    
    var result struct {
        Code    int    `json:"code"`
        Message string `json:"message"`
        Data    struct {
            DownloadToken string `json:"download_token"`
            DownloadURL   string `json:"download_url"`
        } `json:"data"`
    }
    
    json.NewDecoder(resp.Body).Decode(&result)
    return result.Data.DownloadToken, nil
}

// 使用Token下载文件
func downloadWithToken(url, token string) error {
    req, _ := http.NewRequest("GET", url, nil)
    req.Header.Set("Authorization", "Bearer "+token)
    req.Header.Set("User-Agent", "MyApp/1.2.0 (Windows)")
    
    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != 200 {
        return fmt.Errorf("download failed with status: %d", resp.StatusCode)
    }
    
    // 保存文件
    file, _ := os.Create("update.exe")
    defer file.Close()
    io.Copy(file, resp.Body)
    
    return nil
}
```

**JavaScript客户端示例:**
```javascript
// 获取下载Token
async function getDownloadToken(clientId, softwareId, currentVersion, platform) {
  const response = await fetch('https://your-domain.com/api/v1/download/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      client_id: clientId,
      software_id: softwareId,
      current_version: currentVersion,
      platform: platform
    })
  });
  
  const result = await response.json();
  return result.data.download_token;
}

// 使用Token下载文件
async function downloadWithToken(url, token) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'User-Agent': 'MyApp/1.2.0 (Windows)'
    }
  });
  
  if (!response.ok) {
    throw new Error(`Download failed: ${response.status}`);
  }
  
  const blob = await response.blob();
  const downloadUrl = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = downloadUrl;
  a.download = 'update.exe';
  a.click();
}
```

## 数据库设计补充

### 客户端表 (client)

```sql
CREATE TABLE client (
    id BIGSERIAL PRIMARY KEY,
    client_id VARCHAR(100) UNIQUE NOT NULL,
    software_id BIGINT REFERENCES software(id) ON DELETE CASCADE,
    software_identifier VARCHAR(100),
    current_version VARCHAR(50),
    platform VARCHAR(50),
    os_version VARCHAR(100),
    device_info JSONB,
    status VARCHAR(20) DEFAULT 'online', -- online/offline
    last_heartbeat TIMESTAMP,
    last_check_update TIMESTAMP,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_client_software ON client(software_id);
CREATE INDEX idx_client_status ON client(status);
CREATE INDEX idx_client_id ON client(client_id);
```

### 推送记录表 (push_record)

```sql
CREATE TABLE push_record (
    id BIGSERIAL PRIMARY KEY,
    push_id VARCHAR(100) UNIQUE NOT NULL,
    version_id BIGINT REFERENCES version(id) ON DELETE CASCADE,
    target_type VARCHAR(20), -- all/software/specific
    target_clients JSONB,
    message TEXT,
    force_notify BOOLEAN DEFAULT false,
    total_count INT DEFAULT 0,
    success_count INT DEFAULT 0,
    failed_count INT DEFAULT 0,
    pushed_by BIGINT REFERENCES users(id),
    pushed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_push_version ON push_record(version_id);
CREATE INDEX idx_push_time ON push_record(pushed_at);
```

### 限流配置表 (rate_limit)

```sql
CREATE TABLE rate_limit (
    id BIGSERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    limit_per_minute INT DEFAULT 60,
    limit_per_hour INT DEFAULT 1000,
    limit_per_day INT DEFAULT 10000,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Webhook配置表 (webhook)

```sql
CREATE TABLE webhook (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    url VARCHAR(500) NOT NULL,
    events JSONB NOT NULL, -- ["version:published", "client:online"]
    secret VARCHAR(100),
    enabled BOOLEAN DEFAULT true,
    last_triggered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_webhook_events ON webhook USING GIN(events);
```

### 增强下载统计表

```sql
CREATE TABLE download_stat (
    id BIGSERIAL PRIMARY KEY,
    version_id BIGINT REFERENCES version(id) ON DELETE CASCADE,
    software_identifier VARCHAR(100),
    client_version VARCHAR(50),
    platform VARCHAR(50),
    ip_address VARCHAR(50),
    user_agent TEXT,
    download_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_size BIGINT,
    download_duration INT -- 下载耗时（秒）
);

CREATE INDEX idx_download_stat_version ON download_stat(version_id);
CREATE INDEX idx_download_stat_time ON download_stat(download_time);
CREATE INDEX idx_download_stat_platform ON download_stat(platform);
```

### IP白名单表 (ip_whitelist)

```sql
CREATE TABLE ip_whitelist (
    id BIGSERIAL PRIMARY KEY,
    ip_address VARCHAR(50) NOT NULL,
    description TEXT,
    enabled BOOLEAN DEFAULT true,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ip_whitelist_address ON ip_whitelist(ip_address);
```

### IP黑名单表 (ip_blacklist)

```sql
CREATE TABLE ip_blacklist (
    id BIGSERIAL PRIMARY KEY,
    ip_address VARCHAR(50) NOT NULL,
    reason TEXT,
    ban_type VARCHAR(20) DEFAULT 'temporary', -- temporary/permanent
    expires_at TIMESTAMP,
    auto_banned BOOLEAN DEFAULT false,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ip_blacklist_address ON ip_blacklist(ip_address);
CREATE INDEX idx_ip_blacklist_expires ON ip_blacklist(expires_at);
```

### 安全日志表 (security_log)

```sql
CREATE TABLE security_log (
    id BIGSERIAL PRIMARY KEY,
    ip_address VARCHAR(50),
    user_agent TEXT,
    referer TEXT,
    request_url TEXT,
    token_valid BOOLEAN,
    signature_valid BOOLEAN,
    country VARCHAR(50),
    blocked_reason TEXT,
    blocked BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_security_log_ip ON security_log(ip_address);
CREATE INDEX idx_security_log_blocked ON security_log(blocked);
CREATE INDEX idx_security_log_time ON security_log(created_at);
```

## UI/UX 设计指南

### 设计原则

参考优秀后台管理系统的设计理念，遵循以下设计原则：

**1. 简洁高效**
- 界面简洁明了，避免冗余元素
- 操作流程直观，减少用户学习成本
- 重要信息突出显示，次要信息适当弱化

**2. 一致性**
- 统一的视觉风格和交互模式
- 一致的色彩、字体、间距规范
- 统一的图标和按钮样式

**3. 响应式设计**
- 支持桌面端、平板、移动端适配
- 灵活的栅格布局系统
- 优化的移动端交互体验

**4. 可访问性**
- 支持键盘导航
- 合理的色彩对比度
- 清晰的文字大小和行高

### 参考项目

**国内优秀后台管理系统**
- **Ant Design Pro** - 蚂蚁集团企业级中后台前端解决方案
- **Vue Element Admin** - 基于 Vue + Element Plus 的后台管理系统模板
- **Arco Design Pro** - 字节跳动出品的企业级中后台产品
- **TinyPro** - OpenTiny 团队出品的企业级前端解决方案

**国际优秀后台系统**
- **AdminLTE** - 响应式管理面板模板
- **Tabler** - 免费开源的仪表盘 UI 套件
- **CoreUI** - 基于 Bootstrap 4 的管理面板模板

### 设计规范

#### 色彩方案

**主色调**
```css
--primary-color: #409EFF;      /* Element Plus 默认蓝色 */
--primary-light: #79bbff;
--primary-dark: #337ecc;
--primary-lighter: #ecf5ff;
```

**功能色**
```css
--success-color: #67C23A;      /* 成功 */
--warning-color: #E6A23C;      /* 警告 */
--danger-color: #F56C6C;       /* 危险 */
--info-color: #909399;         /* 信息 */
```

**中性色**
```css
--text-primary: #303133;       /* 主要文字 */
--text-regular: #606266;       /* 常规文字 */
--text-secondary: #909399;     /* 次要文字 */
--text-placeholder: #C0C4CC;   /* 占位文字 */
--border-base: #DCDFE6;        /* 边框 */
--border-light: #E4E7ED;
--border-lighter: #EBEEF5;
--border-extra-light: #F2F6FC;
--background-base: #FFFFFF;    /* 背景 */
--background-page: #F2F3F5;
```

#### 字体规范

```css
--font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
--font-size-base: 14px;
--font-size-small: 12px;
--font-size-medium: 16px;
--font-size-large: 18px;
--font-size-extra-large: 20px;
--line-height-base: 1.5;
--line-height-small: 1.2;
--line-height-large: 1.8;
```

#### 间距规范

```css
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-base: 16px;
--spacing-lg: 20px;
--spacing-xl: 24px;
--spacing-xxl: 32px;
```

#### 圆角规范

```css
--border-radius-small: 2px;
--border-radius-base: 4px;
--border-radius-large: 8px;
--border-radius-circle: 50%;
```

### 布局设计

#### 整体布局

采用经典的 **左侧导航 + 顶部栏 + 内容区** 布局：

```
+-----------------------------------------------+
|  Logo  |  面包屑  |  用户信息  |  主题切换  |  顶部栏
+--------+-----------------------------------------+
|        |                                         |
|        |                                         |
| 左侧   |           主要内容区域                 |
| 导航   |                                         |
| 菜单   |                                         |
|        |                                         |
+--------+-----------------------------------------+
```

**布局特点**
- 左侧导航栏：可折叠，支持多级菜单
- 顶部栏：面包屑导航、用户信息、通知、主题切换
- 内容区：卡片式布局，清晰的视觉层次
- 响应式：移动端自动转换为抽屉式导航

#### 页面布局

**仪表盘页面**
- 顶部统计卡片：4个关键指标卡片（软件数量、版本数量、下载次数、存储使用）
- 中部图表：下载趋势图、版本分布图、平台分布图
- 底部列表：最近发布版本、最近操作日志

**列表页面**
- 顶部：搜索栏、筛选器、操作按钮（新增、批量操作）
- 中部：数据表格（支持排序、分页、选择）
- 底部：分页器、统计信息

**详情页面**
- 顶部：返回按钮、操作按钮（编辑、删除）
- 中部：信息卡片（分组展示）
- 底部：关联数据（版本列表、操作记录）

**表单页面**
- 左侧：表单字段（分组、分步）
- 右侧：预览区域（可选）
- 底部：操作按钮（保存、取消）

### 组件设计

#### 导航组件

**侧边栏菜单**
- 支持图标 + 文字
- 支持多级折叠
- 支持搜索功能
- 支持自定义主题色
- 支持收起/展开动画

**面包屑导航**
- 显示当前页面路径
- 支持点击跳转
- 支持自定义分隔符

#### 数据展示组件

**统计卡片**
- 图标 + 数值 + 标签
- 支持趋势指示（上升/下降）
- 支持点击跳转
- 支持自定义颜色

**数据表格**
- 支持排序、筛选、分页
- 支持行选择、批量操作
- 支持固定列、固定表头
- 支持自定义列
- 支持导出功能

**图表组件**
- 折线图：下载趋势
- 柱状图：版本分布
- 饼图：平台分布
- 仪表盘：存储使用率

#### 表单组件

**上传组件**
- 支持拖拽上传
- 支持分片上传进度显示
- 支持断点续传
- 支持文件预览
- 支持上传历史

**表单验证**
- 实时验证
- 友好的错误提示
- 支持自定义验证规则
- 支持异步验证

#### 反馈组件

**消息提示**
- 成功、警告、错误、信息
- 支持自动关闭
- 支持自定义位置

**对话框**
- 支持确认、警告、信息类型
- 支持自定义内容
- 支持异步操作

**加载状态**
- 页面加载：骨架屏
- 按钮加载：loading 状态
- 数据加载：loading 动画

### 交互设计

#### 微交互

- 按钮悬停：颜色渐变、轻微缩放
- 卡片悬停：阴影加深、轻微上浮
- 表格行悬停：背景色变化
- 输入框聚焦：边框高亮、阴影效果

- 过渡动画：使用 Element Plus 内置过渡
- 页面切换：淡入淡出
- 菜单展开：平滑动画
- 数据加载：骨架屏过渡

#### 操作反馈

- 成功操作：绿色提示 + 勾选动画
- 失败操作：红色提示 + 震动效果
- 加载中：loading 动画 + 禁用操作
- 确认操作：对话框 + 二次确认

#### 错误处理

- 网络错误：友好提示 + 重试按钮
- 表单错误：字段高亮 + 错误信息
- 权限错误：提示 + 跳转登录
- 404错误：自定义404页面

### 主题设计

#### 亮色主题（默认）
- 背景：白色/浅灰
- 文字：深灰/黑色
- 边框：浅灰
- 强调色：蓝色

#### 暗色主题
- 背景：深灰/黑色
- 文字：浅灰/白色
- 边框：深灰
- 强调色：蓝色

#### 主题切换
- 支持手动切换
- 支持跟随系统
- 支持定时切换
- 持久化存储

### 响应式设计

#### 断点设置

```css
--breakpoint-xs: 480px;   /* 手机 */
--breakpoint-sm: 768px;   /* 平板 */
--breakpoint-md: 992px;   /* 小屏笔记本 */
--breakpoint-lg: 1200px;  /* 桌面 */
--breakpoint-xl: 1600px;  /* 大屏桌面 */
```

#### 响应式策略

- **移动端**（< 768px）：侧边栏收起、表格横向滚动、卡片堆叠
- **平板端**（768px - 992px）：侧边栏可收起、表格自适应
- **桌面端**（> 992px）：完整布局、多列显示

### 性能优化

#### 加载优化
- 路由懒加载
- 组件按需加载
- 图片懒加载
- 资源压缩

#### 渲染优化
- 虚拟滚动（长列表）
- 防抖节流（搜索、滚动）
- computed 缓存
- 减少不必要的重渲染

#### 体验优化
- 骨架屏加载
- 预加载关键资源
- 离线缓存（可选）
- PWA 支持（可选）

### 可访问性

#### 键盘导航
- Tab 键切换焦点
- Enter/Space 键激活
- Esc 键关闭弹窗
- 方向键导航

#### 屏幕阅读器
- 语义化 HTML
- ARIA 标签
- Alt 文本
- 焦点管理

### 开发建议

#### 组件库选择

**推荐：Element Plus**
- 成熟的 Vue 3 组件库
- 丰富的组件和主题
- 完善的文档和社区
- 与 Vue 3 完美集成

**备选：Arco Design Vue**
- 字节跳动出品
- 设计精美
- 性能优秀

#### 状态管理

**Pinia**
- Vue 3 官方推荐
- TypeScript 友好
- 简单易用

#### 样式方案

**CSS 变量 + SCSS**
- 使用 CSS 变量定义主题
- 使用 SCSS 组织样式
- 支持 BEM 命名规范

## 1Panel 部署指南

本指南详细说明如何使用1Panel部署LFS Update Server。

### 前置要求

- 已安装1Panel的服务器（推荐Ubuntu 20.04+或CentOS 7+）
- 服务器至少2GB内存、20GB磁盘空间
- 服务器已安装Docker和Docker Compose（1Panel会自动安装）
- 域名（可选，用于HTTPS访问）

### 部署步骤

#### 第一步：安装1Panel

如果尚未安装1Panel，请执行以下命令：

```bash
curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sh quick_start.sh
```

安装完成后，访问 `http://服务器IP:端口` 进入1Panel管理界面。

#### 第二步：安装PostgreSQL数据库

1. 登录1Panel管理界面
2. 点击左侧菜单「应用商店」
3. 搜索「PostgreSQL」
4. 点击「安装」按钮
5. 配置数据库参数：
   - **版本**: 选择15或更高版本
   - **端口**: 默认5432（建议修改为非默认端口）
   - **用户名**: 设置数据库用户名（如：lfsadmin）
   - **密码**: 设置强密码
   - **数据库名**: lfs_update_server
6. 点击「确定」开始安装
7. 等待安装完成，记录数据库连接信息

#### 第三步：安装Nginx

1. 在应用商店搜索「Nginx」
2. 点击「安装」
3. 配置参数：
   - **端口**: 80（HTTP）、443（HTTPS）
4. 点击「确定」完成安装

#### 第四步：准备项目文件

在服务器上创建项目目录：

```bash
# SSH登录到服务器
mkdir -p /opt/lfs-update-server
cd /opt/lfs-update-server
```

创建以下目录结构：

```bash
mkdir -p backend frontend docker scripts uploads logs
```

#### 第五步：配置环境变量

创建 `.env` 文件：

```bash
nano /opt/lfs-update-server/.env
```

添加以下内容：

```env
# 服务器配置
SERVER_PORT=8080
SERVER_MODE=release

# 数据库配置
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=lfsadmin
DB_PASSWORD=your_database_password
DB_NAME=lfs_update_server
DB_SSL_MODE=disable

# JWT配置
JWT_SECRET=your_jwt_secret_key_change_this
JWT_EXPIRE_HOURS=24

# 存储配置
STORAGE_TYPE=local
# 本地存储配置
LOCAL_UPLOAD_DIR=/opt/lfs-update-server/uploads
LOCAL_URL_PREFIX=https://update.yourdomain.com/uploads

# S3存储配置（可选）
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
S3_REGION=us-east-1
S3_BUCKET=
S3_ENDPOINT=

# 腾讯云COS配置（可选）
COS_SECRET_ID=
COS_SECRET_KEY=
COS_REGION=ap-guangzhou
COS_BUCKET=

# Redis配置（可选，用于缓存和会话）
REDIS_ENABLED=false
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# 分片上传配置
CHUNK_SIZE=5242880
MAX_CHUNK_SIZE=104857600
UPLOAD_EXPIRE_HOURS=24

# 增量更新配置
ENABLE_DIFF=true
DIFF_ALGORITHM=bsdiff

# 管理员账号（首次启动自动创建）
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_admin_password
```

**重要提示**: 请修改所有密码和密钥为强密码。

#### 第六步：创建Docker Compose配置

创建 `docker/docker-compose.yml` 文件：

```bash
nano /opt/lfs-update-server/docker/docker-compose.yml
```

添加以下内容：

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ../backend
      dockerfile: ../docker/Dockerfile.backend
    container_name: lfs-update-backend
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - SERVER_PORT=8080
      - DB_HOST=host.docker.internal
      - DB_PORT=5432
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - JWT_SECRET=${JWT_SECRET}
      - JWT_EXPIRE_HOURS=${JWT_EXPIRE_HOURS}
      - UPLOAD_DIR=/uploads
    volumes:
      - ../uploads:/uploads
      - ../logs:/logs
    extra_hosts:
      - "host.docker.internal:host-gateway"
    networks:
      - lfs-network

  frontend:
    build:
      context: ../frontend
      dockerfile: ../docker/Dockerfile.frontend
    container_name: lfs-update-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - lfs-network

networks:
  lfs-network:
    driver: bridge
```

#### 第七步：创建Dockerfile

创建后端Dockerfile：

```bash
nano /opt/lfs-update-server/docker/Dockerfile.backend
```

添加以下内容：

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 安装依赖
RUN apk add --no-cache git

# 复制go.mod和go.sum
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/server

# 运行阶段
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# 复制编译好的二进制文件
COPY --from=builder /app/main .

# 设置时区
ENV TZ=Asia/Shanghai

EXPOSE 8080

CMD ["./main"]
```

创建前端Dockerfile：

```bash
nano /opt/lfs-update-server/docker/Dockerfile.frontend
```

添加以下内容：

```dockerfile
# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 构建
RUN npm run build

# 运行阶段
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

创建前端nginx配置：

```bash
nano /opt/lfs-update-server/frontend/nginx.conf
```

添加以下内容：

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 第八步：上传项目代码

将项目代码上传到服务器。可以使用以下方法：

**方法1：使用Git（推荐）**

```bash
cd /opt/lfs-update-server
git clone https://your-repo-url/lfs-update-server.git .
```

**方法2：使用SCP上传**

在本地执行：

```bash
scp -r /path/to/local/lfs-update-server/* root@your-server-ip:/opt/lfs-update-server/
```

**方法3：使用1Panel文件管理**

1. 在1Panel界面点击「文件」
2. 导航到 `/opt/lfs-update-server`
3. 点击「上传」按钮上传项目文件

#### 第九步：构建和启动服务

在服务器上执行：

```bash
cd /opt/lfs-update-server/docker

# 加载环境变量
export $(cat ../.env | xargs)

# 构建并启动
docker-compose up -d --build
```

查看服务状态：

```bash
docker-compose ps
docker-compose logs -f
```

#### 第十步：配置Nginx反向代理

1. 在1Panel界面点击「网站」
2. 点击「创建网站」
3. 选择「反向代理」
4. 配置参数：
   - **域名**: 输入你的域名（如：update.yourdomain.com）
   - **代理地址**: http://127.0.0.1:3000
   - **开启HTTPS**: 勾选并配置SSL证书（推荐使用Let's Encrypt免费证书）
5. 点击「创建」

6. 编辑网站配置，添加以下内容到location块：

```nginx
location /api {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # 文件上传大小限制
    client_max_body_size 500M;
}
```

#### 第十一步：配置防火墙

如果服务器启用了防火墙，需要开放相应端口：

```bash
# 如果使用ufw
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 如果使用firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

#### 第十二步：访问管理后台

1. 打开浏览器访问：`https://update.yourdomain.com`
2. 使用默认管理员账号登录：
   - 用户名：admin
   - 密码：.env文件中配置的ADMIN_PASSWORD
3. 首次登录后建议立即修改密码

### 1Panel容器管理

部署完成后，可以在1Panel中管理容器：

1. 点击左侧菜单「容器」
2. 可以看到 `lfs-update-backend` 和 `lfs-update-frontend` 两个容器
3. 支持的操作：
   - 启动/停止/重启容器
   - 查看容器日志
   - 查看容器资源使用情况
   - 进入容器终端
   - 更新容器镜像

### 更新部署

当需要更新应用时：

```bash
cd /opt/lfs-update-server

# 拉取最新代码
git pull

# 重新构建和启动
cd docker
docker-compose down
docker-compose up -d --build
```

### 备份策略

#### 数据库备份

在1Panel中配置PostgreSQL自动备份：

1. 点击「应用商店」→ 找到PostgreSQL应用
2. 点击「设置」→「备份」
3. 配置自动备份策略（建议每天备份）
4. 可以手动创建备份或下载备份文件

#### 文件备份

备份上传的更新包：

```bash
# 创建备份脚本
nano /opt/lfs-update-server/scripts/backup.sh
```

添加以下内容：

```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/lfs-update-server"
DATE=$(date +%Y%m%d_%H%M%S)
SOURCE_DIR="/opt/lfs-update-server/uploads"

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz $SOURCE_DIR

# 保留最近7天的备份
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +7 -delete
```

设置定时任务：

```bash
chmod +x /opt/lfs-update-server/scripts/backup.sh

# 添加到crontab（每天凌晨2点执行）
crontab -e
# 添加：0 2 * * * /opt/lfs-update-server/scripts/backup.sh
```

### 监控和日志

#### 查看应用日志

```bash
# 查看后端日志
docker logs -f lfs-update-backend

# 查看前端日志
docker logs -f lfs-update-frontend

# 查看应用日志文件
tail -f /opt/lfs-update-server/logs/app.log
```

#### 1Panel监控

1. 点击左侧菜单「监控」
2. 可以查看服务器CPU、内存、磁盘、网络使用情况
3. 可以设置告警规则

### 故障排查

#### 容器无法启动

```bash
# 查看容器日志
docker-compose logs

# 检查端口占用
netstat -tulpn | grep 8080
netstat -tulpn | grep 3000

# 检查磁盘空间
df -h
```

#### 数据库连接失败

1. 检查PostgreSQL是否运行
2. 检查数据库连接信息是否正确
3. 检查防火墙是否开放数据库端口
4. 查看后端容器日志

#### 无法访问网站

1. 检查Nginx是否运行
2. 检查域名DNS解析
3. 检查防火墙端口
4. 查看Nginx错误日志

### 安全建议

1. **修改默认密码**: 部署后立即修改所有默认密码
2. **启用HTTPS**: 使用SSL证书加密传输
3. **限制访问**: 通过防火墙限制访问来源
4. **定期更新**: 及时更新系统和应用版本
5. **备份策略**: 建立完善的备份和恢复机制
6. **监控告警**: 配置监控和告警通知

## 开发指南

### 本地开发

#### 后端开发

```bash
cd backend
go mod download
go run cmd/server/main.go
```

#### 前端开发

```bash
cd frontend
npm install
npm run dev
```

### 构建生产版本

```bash
# 构建后端
cd backend
go build -o lfs-update-server cmd/server/main.go

# 构建前端
cd frontend
npm run build
```

## 许可证

MIT License

## 联系方式

如有问题，请提交Issue或联系开发者。
