################################################################################
# UpdateHub 环境检查脚本 (Windows PowerShell 版本)
# 检查系统环境和依赖项是否满足部署要求
################################################################################

# 检查计数器
$TOTAL_CHECKS = 0
$PASSED_CHECKS = 0
$FAILED_CHECKS = 0

################################################################################
# 打印函数
################################################################################

function Print-Header {
    param([string]$Message)
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  $Message" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

function Print-Check {
    param([string]$Message)
    Write-Host "[CHECK] $Message" -ForegroundColor Blue
    $script:TOTAL_CHECKS++
}

function Print-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
    $script:PASSED_CHECKS++
}

function Print-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:FAILED_CHECKS++
}

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

################################################################################
# 检查操作系统
################################################################################

function Check-OS {
    Print-Header "检查操作系统"
    
    $osInfo = Get-CimInstance Win32_OperatingSystem
    Print-Pass "操作系统: $($osInfo.Caption)"
    Print-Pass "版本: $($osInfo.Version)"
    Print-Pass "架构: $($osInfo.OSArchitecture)"
}

################################################################################
# 检查系统资源
################################################################################

function Check-SystemResources {
    Print-Header "检查系统资源"
    
    # 检查内存
    $totalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $totalMemory = [math]::Round($totalMemory, 2)
    
    if ($totalMemory -ge 2) {
        Print-Pass "内存: ${totalMemory}GB (≥2GB)"
    } else {
        Print-Fail "内存: ${totalMemory}GB (<2GB, 建议≥2GB)"
    }
    
    # 检查磁盘空间
    $disk = Get-PSDrive C
    $freeSpace = $disk.Free / 1GB
    $freeSpace = [math]::Round($freeSpace, 2)
    
    if ($freeSpace -ge 20) {
        Print-Pass "磁盘空间: ${freeSpace}GB (≥20GB)"
    } else {
        Print-Fail "磁盘空间: ${freeSpace}GB (<20GB, 建议≥20GB)"
    }
    
    # 检查CPU核心数
    $cpuCores = (Get-CimInstance Win32_Processor).NumberOfCores
    Print-Pass "CPU核心数: $cpuCores"
}

################################################################################
# 检查 Docker
################################################################################

function Check-Docker {
    Print-Header "检查 Docker"
    
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        $dockerVersion = docker --version
        Print-Pass "Docker 已安装: $dockerVersion"
        
        # 检查 Docker 是否运行
        try {
            docker info | Out-Null
            Print-Pass "Docker 服务运行正常"
        } catch {
            Print-Fail "Docker 服务未运行"
        }
    } else {
        Print-Fail "Docker 未安装"
    }
}

################################################################################
# 检查 Docker Compose
################################################################################

function Check-DockerCompose {
    Print-Header "检查 Docker Compose"
    
    $dockerCompose = Get-Command docker-compose -ErrorAction SilentlyContinue
    if ($dockerCompose) {
        $composeVersion = docker-compose --version
        Print-Pass "Docker Compose 已安装: $composeVersion"
    } else {
        Print-Fail "Docker Compose 未安装"
    }
}

################################################################################
# 检查 Git
################################################################################

function Check-Git {
    Print-Header "检查 Git"
    
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $gitVersion = git --version
        Print-Pass "Git 已安装: $gitVersion"
    } else {
        Print-Fail "Git 未安装"
    }
}

################################################################################
# 检查端口占用
################################################################################

function Check-Ports {
    Print-Header "检查端口占用"
    
    $ports = @(80, 8080, 5432, 6379)
    $portNames = @("HTTP", "Backend", "PostgreSQL", "Redis")
    
    for ($i = 0; $i -lt $ports.Count; $i++) {
        $port = $ports[$i]
        $name = $portNames[$i]
        
        $portCheck = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($portCheck) {
            Print-Warning "端口 $port ($name) 已被占用"
        } else {
            Print-Pass "端口 $port ($name) 可用"
        }
    }
}

################################################################################
# 检查网络连接
################################################################################

function Check-Network {
    Print-Header "检查网络连接"
    
    # 检查 DNS 解析
    try {
        $dnsResult = Resolve-DnsName -Name "google.com" -ErrorAction Stop
        Print-Pass "DNS 解析正常"
    } catch {
        Print-Fail "DNS 解析异常"
    }
    
    # 检查外网连接
    try {
        $pingResult = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction Stop
        Print-Pass "外网连接正常"
    } catch {
        Print-Fail "外网连接异常"
    }
}

################################################################################
# 检查防火墙
################################################################################

function Check-Firewall {
    Print-Header "检查防火墙"
    
    try {
        $firewallProfile = Get-NetFirewallProfile
        $enabledProfiles = $firewallProfile | Where-Object { $_.Enabled -eq $true }
        
        if ($enabledProfiles) {
            Print-Info "Windows 防火墙已启用"
            foreach ($profile in $enabledProfiles) {
                Print-Info "  - $($profile.Name): 启用"
            }
        } else {
            Print-Info "Windows 防火墙未启用"
        }
    } catch {
        Print-Info "无法检查防火墙状态"
    }
}

################################################################################
# 检查文件权限
################################################################################

function Check-Permissions {
    Print-Header "检查文件权限"
    
    # 检查管理员权限
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isAdmin) {
        Print-Pass "当前用户: 管理员"
    } else {
        Print-Info "当前用户: 普通用户 (建议使用管理员权限)"
    }
    
    # 检查项目目录写入权限
    $projectDir = "Y:\sourcecode\UpdateHub"
    if (Test-Path $projectDir) {
        $canWrite = Test-Path $projectDir -PathType Container -ErrorAction SilentlyContinue
        if ($canWrite) {
            Print-Pass "项目目录可写"
        } else {
            Print-Fail "项目目录不可写"
        }
    } else {
        Print-Info "项目目录不存在"
    }
}

################################################################################
# 生成报告
################################################################################

function Generate-Report {
    Print-Header "检查报告"
    
    Write-Host "总检查项: $TOTAL_CHECKS"
    Write-Host "通过: $PASSED_CHECKS"
    Write-Host "失败: $FAILED_CHECKS"
    
    if ($FAILED_CHECKS -eq 0) {
        Write-Host "所有检查通过，环境满足部署要求！" -ForegroundColor Green
        return 0
    } else {
        Write-Host "有 $FAILED_CHECKS 项检查失败，请解决后再部署。" -ForegroundColor Red
        return 1
    }
}

################################################################################
# 主函数
################################################################################

function Main {
    Print-Header "UpdateHub 环境检查 (Windows)"
    
    # 执行各项检查
    Check-OS
    Check-SystemResources
    Check-Docker
    Check-DockerCompose
    Check-Git
    Check-Ports
    Check-Network
    Check-Firewall
    Check-Permissions
    
    # 生成报告
    Generate-Report
}

# 运行主函数
Main
