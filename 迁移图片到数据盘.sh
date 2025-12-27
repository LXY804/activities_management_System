#!/bin/bash

# 迁移图片到数据盘脚本

set -e

echo "=========================================="
echo "  迁移图片到数据盘"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置变量
UPLOAD_DIR="/var/www/activities_management/backend/uploads"
NEW_UPLOAD_DIR="/mnt/data/uploads"
MOUNT_POINT="/mnt/data"

# 检查数据盘是否挂载
if ! mountpoint -q "$MOUNT_POINT"; then
    echo -e "${RED}❌ 错误：数据盘未挂载，请先挂载数据盘${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 数据盘已挂载: $MOUNT_POINT${NC}"

# 创建新的上传目录
echo -e "${YELLOW}📋 创建新的上传目录...${NC}"
mkdir -p "$NEW_UPLOAD_DIR"
chown -R www-data:www-data "$NEW_UPLOAD_DIR"
chmod -R 755 "$NEW_UPLOAD_DIR"
echo -e "${GREEN}✅ 目录已创建${NC}"

# 检查原目录是否存在
if [ ! -d "$UPLOAD_DIR" ]; then
    echo -e "${YELLOW}⚠️  原上传目录不存在，创建新目录${NC}"
    mkdir -p "$UPLOAD_DIR"
    chown -R www-data:www-data "$UPLOAD_DIR"
    chmod -R 755 "$UPLOAD_DIR"
fi

# 检查原目录是否有文件
if [ "$(ls -A $UPLOAD_DIR 2>/dev/null)" ]; then
    # 备份原目录
    BACKUP_DIR="${UPLOAD_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}📋 备份原目录...${NC}"
    cp -r "$UPLOAD_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}✅ 备份完成: $BACKUP_DIR${NC}"
    
    # 迁移文件
    echo -e "${YELLOW}📋 迁移文件（这可能需要一些时间）...${NC}"
    rsync -av --progress "$UPLOAD_DIR/" "$NEW_UPLOAD_DIR/"
    echo -e "${GREEN}✅ 迁移完成${NC}"
    
    # 验证文件数量
    OLD_COUNT=$(find "$UPLOAD_DIR" -type f | wc -l)
    NEW_COUNT=$(find "$NEW_UPLOAD_DIR" -type f | wc -l)
    echo "原目录文件数: $OLD_COUNT"
    echo "新目录文件数: $NEW_COUNT"
    
    if [ "$OLD_COUNT" -eq "$NEW_COUNT" ]; then
        echo -e "${GREEN}✅ 文件数量一致，迁移成功${NC}"
    else
        echo -e "${YELLOW}⚠️  文件数量不一致，请检查${NC}"
    fi
else
    echo -e "${GREEN}✅ 原目录为空，无需迁移${NC}"
fi

# 创建软链接
echo -e "${YELLOW}📋 创建软链接...${NC}"
if [ -L "$UPLOAD_DIR" ]; then
    echo -e "${GREEN}✅ 软链接已存在${NC}"
elif [ -d "$UPLOAD_DIR" ]; then
    mv "$UPLOAD_DIR" "${UPLOAD_DIR}.old"
    ln -s "$NEW_UPLOAD_DIR" "$UPLOAD_DIR"
    echo -e "${GREEN}✅ 软链接已创建${NC}"
else
    ln -s "$NEW_UPLOAD_DIR" "$UPLOAD_DIR"
    echo -e "${GREEN}✅ 软链接已创建${NC}"
fi

# 验证软链接
echo ""
echo -e "${GREEN}=========================================="
echo "  ✅ 迁移完成！"
echo "==========================================${NC}"
echo ""
echo "📊 目录信息："
ls -la /var/www/activities_management/backend/ | grep uploads
echo ""
echo "📝 新上传目录: $NEW_UPLOAD_DIR"
echo "🔗 软链接: $UPLOAD_DIR -> $NEW_UPLOAD_DIR"
echo ""

