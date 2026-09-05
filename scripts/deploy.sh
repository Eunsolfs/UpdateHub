#!/bin/bash

################################################################################
# UpdateHub 一键部署脚本 (CI/CD版本)
# 使用预构建的Docker镜像，避免在服务器端构建
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_NAME="UpdateHub"
INSTALL_DIR="/opt/UpdateHub"
BACKUP_DIR="/opt/UpdateHub/backups"
GITHUB_REPO="https://github.com/your-username/UpdateHub.git"

# 镜像配置（GitHub Container Registry）
DEFAULT_BACKEND_IMAGE="ghcr.io/your-username/updatehub-backend:latest"
DEFAULT_FRONTEND_IMAGE="ghcr.io/your-username/updatehub-frontend:latest"

# 默认配置
DEFAULT_DB_PASSWORD="updatehub"
DEFAULT_JWT_SECRET="your-secret-key-change-this"
DEFAULT_SERVER_PORT="8080"

################################################################################
# 打印函数
################################################################################

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
# 环境检查函数
################################################################################

check_environment() {
    print_header "检查环境..."
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then 
        print_warning "建议使用 root 用户运行此脚本"
        read -p "是否继续? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    print_success "Docker 已安装"
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    print_success "Docker Compose 已安装"
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        print_warning "Git 未安装，尝试安装..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y git
        elif command -v yum &> /dev/null; then
            yum install -y git
        else
            print_error "无法自动安装 Git，请手动安装"
            exit 1
        fi
    fi
    print_success "Git 已安装"
    
    # 检查端口占用
    if netstat -tuln 2>/dev/null | grep -q ":8080 "; then
        print_warning "端口 8080 已被占用"
        read -p "是否继续? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":80 "; then
        print_warning "端口 80 已被占用"
        read -p "是否继续? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 配置 Docker 镜像加速
    configure_docker_acceleration
    
    print_success "环境检查完成"
}

################################################################################
# 配置 Docker 镜像加速
################################################################################

configure_docker_acceleration() {
    print_info "配置 Docker 镜像加速..."
    
    # 检查是否已配置
    if [ -f /etc/docker/daemon.json ] && grep -q "registry-mirrors" /etc/docker/daemon.json; then
        print_info "Docker 镜像加速已配置"
        return
    fi
    
    print_info "国内服务器建议配置 Docker 镜像加速以加快下载速度"
    echo ""
    echo "推荐国内镜像源:"
    echo "1) 腾讯云镜像加速"
    echo "2) 阿里云镜像加速"
    echo "3) 中科大镜像加速"
    echo "4) 网易镜像加速"
    echo "5) 跳过"
    
    read -p "请选择 (1-5): " choice
    
    case $choice in
        1)
            mirror="https://mirror.ccs.tencentyun.com"
            ;;
        2)
            mirror="https://registry.cn-hangzhou.aliyuncs.com"
            ;;
        3)
            mirror="https://docker.mirrors.ustc.edu.cn"
            ;;
        4)
            mirror="https://hub-mirror.c.163.com"
            ;;
        5)
            print_info "跳过镜像加速配置"
            return
            ;;
        *)
            print_warning "无效选择，跳过镜像加速配置"
            return
            ;;
    esac
    
    # 创建 Docker 配置目录
    sudo mkdir -p /etc/docker
    
    # 配置镜像加速（使用简单配置避免 referrers 问题）
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": ["$mirror"],
  "features": {
    "registry-mirrors": true
  }
}
EOF
    
    # 重启 Docker 服务
    print_info "重启 Docker 服务..."
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    print_success "Docker 镜像加速已配置"
    print_info "镜像源: $mirror"
}

################################################################################
# 用户输入函数
################################################################################

get_user_input() {
    print_header "配置信息"
    
    # 项目安装目录
    read -p "安装目录 [$INSTALL_DIR]: " input_dir
    INSTALL_DIR=${input_dir:-$INSTALL_DIR}
    
    # 数据库密码
    read -p "数据库密码 [$DEFAULT_DB_PASSWORD]: " input_db_pass
    DB_PASSWORD=${input_db_pass:-$DEFAULT_DB_PASSWORD}
    
    # JWT 密钥
    read -p "JWT 密钥 [$DEFAULT_JWT_SECRET]: " input_jwt_secret
    JWT_SECRET=${input_jwt_secret:-$DEFAULT_JWT_SECRET}
    
    # 服务器端口
    read -p "服务器端口 [$DEFAULT_SERVER_PORT]: " input_port
    SERVER_PORT=${input_port:-$DEFAULT_SERVER_PORT}
    
    # 后端镜像
    read -p "后端镜像 [$DEFAULT_BACKEND_IMAGE]: " input_backend_image
    BACKEND_IMAGE=${input_backend_image:-$DEFAULT_BACKEND_IMAGE}
    
    # 前端镜像
    read -p "前端镜像 [$DEFAULT_FRONTEND_IMAGE]: " input_frontend_image
    FRONTEND_IMAGE=${input_frontend_image:-$DEFAULT_FRONTEND_IMAGE}
    
    # 服务器模式
    read -p "服务器模式 [release]: " input_server_mode
    SERVER_MODE=${input_server_mode:-release}
    
    print_info "配置摘要:"
    echo "  安装目录: $INSTALL_DIR"
    echo "  数据库密码: $DB_PASSWORD"
    echo "  JWT 密钥: $JWT_SECRET"
    echo "  服务器端口: $SERVER_PORT"
    echo "  后端镜像: $BACKEND_IMAGE"
    echo "  前端镜像: $FRONTEND_IMAGE"
    echo "  服务器模式: $SERVER_MODE"
    
    read -p "确认配置? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "配置已取消"
        exit 1
    fi
}

