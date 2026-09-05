################################################################################
# UpdateHub 备份脚本 (Windows PowerShell 版本)
# 自动备份数据库、上传文件和配置文件
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$PROJECT_DIR = "Y:\sourcecode\UpdateHub"
$BACKUP_DIR = "$PROJECT_DIR\backups"
$RETENTION_DAYS = 7  # 保留天数

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
# 环境检查
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
    
    # 检查 PostgreSQL 容器
    $postgresContainer = docker ps --filter "name=updatehub-postgres" --format "{{.Names}}"
    if ([string]::IsNullOrEmpty($postgresContainer)) {
        Print-Warning "PostgreSQL 容器未运行，跳过数据库备份"
    }
    
    Print-Success "环境检查完成"
}

################################################################################
# 创建备份目录
################################################################################

function Create-BackupDir {
    Print-Info "创建备份目录..."
    
    $DATE = Get-Date -Format "yyyyMMdd_HHmmss"
    $BACKUP_PATH = "$BACKUP_DIR\$DATE"
    
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force
    }
    
    New-Item -ItemType Directory -Path "$BACKUP_PATH\postgres" -Force
    New-Item -ItemType Directory -Path "$BACKUP_PATH\uploads" -Force
    New-Item -ItemType Directory -Path "$BACKUP_PATH\configs" -Force
    
    Print-Success "备份目录创建完成: $BACKUP_PATH"
    return $BACKUP_PATH
}

################################################################################
# 备份配置文件
################################################################################

function Backup-Configs {
    param([string]$BackupPath)
    
    Print-Header "备份配置文件..."
    
    $DATE = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # 备份后端配置
    if (Test-Path "$PROJECT_DIR\backend\configs\config.yaml") {
        Copy-Item "$PROJECT_DIR\backend\configs\config.yaml" "$BackupPath\configs\config_backup_$DATE.yaml"
        Print-Success "后端配置备份完成"
    }
    
    # 备份环境变量
    if (Test-Path "$PROJECT_DIR\docker\.env") {
        Copy-Item "$PROJECT_DIR\docker\.env" "$BackupPath\configs\env_backup_$DATE"
        Print-Success "环境变量备份完成"
    }
    
    # 备份 Docker Compose 配置
    if (Test-Path "$PROJECT_DIR\docker\docker-compose.1panel.yml") {
        Copy-Item "$PROJECT_DIR\docker\docker-compose.1panel.yml" "$BackupPath\configs\docker-compose_backup_$DATE.yml"
        Print-Success "Docker Compose 配置备份完成"
    }
}

################################################################################
# 备份上传文件
################################################################################

function Backup-Uploads {
    param([string]$BackupPath)
    
    Print-Header "备份上传文件..."
    
    $DATE = Get-Date -Format "yyyyMMdd_HHmmss"
    $BACKUP_FILE = "$BackupPath\uploads\uploads_backup_$DATE.zip"
    
    if (Test-Path "$PROJECT_DIR\backend\uploads") {
        Print-Info "正在备份上传文件..."
        Compress-Archive -Path "$PROJECT_DIR\backend\uploads" -DestinationPath $BACKUP_FILE
        
        # 计算文件大小
        $FILE_SIZE = (Get-Item $BACKUP_FILE).Length / 1MB
        $FILE_SIZE = [math]::Round($FILE_SIZE, 2)
        
        Print-Success "上传文件备份完成: $BACKUP_FILE ($FILE_SIZE MB)"
    } else {
        Print-Warning "上传目录不存在，跳过"
    }
}

################################################################################
# 备份版本信息
################################################################################

