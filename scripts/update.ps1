################################################################################
# UpdateHub 一键更新脚本 (Windows PowerShell 版本 - CI/CD版本)
# 使用预构建的Docker镜像，只需拉取新版本镜像
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$PROJECT_DIR = "Y:\sourcecode\UpdateHub"
$BACKUP_DIR = "$PROJECT_DIR\backups"
$LOG_FILE = "$PROJECT_DIR\update.log"

################################################################################
# 打印函数
################################################################################

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] $Message"
}

function Print-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [SUCCESS] $Message"
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] $Message"
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [ERROR] $Message"
}

function Print-Header {
    param([string]$Message)
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  $Message" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Add-Content -Path $LOG_FILE -Value "===== $Message ====="
}

################################################################################
# 环境检查函数
################################################################################

function Check-Environment {
    Print-Header "检查环境..."
    
    # 检查项目目录
    if (-not (Test-Path $PROJECT_DIR)) {
        Print-Error "项目目录不存在: $PROJECT_DIR"
        exit 1
    }
    
    # 检查 Docker
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Print-Error "Docker 未安装"
        exit 1
    }
    
    # 检查 Docker Compose
    $dockerCompose = Get-Command docker-compose -ErrorAction SilentlyContinue
    if (-not $dockerCompose) {
        Print-Error "Docker Compose 未安装"
        exit 1
    }
    
    Print-Success "环境检查完成"
}

################################################################################
# 备份函数
################################################################################

function Backup-Data {
    Print-Header "备份数据..."
    
    $DATE = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # 创建备份目录
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force
    }
    
    # 备份配置文件
    Print-Info "备份配置文件..."
    if (Test-Path "$PROJECT_DIR\backend\configs\config.yaml") {
        Copy-Item "$PROJECT_DIR\backend\configs\config.yaml" "$BACKUP_DIR\configs\config_backup_$DATE.yaml"
    }
    if (Test-Path "$PROJECT_DIR\docker\.env") {
        Copy-Item "$PROJECT_DIR\docker\.env" "$BACKUP_DIR\configs\env_backup_$DATE"
    }
    
    # 备份上传文件
    Print-Info "备份上传文件..."
    if (Test-Path "$PROJECT_DIR\backend\uploads") {
        Compress-Archive -Path "$PROJECT_DIR\backend\uploads" -DestinationPath "$BACKUP_DIR\uploads\uploads_backup_$DATE.zip"
    }
    
    # 保存当前镜像信息
    Print-Info "保存当前镜像信息..."
    docker images | Select-String -Pattern "updatehub" | Out-File -FilePath "$BACKUP_DIR\current_images_$DATE.txt"
    
    Print-Success "数据备份完成"
}

################################################################################
# 拉取新镜像
################################################################################

function Pull-NewImages {
    Print-Header "拉取新镜像..."
    
    Set-Location $PROJECT_DIR
    
    # 从环境变量读取镜像地址
    $envContent = Get-Content "$PROJECT_DIR\docker\.env"
    $envLines = $envContent -split "`n"
    $BACKEND_IMAGE = "ghcr.io/your-username/updatehub-backend:latest"
    $FRONTEND_IMAGE = "ghcr.io/your-username/updatehub-frontend:latest"
    
    foreach ($line in $envLines) {
        if ($line -match "^BACKEND_IMAGE=(.+)") {
            $BACKEND_IMAGE = $Matches[1]
        }
        if ($line -match "^FRONTEND_IMAGE=(.+)") {
            $FRONTEND_IMAGE = $Matches[1]
        }
    }
    
    Print-Info "拉取后端镜像: $BACKEND_IMAGE"
    docker pull $BACKEND_IMAGE
    
    Print-Info "拉取前端镜像: $FRONTEND_IMAGE"
    docker pull $FRONTEND_IMAGE
    
    Print-Success "镜像拉取完成"
}

################################################################################
# 更新服务
################################################################################

function Update-Services {
    Print-Header "更新服务..."
    
    Set-Location $PROJECT_DIR
    
    # 选择更新方式
    Write-Host ""
    Write-Host "请选择更新方式:"
    Write-Host "1) 零停机更新 (推荐)"
    Write-Host "2) 完整停机更新"
    $updateChoice = Read-Host "请输入选择 (1-2)"
    
    switch ($updateChoice) {
        "1" {
            Print-Info "执行零停机更新..."
            docker-compose -f docker/docker-compose.1panel.yml pull
            docker-compose -f docker/docker-compose.1panel.yml up -d
        }
        "2" {
            Print-Info "执行完整停机更新..."
            docker-compose -f docker/docker-compose.1panel.yml down
            docker-compose -f docker/docker-compose.1panel.yml pull
            docker-compose -f docker/docker-compose.1panel.yml up -d
        }
        default {
            Print-Error "无效选择"
            exit 1
        }
    }
    
    # 等待服务启动
    Print-Info "等待服务启动..."
    Start-Sleep -Seconds 30
    
    Print-Success "服务更新完成"
}

################################################################################
# 验证更新
################################################################################

function Verify-Update {
    Print-Header "验证更新..."
    
    # 检查容器状态
    Print-Info "检查容器状态..."
    docker-compose -f "$PROJECT_DIR\docker\docker-compose.1panel.yml" ps
    
    # 检查后端健康
    Print-Info "检查后端健康状态..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing
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
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 一键更新脚本 (Windows CI/CD版本)"
    
    # 检查环境
    Check-Environment
    
    # 备份数据
    Backup-Data
    
    # 拉取新镜像
    Pull-NewImages
    
    # 更新服务
    Update-Services
    
    # 验证更新
    $success = Verify-Update
    
    if ($success) {
        Print-Success "更新完成！"
        
        # 显示更新信息
        Set-Location $PROJECT_DIR
        $envContent = Get-Content "$PROJECT_DIR\docker\.env"
        $BACKEND_IMAGE = "ghcr.io/your-username/updatehub-backend:latest"
        $FRONTEND_IMAGE = "ghcr.io/your-yourname/updatehub-frontend:latest"
        
        foreach ($line in $envContent -split "`n") {
            if ($line -match "^BACKEND_IMAGE=(.+)") {
                $BACKEND_IMAGE = $Matches[1]
            }
            if ($line -match "^FRONTEND_IMAGE=(.+)") {
                $FRONTEND_IMAGE = $Matches[1]
            }
        }
        
        Write-Host ""
        Write-Host "更新信息:"
        Write-Host "  后端镜像: $BACKEND_IMAGE"
        Write-Host "  前端镜像: $FRONTEND_IMAGE"
        Write-Host "  更新时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Host "  日志文件: $LOG_FILE"
    } else {
        Print-Error "更新验证失败"
    }
}

# 运行主函数
Main
