# 云服务器部署指南

## 本次更新内容

1. **前端更新**：
   - 修复排行榜头像显示（显示头像而非首字符）
   - 统一刷新数据和积分排行榜按钮宽度
   - 优化积分排行榜组件

2. **后端更新**：
   - 改进日志错误处理（activity_logs 表不存在时静默处理）
   - 优化错误提示信息

3. **数据库更新**：
   - 需要创建 `activity_logs` 表（用于操作日志记录）

## 部署步骤

### 1. 在本地提交并推送代码

```bash
# 如果还没有提交，执行以下命令
git add -A
git commit -m "feat: 修复排行榜头像显示、统一按钮宽度、改进日志错误处理、添加activity_logs表创建脚本"
git push origin LXY
```

### 2. 在云服务器上拉取最新代码

```bash
# SSH 连接到服务器后，进入项目目录
cd /var/www/activities_management

# 切换到 LXY 分支（如果不在该分支）
git checkout LXY

# 拉取最新代码
git pull origin LXY
```

### 3. 创建 activity_logs 表

**方法 1：使用 Node.js 脚本（推荐）**

```bash
cd backend
node scripts/create_activity_logs_table.js
```

**方法 2：使用 MySQL 命令行**

```bash
mysql -u 你的数据库用户名 -p activity_management < backend/database/create_activity_logs.sql
```

**方法 3：在数据库管理工具中执行**

- 打开 Navicat、phpMyAdmin 或 MySQL Workbench
- 连接到 `activity_management` 数据库
- 执行 `backend/database/create_activity_logs.sql` 文件中的 SQL 语句

### 4. 安装/更新后端依赖（如果需要）

```bash
cd backend
npm install
```

### 5. 重启后端服务

```bash
# 使用 PM2 重启
pm2 restart ecosystem.config.js

# 或者停止后重新启动
pm2 stop all
pm2 delete all
pm2 start ecosystem.config.js

# 查看日志确认启动成功
pm2 logs
```

### 6. 构建前端

```bash
cd 校园活动管理系统
npm install  # 如果需要更新依赖
npm run build
```

### 7. 重新加载 Nginx

```bash
sudo systemctl reload nginx
```

### 8. 验证部署

1. 访问网站，检查前端是否正常加载
2. 测试排行榜功能，确认头像显示正常
3. 检查后端日志，确认没有 `activity_logs` 表不存在的错误

## 快速部署脚本

你也可以创建一个部署脚本 `deploy.sh`：

```bash
#!/bin/bash
set -e

echo "开始部署..."

# 1. 拉取代码
cd /var/www/activities_management
git pull origin LXY

# 2. 创建数据库表（如果不存在）
cd backend
node scripts/create_activity_logs_table.js || echo "表可能已存在，继续..."

# 3. 安装依赖（如果需要）
# npm install

# 4. 重启后端
pm2 restart ecosystem.config.js

# 5. 构建前端
cd ../校园活动管理系统
npm run build

# 6. 重新加载 Nginx
sudo systemctl reload nginx

echo "部署完成！"
```

使用方式：
```bash
chmod +x deploy.sh
./deploy.sh
```

## 回滚步骤（如果出现问题）

```bash
# 回滚到上一个提交
cd /var/www/activities_management
git log --oneline -5  # 查看提交历史
git reset --hard <上一个提交的hash>
pm2 restart ecosystem.config.js
cd 校园活动管理系统
npm run build
sudo systemctl reload nginx
```

## 注意事项

1. **数据库备份**：在执行数据库操作前，建议先备份数据库
2. **环境变量**：确保服务器的 `.env` 文件配置正确
3. **文件权限**：确保上传目录有正确的写入权限
4. **日志监控**：部署后查看 PM2 和 Nginx 日志，确认没有错误

