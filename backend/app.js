const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ 
  path: path.join(__dirname, '.env') // 明确指定 .env 文件路径
});

// 调试：打印当前工作目录和 .env 路径
console.log('[APP] 当前工作目录:', process.cwd());
console.log('[APP] 尝试加载 .env 文件:', path.join(__dirname, '.env'));

// 打印关键环境变量（即使为 undefined 也要输出）
console.log('[APP] DB_HOST:', process.env.DB_HOST);
console.log('[APP] DB_USER:', process.env.DB_USER);
console.log('[APP] DB_PASSWORD:', process.env.DB_PASSWORD);
console.log('[APP] DB_NAME:', process.env.DB_NAME);

const app = express();
// 中间件
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      if (origin.startsWith('http://localhost')) {
        return callback(null, true);
      }
      return callback(new Error('Not allowed by CORS'));
    },
    credentials: true
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态资源
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ==== 关键改动 1: 初始化数据库连接 ====
const sequelize = require('./config/database'); // 引入数据库配置

// ✅ 关键改动 2: 使用 async/await 确保数据库测试完成
(async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ 数据库连接成功!');

    // 路由
    app.use('/api/auth', require('./routes/auth'));
    app.use('/api/events', require('./routes/events'));
    app.use('/api/organizer', require('./routes/organizer'));
    app.use('/api/registrations', require('./routes/registrations'));
    app.use('/api/comments', require('./routes/comments'));
    app.use('/api/users', require('./routes/users'));
    app.use('/api/rewards', require('./routes/rewards'));

    // 健康检查
    app.get('/api/health', (req, res) => {
      res.json({ code: 200, message: '服务运行正常' });
    });

    // 错误处理
    const errorHandler = require('./middleware/errorHandler');
    app.use(errorHandler);

    // 404 处理
    app.use((req, res) => {
      res.status(404).json({ code: 404, message: '接口不存在' });
    });

    // 启动服务器
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`服务器运行在 http://localhost:${PORT}`);
      console.log(`API 文档: http://localhost:${PORT}/api/health`);
    });
  } catch (err) {
    console.error('❌ 数据库连接失败:', err);
    process.exit(1); // 如果数据库连接失败，退出进程
  }
})();
// ===================================