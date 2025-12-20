const sequelize = require('./config/database')
const { QueryTypes } = require('sequelize')

async function fixPasswordField() {
  try {
    await sequelize.query(
      'ALTER TABLE users MODIFY COLUMN password VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL',
      { type: QueryTypes.RAW }
    )
    console.log('✅ 密码字段长度已更新为 VARCHAR(255)')
    process.exit(0)
  } catch (err) {
    console.error('❌ 更新失败:', err.message)
    process.exit(1)
  }
}

fixPasswordField()

