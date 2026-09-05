################################################################################
# UpdateHub 一键部署脚本 (Windows PowerShell 版本 - CI/CD版本)
# 使用预构建的Docker镜像，避免在服务器端构建
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$PROJECT_NAME = "UpdateHub"
$INSTALL_DIR = "Y:\sourcecode\UpdateHub"
$BACKUP_DIR = "$INSTALL_DIR\backups"
$GITHUB_REPO = "https://github.com/your-username/UpdateHub.git"

# 镜像配置（GitHub Container Registry）
$DEFAULT_BACKEND_IMAGE = "ghcr.io/your-username/updatehub-backend:latest"
$DEFAULT_FRONTEND_IMAGE = "ghcr.io/your-username/updatehub-frontend:latest"

# 默认配置
$DEFAULT_DB_PASSWORD = "updatehub"
$DEFAULT_JWT_SECRET = "your-secret-key-change-this"
$DEFAULT_SERVER_PORT = "8080"

################################################################################
# 打印函数
################################################################################

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Print-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Print-Header {
    param([string]$Message)
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  $Message" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

################################################################################
# 环境检查函数
################################################################################

function Check-Environment {
    Print-Header "检查环境..."
    
    # 检查 Docker
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Print-Error "Docker 未安装，请先安装 Docker Desktop"
        exit 1
    }
    Print-Success "Docker 已安装"
    
    # 检查 Docker Compose
    $dockerCompose = Get-Command docker-compose -ErrorAction SilentlyContinue
    if (-not $dockerCompose) {
        Print-Error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    }
    Print-Success "Docker Compose 已安装"
    
    # 检查 Git
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Print-Warning "Git 未安装，请安装 Git"
        exit 1
    }
    Print-Success "Git 已安装"
    
    # 检查端口占用
    $port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port8080) {
        Print-Warning "端口 8080 已被占用"
        $continue = Read-Host "是否继续? (y/n)"
        if ($continue -ne "y") {
            exit 1
        }
    }
    
    $port80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
    if ($port80) {
        Print-Warning "端口 80 已被占用"
        $continue = Read-Host "是否继续? (y/n)"
        if ($continue -ne "y") {
            exit 1
        }
    }
    
    Print-Success "环境检查完成"
}

################################################################################
# 用户输入函数
################################################################################

function Get-UserInput {
    Print-Header "配置信息"
    
    # 项目安装目录
    $inputDir = Read-Host "安装目录 [$INSTALL_DIR]"
    if ($inputDir) { $INSTALL_DIR = $inputDir }
    
    # 数据库密码
    $inputDbPass = Read-Host "数据库密码 [$DEFAULT_DB_PASSWORD]"
    if ($inputDbPass) { $DB_PASSWORD = $inputDbPass } else { $DB_PASSWORD = $DEFAULT_DB_PASSWORD }
    
    # JWT 密钥
    $inputJwtSecret = Read-Host "JWT 密钥 [$DEFAULT_JWT_SECRET]"
    if ($inputJwtSecret) { $JWT_SECRET = $inputJwtSecret } else { $JWT_SECRET = $DEFAULT_JWT_SECRET }
    
    # 服务器端口
    $inputPort = Read-Host "服务器端口 [$DEFAULT_SERVER_PORT]"
    if ($inputPort) { $SERVER_PORT = $inputPort } else { $SERVER_PORT = $DEFAULT_SERVER_PORT }
    
    # 后端镜像
    $inputBackendImage = Read-Host "后端镜像 [$DEFAULT_BACKEND_IMAGE]"
    if ($inputBackendImage) { $BACKEND_IMAGE = $inputBackendImage } else { $BACKEND_IMAGE = $DEFAULT_BACKEND_IMAGE }
    
    # 前端镜像
    $inputFrontendImage = Read-Host "前端镜像 [$DEFAULT_FRONTEND_IMAGE]"
    if ($inputFrontendImage) { $FRONTEND_IMAGE = $inputFrontendImage } else { $FRONTEND_IMAGE = $DEFAULT_FRONTEND_IMAGE }
    
    # 服务器模式
    $inputServerMode = Read-Host "服务器模式 [release]"
    if ($inputServerMode) { $SERVER_MODE = $inputServerMode } else { $SERVER_MODE = "release" }
    
    Print-Info "配置摘要:"
    Write-Host "  安装目录: $INSTALL_DIR"
    Write-Host "  数据库密码: $DB_PASSWORD"
    Write-Host "  JWT 密钥: $JWT_SECRET"
    Write-Host "  服务器端口: $SERVER_PORT"
    Write-Host "  后端镜像: $BACKEND_IMAGE"
    Write-Host "  前端镜像: $FRONTEND_IMAGE"
    Write-Host "  服务器模式: $SERVER_MODE"
    
    $confirm = Read-Host "确认配置? (y/n)"
    if ($confirm -ne "y") {
        Print-Error "配置已取消"
        exit 1
    }
}

################################################################################
# 安装函数
################################################################################

