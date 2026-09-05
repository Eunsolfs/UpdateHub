# UpdateHub 部署指南

## 前置要求

- Docker 20.10+
- Docker Compose 1.29+
- 8GB+ 内存
- 20GB+ 磁盘空间

## 快速部署

### 1. 克隆项目

```bash
git clone <repository-url>
cd UpdateHub
```

### 2. 配置环境变量

编辑 `backend/configs/config.yaml` 文件，修改数据库连接等配置：

```yaml
database:
  host: localhost
  port: 5432
  user: updatehub
  password: your-secure-password
  dbname: updatehub
```

### 3. 使用 Docker Compose 部署

#### Linux/Mac:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

#### Windows:

```powershell
cd scripts
.\deploy.ps1
```

### 4. 访问系统

- 前端界面: http://localhost
- 后端 API: http://localhost:8080
- 默认管理员账号: admin / admin123

## 手动部署

### 后端部署

#### 1. 安装依赖

```bash
cd backend
go mod download
```

#### 2. 配置数据库

创建 PostgreSQL 数据库：

```sql
CREATE DATABASE updatehub;
CREATE USER updatehub WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE updatehub TO updatehub;
```

#### 3. 修改配置

编辑 `configs/config.yaml`，修改数据库连接信息。

#### 4. 运行后端

```bash
go run cmd/server/main.go
```

或编译后运行：

```bash
go build -o updatehub-server cmd/server/main.go
./updatehub-server
```

### 前端部署

#### 1. 安装依赖

```bash
cd frontend
npm install
```

#### 2. 开发模式

```bash
npm run dev
```

#### 3. 生产构建

```bash
npm run build
```

构建产物在 `dist` 目录，可以部署到任何静态文件服务器。

#### 4. 使用 Nginx 部署

配置 Nginx：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 生产环境部署建议

### 1. 使用 HTTPS

配置 SSL 证书，推荐使用 Let's Encrypt：

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 2. 配置防火墙

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. 设置数据库备份

```bash
# 备份数据库
docker exec updatehub-postgres pg_dump -U updatehub updatehub > backup.sql

# 恢复数据库
docker exec -i updatehub-postgres psql -U updatehub updatehub < backup.sql
```

### 4. 监控日志

```bash
# 查看容器日志
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 5. 资源限制

在 `docker-compose.yml` 中添加资源限制：

```yaml
backend:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        cpus: '1'
        memory: 1G
```

## 故障排除

### 容器无法启动

```bash
# 查看容器日志
docker-compose logs backend
docker-compose logs postgres

# 重新构建
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 数据库连接失败

检查数据库配置是否正确，确保数据库容器正在运行：

```bash
docker-compose ps
docker-compose logs postgres
```

### 前端无法访问后端

检查 Nginx 配置和后端服务状态：

```bash
docker-compose logs frontend
docker-compose logs backend
```

## 更新升级

```bash
# 拉取最新代码
git pull

# 重新构建并启动
cd docker
docker-compose down
docker-compose build
docker-compose up -d
```
