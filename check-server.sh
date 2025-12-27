#!/bin/bash

echo "=================================="
echo "🔍 服务器状态检查脚本"
echo "=================================="
echo ""

# 检查 Nginx 状态
echo "1️⃣ 检查 Nginx 状态..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx 正在运行"
    systemctl status nginx --no-pager | head -5
else
    echo "❌ Nginx 未运行"
    echo "   尝试启动: sudo systemctl start nginx"
fi
echo ""

# 检查 PM2 和后端服务
echo "2️⃣ 检查后端服务状态..."
if command -v pm2 &> /dev/null; then
    echo "PM2 进程列表:"
    pm2 list
    echo ""
    if pm2 list | grep -q "activities-backend"; then
        echo "✅ 后端服务已启动"
        echo "查看日志: pm2 logs activities-backend --lines 20"
    else
        echo "❌ 后端服务未启动"
        echo "   启动命令: cd /var/www/activities_management/backend && pm2 start ecosystem.config.js"
    fi
else
    echo "❌ PM2 未安装"
    echo "   安装命令: npm install -g pm2"
fi
echo ""

# 检查端口占用
echo "3️⃣ 检查端口占用情况..."
echo "端口 80 (HTTP):"
if netstat -tuln | grep -q ":80 "; then
    echo "✅ 端口 80 已被占用"
    netstat -tuln | grep ":80 "
else
    echo "❌ 端口 80 未被占用（Nginx 可能未运行）"
fi
echo ""

echo "端口 3000 (后端):"
if netstat -tuln | grep -q ":3000 "; then
    echo "✅ 端口 3000 已被占用（后端服务正在运行）"
    netstat -tuln | grep ":3000 "
else
    echo "❌ 端口 3000 未被占用（后端服务可能未运行）"
fi
echo ""

# 检查防火墙
echo "4️⃣ 检查防火墙状态..."
if command -v ufw &> /dev/null; then
    echo "UFW 防火墙状态:"
    sudo ufw status
elif command -v firewall-cmd &> /dev/null; then
    echo "Firewalld 防火墙状态:"
    sudo firewall-cmd --list-all
else
    echo "⚠️  未检测到常见防火墙工具"
fi
echo ""

# 检查 Nginx 配置
echo "5️⃣ 检查 Nginx 配置..."
if [ -f /etc/nginx/sites-enabled/activities_management ]; then
    echo "✅ Nginx 配置文件存在"
    if sudo nginx -t 2>&1 | grep -q "successful"; then
        echo "✅ Nginx 配置测试通过"
    else
        echo "❌ Nginx 配置测试失败:"
        sudo nginx -t
    fi
else
    echo "❌ Nginx 配置文件不存在"
    echo "   需要创建配置文件: /etc/nginx/sites-enabled/activities_management"
fi
echo ""

# 检查前端构建文件
echo "6️⃣ 检查前端构建文件..."
FRONTEND_DIST="/var/www/activities_management/校园活动管理系统/dist"
if [ -d "$FRONTEND_DIST" ]; then
    echo "✅ 前端构建目录存在: $FRONTEND_DIST"
    if [ -f "$FRONTEND_DIST/index.html" ]; then
        echo "✅ index.html 存在"
    else
        echo "❌ index.html 不存在，需要重新构建前端"
    fi
else
    echo "❌ 前端构建目录不存在"
    echo "   构建命令: cd /var/www/activities_management/校园活动管理系统 && npm run build"
fi
echo ""

# 检查最近日志
echo "7️⃣ 最近的后端日志（最后 10 行）..."
if command -v pm2 &> /dev/null && pm2 list | grep -q "activities-backend"; then
    pm2 logs activities-backend --lines 10 --nostream
else
    echo "⚠️  无法获取日志（服务可能未运行）"
fi
echo ""

# 检查 Nginx 错误日志
echo "8️⃣ 最近的 Nginx 错误日志（最后 10 行）..."
if [ -f /var/log/nginx/activities_error.log ]; then
    sudo tail -10 /var/log/nginx/activities_error.log
else
    echo "⚠️  错误日志文件不存在"
fi
echo ""

echo "=================================="
echo "📋 快速修复建议"
echo "=================================="
echo ""
echo "如果 Nginx 未运行:"
echo "  sudo systemctl start nginx"
echo "  sudo systemctl enable nginx"
echo ""
echo "如果后端服务未运行:"
echo "  cd /var/www/activities_management/backend"
echo "  pm2 start ecosystem.config.js"
echo "  pm2 save"
echo ""
echo "如果端口被防火墙阻止:"
echo "  sudo ufw allow 80/tcp"
echo "  sudo ufw allow 443/tcp"
echo ""
echo "重启所有服务:"
echo "  sudo systemctl restart nginx"
echo "  pm2 restart activities-backend"
echo ""







