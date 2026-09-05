################################################################################
# UpdateHub 一键更新脚本 (Windows PowerShell 版本)
# 支持零停机更新和完整停机更新
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
    
    # 检查 Git
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Print-Error "Git 未安装"
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
    Print-Success "配置文件备份完成"
    
    # 备份上传文件
    Print-Info "备份上传文件..."
    if (Test-Path "$PROJECT_DIR\backend\uploads") {
        Compress-Archive -Path "$PROJECT_DIR\backend\uploads" -DestinationPath "$BACKUP_DIR\uploads\uploads_backup_$DATE.zip"
    }
    Print-Success "上传文件备份完成"
    
    # 保存当前 git 信息
    Print-Info "保存当前版本信息..."
    Set-Location $PROJECT_DIR
    $currentCommit = git rev-parse HEAD
    $currentCommit | Out-File -FilePath "$BACKUP_DIR\current_commit_$DATE.txt"
    
    try {
        $currentVersion = git describe --tags
        $currentVersion | Out-File -FilePath "$BACKUP_DIR\current_version_$DATE.txt"
    } catch {
        "unknown" | Out-File -FilePath "$BACKUP_DIR\current_version_$DATE.txt"
    }
    
    Print-Success "版本信息保存完成"
    Print-Success "所有数据备份完成"
}

################################################################################
# 拉取最新代码
################################################################################

function Pull-LatestCode {
    Print-Header "拉取最新代码..."
    
    Set-Location $PROJECT_DIR
    
    # 获取当前版本
    try {
        $CURRENT_VERSION = git describe --tags
    } catch {
        $CURRENT_VERSION = "unknown"
    }
    Print-Info "当前版本: $CURRENT_VERSION"
    
    # 拉取最新代码
    Print-Info "拉取最新代码..."
    git fetch origin
    
    # 显示可用版本
    Print-Info "可用版本:"
    git tag -l --sort=-version:refname | Select-Object -First 5
    
    # 询问用户选择版本
    $selectedVersion = Read-Host "选择版本 (按 Enter 使用最新版本)"
    
    if ([string]::IsNullOrEmpty($selectedVersion)) {
        Print-Info "使用最新版本..."
        git checkout origin/main
    } else {
        Print-Info "切换到版本: $selectedVersion"
        git checkout $selectedVersion
    }
    
    try {
        $NEW_VERSION = git describe --tags
    } catch {
        $NEW_VERSION = "latest"
    }
    Print-Success "代码更新完成: $CURRENT_VERSION -> $NEW_VERSION"
}

################################################################################
# 构建新镜像
################################################################################

function Build-NewImages {
    Print-Header "构建新镜像..."
    
    Set-Location $PROJECT_DIR
    
    Print-Info "构建后端镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build backend
    
    Print-Info "构建前端镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build frontend
    
    Print-Success "镜像构建完成"
}

################################################################################
# 零停机更新
################################################################################

function Rolling-Update {
    Print-Header "执行零停机更新..."
    
    Set-Location $PROJECT_DIR
    
    # 更新后端
    Print-Info "更新后端服务..."
    docker-compose -f docker/docker-compose.1panel.yml stop backend
    docker-compose -f docker/docker-compose.1panel.yml up -d backend
    
    Print-Info "等待后端启动..."
    Start-Sleep -Seconds 15
    
    # 检查后端健康
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Print-Success "后端更新成功"
        } else {
            Print-Error "后端更新失败，开始回滚..."
            Rollback
            exit 1
        }
    } catch {
        Print-Error "后端更新失败，开始回滚..."
        Rollback
        exit 1
    }
    
    # 更新前端
    Print-Info "更新前端服务..."
    docker-compose -f docker/docker-compose.1panel.yml stop frontend
    docker-compose -f docker/docker-compose.1panel.yml up -d frontend
    
    Print-Info "等待前端启动..."
    Start-Sleep -Seconds 10
    
    # 检查前端
    try {
        $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Print-Success "前端更新成功"
        } else {
            Print-Warning "前端可能需要更多时间启动"
        }
    } catch {
        Print-Warning "前端可能需要更多时间启动"
    }
    
    Print-Success "零停机更新完成"
}

