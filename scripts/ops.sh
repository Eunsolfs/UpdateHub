#!/bin/bash

################################################################################
# UpdateHub 运维脚本
# 用于修改系统配置：管理员账户、端口、镜像源等
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
ENV_FILE="$PROJECT_DIR/docker/.env"
BACKUP_DIR="$PROJECT_DIR/backups"

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
# 备份当前配置
################################################################################

backup_config() {
    print_header "备份当前配置..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR
    
    # 备份 .env 文件
    if [ -f "$ENV_FILE" ]; then
        cp $ENV_FILE $BACKUP_DIR/env_backup_$DATE
        print_success "配置文件已备份到: $BACKUP_DIR/env_backup_$DATE"
    else
        print_warning "未找到 .env 文件"
    fi
}

################################################################################
# 修改管理员密码
################################################################################

change_admin_password() {
    print_header "修改管理员密码"
    
    print_info "修改管理员密码需要在 UpdateHub Web 界面中操作"
    print_info "或者直接修改数据库中的用户记录"
    
    echo ""
    echo "选项:"
    echo "1) 通过 Web 界面修改（推荐）"
    echo "2) 通过数据库直接修改"
    echo "3) 跳过"
    
    read -p "请选择 (1-3): " choice
    
    case $choice in
        1)
            print_info "请在浏览器中访问 UpdateHub Web 界面"
            print_info "路径: 系统设置 -> 用户管理 -> 修改密码"
            ;;
        2)
            print_warning "直接修改数据库存在风险，请谨慎操作"
            read -p "确认继续? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                # 进入 PostgreSQL 容器
                docker exec -it updatehub-postgres psql -U updatehub -d updatehub
            fi
            ;;
        3)
            print_info "跳过密码修改"
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
}

################################################################################
# 修改端口号
################################################################################

change_port() {
    print_header "修改端口号"
    
    print_info "当前后端端口配置:"
    grep "SERVER_PORT" $ENV_FILE || echo "未找到端口配置"
    
    echo ""
    read -p "请输入新的后端端口 (默认 8080): " new_port
    
    if [ -z "$new_port" ]; then
        new_port="8080"
    fi
    
    # 备份配置
    backup_config
    
    # 修改端口
    if grep -q "SERVER_PORT" $ENV_FILE; then
        sed -i "s/SERVER_PORT=.*/SERVER_PORT=$new_port/" $ENV_FILE
    else
        echo "SERVER_PORT=$new_port" >> $ENV_FILE
    fi
    
    print_success "后端端口已修改为: $new_port"
    print_info "需要重启服务才能生效:"
    echo "  cd $PROJECT_DIR"
    echo "  docker-compose -f docker/docker-compose.1panel.yml restart"
}

################################################################################
# 修改镜像源
################################################################################

