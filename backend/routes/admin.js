const express = require('express')
const { exec } = require('child_process')
const fs = require('fs')
const path = require('path')
const { authenticate, authorize } = require('../middleware/auth')

const router = express.Router()

// 管理员手动触发数据库备份
// 调用示例：POST /api/admin/backup （需管理员登录）
router.post('/backup', authenticate, authorize('admin'), (req, res) => {
  const {
    DB_NAME = 'activity_management2',
    DB_HOST = process.env.DB_HOST || '127.0.0.1',
    DB_PORT = process.env.DB_PORT || '3306',
    DB_USER,
    DB_PASSWORD,
    BACKUP_DIR = process.env.BACKUP_DIR || 'D:/db_backups',
    MYSQLDUMP_PATH = process.env.MYSQLDUMP_PATH || 'mysqldump'
  } = process.env

  if (!DB_USER || !DB_PASSWORD) {
    return res.status(500).json({ code: 500, message: '未配置 DB_USER/DB_PASSWORD 环境变量' })
  }

  // 确保备份目录存在
  try {
    if (!fs.existsSync(BACKUP_DIR)) {
      fs.mkdirSync(BACKUP_DIR, { recursive: true })
    }
  } catch (e) {
    console.error('创建备份目录失败:', e)
    return res.status(500).json({ code: 500, message: '创建备份目录失败', error: e.message })
  }

  const ts = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14) // YYYYMMDDHHMMSS
  const outfile = path.join(BACKUP_DIR, `${DB_NAME}_${ts}.sql`)

  // 拼接 mysqldump 命令
  const cmd =
    `"${MYSQLDUMP_PATH}" -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ` +
    `--single-transaction --routines --triggers --events ${DB_NAME} > "${outfile}"`

  console.log('执行备份命令:', cmd)

  exec(cmd, (err, stdout, stderr) => {
    if (err) {
      console.error('备份失败:', err)
      console.error('stderr:', stderr)
      return res.status(500).json({
        code: 500,
        message: '备份失败',
        error: stderr || err.message
      })
    }

    return res.json({
      code: 200,
      message: '备份成功',
      file: outfile
    })
  })
})

module.exports = router


