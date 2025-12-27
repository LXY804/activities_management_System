#!/bin/bash
# 服务器部署修复和执行脚本

echo "🚀 开始部署..."

# 1. 进入项目目录
cd /var/www/activities_management

# 2. 处理本地更改
echo "📦 处理本地更改..."
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "⚠️  检测到本地更改，正在保存..."
  git stash
fi

# 3. 切换到 main 分支并拉取代码
echo "📥 切换到 main 分支并拉取代码..."
git checkout main
git pull origin main

# 4. 创建数据库表（如果还没有）
echo "📊 创建 activity_logs 表..."
cd backend
node scripts/create_activity_logs_table.js || echo "⚠️  表可能已存在，继续..."

# 5. 重启后端服务（必须在 backend 目录下）
echo "🔄 重启后端服务..."
pm2 restart ecosystem.config.js || pm2 start ecosystem.config.js

# 6. 构建前端
echo "🏗️  构建前端..."
cd ../校园活动管理系统
npm run build

# 7. 重新加载 Nginx
echo "🌐 重新加载 Nginx..."
sudo systemctl reload nginx

echo "✅ 部署完成！"
echo ""
echo "📋 验证步骤："
echo "1. 访问网站检查前端是否正常"
echo "2. 测试活动信息页面，确认图片加载速度提升"
echo "3. 测试排行榜功能，确认头像显示正常"
echo "4. 查看后端日志: pm2 logs --lines 20"
echo "5. 检查服务状态: pm2 status"


