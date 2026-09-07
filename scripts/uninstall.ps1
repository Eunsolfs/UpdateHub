################################################################################
# UpdateHub 卸载脚本 (Windows PowerShell 版本)
# 支持保留数据或完全卸载
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$PROJECT_DIR = "Y:\sourcecode\UpdateHub"
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
# 检查环境
################################################################################

function Check-Environment {
    Print-Header "检查环境..."
    
    # 检查项目目录
    if (-not (Test-Path $PROJECT_DIR)) {
        Print-Error "UpdateHub 未安装，项目目录不存在: $PROJECT_DIR"
        exit 1
    }
    
    # 检查 Docker
    try {
        docker --version | Out-Null
    } catch {
        Print-Error "Docker 未安装"
        exit 1
    }
    
    # 检查 Docker Compose
    try {
        docker-compose --version | Out-Null
    } catch {
        Print-Error "Docker Compose 未安装"
        exit 1
    }
    
    Print-Success "环境检查完成"
}

################################################################################
# 停止服务
################################################################################

function Stop-Services {
    Print-Header "停止服务..."
    
    Set-Location $PROJECT_DIR
    
    if (Test-Path "docker\docker-compose.1panel.yml") {
        docker-compose -f docker\docker-compose.1panel.yml down
        Print-Success "服务已停止"
    } else {
        Print-Warning "未找到 docker-compose.1panel.yml"
    }
}

################################################################################
# 清理容器
################################################################################

function Cleanup-Containers {
    Print-Header "清理容器..."
    
    # 停止并删除所有 UpdateHub 相关容器
    docker ps -a | Select-String "updatehub" | ForEach-Object {
        $containerId = ($_ -split '\s+')[0]
        docker rm -f $containerId
    }
    
    Print-Success "容器已清理"
}

################################################################################
# 清理镜像
################################################################################

function Cleanup-Images {
    Print-Header "清理镜像..."
    
    # 删除 UpdateHub 相关镜像
    docker images | Select-String "updatehub" | ForEach-Object {
        $imageId = ($_ -split '\s+')[2]
        docker rmi -f $imageId
    }
    
    Print-Success "镜像已清理"
}

################################################################################
# 清理数据卷
################################################################################

function Cleanup-Volumes {
    Print-Header "清理数据卷..."
    
    # 删除 UpdateHub 相关数据卷
    docker volume ls | Select-String "updatehub" | ForEach-Object {
        $volumeName = ($_ -split '\s+')[1]
        docker volume rm $volumeName
    }
    
    Print-Success "数据卷已清理"
}

################################################################################
# 清理网络
################################################################################

function Cleanup-Networks {
    Print-Header "清理网络..."
    
    # 删除 UpdateHub 相关网络
    docker network ls | Select-String "updatehub" | ForEach-Object {
        $networkName = ($_ -split '\s+')[1]
        docker network rm $networkName
    }
    
    Print-Success "网络已清理"
}

################################################################################
# 清理项目文件
################################################################################

function Cleanup-ProjectFiles {
    Print-Header "清理项目文件..."
    
    $confirm = Read-Host "确认删除项目目录 $PROJECT_DIR? (y/n)"
    if ($confirm -eq "y") {
        Remove-Item -Path $PROJECT_DIR -Recurse -Force
        Print-Success "项目文件已清理"
    } else {
        Print-Warning "跳过项目文件清理"
    }
}

################################################################################
# 备份数据
################################################################################

function Backup-Data {
    Print-Header "备份数据..."
    
    # 创建备份目录
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force
    }
    
    # 备份数据库
    $dbContainers = docker ps | Select-String "updatehub-postgres"
    if ($dbContainers) {
        Print-Info "备份数据库..."
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        docker exec updatehub-postgres pg_dump -U updatehub updatehub > "$BACKUP_DIR\db_backup_$timestamp.sql"
        Print-Success "数据库已备份"
    }
    
    # 备份配置文件
    if (Test-Path "$PROJECT_DIR\docker\.env") {
        Print-Info "备份配置文件..."
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item "$PROJECT_DIR\docker\.env" "$BACKUP_DIR\env_backup_$timestamp"
        Print-Success "配置文件已备份"
    }
    
    # 备份上传文件
    if (Test-Path "$PROJECT_DIR\backend\uploads") {
        Print-Info "备份上传文件..."
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Compress-Archive -Path "$PROJECT_DIR\backend\uploads" -DestinationPath "$BACKUP_DIR\uploads_backup_$timestamp.zip"
        Print-Success "上传文件已备份"
    }
    
    Print-Success "数据备份完成，备份位置: $BACKUP_DIR"
}

################################################################################
# 卸载选项1：保留数据，只删除服务
################################################################################

