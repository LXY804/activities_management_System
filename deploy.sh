#!/bin/bash

# 校园活动管理系统 - 快速部署脚本
# 使用方法: ./deploy.sh

set -e  # 遇到错误立即退出

echo "=================================="
echo "校园活动管理系统 - 部署脚本"
echo "=================================="
echo ""

# 检查是否在项目根目录
if [ ! -d "backend" ] || [ ! -d "校园活动管理系统" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 项目路径
PROJECT_ROOT=$(pwd)
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/校园活动管理系统"

echo "📦 步骤 1: 更新代码..."
if [ -d ".git" ]; then
    git pull || echo "⚠️  警告: Git pull 失败，继续部署..."
else
    echo "ℹ️  未检测到 Git 仓库，跳过代码更新"
fi

echo ""
echo "📦 步骤 2: 更新后端依赖..."
cd "$BACKEND_DIR"
npm install --production

echo ""
echo "📦 步骤 3: 检查后端环境变量..."
if [ ! -f ".env" ]; then
    echo "⚠️  警告: 未找到 .env 文件，请确保已配置环境变量"
    echo "   创建 .env 文件示例:"
    echo "   DB_HOST=localhost"
    echo "   DB_PORT=3306"
    echo "   DB_NAME=campus_activities"
    echo "   DB_USER=your_user"
    echo "   DB_PASSWORD=your_password"
    echo "   JWT_SECRET=your_secret"
    echo "   PORT=3000"
    echo "   NODE_ENV=production"
    echo "   CORS_ORIGIN=https://yourdomain.com"
else
    echo "✅ .env 文件存在"
fi

echo ""
echo "📦 步骤 4: 重启后端服务..."
if command -v pm2 &> /dev/null; then
    # 检查应用是否已存在
    if pm2 list | grep -q "activities-backend"; then
        echo "   重启现有 PM2 应用..."
        pm2 restart activities-backend
    else
        echo "   启动新的 PM2 应用..."
        if [ -f "ecosystem.config.js" ]; then
            pm2 start ecosystem.config.js
        else
            pm2 start app.js --name activities-backend
        fi
    fi
    pm2 save
    echo "✅ 后端服务已重启"
else
    echo "⚠️  警告: PM2 未安装，请手动启动后端服务"
    echo "   安装 PM2: npm install -g pm2"
    echo "   启动命令: cd backend && pm2 start app.js --name activities-backend"
fi

echo ""
echo "📦 步骤 5: 更新前端依赖..."
cd "$FRONTEND_DIR"
npm install

echo ""
echo "📦 步骤 6: 检查前端环境变量..."
if [ ! -f ".env.production" ]; then
    echo "⚠️  警告: 未找到 .env.production 文件"
    echo "   创建 .env.production 文件示例:"
    echo "   VITE_API_BASE_URL=https://yourdomain.com/api"
else
    echo "✅ .env.production 文件存在"
fi

echo ""
echo "📦 步骤 7: 构建前端..."
npm run build

if [ -d "dist" ]; then
    echo "✅ 前端构建成功"
    echo "   构建文件位置: $FRONTEND_DIR/dist"
else
    echo "❌ 错误: 前端构建失败，未找到 dist 目录"
    exit 1
fi

echo ""
echo "📦 步骤 8: 重载 Nginx..."
if command -v nginx &> /dev/null; then
    if sudo nginx -t 2>/dev/null; then
        sudo systemctl reload nginx
        echo "✅ Nginx 已重载"
    else
        echo "⚠️  警告: Nginx 配置测试失败，请检查配置"
    fi
else
    echo "⚠️  警告: Nginx 未安装或未在 PATH 中"
fi

echo ""
echo "=================================="
echo "✅ 部署完成！"
echo "=================================="
echo ""
echo "📊 检查服务状态:"
if command -v pm2 &> /dev/null; then
    pm2 status
fi
echo ""
echo "🔍 查看后端日志: pm2 logs activities-backend"
echo "🔍 查看 Nginx 日志: sudo tail -f /var/log/nginx/activities_error.log"
echo ""
echo "🌐 访问地址: https://yourdomain.com (请替换为实际域名)"
echo ""


