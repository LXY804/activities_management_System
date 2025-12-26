# 校园活动管理系统 - 上传脚本（PowerShell）
# 使用方法: 右键以管理员身份运行 PowerShell，然后执行: .\上传到服务器.ps1

$SERVER_IP = "124.70.221.193"
$SERVER_USER = "root"  # 根据实际情况修改
$SERVER_PATH = "/var/www/activities_management"
$LOCAL_PROJECT = "D:\桌面\activities_management_System"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "校园活动管理系统 - 文件上传脚本" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 检查本地项目目录
if (-not (Test-Path $LOCAL_PROJECT)) {
    Write-Host "❌ 错误: 本地项目目录不存在: $LOCAL_PROJECT" -ForegroundColor Red
    Write-Host "请修改脚本中的 LOCAL_PROJECT 变量" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 步骤 1: 构建前端..." -ForegroundColor Yellow
$frontendDir = Join-Path $LOCAL_PROJECT "校园活动管理系统"
Set-Location $frontendDir

# 检查是否已构建
if (-not (Test-Path "dist")) {
    Write-Host "   正在构建前端..." -ForegroundColor Gray
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 前端构建失败！" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   检测到已构建的 dist 目录，跳过构建" -ForegroundColor Gray
    Write-Host "   如需重新构建，请删除 dist 目录后重试" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📤 步骤 2: 上传文件到服务器..." -ForegroundColor Yellow
Write-Host "   服务器: $SERVER_USER@$SERVER_IP" -ForegroundColor Gray
Write-Host "   目标路径: $SERVER_PATH" -ForegroundColor Gray
Write-Host ""

# 上传修改的 Vue 文件
$vueFile = Join-Path $frontendDir "src\views\AdminDashboard.vue"
if (Test-Path $vueFile) {
    Write-Host "   上传 AdminDashboard.vue..." -ForegroundColor Gray
    scp $vueFile "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/校园活动管理系统/src/views/"
} else {
    Write-Host "   ⚠️  未找到 AdminDashboard.vue" -ForegroundColor Yellow
}

# 上传 dist 目录
$distDir = Join-Path $frontendDir "dist"
if (Test-Path $distDir) {
    Write-Host "   上传 dist 目录（这可能需要一些时间）..." -ForegroundColor Gray
    scp -r $distDir "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/校园活动管理系统/"
} else {
    Write-Host "   ❌ 未找到 dist 目录，请先构建前端" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ 文件上传完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📋 下一步操作（在服务器上执行）：" -ForegroundColor Cyan
Write-Host "   1. SSH 连接到服务器: ssh $SERVER_USER@$SERVER_IP" -ForegroundColor White
Write-Host "   2. 重载 Nginx: sudo systemctl reload nginx" -ForegroundColor White
Write-Host "   3. 检查服务状态: pm2 status" -ForegroundColor White
Write-Host ""