change_image_source() {
    print_header "修改镜像源"
    
    print_info "当前镜像配置:"
    grep "BACKEND_IMAGE" $ENV_FILE || echo "未找到后端镜像配置"
    grep "FRONTEND_IMAGE" $ENV_FILE || echo "未找到前端镜像配置"
    
    echo ""
    echo "选项:"
    echo "1) 使用 latest 标签（最新版本）"
    echo "2) 使用特定版本标签（如 v1.0.0）"
    echo "3) 自定义镜像地址"
    echo "4) 跳过"
    
    read -p "请选择 (1-4): " choice
    
    case $choice in
        1)
            read -p "输入你的 GitHub 用户名（小写）: " username
            username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
            
            # 备份配置
            backup_config
            
            # 修改镜像
            if grep -q "BACKEND_IMAGE" $ENV_FILE; then
                sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:latest|" $ENV_FILE
            else
                echo "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:latest" >> $ENV_FILE
            fi
            
            if grep -q "FRONTEND_IMAGE" $ENV_FILE; then
                sed -i "s|FRONTEND_IMAGE=.*|FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:latest|" $ENV_FILE
            else
                echo "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:latest" >> $ENV_FILE
            fi
            
            print_success "镜像源已修改为 latest 标签"
            ;;
        2)
            read -p "输入版本号 (如 v1.0.0): " version
            read -p "输入你的 GitHub 用户名（小写）: " username
            username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
            
            # 备份配置
            backup_config
            
            # 修改镜像
            if grep -q "BACKEND_IMAGE" $ENV_FILE; then
                sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:$version|" $ENV_FILE
            else
                echo "BACKEND_IMAGE=ghcr.io/$username/updatehub-backend:$version" >> $ENV_FILE
            fi
            
            if grep -q "FRONTEND_IMAGE" $ENV_FILE; then
                sed -i "s|FRONTEND_IMAGE=.*|FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:$version|" $ENV_FILE
            else
                echo "FRONTEND_IMAGE=ghcr.io/$username/updatehub-frontend:$version" >> $ENV_FILE
            fi
            
            print_success "镜像源已修改为: $version"
            ;;
        3)
            read -p "输入后端镜像地址: " backend_image
            read -p "输入前端镜像地址: " frontend_image
            
            # 备份配置
            backup_config
            
            # 修改镜像
            if grep -q "BACKEND_IMAGE" $ENV_FILE; then
                sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$backend_image|" $ENV_FILE
            else
                echo "BACKEND_IMAGE=$backend_image" >> $ENV_FILE
            fi
            
            if grep -q "FRONTEND_IMAGE" $ENV_FILE; then
                sed -i "s|FRONTEND_IMAGE=.*|FRONTEND_IMAGE=$frontend_image|" $ENV_FILE
            else
                echo "FRONTEND_IMAGE=$frontend_image" >> $ENV_FILE
            fi
            
            print_success "镜像源已修改为自定义地址"
            ;;
        4)
            print_info "跳过镜像源修改"
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
    
    print_info "需要重启服务才能生效:"
    echo "  cd $PROJECT_DIR"
    echo "  docker-compose -f docker/docker-compose.1panel.yml up -d"
}

################################################################################
# 修改数据库密码
################################################################################

change_database_password() {
    print_header "修改数据库密码"
    
    print_warning "修改数据库密码需要停止服务并重新创建数据库"
    print_info "请确保已备份数据库"
    
    read -p "确认继续? (y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        print_info "取消操作"
        return
    fi
    
    # 备份配置
    backup_config
    
    # 备份数据库
    print_info "备份数据库..."
    docker exec updatehub-postgres pg_dump -U updatehub updatehub > $BACKUP_DIR/db_backup_$(date +%Y%m%d_%H%M%S).sql
    
    # 停止服务
    print_info "停止服务..."
    cd $PROJECT_DIR
    docker-compose -f docker/docker-compose.1panel.yml down
    
    # 修改密码
    read -p "输入新的数据库密码: " new_password
    
    # 修改 .env 文件
    if grep -q "POSTGRES_PASSWORD" $ENV_FILE; then
        sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$new_password/" $ENV_FILE
    else
        echo "POSTGRES_PASSWORD=$new_password" >> $ENV_FILE
    fi
    
    # 删除旧的数据库卷
    print_warning "删除旧的数据库卷..."
    docker volume rm docker_postgres_data
    
    # 重新启动服务
    print_info "重新启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    print_success "数据库密码已修改"
    print_info "数据库已重新创建，需要重新初始化数据"
}

################################################################################
# 修改 JWT 密钥
################################################################################

change_jwt_secret() {
    print_header "修改 JWT 密钥"
    
    print_info "修改 JWT 密钥会使所有现有 Token 失效"
    print_info "用户需要重新登录"
    
    read -p "确认继续? (y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        print_info "取消操作"
        return
    fi
    
    # 备份配置
    backup_config
    
    # 生成随机密钥
    new_secret=$(openssl rand -hex 32)
    
    # 修改 JWT 密钥
    if grep -q "JWT_SECRET" $ENV_FILE; then
        sed -i "s/JWT_SECRET=.*/JWT_SECRET=$new_secret/" $ENV_FILE
    else
        echo "JWT_SECRET=$new_secret" >> $ENV_FILE
    fi
    
    print_success "JWT 密钥已修改"
    print_info "用户需要重新登录"
    print_info "需要重启服务才能生效:"
    echo "  cd $PROJECT_DIR"
    echo "  docker-compose -f docker/docker-compose.1panel.yml restart"
}

