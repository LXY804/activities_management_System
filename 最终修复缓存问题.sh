#!/bin/bash

# 最终修复缓存问题

set -e

NGINX_CONFIG="/etc/nginx/sites-available/activities_management"

echo "=========================================="
echo "  最终修复缓存问题"
echo "=========================================="
echo ""

# 备份
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo "✅ 配置已备份: $BACKUP_FILE"

echo "📋 问题分析："
echo "  通用静态资源缓存配置可能也在匹配 /uploads/ 路径"
echo "  需要排除 /uploads/ 路径"
echo ""

# 修改通用静态资源缓存配置，排除 /uploads/ 路径
python3 << 'PYTHON_SCRIPT'
import re

config_file = "/etc/nginx/sites-available/activities_management"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 找到 location ~* \.(jpg|jpeg|png|...) 配置块
# 匹配：location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
# 注意：在Python正则中，\. 需要写成 \\.，| 需要写成 \|，$ 需要写成 \$
pattern = r'(location ~\* \\.\(jpg\|jpeg\|png\|gif\|ico\|css\|js\|svg\|woff\|woff2\|ttf\|eot\)\$ \{)'

def replace_func(match):
    return match.group(1) + '\n        # 排除 /uploads/ 路径，让专门的图片服务配置生效\n        if ($request_uri ~* ^/uploads/) {\n            break;\n        }'

content = re.sub(pattern, replace_func, content)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ 已修改通用静态资源缓存配置，排除 /uploads/ 路径")
PYTHON_SCRIPT

if [ $? -ne 0 ]; then
    echo "❌ 修改失败，恢复备份..."
    cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi

# 测试配置
echo ""
echo "📋 测试 Nginx 配置..."
if nginx -t 2>/dev/null; then
    echo "✅ Nginx 配置测试通过"
    systemctl reload nginx
    echo "✅ Nginx 已重载"
else
    echo "❌ Nginx 配置测试失败，正在恢复备份..."
    cp "$BACKUP_FILE" "$NGINX_CONFIG"
    nginx -t
    exit 1
fi

echo ""
echo "=========================================="
echo "  ✅ 修复完成！"
echo "=========================================="
echo ""
echo "🧪 验证方法："
echo "  find /var/www/activities_management/backend/uploads -type f \\( -iname \"*.jpg\" -o -iname \"*.png\" \\) 2>/dev/null | head -1 | xargs -I {} basename {} | xargs -I {} curl -sI \"http://localhost/uploads/{}\" | grep -E \"HTTP|Cache-Control|Expires\""
echo ""


