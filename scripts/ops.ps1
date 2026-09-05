################################################################################
# UpdateHub 运维脚本 (Windows PowerShell 版本)
# 用于修改系统配置：管理员账户、端口、镜像源等
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$PROJECT_DIR = "Y:\sourcecode\UpdateHub"
$ENV_FILE = "$PROJECT_DIR\docker\.env"
$BACKUP_DIR = "$PROJECT_DIR\backups"

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
# 备份当前配置
################################################################################

function Backup-Config {
    Print-Header "备份当前配置..."
    
    $DATE = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # 创建备份目录
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force
    }
    
    # 备份 .env 文件
    if (Test-Path $ENV_FILE) {
        Copy-Item $ENV_FILE "$BACKUP_DIR\env_backup_$DATE"
        Print-Success "配置文件已备份到: $BACKUP_DIR\env_backup_$DATE"
    } else {
        Print-Warning "未找到 .env 文件"
    }
}

################################################################################
# 修改端口号
################################################################################

function Change-Port {
    Print-Header "修改端口号"
    
    Print-Info "当前后端端口配置:"
    if (Test-Path $ENV_FILE) {
        Select-String -Path $ENV_FILE -Pattern "SERVER_PORT"
    } else {
        Print-Warning "未找到端口配置"
    }
    
    $newPort = Read-Host "请输入新的后端端口 (默认 8080)"
    if ([string]::IsNullOrEmpty($newPort)) {
        $newPort = "8080"
    }
    
    # 备份配置
    Backup-Config
    
    # 修改端口
    if (Test-Path $ENV_FILE) {
        $content = Get-Content $ENV_FILE
        $modified = $false
        
        for ($i = 0; $i -lt $content.Count; $i++) {
            if ($content[$i] -match "^SERVER_PORT=") {
                $content[$i] = "SERVER_PORT=$newPort"
                $modified = $true
            }
        }
        
        if (-not $modified) {
            $content += "SERVER_PORT=$newPort"
        }
        
        $content | Set-Content $ENV_FILE
        Print-Success "后端端口已修改为: $newPort"
    } else {
        Print-Error "未找到 .env 文件"
    }
    
    Print-Info "需要重启服务才能生效"
}

################################################################################
# 修改镜像源
################################################################################

function Change-ImageSource {
    Print-Header "修改镜像源"
    
    Print-Info "当前镜像配置:"
    if (Test-Path $ENV_FILE) {
        Select-String -Path $ENV_FILE -Pattern "BACKEND_IMAGE"
        Select-String -Path $ENV_FILE -Pattern "FRONTEND_IMAGE"
    } else {
        Print-Warning "未找到镜像配置"
    }
    
    Write-Host ""
    Write-Host "选项:"
    Write-Host "1) 使用 latest 标签（最新版本）"
    Write-Host "2) 使用特定版本标签（如 v1.0.0）"
    Write-Host "3) 自定义镜像地址"
    Write-Host "4) 跳过"
    
    $choice = Read-Host "请选择 (1-4)"
    
    switch ($choice) {
        "1" {
            $username = Read-Host "输入你的 GitHub 用户名（小写）"
            $username = $username.ToLower()
            
            # 备份配置
            Backup-Config
            
            # 修改镜像
            $content = Get-Content $ENV_FILE
            $modified = $false
            
            for ($i = 0; $i -lt $content.Count; $i++) {
                if ($content[$i] -match "^BACKEND_IMAGE=") {
                    $content[$i] = "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:latest"
                    $modified = $true
                }
                if ($content[$i] -match "^FRONTEND_IMAGE=") {
                    $content[$i] = "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:latest"
                    $modified = $true
                }
            }
            
            if (-not $modified) {
                $content += "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:latest"
                $content += "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:latest"
            }
            
            $content | Set-Content $ENV_FILE
            Print-Success "镜像源已修改为 latest 标签"
        }
        "2" {
            $version = Read-Host "输入版本号 (如 v1.0.0)"
            $username = Read-Host "输入你的 GitHub 用户名（小写）"
            $username = $username.ToLower()
            
            # 备份配置
            Backup-Config
            
            # 修改镜像
            $content = Get-Content $ENV_FILE
            $modified = $false
            
            for ($i = 0; $i -lt $content.Count; $i++) {
                if ($content[$i] -match "^BACKEND_IMAGE=") {
                    $content[$i] = "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:$version"
                    $modified = $true
                }
                if ($content[$i] -match "^FRONTEND_IMAGE=") {
                    $content[$i] = "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:$version"
                    $modified = $true
                }
            }
            
            if (-not $modified) {
                $content += "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:$version"
                $content += "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:$version"
            }
            
            $content | Set-Content $ENV_FILE
            Print-Success "镜像源已修改为: $version"
        }
        "3" {
            $backendImage = Read-Host "输入后端镜像地址"
            $frontendImage = Read-Host "输入前端镜像地址"
            
            # 备份配置
            Backup-Config
            
            # 修改镜像
            $content = Get-Content $ENV_FILE
            $modified = $false
            
            for ($i = 0; $i -lt $content.Count; $i++) {
                if ($content[$i] -match "^BACKEND_IMAGE=") {
                    $content[$i] = "BACKEND_IMAGE=$backendImage"
                    $modified = $true
                }
                if ($content[$i] -match "^FRONTEND_IMAGE=") {
                    $content[$i] = "FRONTEND_IMAGE=$frontendImage"
                    $modified = $true
                }
            }
            
            if (-not $modified) {
                $content += "BACKEND_IMAGE=$backendImage"
                $content += "FRONTEND_IMAGE=$frontendImage"
            }
            
            $content | Set-Content $ENV_FILE
            Print-Success "镜像源已修改为自定义地址"
        }
        "4" {
            Print-Info "跳过镜像源修改"
        }
        default {
            Print-Error "无效选择"
        }
    }
    
    Print-Info "需要重启服务才能生效"
}