function Uninstall-KeepData {
    Print-Header "卸载模式：保留数据，只删除服务"
    
    Print-Warning "此操作将："
    Print-Warning "- 停止所有服务"
    Print-Warning "- 删除 Docker 容器"
    Print-Warning "- 保留数据库数据"
    Print-Warning "- 保留配置文件"
    Print-Warning "- 保留上传文件"
    Print-Warning "- 保留 Docker 镜像"
    
    $confirm = Read-Host "确认继续? (y/n)"
    if ($confirm -ne "y") {
        Print-Info "取消卸载"
        return
    }
    
    # 备份数据
    Backup-Data
    
    # 停止服务
    Stop-Services
    
    # 清理容器
    Cleanup-Containers
    
    Print-Success "卸载完成（数据已保留）"
    Print-Info "如需重新部署，可以直接启动服务"
}

################################################################################
# 卸载选项2：清除所有数据和服务
################################################################################

function Uninstall-All {
    Print-Header "卸载模式：清除所有数据和服务"
    
    Print-Warning "此操作将："
    Print-Warning "- 停止所有服务"
    Print-Warning "- 删除 Docker 容器"
    Print-Warning "- 删除数据库数据"
    Print-Warning "- 删除配置文件"
    Print-Warning "- 删除上传文件"
    Print-Warning "- 删除 Docker 镜像"
    Print-Warning "- 删除项目文件"
    Print-Warning "- ⚠️ 此操作不可逆！"
    
    $confirm = Read-Host "确认继续? (y/n)"
    if ($confirm -ne "y") {
        Print-Info "取消卸载"
        return
    }
    
    # 先备份数据（以防万一）
    Backup-Data
    
    # 停止服务
    Stop-Services
    
    # 清理容器
    Cleanup-Containers
    
    # 清理镜像
    Cleanup-Images
    
    # 清理数据卷
    Cleanup-Volumes
    
    # 清理网络
    Cleanup-Networks
    
    # 清理项目文件
    Cleanup-ProjectFiles
    
    Print-Success "完全卸载完成"
    Print-Info "数据已备份到: $BACKUP_DIR"
}

################################################################################
# 卸载选项3：选择性清理
################################################################################

function Uninstall-Selective {
    Print-Header "卸载模式：选择性清理"
    
    while ($true) {
        Write-Host ""
        Write-Host "请选择要清理的内容："
        Write-Host "1) 清理 Docker 容器"
        Write-Host "2) 清理 Docker 镜像"
        Write-Host "3) 清理数据卷（数据库数据）"
        Write-Host "4) 清理配置文件"
        Write-Host "5) 清理上传文件"
        Write-Host "6) 清理项目文件"
        Write-Host "7) 返回主菜单"
        
        $choice = Read-Host "请选择 (1-7)"
        
        switch ($choice) {
            "1" {
                Cleanup-Containers
            }
            "2" {
                Cleanup-Images
            }
            "3" {
                $confirm = Read-Host "确认清理数据卷（将删除数据库数据）? (y/n)"
                if ($confirm -eq "y") {
                    Backup-Data
                    Cleanup-Volumes
                }
            }
            "4" {
                $confirm = Read-Host "确认清理配置文件? (y/n)"
                if ($confirm -eq "y") {
                    Backup-Data
                    Remove-Item "$PROJECT_DIR\docker\.env" -Force
                    Remove-Item "$PROJECT_DIR\docker\nginx.conf" -Force
                    Print-Success "配置文件已清理"
                }
            }
            "5" {
                $confirm = Read-Host "确认清理上传文件? (y/n)"
                if ($confirm -eq "y") {
                    Backup-Data
                    Remove-Item "$PROJECT_DIR\backend\uploads" -Recurse -Force
                    Print-Success "上传文件已清理"
                }
            }
            "6" {
                Cleanup-ProjectFiles
            }
            "7" {
                return
            }
            default {
                Print-Error "无效选择"
            }
        }
    }
}

################################################################################
# 主菜单
################################################################################

function Main-Menu {
    while ($true) {
        Print-Header "UpdateHub 卸载管理"
        
        Write-Host "1) 保留数据，只删除服务"
        Write-Host "2) 清除所有数据和服务（⚠️ 不可逆）"
        Write-Host "3) 选择性清理"
        Write-Host "4) 退出"
        
        $choice = Read-Host "请选择卸载方式 (1-4)"
        
        switch ($choice) {
            "1" {
                Uninstall-KeepData
            }
            "2" {
                Uninstall-All
            }
            "3" {
                Uninstall-Selective
            }
            "4" {
                Print-Success "退出卸载管理"
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
    # 检查环境
    Check-Environment
    
    # 显示警告
    Print-Warning "您即将卸载 UpdateHub"
    Print-Warning "请确保已备份重要数据"
    
    # 运行主菜单
    Main-Menu
}

# 运行主函数
Main
