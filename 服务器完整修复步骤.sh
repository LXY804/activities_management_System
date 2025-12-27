#!/bin/bash
# 服务器完整修复步骤

echo "=== 开始修复 AI 聊天超时问题 ==="

# 1. 检查后端服务
echo -e "\n[1/5] 检查后端服务状态..."
cd /var/www/activities_management/backend
pm2 status
pm2 logs activities-backend --lines 10 --nostream

# 2. 修复前端超时设置
echo -e "\n[2/5] 修复前端超时设置..."
cd /var/www/activities_management/校园活动管理系统

# 备份原文件
cp src/api/request.js src/api/request.js.bak 2>/dev/null || true

# 修改 request.js
if grep -q "timeout: 10000" src/api/request.js; then
    sed -i 's/timeout: 10000/timeout: 60000/g' src/api/request.js
    echo "✅ request.js 超时已修改为 60 秒"
else
    echo "⚠️  request.js 中未找到 timeout: 10000，可能已修改"
fi

# 检查并修改 ChatFloat.vue（如果存在）
if [ -f "src/components/ChatFloat.vue" ]; then
    if grep -q "timeout.*10000" src/components/ChatFloat.vue; then
        sed -i 's/timeout.*10000/timeout: 60000/g' src/components/ChatFloat.vue
        echo "✅ ChatFloat.vue 超时已修改为 60 秒"
    fi
fi

# 验证修改
echo -e "\n验证修改结果:"
grep "timeout" src/api/request.js | head -1

# 3. 重新构建前端
echo -e "\n[3/5] 重新构建前端..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ 前端构建成功"
else
    echo "❌ 前端构建失败，请检查错误信息"
    exit 1
fi

# 4. 检查构建后的文件
echo -e "\n[4/5] 检查构建后的文件..."
if grep -r "timeout.*60000" dist/ > /dev/null 2>&1; then
    echo "✅ 构建后的文件中包含 60 秒超时设置"
else
    echo "⚠️  警告：构建后的文件中可能仍包含旧超时设置"
    echo "请检查 dist/ 目录中的文件"
fi

# 5. 重新加载 Nginx
echo -e "\n[5/5] 重新加载 Nginx..."
sudo systemctl reload nginx

echo -e "\n=== 修复完成！ ==="
echo "请清除浏览器缓存（Ctrl+Shift+Delete）或使用硬刷新（Ctrl+F5）"
echo "然后重新测试 AI 聊天功能"

