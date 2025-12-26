# Git 部署指南

## 📋 前提条件

1. 本地项目已初始化 Git 仓库
2. 已创建远程 Git 仓库（GitHub、Gitee、GitLab 等）
3. 服务器已安装 Git

---

## 🔧 步骤 1：本地提交代码

### 1.1 检查本地 Git 状态

```powershell
# 在项目根目录
cd D:\桌面\activities_management_System

# 检查 Git 状态
git status

# 查看远程仓库配置
git remote -v
```

### 1.2 如果没有远程仓库，先添加

```powershell
# 如果使用 GitHub
git remote add origin https://github.com/你的用户名/仓库名.git

# 如果使用 Gitee（推荐，国内访问快）
git remote add origin https://gitee.com/你的用户名/仓库名.git

# 如果使用 SSH（需要配置 SSH 密钥）
git remote add origin git@gitee.com:你的用户名/仓库名.git
```

### 1.3 提交并推送代码

```powershell
# 添加所有修改
git add .

# 提交修改
git commit -m "添加图片自动压缩功能，优化加载速度"

# 推送到远程仓库
git push origin main
# 或者
git push origin master
```

---

## 🖥️ 步骤 2：在服务器上配置 Git

### 2.1 找到或创建项目目录

```bash
# SSH 连接到服务器
ssh root@124.70.221.193

# 检查项目目录是否存在
ls -la /var/www/

# 如果目录不存在，创建它
sudo mkdir -p /var/www/activities_management
sudo chown -R $USER:$USER /var/www/activities_management
cd /var/www/activities_management
```

### 2.2 初始化 Git 仓库（如果还没有）

**情况 A：目录是空的，需要克隆**

```bash
cd /var/www/activities_management

# 克隆远程仓库
git clone https://gitee.com/你的用户名/仓库名.git .

# 或者如果使用 SSH
git clone git@gitee.com:你的用户名/仓库名.git .
```

**情况 B：目录已有文件，需要初始化**

```bash
cd /var/www/activities_management

# 初始化 Git 仓库
git init

# 添加远程仓库
git remote add origin https://gitee.com/你的用户名/仓库名.git

# 拉取代码
git pull origin main --allow-unrelated-histories
# 或者
git pull origin master --allow-unrelated-histories
```

### 2.3 配置 Git 用户信息（首次使用）

```bash
git config --global user.name "你的名字"
git config --global user.email "your.email@example.com"
```

### 2.4 配置 Git 认证（避免每次输入密码）

**方法 1：使用 SSH 密钥（推荐）**

```bash
# 生成 SSH 密钥（如果还没有）
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
# 按 Enter 使用默认路径，可以设置密码或直接回车

# 查看公钥
cat ~/.ssh/id_rsa.pub

# 复制公钥内容，添加到 Gitee/GitHub：
# Gitee: https://gitee.com/profile/sshkeys
# GitHub: https://github.com/settings/keys
```

**方法 2：使用 Git Credential Helper（HTTPS）**

```bash
# 保存凭据
git config --global credential.helper store

# 第一次 pull 时会提示输入用户名和密码，之后会自动保存
```

---

## 🚀 步骤 3：部署流程

### 3.1 在服务器上拉取最新代码

```bash
cd /var/www/activities_management

# 拉取最新代码
git pull origin main
# 或者
git pull origin master

# 如果遇到冲突，查看状态
git status
```

### 3.2 更新依赖并构建

```bash
# 更新后端依赖（如果需要）
cd backend
npm install --production

# 更新前端依赖并构建
cd ../校园活动管理系统
npm install
npm run build
```

### 3.3 重启服务

```bash
# 重启后端
cd /var/www/activities_management/backend
pm2 restart activities-backend

# 重载 Nginx
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📝 创建自动化部署脚本

创建一个部署脚本，一键完成所有操作：

```bash
# 在服务器上创建部署脚本
nano /var/www/activities_management/deploy.sh
```

脚本内容：

```bash
#!/bin/bash

echo "=================================="
echo "开始部署..."
echo "=================================="

# 进入项目目录
cd /var/www/activities_management

# 拉取最新代码
echo "📦 拉取最新代码..."
git pull origin main || git pull origin master

# 更新后端依赖
echo "📦 更新后端依赖..."
cd backend
npm install --production

# 更新前端依赖并构建
echo "📦 构建前端..."
cd ../校园活动管理系统
npm install
npm run build

# 重启后端
echo "🔄 重启后端服务..."
cd ../backend
pm2 restart activities-backend

