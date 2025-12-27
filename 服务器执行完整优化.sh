#!/bin/bash

# 立即执行优化方案 - 完整脚本
# 功能：增加数据盘、迁移图片、压缩图片

set -e

echo "=========================================="
echo "  立即执行优化方案"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 错误：请使用 sudo 运行此脚本${NC}"
    exit 1
fi

# 配置变量
DATA_DISK="/dev/vdb"  # 根据实际情况修改
MOUNT_POINT="/mnt/data"
UPLOAD_DIR="/var/www/activities_management/backend/uploads"
NEW_UPLOAD_DIR="$MOUNT_POINT/uploads"

echo -e "${YELLOW}⚠️  此脚本将执行以下操作：${NC}"
echo "  1. 格式化数据盘（如果未格式化）"
echo "  2. 挂载数据盘到 $MOUNT_POINT"
echo "  3. 迁移图片到数据盘"
echo "  4. 创建软链接"
echo "  5. 更新 Nginx 配置"
echo "  6. 压缩现有图片"
echo ""
read -p "是否继续？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# ==========================================
# 步骤 1: 检查并挂载数据盘
# ==========================================
echo -e "${YELLOW}📋 步骤 1: 检查数据盘...${NC}"

# 检查磁盘是否存在
if [ ! -b "$DATA_DISK" ]; then
    echo -e "${RED}❌ 错误：数据盘 $DATA_DISK 不存在${NC}"
    echo "   请检查："
    echo "   1. 是否在云控制台创建并挂载了云硬盘"
    echo "   2. 磁盘设备名称是否正确（使用 fdisk -l 查看）"
    exit 1
fi

echo -e "${GREEN}✅ 找到数据盘: $DATA_DISK${NC}"

# 检查是否已格式化
if ! blkid "$DATA_DISK" > /dev/null 2>&1; then
    echo -e "${YELLOW}📋 格式化数据盘...${NC}"
    mkfs.ext4 -F "$DATA_DISK"
    echo -e "${GREEN}✅ 格式化完成${NC}"
else
    echo -e "${GREEN}✅ 数据盘已格式化${NC}"
fi

# 创建挂载点
mkdir -p "$MOUNT_POINT"

# 检查是否已挂载
if mountpoint -q "$MOUNT_POINT"; then
    echo -e "${GREEN}✅ 数据盘已挂载${NC}"
else
    echo -e "${YELLOW}📋 挂载数据盘...${NC}"
    mount "$DATA_DISK" "$MOUNT_POINT"
    echo -e "${GREEN}✅ 挂载完成${NC}"
fi

# 设置开机自动挂载
if ! grep -q "$DATA_DISK.*$MOUNT_POINT" /etc/fstab; then
    echo "$DATA_DISK $MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
    echo -e "${GREEN}✅ 已设置开机自动挂载${NC}"
fi

# ==========================================
# 步骤 2: 迁移图片到数据盘
# ==========================================
echo -e "${YELLOW}📋 步骤 2: 迁移图片到数据盘...${NC}"

# 创建新的上传目录
mkdir -p "$NEW_UPLOAD_DIR"
chown -R www-data:www-data "$NEW_UPLOAD_DIR"
chmod -R 755 "$NEW_UPLOAD_DIR"

# 检查原目录是否存在
if [ ! -d "$UPLOAD_DIR" ]; then
    echo -e "${YELLOW}⚠️  原上传目录不存在，创建新目录${NC}"
    mkdir -p "$UPLOAD_DIR"
    chown -R www-data:www-data "$UPLOAD_DIR"
    chmod -R 755 "$UPLOAD_DIR"
fi

# 备份原目录
BACKUP_DIR="${UPLOAD_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
if [ -d "$UPLOAD_DIR" ] && [ "$(ls -A $UPLOAD_DIR 2>/dev/null)" ]; then
    echo -e "${YELLOW}📋 备份原目录...${NC}"
    cp -r "$UPLOAD_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}✅ 备份完成: $BACKUP_DIR${NC}"
    
    # 迁移文件
    echo -e "${YELLOW}📋 迁移文件（这可能需要一些时间）...${NC}"
    rsync -av --progress "$UPLOAD_DIR/" "$NEW_UPLOAD_DIR/"
    echo -e "${GREEN}✅ 迁移完成${NC}"
else
    echo -e "${GREEN}✅ 原目录为空，无需迁移${NC}"
fi

# 创建软链接
if [ -L "$UPLOAD_DIR" ]; then
    echo -e "${GREEN}✅ 软链接已存在${NC}"
