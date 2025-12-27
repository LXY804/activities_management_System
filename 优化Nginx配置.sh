#!/bin/bash

# Nginx 优化配置脚本
# 功能：让 Nginx 直接服务静态图片文件，不经过 Node.js，大幅提升性能

set -e

echo "=================================="
echo "🚀 Nginx 图片服务优化配置"
echo "=================================="
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
  echo "❌ 请使用 sudo 运行此脚本"
  exit 1
fi

# 配置变量
NGINX_CONFIG="/etc/nginx/sites-available/activities_management"
NGINX_ENABLED="/etc/nginx/sites-enabled/activities_management"
BACKEND_PATH="/var/www/activities_management/backend"

# 检查 Nginx 配置是否存在
if [ ! -f "$NGINX_CONFIG" ]; then
  echo "⚠️  Nginx 配置文件不存在: $NGINX_CONFIG"
  echo "   请先创建配置文件，或使用 nginx.conf.example 作为模板"
  exit 1
fi

echo "📝 备份原配置文件..."
cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ 备份完成"

# 检查后端上传目录是否存在
if [ ! -d "$BACKEND_PATH/uploads" ]; then
  echo "⚠️  上传目录不存在: $BACKEND_PATH/uploads"
  echo "   创建目录..."
  mkdir -p "$BACKEND_PATH/uploads"
  chown -R www-data:www-data "$BACKEND_PATH/uploads"
  echo "✅ 目录已创建"
fi

# 创建优化的配置片段
cat > /tmp/nginx_uploads_optimized.conf << 'EOF'
    # 上传的图片文件（直接由 Nginx 服务，不经过后端，大幅提升性能）
    location ~* ^/uploads/.*\.(jpg|jpeg|png|gif|webp|svg)$ {
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
    }
EOF

echo ""
echo "📋 当前配置中的图片服务部分："
echo "----------------------------------------"
grep -A 15 "^[[:space:]]*location.*uploads.*\.(jpg\|jpeg\|png\|gif\|webp\|svg)" "$NGINX_CONFIG" || echo "未找到图片服务配置"
echo "----------------------------------------"
echo ""

# 询问是否继续
read -p "是否替换为优化配置？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ 已取消"
  exit 1
fi

# 使用 sed 替换配置
# 先删除旧的图片服务配置
sed -i '/location ~\* \^\/uploads\/.*\.(jpg|jpeg|png|gif|webp|svg)\$/,/^[[:space:]]*}/d' "$NGINX_CONFIG"

# 在 WebSocket 配置后插入新配置
if grep -q "location /ws" "$NGINX_CONFIG"; then
  # 在 WebSocket 配置后插入
  sed -i '/location \/ws {/,/^[[:space:]]*}/r /tmp/nginx_uploads_optimized.conf' "$NGINX_CONFIG"
else
  # 如果找不到 WebSocket 配置，在 API 配置后插入
  sed -i '/location \/api {/,/^[[:space:]]*}/r /tmp/nginx_uploads_optimized.conf' "$NGINX_CONFIG"
fi

echo "✅ 配置已更新"

# 测试 Nginx 配置
echo ""
echo "🧪 测试 Nginx 配置..."
if nginx -t; then
  echo "✅ Nginx 配置测试通过"
else
  echo "❌ Nginx 配置测试失败，正在恢复备份..."
  cp "${NGINX_CONFIG}.backup."* "$NGINX_CONFIG" 2>/dev/null || true
  exit 1
fi

# 重载 Nginx
echo ""
echo "🔄 重载 Nginx..."
systemctl reload nginx
echo "✅ Nginx 已重载"

# 清理临时文件
rm -f /tmp/nginx_uploads_optimized.conf

echo ""
echo "=================================="
echo "✅ 优化完成！"
echo "=================================="
echo ""
echo "📊 优化效果："
echo "  - 图片直接由 Nginx 服务，不经过 Node.js"
echo "  - 减少后端负载，提升响应速度"
echo "  - 启用 sendfile 零拷贝，提升 I/O 性能"
echo "  - 浏览器缓存 30 天，减少重复请求"
echo ""
echo "🔍 验证方法："
echo "  1. 访问网站，打开浏览器开发者工具"
echo "  2. 查看 Network 标签，检查图片请求"
echo "  3. 图片应该直接从 Nginx 返回（不经过 /api）"
echo ""

