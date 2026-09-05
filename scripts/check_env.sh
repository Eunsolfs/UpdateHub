#!/bin/bash

################################################################################
# UpdateHub 环境检查脚本
# 检查系统环境和依赖项是否满足部署要求
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# 打印函数
print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# 检查操作系统
################################################################################

check_os() {
    print_header "检查操作系统"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_pass "操作系统: $NAME $VERSION"
    else
        print_fail "无法识别操作系统"
    fi
    
    # 检查架构
    ARCH=$(uname -m)
    print_pass "系统架构: $ARCH"
    
    # 检查内核版本
    KERNEL=$(uname -r)
    print_pass "内核版本: $KERNEL"
}

################################################################################
# 检查系统资源
################################################################################

check_system_resources() {
    print_header "检查系统资源"
    
    # 检查内存
    TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
    if [ $TOTAL_MEM -ge 2048 ]; then
        print_pass "内存: ${TOTAL_MEM}MB (≥2GB)"
    else
        print_fail "内存: ${TOTAL_MEM}MB (<2GB, 建议≥2GB)"
    fi
    
    # 检查磁盘空间
    DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $DISK_SPACE -ge 20 ]; then
        print_pass "磁盘空间: ${DISK_SPACE}GB (≥20GB)"
    else
        print_fail "磁盘空间: ${DISK_SPACE}GB (<20GB, 建议≥20GB)"
    fi
    
    # 检查CPU核心数
    CPU_CORES=$(nproc)
    print_pass "CPU核心数: $CPU_CORES"
}

################################################################################
# 检查 Docker
################################################################################

check_docker() {
    print_header "检查 Docker"
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        print_pass "Docker 已安装: $DOCKER_VERSION"
        
        # 检查 Docker 是否运行
        if docker info &> /dev/null; then
            print_pass "Docker 服务运行正常"
        else
            print_fail "Docker 服务未运行"
        fi
    else
        print_fail "Docker 未安装"
    fi
}

################################################################################
# 检查 Docker Compose
################################################################################

check_docker_compose() {
    print_header "检查 Docker Compose"
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version)
        print_pass "Docker Compose 已安装: $COMPOSE_VERSION"
    else
        print_fail "Docker Compose 未安装"
    fi
}

################################################################################
# 检查 Git
################################################################################

check_git() {
    print_header "检查 Git"
    
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_pass "Git 已安装: $GIT_VERSION"
    else
        print_fail "Git 未安装"
    fi
}

################################################################################
# 检查端口占用
################################################################################

check_ports() {
    print_header "检查端口占用"
    
    PORTS=(80 8080 5432 6379)
    PORT_NAMES=("HTTP" "Backend" "PostgreSQL" "Redis")
    
    for i in "${!PORTS[@]}"; do
        PORT=${PORTS[$i]}
        NAME=${PORT_NAMES[$i]}
        
        if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
            print_warning "端口 $PORT ($NAME) 已被占用"
        else
            print_pass "端口 $PORT ($NAME) 可用"
        fi
    done
}

################################################################################
# 检查网络连接
################################################################################

check_network() {
    print_header "检查网络连接"
    
    # 检查 DNS 解析
    if nslookup google.com &> /dev/null; then
        print_pass "DNS 解析正常"
    else
        print_fail "DNS 解析异常"
    fi
    
    # 检查外网连接
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        print_pass "外网连接正常"
    else
        print_fail "外网连接异常"
    fi
}

################################################################################
# 检查防火墙
################################################################################

check_firewall() {
    print_header "检查防火墙"
    
    if command -v ufw &> /dev/null; then
        UFW_STATUS=$(ufw status | head -1)
        print_info "UFW 防火墙: $UFW_STATUS"
    elif command -v firewall-cmd &> /dev/null; then
        FIREWALL_STATUS=$(firewall-cmd --state)
        print_info "firewalld 防火墙: $FIREWALL_STATUS"
    else
        print_info "未检测到常见防火墙"
    fi
}

################################################################################
# 检查文件权限
################################################################################

check_permissions() {
    print_header "检查文件权限"
    
    # 检查是否为 root 用户
    if [ "$EUID" -eq 0 ]; then
        print_pass "当前用户: root"
    else
        print_info "当前用户: $(whoami) (建议使用 root)"
    fi
    
    # 检查 /opt 目录写入权限
    if [ -w /opt ]; then
        print_pass "/opt 目录可写"
    else
        print_fail "/opt 目录不可写"
    fi
}

################################################################################
# 检查 1Panel (可选)
################################################################################

check_1panel() {
    print_header "检查 1Panel"
    
    if command -v 1panel &> /dev/null; then
        PANEL_VERSION=$(1panel version)
        print_pass "1Panel 已安装: $PANEL_VERSION"
    else
        print_info "1Panel 未安装 (可选)"
    fi
}

################################################################################
# 生成报告
################################################################################

generate_report() {
    print_header "检查报告"
    
    echo "总检查项: $TOTAL_CHECKS"
    echo "通过: $PASSED_CHECKS"
    echo "失败: $FAILED_CHECKS"
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}所有检查通过，环境满足部署要求！${NC}"
        return 0
    else
        echo -e "${RED}有 $FAILED_CHECKS 项检查失败，请解决后再部署。${NC}"
        return 1
    fi
}

################################################################################
# 主函数
################################################################################

main() {
    print_header "UpdateHub 环境检查"
    
    # 执行各项检查
    check_os
    check_system_resources
    check_docker
    check_docker_compose
    check_git
    check_ports
    check_network
    check_firewall
    check_permissions
    check_1panel
    
    # 生成报告
    generate_report
}

# 运行主函数
main
