################################################################################
# UpdateHub 一键安装脚本 (Windows PowerShell 版本)
# 超级简单的安装方式：下载脚本 -> 添加执行权限 -> 运行即可
################################################################################

# 错误处理
$ErrorActionPreference = "Stop"

# 配置变量
$GITHUB_REPO = "https://github.com/Eunsolfs/UpdateHub.git"
$INSTALL_DIR = "Y:\sourcecode\UpdateHub"
$TEMP_DIR = "$env:TEMP\updatehub-install"

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
# 检查管理员权限
################################################################################

function Check-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Print-Error "请以管理员身份运行此脚本"
        Print-Info "右键点击脚本，选择'以管理员身份运行'"
        exit 1
    }
}

################################################################################
# 检查基础环境
################################################################################

function Check-BasicEnvironment {
    Print-Header "检查基础环境..."
    
    # 检查操作系统
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    Print-Info "操作系统: $($osInfo.Caption)"
    
    # 检查网络连接
    Print-Info "检查网络连接..."
    try {
        Test-Connection github.com -Count 1 -Quiet | Out-Null
        Print-Success "网络连接正常"
    } catch {
        Print-Error "无法连接到 GitHub，请检查网络连接"
        exit 1
    }
    
    # 检查 git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Print-Warning "git 未安装，正在安装..."
        # Windows 需要手动安装 git
        Print-Error "请手动安装 Git: https://git-scm.com/download/win"
        exit 1
    }
    Print-Success "git 已安装"
}

################################################################################
# 检查/安装 Docker Desktop
################################################################################

function Install-Docker {
    Print-Header "检查/安装 Docker..."
    
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Print-Success "Docker 已安装: $(docker --version)"
    } else {
        Print-Warning "Docker 未安装"
        Print-Info "请手动安装 Docker Desktop: https://www.docker.com/products/docker-desktop"
        Print-Info "安装完成后请重新运行此脚本"
        exit 1
    }
}

################################################################################
# 下载项目代码
################################################################################

function Download-Project {
    Print-Header "下载项目代码..."
    
    # 创建临时目录
    if (Test-Path $TEMP_DIR) {
        Remove-Item -Path $TEMP_DIR -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
    
    # 克隆项目
    Print-Info "正在从 GitHub 克隆项目..."
    git clone $GITHUB_REPO $TEMP_DIR
    
    Print-Success "项目代码下载完成"
}

################################################################################
# 执行部署脚本
################################################################################

function Run-Deploy {
    Print-Header "执行部署..."
    
    # 移动项目到安装目录
    Print-Info "移动项目到安装目录..."
    if (Test-Path $INSTALL_DIR) {
        Remove-Item -Path $INSTALL_DIR -Recurse -Force
    }
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Copy-Item -Path "$TEMP_DIR\*" -Destination $INSTALL_DIR -Recurse -Force
    
    # 清理临时目录
    Remove-Item -Path $TEMP_DIR -Recurse -Force
    
    # 添加执行权限
    Print-Info "准备脚本执行权限..."
    
    # 运行部署脚本
    Print-Info "启动自动化部署..."
    Set-Location "$INSTALL_DIR\scripts"
    .\deploy.ps1
}

################################################################################
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 一键安装"
    
    Print-Info "本脚本将自动完成以下操作："
    Print-Info "1. 检查基础环境"
    Print-Info "2. 检查 Docker 环境"
    Print-Info "3. 下载项目代码"
    Print-Info "4. 执行自动化部署"
    
    Write-Host ""
    $confirm = Read-Host "是否继续? (y/n)"
    if ($confirm -ne "y") {
        Print-Info "安装已取消"
        exit 0
    }
    
    # 检查管理员权限
    Check-Admin
    
    # 检查基础环境
    Check-BasicEnvironment
    
    # 检查/安装 Docker
    Install-Docker
    
    # 下载项目代码
    Download-Project
    
    # 执行部署
    Run-Deploy
    
    Print-Header "安装完成"
    Print-Success "UpdateHub 已成功安装！"
    Print-Info "项目目录: $INSTALL_DIR"
    Print-Info "部署脚本: $INSTALL_DIR\scripts\deploy.ps1"
    Print-Info "运维脚本: $INSTALL_DIR\scripts\ops.ps1"
    Print-Info "卸载脚本: $INSTALL_DIR\scripts\uninstall.ps1"
    
    Write-Host ""
    Print-Info "后续运维命令："
    Print-Info "  运维管理: cd $INSTALL_DIR\scripts; .\ops.ps1"
    Print-Info "  系统更新: cd $INSTALL_DIR\scripts; .\update.ps1"
    Print-Info "  数据备份: cd $INSTALL_DIR\scripts; .\backup.ps1"
    Print-Info "  卸载系统: cd $INSTALL_DIR\scripts; .\uninstall.ps1"
}

# 运行主函数
Main
