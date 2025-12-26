@echo off
REM 积分排行榜性能优化 - 快速测试指南 (Windows)

echo.
echo =========================================
echo 积分排行榜性能优化 - 快速测试
echo =========================================
echo.

echo [✓] 步骤 1: 启动后端服务
echo     命令: cd backend ^&^& npm start
echo     预期: 看到 '✅ 数据库连接成功!' 和 '服务器运行在 http://localhost:3000'
echo.

echo [✓] 步骤 2: 启动前端开发服务器 (新终端)
echo     命令: cd 校园活动管理系统 ^&^& npm run dev
echo     预期: Vite 开发服务器启动
echo.

echo [✓] 步骤 3: 打开浏览器开发者工具
echo     快捷键: F12 或 Ctrl+Shift+I
echo     切换到 Console 标签页
echo.

echo [✓] 步骤 4: 点击积分排行榜按钮
echo     预期输出:
echo       [排行榜] 开始加载，参数: {limit: 10, offset: 0}
echo       [排行榜] 响应数据: {ranking: [...], pagination: {...}}
echo       [排行榜] 加载完成，返回 10 条数据
echo.

echo [✓] 步骤 5: 检查后端服务器日志
echo     关键日志:
echo       [排行榜] 开始查询，限制为10，偏移为0
echo       [排行榜] 查询完成，用时XXXms，返回N条记录
echo       [排行榜] 分页：总N条，第1/P页，返回10条
echo.

echo [✓] 步骤 6: 检查性能指标
echo     查询时间: 应在 1000ms 以内
echo     响应时间: 应在 2000ms 以内
echo.

echo =========================================
echo 如果看到上述日志，说明优化成功！
echo =========================================
echo.

echo 常见问题排查:
echo   1. 加载一直显示 loading:
echo      - 查看浏览器 Network 标签，检查请求是否完成
echo      - 查看浏览器 Console，检查是否有错误信息
echo      - 查看服务器日志，检查是否有错误
echo.
echo   2. 显示错误信息:
echo      - 点击 '重试' 按钮
echo      - 查看完整的错误信息
echo      - 查看服务器日志了解详细原因
echo.
echo   3. 查询很慢（^> 3s）:
echo      - 需要应用数据库索引
echo      - 执行 SQL: backend\scripts\optimize-ranking.sql
echo      - 然后重新测试
echo.

echo 详细指南: 查看 DEBUG_RANKING.md
echo.
pause