################################################################################
# 完整停机更新
################################################################################

function Full-Update {
    Print-Header "执行完整停机更新..."
    
    Set-Location $PROJECT_DIR
    
    # 停止所有服务
    Print-Info "停止所有服务..."
    docker-compose -f docker/docker-compose.1panel.yml down
    
    # 构建新镜像
    Build-NewImages
    
    # 启动所有服务
    Print-Info "启动所有服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    # 等待服务启动
    Print-Info "等待服务启动..."
    Start-Sleep -Seconds 30
    
    # 检查服务状态
    Print-Info "检查服务状态..."
    docker-compose -f docker/docker-compose.1panel.yml ps
    
    Print-Success "完整停机更新完成"
}

################################################################################
# 数据库迁移
################################################################################

function Run-Migrations {
    Print-Header "执行数据库迁移..."
    
    Set-Location $PROJECT_DIR
    
    # 检查是否有迁移文件
    if (Test-Path "backend\migrations") {
        $migrations = Get-ChildItem "backend\migrations"
        if ($migrations.Count -gt 0) {
            Print-Info "发现迁移文件，执行迁移..."
            Print-Info "数据库迁移将在服务启动时自动执行"
        } else {
            Print-Info "没有发现迁移文件"
        }
    } else {
        Print-Info "没有发现迁移文件"
    }
    
    Print-Success "数据库迁移检查完成"
}

################################################################################
# 回滚函数
################################################################################

function Rollback {
    Print-Header "执行回滚..."
    
    Set-Location $PROJECT_DIR
    
    # 恢复之前的版本
    Print-Info "恢复之前的版本..."
    $backupFiles = Get-ChildItem "$BACKUP_DIR\current_commit_*.txt" | Sort-Object LastWriteTime -Descending
    if ($backupFiles.Count -gt 0) {
        $lastCommit = Get-Content $backupFiles[0].FullName
        git checkout $lastCommit
    } else {
        Print-Error "没有找到备份文件"
        exit 1
    }
    
    # 重新构建
    Print-Info "重新构建镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build
    
    # 启动服务
    Print-Info "启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    Print-Success "回滚完成"
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
# 清理旧备份
################################################################################

function Cleanup-OldBackups {
    Print-Header "清理旧备份..."
    
    # 保留最近7天的备份
    $cutoffDate = (Get-Date).AddDays(-7)
    
    Get-ChildItem "$BACKUP_DIR\configs" -Filter "*.yaml" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item
    Get-ChildItem "$BACKUP_DIR\configs" -Filter "*_backup_*" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item
    Get-ChildItem "$BACKUP_DIR\uploads" -Filter "*.zip" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item
    Get-ChildItem "$BACKUP_DIR" -Filter "*.txt" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item
    
    Print-Success "旧备份清理完成"
}

################################################################################
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 一键更新脚本 (Windows)"
    
    # 检查环境
    Check-Environment
    
    # 备份数据
    Backup-Data
    
    # 拉取最新代码
    Pull-LatestCode
    
    # 选择更新方式
    Write-Host ""
    Write-Host "请选择更新方式:"
    Write-Host "1) 零停机更新 (推荐)"
    Write-Host "2) 完整停机更新"
    $updateChoice = Read-Host "请输入选择 (1-2)"
    
    switch ($updateChoice) {
        "1" {
            Build-NewImages
            Rolling-Update
        }
        "2" {
            Full-Update
        }
        default {
            Print-Error "无效选择"
            exit 1
        }
    }
    
    # 执行数据库迁移
    Run-Migrations
    
    # 验证更新
    $success = Verify-Update
    
    if ($success) {
        # 清理旧备份
        Cleanup-OldBackups
        
        Print-Success "更新完成！"
        
        # 显示更新信息
        Set-Location $PROJECT_DIR
        try {
            $NEW_VERSION = git describe --tags
        } catch {
            $NEW_VERSION = "latest"
        }
        Write-Host ""
        Write-Host "更新信息:"
        Write-Host "  新版本: $NEW_VERSION"
        Write-Host "  更新时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Host "  日志文件: $LOG_FILE"
    } else {
        Print-Error "更新验证失败"
    }
}

# 运行主函数
Main