################################################################################
# 修改数据库密码
################################################################################

function Change-DatabasePassword {
    Print-Header "修改数据库密码"
    
    Print-Warning "修改数据库密码需要停止服务并重新创建数据库"
    Print-Info "请确保已备份数据库"
    
    $confirm = Read-Host "确认继续? (y/n)"
    
    if ($confirm -ne "y") {
        Print-Info "取消操作"
        return
    }
    
    # 备份配置
    Backup-Config
    
    # 备份数据库
    Print-Info "备份数据库..."
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    docker exec updatehub-postgres pg_dump -U updatehub updatehub > "$BACKUP_DIR\db_backup_$timestamp.sql"
    
    # 停止服务
    Print-Info "停止服务..."
    Set-Location $PROJECT_DIR
    docker-compose -f docker/docker-compose.1panel.yml down
    
    # 修改密码
    $newPassword = Read-Host "输入新的数据库密码"
    
    # 修改 .env 文件
    $content = Get-Content $ENV_FILE
    $modified = $false
    
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match "^POSTGRES_PASSWORD=") {
            $content[$i] = "POSTGRES_PASSWORD=$newPassword"
            $modified = $true
        }
    }
    
    if (-not $modified) {
        $content += "POSTGRES_PASSWORD=$newPassword"
    }
    
    $content | Set-Content $ENV_FILE
    
    # 删除旧的数据库卷
    Print-Warning "删除旧的数据库卷..."
    docker volume rm docker_postgres_data
    
    # 重新启动服务
    Print-Info "重新启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    Print-Success "数据库密码已修改"
    Print-Info "数据库已重新创建，需要重新初始化数据"
}

################################################################################
# 修改 JWT 密钥
################################################################################

function Change-JwtSecret {
    Print-Header "修改 JWT 密钥"
    
    Print-Info "修改 JWT 密钥会使所有现有 Token 失效"
    Print-Info "用户需要重新登录"
    
    $confirm = Read-Host "确认继续? (y/n)"
    
    if ($confirm -ne "y") {
        Print-Info "取消操作"
        return
    }
    
    # 备份配置
    Backup-Config
    
    # 生成随机密钥
    $newSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
    
    # 修改 JWT 密钥
    $content = Get-Content $ENV_FILE
    $modified = $false
    
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match "^JWT_SECRET=") {
            $content[$i] = "JWT_SECRET=$newSecret"
            $modified = $true
        }
    }
    
    if (-not $modified) {
        $content += "JWT_SECRET=$newSecret"
    }
    
    $content | Set-Content $ENV_FILE
    
    Print-Success "JWT 密钥已修改"
    Print-Info "用户需要重新登录"
    Print-Info "需要重启服务才能生效"
}

################################################################################
# 配置 Docker 镜像加速
################################################################################

