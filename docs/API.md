# UpdateHub API 文档

## 基础信息

- Base URL: `http://localhost:8080/api/v1`
- 认证方式: JWT Bearer Token
- 数据格式: JSON

## 客户端接口

### 检查更新

```http
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
    "force_update": false
  }
}
```

### 下载文件

```http
GET /api/v1/download/:id
```

**请求头:**
```
Authorization: Bearer {token}
```

## 认证接口

### 用户登录

```http
POST /api/v1/auth/login
```

**请求参数:**
```json
{
  "username": "admin",
  "password": "password"
}
```

**响应:**
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

### 用户登出

```http
POST /api/v1/auth/logout
```

**请求头:**
```
Authorization: Bearer {token}
```

### 刷新 Token

```http
POST /api/v1/auth/refresh
```

**请求参数:**
```json
{
  "refresh_token": "your-refresh-token"
}
```

### 获取当前用户信息

```http
GET /api/v1/auth/user
```

**请求头:**
```
Authorization: Bearer {token}
```

### 修改密码

```http
PUT /api/v1/auth/password
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "old_password": "old-password",
  "new_password": "new-password"
}
```

## 软件管理接口

### 获取软件列表

```http
GET /api/v1/software
```

**请求头:**
```
Authorization: Bearer {token}
```

**查询参数:**
- `offset`: 偏移量 (默认: 0)
- `limit`: 每页数量 (默认: 10)

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "software": [
      {
        "id": 1,
        "name": "MyApp",
        "identifier": "my-app",
        "description": "示例应用",
        "icon": "icon.png",
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "total": 1,
    "offset": 0,
    "limit": 10
  }
}
```

### 创建软件

```http
POST /api/v1/software
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "name": "MyApp",
  "identifier": "my-app",
  "description": "示例应用",
  "icon": "icon.png"
}
```

### 更新软件

```http
PUT /api/v1/software/:id
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "name": "MyApp",
  "description": "更新后的描述",
  "icon": "new-icon.png"
}
```

### 删除软件

```http
DELETE /api/v1/software/:id
```

**请求头:**
```
Authorization: Bearer {token}
```

## 版本管理接口

### 创建版本

```http
POST /api/v1/version
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "software_id": 1,
  "version_number": "1.0.0",
  "release_notes": "更新说明",
  "file_id": "file-uuid",
  "file_path": "/uploads/app.exe",
  "file_size": 1024000,
  "md5": "md5-hash",
  "sha256": "sha256-hash",
  "update_type": "full",
  "platform": "windows",
  "force_update": false
}
```

### 获取版本详情

```http
GET /api/v1/version/:id
```

**请求头:**
```
Authorization: Bearer {token}
```

### 更新版本状态

```http
PUT /api/v1/version/:id/status
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "status": "published"
}
```

### 版本回滚

```http
POST /api/v1/version/:id/rollback
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "rollback_type": "soft",
  "reason": "版本存在严重bug"
}
```

### 获取版本历史

```http
GET /api/v1/version/:id/history
```

**请求头:**
```
Authorization: Bearer {token}
```

### 切换版本

```http
POST /api/v1/version/:id/switch
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "target_version_id": 122,
  "reason": "回滚到稳定版本"
}
```

### 删除版本

```http
DELETE /api/v1/version/:id
```

**请求头:**
```
Authorization: Bearer {token}
```

## 文件上传接口

### 初始化上传

```http
POST /api/v1/upload/init
```

**请求头:**
```
Authorization: Bearer {token}
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

### 上传分片

```http
POST /api/v1/upload/chunk
```

**请求头:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数:**
- `task_id`: 任务ID
- `chunk_index`: 分片索引
- `chunk`: 分片文件
- `chunk_hash`: 分片MD5

### 完成上传

```http
POST /api/v1/upload/complete
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "task_id": "upload-task-uuid",
  "file_hash": "md5-hash-of-entire-file"
}
```

### 取消上传

```http
POST /api/v1/upload/cancel
```

**请求头:**
```
Authorization: Bearer {token}
```

**请求参数:**
```json
{
  "task_id": "upload-task-uuid"
}
```

### 查询上传状态

```http
GET /api/v1/upload/status/:taskId
```

**请求头:**
```
Authorization: Bearer {token}
```

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |
