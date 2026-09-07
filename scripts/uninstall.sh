#!/bin/bash

################################################################################
# UpdateHub 卸载脚本
# 支持保留数据或完全卸载
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
PROJECT_DIR="/opt/UpdateHub"
BACKUP_DIR="/opt/UpdateHub/backups"

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
# 检查环境
################################################################################

check_environment() {
    print_header "检查环境..."
    
    # 检查项目目录
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "UpdateHub 未安装，项目目录不存在: $PROJECT_DIR"
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
# 停止服务
################################################################################

stop_services() {
    print_header "停止服务..."
    
    cd $PROJECT_DIR
    
    if [ -f "docker/docker-compose.1panel.yml" ]; then
        docker-compose -f docker/docker-compose.1panel.yml down
        print_success "服务已停止"
    else
        print_warning "未找到 docker-compose.1panel.yml"
    fi
}

################################################################################
# 清理容器
################################################################################

cleanup_containers() {
    print_header "清理容器..."
    
    # 停止并删除所有 UpdateHub 相关容器
    docker ps -a | grep updatehub | awk '{print $1}' | xargs -r docker rm -f
    
    print_success "容器已清理"
}

################################################################################
# 清理镜像
################################################################################

cleanup_images() {
    print_header "清理镜像..."
    
    # 删除 UpdateHub 相关镜像
    docker images | grep updatehub | awk '{print $3}' | xargs -r docker rmi -f
    
    print_success "镜像已清理"
}

################################################################################
# 清理数据卷
################################################################################

cleanup_volumes() {
    print_header "清理数据卷..."
    
    # 删除 UpdateHub 相关数据卷
    docker volume ls | grep updatehub | awk '{print $2}' | xargs -r docker volume rm -f
    
    print_success "数据卷已清理"
}

################################################################################
# 清理网络
################################################################################

cleanup_networks() {
    print_header "清理网络..."
    
    # 删除 UpdateHub 相关网络
    docker network ls | grep updatehub | awk '{print $2}' | xargs -r docker network rm
    
    print_success "网络已清理"
}

################################################################################
# 清理项目文件
################################################################################

cleanup_project_files() {
    print_header "清理项目文件..."
    
    read -p "确认删除项目目录 $PROJECT_DIR? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        sudo rm -rf $PROJECT_DIR
        print_success "项目文件已清理"
    else
        print_warning "跳过项目文件清理"
    fi
}

################################################################################
# 备份数据
################################################################################

backup_data() {
    print_header "备份数据..."
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR
    
    # 备份数据库
    if docker ps | grep -q updatehub-postgres; then
        print_info "备份数据库..."
        docker exec updatehub-postgres pg_dump -U updatehub updatehub > $BACKUP_DIR/db_backup_$(date +%Y%m%d_%H%M%S).sql
        print_success "数据库已备份"
    fi
    
    # 备份配置文件
    if [ -f "$PROJECT_DIR/docker/.env" ]; then
        print_info "备份配置文件..."
        cp $PROJECT_DIR/docker/.env $BACKUP_DIR/env_backup_$(date +%Y%m%d_%H%M%S)
        print_success "配置文件已备份"
    fi
    
    # 备份上传文件
    if [ -d "$PROJECT_DIR/backend/uploads" ]; then
        print_info "备份上传文件..."
        tar -czf $BACKUP_DIR/uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz $PROJECT_DIR/backend/uploads
        print_success "上传文件已备份"
    fi
    
    print_success "数据备份完成，备份位置: $BACKUP_DIR"
}

################################################################################
# 卸载选项1：保留数据，只删除服务
################################################################################

uninstall_keep_data() {
    print_header "卸载模式：保留数据，只删除服务"
    
    print_warning "此操作将："
    print_warning "- 停止所有服务"
    print_warning "- 删除 Docker 容器"
    print_warning "- 保留数据库数据"
    print_warning "- 保留配置文件"
    print_warning "- 保留上传文件"
    print_warning "- 保留 Docker 镜像"
    
    read -p "确认继续? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        print_info "取消卸载"
        return
    fi
    
    # 备份数据
    backup_data
    
    # 停止服务
    stop_services
    
    # 清理容器
    cleanup_containers
    
    print_success "卸载完成（数据已保留）"
    print_info "如需重新部署，可以直接启动服务"
}

################################################################################
# 卸载选项2：清除所有数据和服务
################################################################################

uninstall_all() {
    print_header "卸载模式：清除所有数据和服务"
    
    print_warning "此操作将："
    print_warning "- 停止所有服务"
    print_warning "- 删除 Docker 容器"
    print_warning "- 删除数据库数据"
    print_warning "- 删除配置文件"
    print_warning "- 删除上传文件"
    print_warning "- 删除 Docker 镜像"
    print_warning "- 删除项目文件"
    print_warning "- ⚠️ 此操作不可逆！"
    
    read -p "确认继续? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        print_info "取消卸载"
        return
    fi
    
    # 先备份数据（以防万一）
    backup_data
    
    # 停止服务
    stop_services
    
    # 清理容器
    cleanup_containers
    
    # 清理镜像
    cleanup_images
    
    # 清理数据卷
    cleanup_volumes
    
    # 清理网络
    cleanup_networks
    
    # 清理项目文件
    cleanup_project_files
    
    print_success "完全卸载完成"
    print_info "数据已备份到: $BACKUP_DIR"
}

################################################################################
# 卸载选项3：选择性清理
################################################################################

uninstall_selective() {
    print_header "卸载模式：选择性清理"
    
    while true; do
        echo ""
        echo "请选择要清理的内容："
        echo "1) 清理 Docker 容器"
        echo "2) 清理 Docker 镜像"
        echo "3) 清理数据卷（数据库数据）"
        echo "4) 清理配置文件"
        echo "5) 清理上传文件"
        echo "6) 清理项目文件"
        echo "7) 返回主菜单"
        
        read -p "请选择 (1-7): " choice
        
        case $choice in
            1)
                cleanup_containers
                ;;
            2)
                cleanup_images
                ;;
            3)
                read -p "确认清理数据卷（将删除数据库数据）? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    backup_data
                    cleanup_volumes
                fi
                ;;
            4)
                read -p "确认清理配置文件? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    backup_data
                    rm -f $PROJECT_DIR/docker/.env
                    rm -f $PROJECT_DIR/docker/nginx.conf
                    print_success "配置文件已清理"
                fi
                ;;
            5)
                read -p "确认清理上传文件? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    backup_data
                    rm -rf $PROJECT_DIR/backend/uploads
                    print_success "上传文件已清理"
                fi
                ;;
            6)
                cleanup_project_files
                ;;
            7)
                return
                ;;
            *)
                print_error "无效选择"
                ;;
        esac
    done
}

################################################################################
# 主菜单
################################################################################

main_menu() {
    while true; do
        print_header "UpdateHub 卸载管理"
        
        echo "1) 保留数据，只删除服务"
        echo "2) 清除所有数据和服务（⚠️ 不可逆）"
        echo "3) 选择性清理"
        echo "4) 退出"
        
        read -p "请选择卸载方式 (1-4): " choice
        
        case $choice in
            1)
                uninstall_keep_data
                ;;
            2)
                uninstall_all
                ;;
            3)
                uninstall_selective
                ;;
            4)
                print_success "退出卸载管理"
                exit 0
                ;;
            *)
                print_error "无效选择"
                ;;
        esac
        
        echo ""
        read -p "按 Enter 继续..."
    done
}

################################################################################
# 主函数
################################################################################

main() {
    # 检查环境
    check_environment
    
    # 显示警告
    print_warning "您即将卸载 UpdateHub"
    print_warning "请确保已备份重要数据"
    
    # 运行主菜单
    main_menu
}

# 运行主函数
main
