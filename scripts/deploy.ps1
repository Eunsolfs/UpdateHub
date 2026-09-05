# UpdateHub 部署脚本 (PowerShell)

Write-Host "开始部署 UpdateHub..." -ForegroundColor Green

# 检查 Docker 是否安装
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "错误: Docker 未安装，请先安装 Docker" -ForegroundColor Red
    exit 1
}

# 检查 Docker Compose 是否安装
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "错误: Docker Compose 未安装，请先安装 Docker Compose" -ForegroundColor Red
    exit 1
}

# 进入 docker 目录
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dockerPath = Join-Path $scriptPath "..\docker"
Set-Location $dockerPath

# 停止并删除旧容器
Write-Host "停止旧容器..." -ForegroundColor Yellow
docker-compose down

# 构建并启动服务
Write-Host "构建并启动服务..." -ForegroundColor Yellow
docker-compose up -d

# 等待服务启动
Write-Host "等待服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 检查服务状态
Write-Host "检查服务状态..." -ForegroundColor Yellow
docker-compose ps

Write-Host "部署完成！" -ForegroundColor Green
Write-Host "前端访问地址: http://localhost" -ForegroundColor Cyan
Write-Host "后端 API 地址: http://localhost:8080" -ForegroundColor Cyan
Write-Host "数据库端口: 5432" -ForegroundColor Cyan
Write-Host "Redis 端口: 6379" -ForegroundColor Cyan
