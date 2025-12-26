# 部署到云服务器指南（使用 main 分支）

## 📋 本次更新内容

1. **前端优化**：
   - ✅ 优化活动信息页面图片加载（预加载、骨架屏、错误处理）
   - ✅ 优化活动列表页面图片加载（懒加载、占位符）
   - ✅ 修复排行榜头像显示（显示头像而非首字符）
   - ✅ 统一刷新数据和积分排行榜按钮宽度

2. **后端更新**：
   - ✅ 改进日志错误处理（activity_logs 表不存在时静默处理）
   - ✅ 添加 activity_logs 表创建脚本

3. **数据库更新**：
   - ⚠️ 需要创建 `activity_logs` 表（用于操作日志记录）

## 🚀 部署步骤

### 第一步：在本地提交代码到 main 分支

```bash
# 1. 确保在 main 分支
git checkout main

# 2. 添加所有更改
git add -A

# 3. 提交更改
git commit -m "feat: 优化图片加载性能、修复排行榜头像显示、统一按钮宽度、改进日志错误处理"

# 4. 推送到远程 main 分支
git push origin main
```

### 第二步：在云服务器上拉取并部署

**方法 1：使用自动部署脚本（推荐）**

```bash
# SSH 连接到服务器
ssh 你的用户名@服务器IP

# 进入项目目录
cd /var/www/activities_management

# 拉取最新代码
git checkout main
git pull origin main

# 执行部署脚本
chmod +x deploy.sh
./deploy.sh
```

**方法 2：手动部署**

```bash
# 1. SSH 连接到服务器
ssh 你的用户名@服务器IP

# 2. 进入项目目录并拉取代码
cd /var/www/activities_management
git checkout main
git pull origin main

# 3. 创建 activity_logs 表（如果还没有创建）
cd backend
node scripts/create_activity_logs_table.js

# 4. 重启后端服务
pm2 restart ecosystem.config.js

# 5. 构建前端
cd ../校园活动管理系统
npm run build

# 6. 重新加载 Nginx
sudo systemctl reload nginx
```

### 第三步：验证部署

1. ✅ 访问网站，检查前端是否正常加载
2. ✅ 测试活动信息页面，确认图片加载速度提升
3. ✅ 测试排行榜功能，确认头像显示正常
4. ✅ 查看后端日志：`pm2 logs`，确认没有错误

## 📝 快速部署命令（一键执行）

在服务器上执行以下命令：

```bash
cd /var/www/activities_management && \
git checkout main && \
git pull origin main && \
cd backend && \
node scripts/create_activity_logs_table.js || echo "表可能已存在" && \
pm2 restart ecosystem.config.js && \
cd ../校园活动管理系统 && \
npm run build && \
sudo systemctl reload nginx && \
echo "✅ 部署完成！"
```

## ⚠️ 注意事项

1. **数据库备份**：在执行数据库操作前，建议先备份数据库
2. **环境变量**：确保服务器的 `.env` 文件配置正确
3. **文件权限**：确保上传目录有正确的写入权限
4. **Git 认证**：如果推送时遇到认证问题，可以使用 SSH 方式或配置 Git 凭证

## 🔄 回滚步骤（如果出现问题）

```bash
# 在服务器上回滚到上一个提交
cd /var/www/activities_management
git log --oneline -5  # 查看提交历史
git reset --hard <上一个提交的hash>
pm2 restart ecosystem.config.js
cd 校园活动管理系统
npm run build
sudo systemctl reload nginx
```

## 📞 问题排查

如果遇到问题，可以：

1. 查看后端日志：`pm2 logs`
2. 查看 Nginx 日志：`sudo tail -f /var/log/nginx/error.log`
3. 检查 Git 状态：`git status`
4. 检查文件权限：`ls -la`

