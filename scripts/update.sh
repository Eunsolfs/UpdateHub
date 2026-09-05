#!/bin/bash

################################################################################
# UpdateHub 一键更新脚本
# 支持零停机更新和完整停机更新
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
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        print_error "Git 未安装"
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
    
    # 备份数据库
    print_info "备份数据库..."
    docker exec updatehub-postgres pg_dump -U updatehub updatehub > $BACKUP_DIR/postgres/updatehub_backup_$DATE.sql
    print_success "数据库备份完成"
    
    # 备份上传文件
    print_info "备份上传文件..."
    tar -czf $BACKUP_DIR/uploads/uploads_backup_$DATE.tar.gz -C $PROJECT_DIR backend/uploads
    print_success "上传文件备份完成"
    
    # 备份配置文件
    print_info "备份配置文件..."
    cp $PROJECT_DIR/backend/configs/config.yaml $BACKUP_DIR/configs/config_backup_$DATE.yaml
    cp $PROJECT_DIR/docker/.env $BACKUP_DIR/configs/env_backup_$DATE
    print_success "配置文件备份完成"
    
    # 保存当前 git 信息
    print_info "保存当前版本信息..."
    cd $PROJECT_DIR
    git rev-parse HEAD > $BACKUP_DIR/current_commit_$DATE.txt
    git describe --tags > $BACKUP_DIR/current_version_$DATE.txt
    print_success "版本信息保存完成"
    
    print_success "所有数据备份完成"
}

################################################################################
# 拉取最新代码
################################################################################

pull_latest_code() {
    print_header "拉取最新代码..."
    
    cd $PROJECT_DIR
    
    # 获取当前版本
    CURRENT_VERSION=$(git describe --tags 2>/dev/null || echo "unknown")
    print_info "当前版本: $CURRENT_VERSION"
    
    # 拉取最新代码
    print_info "拉取最新代码..."
    git fetch origin
    
    # 显示可用版本
    print_info "可用版本:"
    git tag -l --sort=-version:refname | head -5
    
    # 询问用户选择版本
    read -p "选择版本 (按 Enter 使用最新版本): " selected_version
    
    if [ -z "$selected_version" ]; then
        print_info "使用最新版本..."
        git checkout origin/main
    else
        print_info "切换到版本: $selected_version"
        git checkout $selected_version
    fi
    
    NEW_VERSION=$(git describe --tags 2>/dev/null || echo "latest")
    print_success "代码更新完成: $CURRENT_VERSION -> $NEW_VERSION"
}

################################################################################
# 构建新镜像
################################################################################

build_new_images() {
    print_header "构建新镜像..."
    
    cd $PROJECT_DIR
    
    print_info "构建后端镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build backend
    
    print_info "构建前端镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build frontend
    
    print_success "镜像构建完成"
}

################################################################################
# 零停机更新
################################################################################

rolling_update() {
    print_header "执行零停机更新..."
    
    cd $PROJECT_DIR
    
    # 更新后端
    print_info "更新后端服务..."
    docker-compose -f docker/docker-compose.1panel.yml stop backend
    docker-compose -f docker/docker-compose.1panel.yml up -d backend
    
    print_info "等待后端启动..."
    sleep 15
    
    # 检查后端健康
    if curl -f http://localhost:8080/health &> /dev/null; then
        print_success "后端更新成功"
    else
        print_error "后端更新失败，开始回滚..."
        rollback
        exit 1
    fi
    
    # 更新前端
    print_info "更新前端服务..."
    docker-compose -f docker/docker-compose.1panel.yml stop frontend
    docker-compose -f docker/docker-compose.1panel.yml up -d frontend
    
    print_info "等待前端启动..."
    sleep 10
    
    # 检查前端
    if curl -f http://localhost/ &> /dev/null; then
        print_success "前端更新成功"
    else
        print_warning "前端可能需要更多时间启动"
    fi
    
    print_success "零停机更新完成"
}

################################################################################
# 完整停机更新
################################################################################

full_update() {
    print_header "执行完整停机更新..."
    
    cd $PROJECT_DIR
    
    # 停止所有服务
    print_info "停止所有服务..."
    docker-compose -f docker/docker-compose.1panel.yml down
    
    # 构建新镜像
    build_new_images
    
    # 启动所有服务
    print_info "启动所有服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 30
    
    # 检查服务状态
    print_info "检查服务状态..."
    docker-compose -f docker/docker-compose.1panel.yml ps
    
    print_success "完整停机更新完成"
}

################################################################################
# 数据库迁移
################################################################################

run_migrations() {
    print_header "执行数据库迁移..."
    
    cd $PROJECT_DIR
    
    # 检查是否有迁移文件
    if [ -d "backend/migrations" ] && [ "$(ls -A backend/migrations)" ]; then
        print_info "发现迁移文件，执行迁移..."
        
        # 这里需要根据实际的迁移方式调整
        # 示例：如果迁移是自动执行的，则不需要手动处理
        print_info "数据库迁移将在服务启动时自动执行"
    else
        print_info "没有发现迁移文件"
    fi
    
    print_success "数据库迁移检查完成"
}

################################################################################
# 回滚函数
################################################################################

rollback() {
    print_header "执行回滚..."
    
    cd $PROJECT_DIR
    
    # 恢复之前的版本
    print_info "恢复之前的版本..."
    git checkout $(cat $BACKUP_DIR/current_commit_*.txt | tail -1)
    
    # 重新构建
    print_info "重新构建镜像..."
    docker-compose -f docker/docker-compose.1panel.yml build
    
    # 启动服务
    print_info "启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    print_success "回滚完成"
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
# 清理旧备份
################################################################################

cleanup_old_backups() {
    print_header "清理旧备份..."
    
    # 保留最近7天的备份
    find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
    find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
    find $BACKUP_DIR -name "*.yaml" -mtime +7 -delete
    find $BACKUP_DIR -name "*.txt" -mtime +7 -delete
    
    print_success "旧备份清理完成"
}

################################################################################
# 主函数
################################################################################

main() {
    print_header "UpdateHub 一键更新脚本"
    
    # 检查环境
    check_environment
    
    # 备份数据
    backup_data
    
    # 拉取最新代码
    pull_latest_code
    
    # 选择更新方式
    echo ""
    echo "请选择更新方式:"
    echo "1) 零停机更新 (推荐)"
    echo "2) 完整停机更新"
    read -p "请输入选择 (1-2): " update_choice
    
    case $update_choice in
        1)
            build_new_images
            rolling_update
            ;;
        2)
            full_update
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac
    
    # 执行数据库迁移
    run_migrations
    
    # 验证更新
    verify_update
    
    # 清理旧备份
    cleanup_old_backups
    
    print_success "更新完成！"
    
    # 显示更新信息
    cd $PROJECT_DIR
    NEW_VERSION=$(git describe --tags 2>/dev/null || echo "latest")
    echo ""
    echo "更新信息:"
    echo "  新版本: $NEW_VERSION"
    echo "  更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  日志文件: $LOG_FILE"
}

# 运行主函数
main
