#!/bin/bash

# 图片优化 - Nginx 配置更新脚本
# 功能：让 Nginx 直接服务静态图片文件，不经过 Node.js，大幅提升性能

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  图片优化 - Nginx 配置更新"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 错误：请使用 sudo 运行此脚本${NC}"
    exit 1
fi

# 配置文件路径
NGINX_SITE_CONFIG="/etc/nginx/sites-available/activities_management"
NGINX_SITE_ENABLED="/etc/nginx/sites-enabled/activities_management"
BACKUP_FILE="${NGINX_SITE_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${YELLOW}📋 步骤 1: 检查 Nginx 配置文件...${NC}"

# 检查配置文件是否存在
if [ ! -f "$NGINX_SITE_CONFIG" ]; then
    echo -e "${RED}❌ 错误：找不到 Nginx 配置文件: $NGINX_SITE_CONFIG${NC}"
    echo "   请确认 Nginx 配置文件的路径是否正确"
    exit 1
fi

echo -e "${GREEN}✅ 找到配置文件: $NGINX_SITE_CONFIG${NC}"

# 备份原配置
echo -e "${YELLOW}📋 步骤 2: 备份原配置文件...${NC}"
cp "$NGINX_SITE_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ 备份已保存到: $BACKUP_FILE${NC}"

# 检查是否已经优化过
if grep -q "root /var/www/activities_management/backend;" "$NGINX_SITE_CONFIG" && grep -q "try_files \$uri =404;" "$NGINX_SITE_CONFIG"; then
    echo -e "${YELLOW}⚠️  配置文件似乎已经优化过了${NC}"
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 0
    fi
fi

echo -e "${YELLOW}📋 步骤 3: 更新图片服务配置...${NC}"

# 创建临时文件
TEMP_FILE=$(mktemp)

# 使用 sed 替换图片服务配置
# 查找并替换 location ~* ^/uploads/.*\.(jpg|jpeg|png|gif|webp|svg)$ 块
sed -E '
    # 匹配图片服务 location 块
    /location ~\* \^\\\/uploads\\\/\.\*\\\.\(jpg\\|jpeg\\|png\\|gif\\|webp\\|svg\)\$/ {
        # 读取整个块直到下一个 location 或 }
        :loop
        N
        /^\s*}\s*$/!b loop
        
        # 替换整个块
        c\
    # 上传的图片文件（直接由 Nginx 服务，不经过后端，大幅提升性能）\
    location ~* ^/uploads/.*\.(jpg|jpeg|png|gif|webp|svg)$ {\
        # 直接服务静态文件，不经过后端代理\
        root /var/www/activities_management/backend;\
        \
        # 允许浏览器缓存图片 30 天，大幅提升加载速度\
        expires 30d;\
        add_header Cache-Control "public, max-age=2592000";\
        add_header X-Content-Type-Options "nosniff";\
        \
        # 启用 sendfile（零拷贝，提升性能）\
        sendfile on;\
        tcp_nopush on;\
        tcp_nodelay on;\
        \
        # 启用 gzip（对未压缩的图片有效）\
        gzip_static on;\
        \
        # 如果文件不存在，返回 404（不转发到后端）\
        try_files $uri =404;\
    }
    ' "$NGINX_SITE_CONFIG" > "$TEMP_FILE"

# 如果 sed 替换失败，使用 Python 脚本
if [ $? -ne 0 ] || ! grep -q "root /var/www/activities_management/backend;" "$TEMP_FILE"; then
    echo -e "${YELLOW}⚠️  使用 Python 进行更精确的替换...${NC}"
    
    python3 << 'PYTHON_SCRIPT'
import re
import sys

config_file = "/etc/nginx/sites-available/activities_management"
backup_file = config_file + ".backup.before_python"

# 读取配置文件
with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 新的图片服务配置
new_config = '''    # 上传的图片文件（直接由 Nginx 服务，不经过后端，大幅提升性能）
    location ~* ^/uploads/.*\\.(jpg|jpeg|png|gif|webp|svg)$ {
        # 直接服务静态文件，不经过后端代理
        root /var/www/activities_management/backend;
        
        # 允许浏览器缓存图片 30 天，大幅提升加载速度
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
        add_header X-Content-Type-Options "nosniff";
        
        # 启用 sendfile（零拷贝，提升性能）
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        
        # 启用 gzip（对未压缩的图片有效）
        gzip_static on;
        
        # 如果文件不存在，返回 404（不转发到后端）
        try_files $uri =404;
    }'''