################################################################################
# 安装函数
################################################################################

install_project() {
    print_header "开始安装..."
    
    # 创建安装目录
    print_info "创建安装目录..."
    mkdir -p $INSTALL_DIR
    mkdir -p $BACKUP_DIR
    mkdir -p $BACKUP_DIR/postgres
    mkdir -p $BACKUP_DIR/uploads
    mkdir -p $BACKUP_DIR/configs
    
    # 克隆项目代码（仅用于获取配置文件）
    print_info "克隆项目代码..."
    if [ -d "$INSTALL_DIR/.git" ]; then
        print_info "项目已存在，拉取最新代码..."
        cd $INSTALL_DIR
        git pull origin main
    else
        git clone $GITHUB_REPO $INSTALL_DIR
        cd $INSTALL_DIR
    fi
    
    # 创建环境变量文件
    print_info "创建环境变量文件..."
    cat > $INSTALL_DIR/docker/.env << EOF
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
EOF
    
    # 修改 docker-compose 配置以使用环境变量
    print_info "修改 Docker Compose 配置..."
    sed -i "s|${SERVER_PORT:-8080}:8080|$SERVER_PORT:8080|g" $INSTALL_DIR/docker/docker-compose.1panel.yml
    
    # 拉取预构建镜像
    print_info "拉取预构建的Docker镜像..."
    docker pull $BACKEND_IMAGE
    docker pull $FRONTEND_IMAGE
    
    # 启动服务
    print_info "启动服务..."
    cd $INSTALL_DIR
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 30
    
    print_success "安装完成"
}

################################################################################
# 验证函数
################################################################################

verify_installation() {
    print_header "验证安装..."
    
    # 检查容器状态
    print_info "检查容器状态..."
    docker-compose -f $INSTALL_DIR/docker/docker-compose.1panel.yml ps
    
    # 检查后端健康
    print_info "检查后端健康状态..."
    if curl -f http://localhost:$SERVER_PORT/health &> /dev/null; then
        print_success "后端服务正常"
    else
        print_error "后端服务异常"
        return 1
    fi
    
    # 检查前端
    print_info "检查前端服务..."
    if curl -f http://localhost/ &> /dev/null; then
        print_success "前端服务正常"
    else
        print_warning "前端服务可能需要更多时间启动"
    fi
    
    print_success "验证完成"
}

################################################################################
# 显示信息函数
################################################################################

show_info() {
    print_header "安装信息"
    
    echo "UpdateHub 已成功安装！"
    echo ""
    echo "部署方式: 使用预构建Docker镜像 (CI/CD)"
    echo ""
    echo "访问地址:"
    echo "  前端: http://$(hostname -I | awk '{print $1}')"
    echo "  后端: http://$(hostname -I | awk '{print $1}'):$SERVER_PORT"
    echo "  健康检查: http://$(hostname -I | awk '{print $1}'):$SERVER_PORT/health"
    echo ""
    echo "使用的镜像:"
    echo "  后端: $BACKEND_IMAGE"
    echo "  前端: $FRONTEND_IMAGE"
    echo ""
    echo "默认账户:"
    echo "  用户名: admin"
    echo "  密码: admin123"
    echo ""
    echo "⚠️  重要: 请立即修改默认密码！"
    echo ""
    echo "常用命令:"
    echo "  查看日志: docker-compose -f $INSTALL_DIR/docker/docker-compose.1panel.yml logs -f"
    echo "  停止服务: docker-compose -f $INSTALL_DIR/docker/docker-compose.1panel.yml down"
    echo "  启动服务: docker-compose -f $INSTALL_DIR/docker/docker-compose.1panel.yml up -d"
    echo "  重启服务: docker-compose -f $INSTALL_DIR/docker/docker-compose.1panel.yml restart"
    echo "  更新镜像: docker pull $BACKEND_IMAGE && docker pull $FRONTEND_IMAGE"
    echo ""
    echo "项目目录: $INSTALL_DIR"
    echo "备份目录: $BACKUP_DIR"
}

################################################################################
# 主函数
################################################################################

main() {
    print_header "UpdateHub 一键部署脚本 (CI/CD版本)"
    
    # 检查环境
    check_environment
    
    # 获取用户输入
    get_user_input
    
    # 安装项目
    install_project
    
    # 验证安装
    verify_installation
    
    # 显示信息
    show_info
    
    print_success "部署完成！"
}

# 运行主函数
main
