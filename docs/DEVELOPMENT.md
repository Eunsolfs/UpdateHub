# UpdateHub 开发指南

## 开发环境搭建

### 前置要求

- Go 1.21+
- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- Git

### 后端开发

#### 1. 安装依赖

```bash
cd backend
go mod download
```

#### 2. 配置数据库

修改 `configs/config.yaml` 中的数据库连接信息：

```yaml
database:
  host: localhost
  port: 5432
  user: updatehub
  password: updatehub
  dbname: updatehub
```

#### 3. 运行开发服务器

```bash
go run cmd/server/main.go
```

#### 4. 运行测试

```bash
go test ./...
```

#### 5. 生成 API 文档

```bash
swag init -g cmd/server/main.go
```

### 前端开发

#### 1. 安装依赖

```bash
cd frontend
npm install
```

#### 2. 运行开发服务器

```bash
npm run dev
```

开发服务器将在 http://localhost:3000 启动

#### 3. 构建生产版本

```bash
npm run build
```

#### 4. 运行测试

```bash
npm run lint
```

## 项目结构

### 后端结构

```
backend/
├── cmd/
│   └── server/
│       └── main.go          # 主程序入口
├── internal/
│   ├── api/                 # API 处理器
│   ├── model/               # 数据模型
│   ├── service/             # 业务逻辑
│   ├── repository/          # 数据访问
│   └── middleware/          # 中间件
├── pkg/                     # 公共包
│   ├── storage/             # 存储抽象层
│   ├── upload/              # 分片上传处理
│   └── diff/                # 增量更新算法
├── configs/                 # 配置文件
├── uploads/                 # 上传文件存储
├── go.mod
└── go.sum
```

### 前端结构

```
frontend/
├── src/
│   ├── api/                 # API 调用
│   ├── views/               # 页面组件
│   ├── components/          # 通用组件
│   ├── router/              # 路由配置
│   ├── stores/              # 状态管理
│   ├── utils/               # 工具函数
│   ├── locales/             # 国际化文件
│   ├── App.vue              # 根组件
│   └── main.ts              # 入口文件
├── public/                  # 静态资源
├── index.html
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## 代码规范

### Go 代码规范

遵循 [Effective Go](https://golang.org/doc/effective_go) 和 [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)。

- 使用 `gofmt` 格式化代码
- 使用 `golint` 检查代码
- 函数命名使用驼峰命名法
- 导出的函数和类型必须添加注释

### TypeScript 代码规范

遵循 [TypeScript 官方风格指南](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)。

- 使用 `eslint` 检查代码
- 使用 `prettier` 格式化代码
- 组件命名使用 PascalCase
- 工具函数命名使用 camelCase

## Git 工作流

### 分支策略

- `main`: 主分支，稳定版本
- `develop`: 开发分支
- `feature/*`: 功能分支
- `bugfix/*`: 修复分支
- `hotfix/*`: 紧急修复分支

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

类型：
- `feat`: 新功能
- `fix`: 修复
- `docs`: 文档
- `style`: 格式
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建

示例：
```
feat(auth): add JWT authentication

Implement JWT token-based authentication for API endpoints.
Add login, logout, and token refresh functionality.

Closes #123
```

## 测试策略

### 后端测试

- 单元测试：测试各个函数和方法
- 集成测试：测试 API 接口
- 端到端测试：测试完整流程

### 前端测试

- 单元测试：测试组件和工具函数
- 集成测试：测试页面交互
- 端到端测试：测试用户流程

## 性能优化

### 后端优化

- 使用连接池管理数据库连接
- 使用 Redis 缓存热点数据
- 实现限流防止接口滥用
- 优化数据库查询

### 前端优化

- 使用代码分割减少初始加载时间
- 懒加载路由组件
- 使用 CDN 加速静态资源
- 实现虚拟滚动处理大数据列表

## 安全考虑

### 后端安全

- 使用 HTTPS 加密传输
- 实现 JWT 认证和授权
- 验证所有输入数据
- 防止 SQL 注入和 XSS 攻击
- 实现限流防止 DDoS 攻击

### 前端安全

- 验证用户输入
- 使用 CSP 防止 XSS
- 实现 CSRF 保护
- 加密敏感数据存储

## 调试技巧

### 后端调试

```bash
# 使用 Delve 调试器
dlv debug cmd/server/main.go

# 添加日志
log.Printf("Debug info: %+v", data)
```

### 前端调试

```typescript
// 使用 console.log
console.log('Debug info:', data)

// 使用 Vue DevTools
// 安装 Vue DevTools 浏览器扩展
```

## 常见问题

### 后端开发问题

**Q: 数据库连接失败**
A: 检查数据库配置和连接状态，确保数据库服务正在运行。

**Q: Go modules 下载缓慢**
A: 使用 Go 代理：`export GOPROXY=https://goproxy.cn,direct`

### 前端开发问题

**Q: npm install 失败**
A: 清除缓存并重试：`npm cache clean --force && npm install`

**Q: Vite 热更新不工作**
A: 检查文件监听限制：`fs.inotify.max_user_watches=524288`

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

请确保：
- 代码通过所有测试
- 代码符合项目规范
- 添加必要的文档
- 更新相关文档