function Backup-VersionInfo {
    param([string]$BackupPath)
    
    Print-Header "备份版本信息..."
    
    Set-Location $PROJECT_DIR
    
    # 备份当前 commit
    $currentCommit = git rev-parse HEAD
    $currentCommit | Out-File -FilePath "$BackupPath\current_commit.txt"
    
    # 备份当前版本标签
    try {
        $currentVersion = git describe --tags
        $currentVersion | Out-File -FilePath "$BackupPath\current_version.txt"
    } catch {
        "unknown" | Out-File -FilePath "$BackupPath\current_version.txt"
    }
    
    # 备份分支信息
    try {
        $currentBranch = git branch --show-current
        $currentBranch | Out-File -FilePath "$BackupPath\current_branch.txt"
    } catch {
        "unknown" | Out-File -FilePath "$BackupPath\current_branch.txt"
    }
    
    Print-Success "版本信息备份完成"
}

################################################################################
# 清理旧备份
################################################################################

function Cleanup-OldBackups {
    Print-Header "清理旧备份..."
    
    $cutoffDate = (Get-Date).AddDays(-$RETENTION_DAYS)
    
    # 删除超过保留天数的备份
    Get-ChildItem $BACKUP_DIR -Directory | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -Force
    
    # 统计当前备份数量
    $BACKUP_COUNT = (Get-ChildItem $BACKUP_DIR -Directory).Count
    
    Print-Success "旧备份清理完成，当前保留 $BACKUP_COUNT 个备份"
}

################################################################################
# 生成备份报告
################################################################################

function Generate-BackupReport {
    param([string]$BackupPath)
    
    Print-Header "生成备份报告..."
    
    $REPORT_FILE = "$BackupPath\backup_report.txt"
    
    Set-Location $PROJECT_DIR
    
    # 获取版本信息
    try {
        $currentVersion = git describe --tags
    } catch {
        $currentVersion = "unknown"
    }
    
    try {
        $currentBranch = git branch --show-current
    } catch {
        $currentBranch = "unknown"
    }
    
    $currentCommit = git rev-parse HEAD
    
    # 计算备份大小
    $backupSize = (Get-ChildItem $BackupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $backupSize = [math]::Round($backupSize, 2)
    
    # 获取磁盘空间
    $diskSpace = (Get-PSDrive $BACKUP_DIR.Substring(0,1)).Free / 1GB
    $diskSpace = [math]::Round($diskSpace, 2)
    
    $report = @"
UpdateHub 备份报告
==================

备份时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
备份目录: $BackupPath

备份内容:
- 配置文件: config_backup_*.yaml, env_backup_*
- 上传文件: uploads_backup_*.zip
- 版本信息: current_commit.txt, current_version.txt

项目信息:
- 当前分支: $currentBranch
- 当前版本: $currentVersion
- 当前提交: $currentCommit

系统信息:
- 主机名: $env:COMPUTERNAME
- 操作系统: $((Get-CimInstance Win32_OperatingSystem).Caption)
- Docker 版本: $(docker --version)
- PowerShell 版本: $PSVersionTable.PSVersion

存储信息:
- 总备份大小: $backupSize MB
- 可用磁盘空间: $diskSpace GB

保留策略: 保留最近 $RETENTION_DAYS 天的备份
"@
    
    $report | Out-File -FilePath $REPORT_FILE -Encoding utf8
    
    Print-Success "备份报告生成完成: $REPORT_FILE"
}

################################################################################
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 备份脚本 (Windows)"
    
    # 检查环境
    Check-Environment
    
    # 创建备份目录
    $backupPath = Create-BackupDir
    
    # 执行备份
    Backup-Configs -BackupPath $backupPath
    Backup-Uploads -BackupPath $backupPath
    Backup-VersionInfo -BackupPath $backupPath
    
    # 生成报告
    Generate-BackupReport -BackupPath $backupPath
    
    # 清理旧备份
    Cleanup-OldBackups
    
    Print-Success "备份完成！"
    
    # 显示备份信息
    $backupSize = (Get-ChildItem $backupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $backupSize = [math]::Round($backupSize, 2)
    
    Write-Host ""
    Write-Host "备份信息:"
    Write-Host "  备份目录: $backupPath"
    Write-Host "  备份时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "  保留策略: $RETENTION_DAYS 天"
    Write-Host "  备份大小: $backupSize MB"
}

# 运行主函数
Main