function Install-Project {
    Print-Header "开始安装..."
    
    # 创建安装目录
    Print-Info "创建安装目录..."
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force
    }
    
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force
        New-Item -ItemType Directory -Path "$BACKUP_DIR\postgres" -Force
        New-Item -ItemType Directory -Path "$BACKUP_DIR\uploads" -Force
        New-Item -ItemType Directory -Path "$BACKUP_DIR\configs" -Force
    }
    
    # 克隆项目代码（仅用于获取配置文件）
    Print-Info "克隆项目代码..."
    if (Test-Path "$INSTALL_DIR\.git") {
        Print-Info "项目已存在，拉取最新代码..."
        Set-Location $INSTALL_DIR
        git pull origin main
    } else {
        git clone $GITHUB_REPO $INSTALL_DIR
        Set-Location $INSTALL_DIR
    }
    
    # 创建环境变量文件
    Print-Info "创建环境变量文件..."
    $envContent = @"
# UpdateHub 环境变量配置
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=updatehub
POSTGRES_USER=updatehub

REDIS_PASSWORD=

JWT_SECRET=$JWT_SECRET
REFRESH_SECRET=$JWT_SECRET-refresh

SERVER_MODE=$SERVER_MODE
SERVER_PORT=$SERVER_PORT

BACKEND_IMAGE=$BACKEND_IMAGE
FRONTEND_IMAGE=$FRONTEND_IMAGE

STORAGE_TYPE=local

LOG_LEVEL=info
"@
    
    $envContent | Out-File -FilePath "$INSTALL_DIR\docker\.env" -Encoding utf8
    
    # 拉取预构建镜像
    Print-Info "拉取预构建的Docker镜像..."
    docker pull $BACKEND_IMAGE
    docker pull $FRONTEND_IMAGE
    
    # 启动服务
    Print-Info "启动服务..."
    Set-Location $INSTALL_DIR
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    # 等待服务启动
    Print-Info "等待服务启动..."
    Start-Sleep -Seconds 30
    
    Print-Success "安装完成"
}

################################################################################
# 验证函数
################################################################################

function Verify-Installation {
    Print-Header "验证安装..."
    
    # 检查容器状态
    Print-Info "检查容器状态..."
    docker-compose -f "$INSTALL_DIR\docker\docker-compose.1panel.yml" ps
    
    # 检查后端健康
    Print-Info "检查后端健康状态..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$SERVER_PORT/health" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Print-Success "后端服务正常"
        } else {
            Print-Error "后端服务异常"
            return $false
        }
    } catch {
        Print-Error "后端服务异常"
        return $false
    }
    
    # 检查前端
    Print-Info "检查前端服务..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Print-Success "前端服务正常"
        } else {
            Print-Warning "前端服务可能需要更多时间启动"
        }
    } catch {
        Print-Warning "前端服务可能需要更多时间启动"
    }
    
    Print-Success "验证完成"
    return $true
}

################################################################################
# 显示信息函数
################################################################################

function Show-Info {
    Print-Header "安装信息"
    
    Write-Host "UpdateHub 已成功安装！" -ForegroundColor Green
    Write-Host ""
    Write-Host "部署方式: 使用预构建Docker镜像 (CI/CD)" -ForegroundColor Green
    Write-Host ""
    Write-Host "访问地址:"
    Write-Host "  前端: http://localhost"
    Write-Host "  后端: http://localhost:$SERVER_PORT"
    Write-Host "  健康检查: http://localhost:$SERVER_PORT/health"
    Write-Host ""
    Write-Host "使用的镜像:"
    Write-Host "  后端: $BACKEND_IMAGE"
    Write-Host "  前端: $FRONTEND_IMAGE"
    Write-Host ""
    Write-Host "默认账户:"
    Write-Host "  用户名: admin"
    Write-Host "  密码: admin123"
    Write-Host ""
    Write-Host "⚠️  重要: 请立即修改默认密码！" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "常用命令:"
    Write-Host "  查看日志: docker-compose -f docker\docker-compose.1panel.yml logs -f"
    Write-Host "  停止服务: docker-compose -f docker\docker-compose.1panel.yml down"
    Write-Host "  启动服务: docker-compose -f docker\docker-compose.1panel.yml up -d"
    Write-Host "  重启服务: docker-compose -f docker\docker-compose.1panel.yml restart"
    Write-Host "  更新镜像: docker pull $BACKEND_IMAGE && docker pull $FRONTEND_IMAGE"
    Write-Host ""
    Write-Host "项目目录: $INSTALL_DIR"
    Write-Host "备份目录: $BACKUP_DIR"
}

################################################################################
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 一键部署脚本 (Windows CI/CD版本)"
    
    # 检查环境
    Check-Environment
    
    # 获取用户输入
    Get-UserInput
    
    # 安装项目
    Install-Project
    
    # 验证安装
    $success = Verify-Installation
    
    if ($success) {
        # 显示信息
        Show-Info
        
        Print-Success "部署完成！"
    } else {
        Print-Error "部署验证失败，请检查日志"
    }
}

# 运行主函数
Main