# 匹配旧的图片服务配置块（支持多种格式）
pattern = r'location\s+~\*\s+\^/uploads/.*?\{[^}]*proxy_pass[^}]*?\}'

# 查找并替换
if re.search(pattern, content, re.DOTALL):
    content = re.sub(pattern, new_config, content, flags=re.DOTALL)
    print("✅ 使用正则表达式替换成功")
else:
    # 如果正则匹配失败，尝试查找包含 proxy_pass 的 location 块
    lines = content.split('\n')
    new_lines = []
    in_image_location = False
    skip_until_brace = False
    brace_count = 0
    
    for i, line in enumerate(lines):
        # 检测图片 location 块的开始
        if re.search(r'location.*uploads.*\.(jpg|jpeg|png|gif|webp|svg)', line, re.IGNORECASE):
            in_image_location = True
            skip_until_brace = True
            brace_count = 0
            new_lines.append(new_config.split('\n')[0])  # 添加新配置的第一行
            continue
        
        if skip_until_brace:
            # 计算大括号
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0 and '}' in line:
                # 块结束，添加新配置的剩余部分
                for new_line in new_config.split('\n')[1:]:
                    new_lines.append(new_line)
                skip_until_brace = False
                in_image_location = False
                continue
            # 跳过旧配置的行
            continue
        
        new_lines.append(line)
    
    content = '\n'.join(new_lines)
    print("✅ 使用逐行解析替换成功")

# 写回文件
with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ 配置文件已更新")
PYTHON_SCRIPT

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Python 替换失败，请手动编辑配置文件${NC}"
        echo "   配置文件路径: $NGINX_SITE_CONFIG"
        echo "   备份文件: $BACKUP_FILE"
        exit 1
    fi
else
    mv "$TEMP_FILE" "$NGINX_SITE_CONFIG"
fi

# 验证配置
echo -e "${YELLOW}📋 步骤 4: 验证 Nginx 配置...${NC}"
if nginx -t 2>/dev/null; then
    echo -e "${GREEN}✅ Nginx 配置语法正确${NC}"
else
    echo -e "${RED}❌ Nginx 配置语法错误！${NC}"
    echo -e "${YELLOW}正在恢复备份...${NC}"
    cp "$BACKUP_FILE" "$NGINX_SITE_CONFIG"
    echo -e "${GREEN}✅ 已恢复备份配置${NC}"
    exit 1
fi

# 重载 Nginx
echo -e "${YELLOW}📋 步骤 5: 重载 Nginx...${NC}"
if systemctl reload nginx 2>/dev/null; then
    echo -e "${GREEN}✅ Nginx 已重载${NC}"
else
    echo -e "${RED}❌ Nginx 重载失败${NC}"
    echo -e "${YELLOW}正在恢复备份...${NC}"
    cp "$BACKUP_FILE" "$NGINX_SITE_CONFIG"
    systemctl reload nginx
    exit 1
fi

# 检查文件权限
echo -e "${YELLOW}📋 步骤 6: 检查上传目录权限...${NC}"
UPLOAD_DIR="/var/www/activities_management/backend/uploads"
if [ -d "$UPLOAD_DIR" ]; then
    chown -R www-data:www-data "$UPLOAD_DIR" 2>/dev/null || true
    chmod -R 755 "$UPLOAD_DIR" 2>/dev/null || true
    echo -e "${GREEN}✅ 上传目录权限已设置${NC}"
else
    echo -e "${YELLOW}⚠️  上传目录不存在: $UPLOAD_DIR${NC}"
    echo "   如果后续上传图片失败，请手动创建此目录"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  ✅ 优化完成！"
echo "==========================================${NC}"
echo ""
echo "📊 优化内容："
echo "  • Nginx 直接服务静态图片文件（不经过 Node.js）"
echo "  • 启用浏览器缓存（30天）"
echo "  • 启用 sendfile 零拷贝"
echo ""
echo "📝 备份文件：$BACKUP_FILE"
echo ""
echo "🧪 测试方法："
echo "  1. 打开网站，按 F12 查看 Network"
echo "  2. 刷新页面，查看图片请求"
echo "  3. 图片应该直接从 Nginx 返回（状态码 200）"
echo "  4. 响应头应包含: Cache-Control: public, max-age=2592000"
echo ""