################################################################################
# 配置 Docker 镜像加速
################################################################################

configure_docker_acceleration() {
    print_header "配置 Docker 镜像加速"
    
    print_info "配置 Docker 镜像加速可以显著提高镜像下载速度"
    
    echo ""
    echo "推荐国内镜像源:"
    echo "1) 阿里云镜像加速"
    echo "2) 腾讯云镜像加速"
    echo "3) 中科大镜像加速"
    echo "4) 网易镜像加速"
    echo "5) 自定义镜像源"
    echo "6) 跳过"
    
    read -p "请选择 (1-6): " choice
    
    case $choice in
        1)
            mirror="https://mirror.ccs.tencentyun.com"
            ;;
        2)
            mirror="https://mirror.ccs.tencentyun.com"
            ;;
        3)
            mirror="https://docker.mirrors.ustc.edu.cn"
            ;;
        4)
            mirror="https://hub-mirror.c.163.com"
            ;;
        5)
            read -p "输入自定义镜像源地址: " mirror
            ;;
        6)
            print_info "跳过镜像加速配置"
            return
            ;;
        *)
            print_error "无效选择"
            return
            ;;
    esac
    
    # 创建 Docker 配置目录
    sudo mkdir -p /etc/docker
    
    # 配置镜像加速
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "$mirror"
  ]
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
# 重启服务
################################################################################

restart_services() {
    print_header "重启服务"
    
    cd $PROJECT_DIR
    
    print_info "停止服务..."
    docker-compose -f docker/docker-compose.1panel.yml down
    
    print_info "启动服务..."
    docker-compose -f docker/docker-compose.1panel.yml up -d
    
    print_success "服务已重启"
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    print_info "检查服务状态..."
    docker-compose -f docker/docker-compose.1panel.yml ps
}

################################################################################
# 查看当前配置
################################################################################

show_config() {
    print_header "当前配置"
    
    if [ -f "$ENV_FILE" ]; then
        echo "=== 环境变量配置 ==="
        cat $ENV_FILE
    else
        print_warning "未找到 .env 文件"
    fi
    
    echo ""
    echo "=== 容器状态 ==="
    cd $PROJECT_DIR
    docker-compose -f docker/docker-compose.1panel.yml ps
}

################################################################################
# 主菜单
################################################################################

main_menu() {
    while true; do
        print_header "UpdateHub 运维管理"
        
        echo "1) 修改管理员密码"
        echo "2) 修改端口号"
        echo "3) 修改镜像源"
        echo "4) 修改数据库密码"
        echo "5) 修改 JWT 密钥"
        echo "6) 配置 Docker 镜像加速"
        echo "7) 重启服务"
        echo "8) 查看当前配置"
        echo "9) 退出"
        
        read -p "请选择操作 (1-9): " choice
        
        case $choice in
            1)
                change_admin_password
                ;;
            2)
                change_port
                ;;
            3)
                change_image_source
                ;;
            4)
                change_database_password
                ;;
            5)
                change_jwt_secret
                ;;
            6)
                configure_docker_acceleration
                ;;
            7)
                restart_services
                ;;
            8)
                show_config
                ;;
            9)
                print_success "退出运维管理"
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
    # 检查项目目录
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    # 检查 .env 文件
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "未找到 .env 文件，将创建默认配置"
        cp $PROJECT_DIR/docker/.env.example $ENV_FILE
    fi
    
    # 运行主菜单
    main_menu
}

# 运行主函数
main
