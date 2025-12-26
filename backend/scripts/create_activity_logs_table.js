/**
 * 创建 activity_logs 表的脚本
 * 使用方法: node scripts/create_activity_logs_table.js
 */

const fs = require('fs')
const path = require('path')
const sequelize = require('../config/database')

async function createActivityLogsTable() {
  try {
    console.log('正在连接数据库...')
    await sequelize.authenticate()
    console.log('数据库连接成功！')

    const sqlPath = path.join(__dirname, '../database/create_activity_logs.sql')
    const sql = fs.readFileSync(sqlPath, 'utf8')

    console.log('正在创建 activity_logs 表...')
    await sequelize.query(sql, { raw: true })
    console.log('✅ activity_logs 表创建成功！')

    // 验证表是否存在
    const [results] = await sequelize.query("SHOW TABLES LIKE 'activity_logs'")
    if (results.length > 0) {
      console.log('✅ 验证成功：activity_logs 表已存在')
    } else {
      console.log('⚠️  警告：表可能未创建成功，请手动检查')
    }

    process.exit(0)
  } catch (err) {
    console.error('❌ 创建表失败:', err.message)
    if (err.message.includes('already exists')) {
      console.log('ℹ️  表已存在，无需重复创建')
      process.exit(0)
    } else {
      process.exit(1)
    }
  }
}

createActivityLogsTable()