# 重载 Nginx
echo "🔄 重载 Nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo "=================================="
echo "✅ 部署完成！"
echo "=================================="
```

设置执行权限：

```bash
chmod +x /var/www/activities_management/deploy.sh
```

以后只需要执行：

```bash
/var/www/activities_management/deploy.sh
```

---

## 🔍 常见问题排查

### 问题 1：git pull 卡住不动

**原因**：等待输入密码或网络问题

**解决方案**：
```bash
# 按 Ctrl+C 取消
# 使用 SSH 密钥认证（推荐）
# 或配置 credential helper
git config --global credential.helper store
```

### 问题 2：权限被拒绝（Permission denied）

**解决方案**：
```bash
# 检查目录权限
ls -la /var/www/activities_management

# 修改所有者
sudo chown -R $USER:$USER /var/www/activities_management
```

### 问题 3：合并冲突

**解决方案**：
```bash
# 查看冲突文件
git status

# 手动解决冲突后
git add .
git commit -m "解决合并冲突"
git push
```

### 问题 4：需要输入密码

**解决方案**：
- 使用 SSH 密钥（推荐）
- 或使用 Personal Access Token（GitHub/Gitee）

### 问题 5：AI 大模型功能报错

**症状**：聊天功能或 AI 推荐功能报错，提示 "DEEPSEEK_API_KEY 未配置" 或 "DeepSeek error"

**可能原因**：
1. `.env` 文件中未配置 `DEEPSEEK_API_KEY`
2. 环境变量未正确加载
3. API Key 无效或已过期

**解决方案**：
```bash
# 1. 检查 .env 文件是否存在
cd /var/www/activities_management/backend
ls -la .env

# 2. 如果不存在，创建 .env 文件
nano .env

# 3. 添加以下配置（替换为你的实际 API Key）
# DEEPSEEK_API_KEY=your_actual_api_key_here
# DEEPSEEK_MODEL=deepseek-chat

# 4. 确保文件权限安全
chmod 600 .env

# 5. 重启后端服务使配置生效
pm2 restart activities-backend

# 6. 查看日志确认配置是否生效
pm2 logs activities-backend --lines 50
```

**获取 DeepSeek API Key**：
1. 访问 https://platform.deepseek.com/
2. 注册/登录账号
3. 在控制台创建 API Key
4. 将 API Key 复制到 `.env` 文件中

### 问题 6：无法访问网站（ERR_CONNECTION_REFUSED）

**症状**：浏览器显示"拒绝连接"或"无法访问此页面"

**可能原因**：
1. Nginx 服务未运行
2. 后端服务未运行
3. 防火墙阻止了端口
4. 服务配置错误

**快速排查步骤**：

```bash
# 1. 使用检查脚本（推荐）
# 将 check-server.sh 上传到服务器后执行
chmod +x check-server.sh
./check-server.sh

# 2. 手动检查 Nginx
sudo systemctl status nginx
# 如果未运行，启动它
sudo systemctl start nginx
sudo systemctl enable nginx  # 设置开机自启

# 3. 检查后端服务
pm2 list
# 如果未运行，启动它
cd /var/www/activities_management/backend
pm2 start ecosystem.config.js
pm2 save

# 4. 检查端口是否被占用
netstat -tuln | grep -E ":(80|3000) "

# 5. 检查防火墙（如果使用 UFW）
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 6. 检查 Nginx 配置
sudo nginx -t
# 如果有错误，修复后重载
sudo systemctl reload nginx

# 7. 查看错误日志
pm2 logs activities-backend --lines 50
sudo tail -50 /var/log/nginx/activities_error.log
```

**快速修复命令**（按顺序执行）：

```bash
# 重启所有服务
cd /var/www/activities_management/backend
pm2 restart activities-backend
sudo systemctl restart nginx

# 如果服务不存在，重新启动
pm2 start ecosystem.config.js
pm2 save
```

---

## 🎯 推荐的 Git 工作流程

1. **本地开发**
   ```powershell
   git add .
   git commit -m "功能描述"
   git push
   ```

2. **服务器部署**
   ```bash
   cd /var/www/activities_management
   git pull
   # 然后运行部署脚本或手动执行构建命令
   ```

3. **定期备份**
   ```bash
   # 在服务器上创建备份
   git tag backup-$(date +%Y%m%d)
   git push origin --tags
   ```

---

## 📚 推荐的 Git 托管平台

1. **Gitee（码云）** - 国内访问快
   - 网址：https://gitee.com
   - 适合：国内服务器

2. **GitHub** - 全球最大
   - 网址：https://github.com
   - 适合：国际项目

3. **GitLab** - 功能强大
   - 网址：https://gitlab.com
   - 适合：企业项目

---

## ✅ 检查清单

- [ ] 本地代码已提交并推送到远程仓库
- [ ] 服务器上已安装 Git
- [ ] 服务器上已配置 Git 用户信息
- [ ] 已配置 SSH 密钥或 credential helper
- [ ] 服务器上项目目录已初始化 Git
- [ ] 远程仓库地址配置正确
- [ ] 可以正常执行 `git pull`
- [ ] 已创建自动化部署脚本