elif [ -d "$UPLOAD_DIR" ]; then
    echo -e "${YELLOW}📋 创建软链接...${NC}"
    mv "$UPLOAD_DIR" "${UPLOAD_DIR}.old"
    ln -s "$NEW_UPLOAD_DIR" "$UPLOAD_DIR"
    echo -e "${GREEN}✅ 软链接已创建${NC}"
else
    ln -s "$NEW_UPLOAD_DIR" "$UPLOAD_DIR"
    echo -e "${GREEN}✅ 软链接已创建${NC}"
fi

# ==========================================
# 步骤 3: 更新 Nginx 配置
# ==========================================
echo -e "${YELLOW}📋 步骤 3: 更新 Nginx 配置...${NC}"

NGINX_CONFIG="/etc/nginx/sites-available/activities_management"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ 错误：Nginx 配置文件不存在${NC}"
    exit 1
fi

# 备份配置
cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# 更新 root 路径
sed -i "s|root /var/www/activities_management/backend;|root $MOUNT_POINT;|g" "$NGINX_CONFIG"

# 测试配置
if nginx -t 2>/dev/null; then
    echo -e "${GREEN}✅ Nginx 配置测试通过${NC}"
    systemctl reload nginx
    echo -e "${GREEN}✅ Nginx 已重载${NC}"
else
    echo -e "${RED}❌ Nginx 配置测试失败，正在恢复备份...${NC}"
    cp "${NGINX_CONFIG}.backup."* "$NGINX_CONFIG" 2>/dev/null || true
    exit 1
fi

# ==========================================
# 步骤 4: 安装压缩工具
# ==========================================
echo -e "${YELLOW}📋 步骤 4: 安装图片压缩工具...${NC}"

if ! command -v jpegoptim &> /dev/null || ! command -v optipng &> /dev/null; then
    apt update
    apt install -y jpegoptim optipng imagemagick
    echo -e "${GREEN}✅ 压缩工具已安装${NC}"
else
    echo -e "${GREEN}✅ 压缩工具已安装${NC}"
fi

# ==========================================
# 步骤 5: 压缩图片
# ==========================================
echo -e "${YELLOW}📋 步骤 5: 压缩图片（这可能需要较长时间）...${NC}"

LOG_FILE="/var/log/image_compress.log"
TOTAL_FILES=0
COMPRESSED_FILES=0

# 压缩函数
compress_image() {
    local file="$1"
    local ext="${file##*.}"
    local size_before=$(stat -c%s "$file" 2>/dev/null || echo 0)
    
    if [ "$size_before" -eq 0 ]; then
        return
    fi
    
    case "${ext,,}" in
        jpg|jpeg)
            jpegoptim --max=85 --strip-all --preserve --force "$file" 2>/dev/null || true
            ;;
        png)
            optipng -o2 -quiet -force "$file" 2>/dev/null || true
            ;;
        gif)
            convert "$file" -strip "$file.tmp" 2>/dev/null && mv "$file.tmp" "$file" 2>/dev/null || true
            ;;
    esac
    
    local size_after=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if [ "$size_after" -lt "$size_before" ]; then
        COMPRESSED_FILES=$((COMPRESSED_FILES + 1))
    fi
    TOTAL_FILES=$((TOTAL_FILES + 1))
}

# 导出函数供 find 使用
export -f compress_image
export COMPRESSED_FILES TOTAL_FILES

# 压缩所有图片
find "$NEW_UPLOAD_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -exec bash -c 'compress_image "$0"' {} \; | tee "$LOG_FILE"

echo -e "${GREEN}✅ 压缩完成${NC}"
echo "   日志文件: $LOG_FILE"

# ==========================================
# 完成
# ==========================================
echo ""
echo -e "${GREEN}=========================================="
echo "  ✅ 优化完成！"
echo "==========================================${NC}"
echo ""
echo "📊 优化内容："
echo "  ✅ 数据盘已挂载: $MOUNT_POINT"
echo "  ✅ 图片已迁移到数据盘"
echo "  ✅ Nginx 配置已更新"
echo "  ✅ 图片已压缩"
echo ""
echo "📝 重要信息："
echo "  - 备份目录: $BACKUP_DIR"
echo "  - 新上传目录: $NEW_UPLOAD_DIR"
echo "  - 压缩日志: $LOG_FILE"
echo ""
echo "🧪 验证方法："
echo "  1. 检查挂载: df -h | grep $MOUNT_POINT"
echo "  2. 检查软链接: ls -la $UPLOAD_DIR"
echo "  3. 访问网站，检查图片是否正常显示"
echo ""

