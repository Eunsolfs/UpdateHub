#!/bin/bash

################################################################################
# UpdateHub 一键安装脚本
# 超级简单的安装方式：下载脚本 -> 添加执行权限 -> 运行即可
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
GITHUB_REPO="https://github.com/Eunsolfs/UpdateHub.git"
INSTALL_DIR="/opt/UpdateHub"
TEMP_DIR="/tmp/updatehub-install"

# 颜色函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

################################################################################
# 检查是否为 root 用户
################################################################################

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "请使用 root 用户运行此脚本"
        print_info "使用方法: sudo ./install.sh"
        exit 1
    fi
}

################################################################################
# 检查基础环境
################################################################################

check_basic_environment() {
    print_header "检查基础环境..."
    
    # 检查操作系统
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_info "操作系统: $PRETTY_NAME"
    else
        print_error "无法检测操作系统"
        exit 1
    fi
    
    # 检查网络连接
    print_info "检查网络连接..."
    if ! ping -c 1 github.com &> /dev/null; then
        print_error "无法连接到 GitHub，请检查网络连接"
        exit 1
    fi
    print_success "网络连接正常"
    
    # 检查 curl
    if ! command -v curl &> /dev/null; then
        print_warning "curl 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y curl
        elif command -v yum &> /dev/null; then
            yum install -y curl
        else
            print_error "无法自动安装 curl，请手动安装"
            exit 1
        fi
    fi
    print_success "curl 已安装"
    
    # 检查 git
    if ! command -v git &> /dev/null; then
        print_warning "git 未安装，正在安装..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y git
        elif command -v yum &> /dev/null; then
            yum install -y git
        else
            print_error "无法自动安装 git，请手动安装"
            exit 1
        fi
    fi
    print_success "git 已安装"
}

################################################################################
# 安装 Docker
################################################################################

install_docker() {
    print_header "检查/安装 Docker..."
    
    if command -v docker &> /dev/null; then
        print_success "Docker 已安装: $(docker --version)"
    else
        print_info "Docker 未安装，正在安装..."
        
        # 使用官方安装脚本
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        # 启动 Docker
        systemctl start docker
        systemctl enable docker
        
        print_success "Docker 安装完成"
    fi
}

################################################################################
# 安装 Docker Compose
################################################################################

install_docker_compose() {
    print_header "检查/安装 Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose 已安装: $(docker-compose --version)"
    else
        print_info "Docker Compose 未安装，正在安装..."
        
        # 下载 Docker Compose
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        
        print_success "Docker Compose 安装完成"
    fi
}

################################################################################
# 下载项目代码
################################################################################

download_project() {
    print_header "下载项目代码..."
    
    # 创建临时目录
    mkdir -p $TEMP_DIR
    cd $TEMP_DIR
    
    # 克隆项目
    print_info "正在从 GitHub 克隆项目..."
    git clone $GITHUB_REPO .
    
    print_success "项目代码下载完成"
}

################################################################################
# 执行部署脚本
################################################################################

run_deploy() {
    print_header "执行部署..."
    
    # 移动项目到安装目录
    print_info "移动项目到安装目录..."
    mkdir -p $INSTALL_DIR
    cp -r $TEMP_DIR/* $INSTALL_DIR/
    
    # 清理临时目录
    rm -rf $TEMP_DIR
    
    # 添加执行权限
    print_info "添加脚本执行权限..."
    chmod +x $INSTALL_DIR/scripts/*.sh
    
    # 运行部署脚本
    print_info "启动自动化部署..."
    cd $INSTALL_DIR/scripts
    ./deploy.sh
}

################################################################################
# 主函数
################################################################################

main() {
    print_header "UpdateHub 一键安装"
    
    print_info "本脚本将自动完成以下操作："
    print_info "1. 检查基础环境"
    print_info "2. 安装 Docker 和 Docker Compose"
    print_info "3. 下载项目代码"
    print_info "4. 执行自动化部署"
    
    echo ""
    read -p "是否继续? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        print_info "安装已取消"
        exit 0
    fi
    
    # 检查 root 用户
    check_root
    
    # 检查基础环境
    check_basic_environment
    
    # 安装 Docker
    install_docker
    
    # 安装 Docker Compose
    install_docker_compose
    
    # 下载项目代码
    download_project
    
    # 执行部署
    run_deploy
    
    print_header "安装完成"
    print_success "UpdateHub 已成功安装！"
    print_info "项目目录: $INSTALL_DIR"
    print_info "部署脚本: $INSTALL_DIR/scripts/deploy.sh"
    print_info "运维脚本: $INSTALL_DIR/scripts/ops.sh"
    print_info "卸载脚本: $INSTALL_DIR/scripts/uninstall.sh"
    
    echo ""
    print_info "后续运维命令："
    print_info "  运维管理: cd $INSTALL_DIR/scripts && ./ops.sh"
    print_info "  系统更新: cd $INSTALL_DIR/scripts && ./update.sh"
    print_info "  数据备份: cd $INSTALL_DIR/scripts && ./backup.sh"
    print_info "  卸载系统: cd $INSTALL_DIR/scripts && ./uninstall.sh"
}

# 运行主函数
main
