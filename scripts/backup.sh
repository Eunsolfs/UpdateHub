#!/bin/bash

################################################################################
# UpdateHub 备份脚本
# 自动备份数据库、上传文件和配置文件
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
RETENTION_DAYS=7  # 保留天数

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
# 环境检查
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
    
    # 检查 PostgreSQL 容器
    if ! docker ps | grep -q updatehub-postgres; then
        print_error "PostgreSQL 容器未运行"
        exit 1
    fi
    
    print_success "环境检查完成"
}

################################################################################
# 创建备份目录
################################################################################

create_backup_dir() {
    print_info "创建备份目录..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/$DATE"
    
    mkdir -p "$BACKUP_PATH/postgres"
    mkdir -p "$BACKUP_PATH/uploads"
    mkdir -p "$BACKUP_PATH/configs"
    
    print_success "备份目录创建完成: $BACKUP_PATH"
}

################################################################################
# 备份数据库
################################################################################

backup_database() {
    print_header "备份数据库..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/$DATE/postgres/updatehub_backup_$DATE.sql"
    
    print_info "正在备份数据库..."
    docker exec updatehub-postgres pg_dump -U updatehub updatehub > "$BACKUP_FILE"
    
    # 压缩备份文件
    gzip "$BACKUP_FILE"
    
    # 计算文件大小
    FILE_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
    
    print_success "数据库备份完成: $BACKUP_FILE.gz ($FILE_SIZE)"
}

################################################################################
# 备份上传文件
################################################################################

backup_uploads() {
    print_header "备份上传文件..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/$DATE/uploads/uploads_backup_$DATE.tar.gz"
    
    if [ -d "$PROJECT_DIR/backend/uploads" ]; then
        print_info "正在备份上传文件..."
        tar -czf "$BACKUP_FILE" -C "$PROJECT_DIR" backend/uploads
        
        # 计算文件大小
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        
        print_success "上传文件备份完成: $BACKUP_FILE ($FILE_SIZE)"
    else
        print_warning "上传目录不存在，跳过"
    fi
}

################################################################################
# 备份配置文件
################################################################################

backup_configs() {
    print_header "备份配置文件..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    
    # 备份后端配置
    if [ -f "$PROJECT_DIR/backend/configs/config.yaml" ]; then
        cp "$PROJECT_DIR/backend/configs/config.yaml" "$BACKUP_DIR/$DATE/configs/config_backup_$DATE.yaml"
        print_success "后端配置备份完成"
    fi
    
    # 备份环境变量
    if [ -f "$PROJECT_DIR/docker/.env" ]; then
        cp "$PROJECT_DIR/docker/.env" "$BACKUP_DIR/$DATE/configs/env_backup_$DATE"
        print_success "环境变量备份完成"
    fi
    
    # 备份 Docker Compose 配置
    if [ -f "$PROJECT_DIR/docker/docker-compose.1panel.yml" ]; then
        cp "$PROJECT_DIR/docker/docker-compose.1panel.yml" "$BACKUP_DIR/$DATE/configs/docker-compose_backup_$DATE.yml"
        print_success "Docker Compose 配置备份完成"
    fi
}

################################################################################
# 备份版本信息
################################################################################

backup_version_info() {
    print_header "备份版本信息..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    
    cd $PROJECT_DIR
    
    # 备份当前 commit
    git rev-parse HEAD > "$BACKUP_DIR/$DATE/current_commit.txt"
    
    # 备份当前版本标签
    git describe --tags > "$BACKUP_DIR/$DATE/current_version.txt" 2>/dev/null || echo "unknown" > "$BACKUP_DIR/$DATE/current_version.txt"
    
    # 备份分支信息
    git branch --show-current > "$BACKUP_DIR/$DATE/current_branch.txt"
    
    print_success "版本信息备份完成"
}

################################################################################
# 清理旧备份
################################################################################

cleanup_old_backups() {
    print_header "清理旧备份..."
    
    # 删除超过保留天数的备份
    find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null || true
    
    # 统计当前备份数量
    BACKUP_COUNT=$(find "$BACKUP_DIR" -type d -mindepth 1 -maxdepth 1 | wc -l)
    
    print_success "旧备份清理完成，当前保留 $BACKUP_COUNT 个备份"
}

################################################################################
# 生成备份报告
################################################################################

generate_backup_report() {
    print_header "生成备份报告..."
    
    DATE=$(date +%Y%m%d_%H%M%S)
    REPORT_FILE="$BACKUP_DIR/$DATE/backup_report.txt"
    
    cat > "$REPORT_FILE" << EOF
UpdateHub 备份报告
==================

备份时间: $(date '+%Y-%m-%d %H:%M:%S')
备份目录: $BACKUP_DIR/$DATE

备份内容:
- 数据库: updatehub_backup_$DATE.sql.gz
- 上传文件: uploads_backup_$DATE.tar.gz
- 配置文件: config_backup_$DATE.yaml, env_backup_$DATE
- 版本信息: current_commit.txt, current_version.txt

项目信息:
- 当前分支: $(git branch --show-current)
- 当前版本: $(git describe --tags 2>/dev/null || echo "unknown")
- 当前提交: $(git rev-parse HEAD)

系统信息:
- 主机名: $(hostname)
- 操作系统: $(uname -a)
- Docker 版本: $(docker --version)
- Docker Compose 版本: $(docker-compose --version)

存储信息:
- 总备份大小: $(du -sh "$BACKUP_DIR/$DATE" | cut -f1)
- 可用磁盘空间: $(df -h "$BACKUP_DIR" | tail -1 | awk '{print $4}')

保留策略: 保留最近 $RETENTION_DAYS 天的备份
EOF
    
    print_success "备份报告生成完成: $REPORT_FILE"
}

################################################################################
# 主函数
################################################################################

main() {
    print_header "UpdateHub 备份脚本"
    
    # 检查环境
    check_environment
    
    # 创建备份目录
    create_backup_dir
    
    # 执行备份
    backup_database
    backup_uploads
    backup_configs
    backup_version_info
    
    # 生成报告
    generate_backup_report
    
    # 清理旧备份
    cleanup_old_backups
    
    print_success "备份完成！"
    
    # 显示备份信息
    DATE=$(date +%Y%m%d_%H%M%S)
    echo ""
    echo "备份信息:"
    echo "  备份目录: $BACKUP_DIR/$DATE"
    echo "  备份时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  保留策略: $RETENTION_DAYS 天"
    echo "  备份大小: $(du -sh "$BACKUP_DIR/$DATE" | cut -f1)"
}

# 运行主函数
main