function Configure-DockerAcceleration {
    Print-Header "配置 Docker 镜像加速"
    
    Print-Info "配置 Docker 镜像加速可以显著提高镜像下载速度"
    
    Write-Host ""
    Write-Host "推荐国内镜像源:"
    Write-Host "1) 阿里云镜像加速"
    Write-Host "2) 腾讯云镜像加速"
    Write-Host "3) 中科大镜像加速"
    Write-Host "4) 网易镜像加速"
    Write-Host "5) 自定义镜像源"
    Write-Host "6) 跳过"
    
    $choice = Read-Host "请选择 (1-6)"
    
    switch ($choice) {
        "1" {
            $mirror = "https://mirror.ccs.tencentyun.com"
        }
        "2" {
            $mirror = "https://mirror.ccs.tencentyun.com"
        }
        "3" {
            $mirror = "https://docker.mirrors.ustc.edu.cn"
        }
        "4" {
            $mirror = "https://hub-mirror.c.163.com"
        }
        "5" {
            $mirror = Read-Host "输入自定义镜像源地址"
        }
        "6" {
            Print-Info "跳过镜像加速配置"
            return
        }
        default {
            Print-Error "无效选择"
            return
        }
    }
    
    # 创建 Docker 配置目录
    if (-not (Test-Path "C:\ProgramData\docker")) {
        New-Item -ItemType Directory -Path "C:\ProgramData\docker" -Force
    }
    
    # 配置镜像加速
    $config = @{
        "registry-mirrors" = @($mirror)
    }
    
    $config | ConvertTo-Json | Set-Content "C:\ProgramData\docker\daemon.json"
    
    # 重启 Docker 服务
    Print-Info "重启 Docker 服务..."
    Restart-Service docker
    
    Print-Success "Docker 镜像加速已配置"
    Print-Info "镜像源: $mirror"
}

################################################################################
# 重启服务
################################################################################

function Restart-Services {
    Print-Header "重启服务"
    
    Set-Location $PROJECT_DIR
    
    Print-Info "停止服务..."
    docker-compose -f docker/docker-compose.1panel.yml down
    
    Print-Info "启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    Print-Success "服务已重启"
    
    # 等待服务启动
    Print-Info "等待服务启动..."
    Start-Sleep -Seconds 10
    
    # 检查服务状态
    Print-Info "检查服务状态..."
    docker-compose -f docker/docker-compose.1panel.yml ps
}

################################################################################
# 查看当前配置
################################################################################

function Show-Config {
    Print-Header "当前配置"
    
    if (Test-Path $ENV_FILE) {
        Write-Host "=== 环境变量配置 ==="
        Get-Content $ENV_FILE
    } else {
        Print-Warning "未找到 .env 文件"
    }
    
    Write-Host ""
    Write-Host "=== 容器状态 ==="
    Set-Location $PROJECT_DIR
    docker-compose -f docker/docker-compose.1panel.yml ps
}

################################################################################
# 主菜单
################################################################################

function Main-Menu {
    while ($true) {
        Print-Header "UpdateHub 运维管理"
        
        Write-Host "1) 修改端口号"
        Write-Host "2) 修改镜像源"
        Write-Host "3) 修改数据库密码"
        Write-Host "4) 修改 JWT 密钥"
        Write-Host "5) 配置 Docker 镜像加速"
        Write-Host "6) 重启服务"
        Write-Host "7) 查看当前配置"
        Write-Host "8) 退出"
        
        $choice = Read-Host "请选择操作 (1-8)"
        
        switch ($choice) {
            "1" {
                Change-Port
            }
            "2" {
                Change-ImageSource
            }
            "3" {
                Change-DatabasePassword
            }
            "4" {
                Change-JwtSecret
            }
            "5" {
                Configure-DockerAcceleration
            }
            "6" {
                Restart-Services
            }
            "7" {
                Show-Config
            }
            "8" {
                Print-Success "退出运维管理"
                exit
            }
            default {
                Print-Error "无效选择"
            }
        }
        
        Write-Host ""
        Read-Host "按 Enter 继续..."
    }
}

################################################################################
# 主函数
################################################################################

function Main {
    # 检查项目目录
    if (-not (Test-Path $PROJECT_DIR)) {
        Print-Error "项目目录不存在: $PROJECT_DIR"
        exit 1
    }
    
    # 检查 .env 文件
    if (-not (Test-Path $ENV_FILE)) {
        Print-Warning "未找到 .env 文件，将创建默认配置"
        Copy-Item "$PROJECT_DIR\docker\.env.example" $ENV_FILE
    }
    
    # 运行主菜单
    Main-Menu
}

# 运行主函数
Main
