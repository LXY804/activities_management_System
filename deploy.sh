#!/bin/bash
set -e

echo "🚀 开始部署到云服务器..."

# 1. 拉取代码
echo "📥 拉取最新代码..."
cd /var/www/activities_management
git checkout main
git pull origin main

# 2. 创建数据库表（如果不存在）
echo "📊 创建 activity_logs 表..."
cd backend
node scripts/create_activity_logs_table.js || echo "⚠️  表可能已存在，继续..."

# 3. 安装后端依赖（如果需要）
# echo "📦 安装后端依赖..."
# npm install

# 4. 重启后端服务
echo "🔄 重启后端服务..."
pm2 restart ecosystem.config.js || pm2 start ecosystem.config.js

# 5. 构建前端
echo "🏗️  构建前端..."
cd ../校园活动管理系统
npm run build

# 6. 重新加载 Nginx
echo "🌐 重新加载 Nginx..."
sudo systemctl reload nginx

echo "✅ 部署完成！"
echo ""
echo "📋 验证步骤："
echo "1. 访问网站检查前端是否正常"
echo "2. 测试排行榜功能，确认头像显示正常"
echo "3. 查看后端日志: pm2 logs"
echo "4. 检查 Nginx 日志: sudo tail -f /var/log/nginx/error.log"
