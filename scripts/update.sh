#!/bin/bash

################################################################################
# UpdateHub 一键更新脚本 (CI/CD版本)
# 使用预构建的Docker镜像，只需拉取新版本镜像
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_DIR="/opt/UpdateHub"
BACKUP_DIR="/opt/UpdateHub/backups"
LOG_FILE="/opt/UpdateHub/update.log"

# 颜色函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> $LOG_FILE
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> $LOG_FILE
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >> $LOG_FILE
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> $LOG_FILE
}

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== $1 =====" >> $LOG_FILE
}

################################################################################
# 环境检查函数
################################################################################

check_environment() {
    print_header "检查环境..."
    
    # 检查项目目录
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装"
        exit 1
    fi
    
    print_success "环境检查完成"
}

################################################################################
# 备份函数
################################################################################

backup_data() {
    print_header "备份数据..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR
    
    # 备份配置文件
    print_info "备份配置文件..."
    if [ -f "$PROJECT_DIR/backend/configs/config.yaml" ]; then
        cp $PROJECT_DIR/backend/configs/config.yaml $BACKUP_DIR/configs/config_backup_$DATE.yaml
    fi
    if [ -f "$PROJECT_DIR/docker/.env" ]; then
        cp $PROJECT_DIR/docker/.env $BACKUP_DIR/configs/env_backup_$DATE
    fi
    
    # 备份上传文件
    print_info "备份上传文件..."
    if [ -d "$PROJECT_DIR/backend/uploads" ]; then
        tar -czf $BACKUP_DIR/uploads/uploads_backup_$DATE.tar.gz -C $PROJECT_DIR backend/uploads
    fi
    
    # 保存当前镜像信息
    print_info "保存当前镜像信息..."
    cd $PROJECT_DIR
    docker images | grep updatehub > $BACKUP_DIR/current_images_$DATE.txt
    
    print_success "数据备份完成"
}

################################################################################
# 拉取新镜像
################################################################################

pull_new_images() {
    print_header "拉取新镜像..."
    
    cd $PROJECT_DIR
    
    # 从环境变量读取镜像地址
    source docker/.env
    
    BACKEND_IMAGE=${BACKEND_IMAGE:-ghcr.io/your-username/updatehub-backend:latest}
    FRONTEND_IMAGE=${FRONTEND_IMAGE:-ghcr.io/your-username/updatehub-frontend:latest}
    
    print_info "拉取后端镜像: $BACKEND_IMAGE"
    docker pull $BACKEND_IMAGE
    
    print_info "拉取前端镜像: $FRONTEND_IMAGE"
    docker pull $FRONTEND_IMAGE
    
    print_success "镜像拉取完成"
}

################################################################################
# 更新服务
################################################################################

update_services() {
    print_header "更新服务..."
    
    cd $PROJECT_DIR
    
    # 选择更新方式
    echo ""
    echo "请选择更新方式:"
    echo "1) 零停机更新 (推荐)"
    echo "2) 完整停机更新"
    read -p "请输入选择 (1-2): " update_choice
    
    case $update_choice in
        1)
            print_info "执行零停机更新..."
            docker-compose -f docker/docker-compose.1panel.yml pull
            docker-compose -f docker/docker-compose.1panel.yml up -d
            ;;
        2)
            print_info "执行完整停机更新..."
            docker-compose -f docker/docker-compose.1panel.yml down
            docker-compose -f docker/docker-compose.1panel.yml pull
            docker-compose -f docker/docker-compose.1panel.yml up -d
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 30
    
    print_success "服务更新完成"
}

################################################################################
# 验证更新
################################################################################

verify_update() {
    print_header "验证更新..."
    
    # 检查容器状态
    print_info "检查容器状态..."
    docker-compose -f $PROJECT_DIR/docker/docker-compose.1panel.yml ps
    
    # 检查后端健康
    print_info "检查后端健康状态..."
    if curl -f http://localhost:8080/health &> /dev/null; then
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
# 主函数
################################################################################

main() {
    print_header "UpdateHub 一键更新脚本 (CI/CD版本)"
    
    # 检查环境
    check_environment
    
    # 备份数据
    backup_data
    
    # 拉取新镜像
    pull_new_images
    
    # 更新服务
    update_services
    
    # 验证更新
    verify_update
    
    print_success "更新完成！"
    
    # 显示更新信息
    cd $PROJECT_DIR
    source docker/.env
    echo ""
    echo "更新信息:"
    echo "  后端镜像: $BACKEND_IMAGE"
    echo "  前端镜像: $FRONTEND_IMAGE"
    echo "  更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  日志文件: $LOG_FILE"
}

# 运行主函数
main
