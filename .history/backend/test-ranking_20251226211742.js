/**
 * 测试积分排行榜数据
 */
const { Sequelize, QueryTypes } = require('sequelize')
require('dotenv').config()

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    timezone: '+08:00'
  }
)

(async () => {
  try {
    await sequelize.authenticate()
    console.log('✅ 数据库连接成功')

    // 测试1: 查看v_user_points视图数据
    console.log('\n【测试1】查看v_user_points视图中的所有数据:')
    const viewData = await sequelize.query(
      `SELECT * FROM v_user_points ORDER BY total_points DESC`,
      { type: QueryTypes.SELECT }
    )
    console.log(JSON.stringify(viewData, null, 2))

    // 测试2: 查看有积分的用户数
    console.log('\n【测试2】查看有积分(>0)的用户数:')
    const countData = await sequelize.query(
      `SELECT COUNT(*) AS total FROM v_user_points WHERE total_points > 0`,
      { type: QueryTypes.SELECT }
    )
    console.log('有积分的用户数:', countData[0].total)

    // 测试3: 执行实际的排行榜查询
    console.log('\n【测试3】执行完整的排行榜查询:')
    const rankingQuery = `
      SELECT 
        vup.user_id AS userId,
        u.username,
        u.user_type AS userType,
        u.avatar,
        vup.total_points AS totalPoints
      FROM v_user_points vup
      LEFT JOIN users u ON vup.user_id = u.user_id
      WHERE vup.total_points > 0
      ORDER BY vup.total_points DESC, vup.user_id ASC
    `
    const ranking = await sequelize.query(rankingQuery, { type: QueryTypes.SELECT })
    console.log(`查询到 ${ranking.length} 条数据:`)
    console.log(JSON.stringify(ranking, null, 2))

    // 测试4: 查看users表和point_transactions表的数据
    console.log('\n【测试4】用户数量:')
    const userCount = await sequelize.query(
      `SELECT COUNT(*) AS total FROM users`,
      { type: QueryTypes.SELECT }
    )
    console.log('总用户数:', userCount[0].total)

    console.log('\n【测试5】积分交易记录数:')
    const transCount = await sequelize.query(
      `SELECT COUNT(*) AS total FROM point_transactions`,
      { type: QueryTypes.SELECT }
    )
    console.log('总交易记录数:', transCount[0].total)

    console.log('\n✅ 所有测试完成')
    process.exit(0)
  } catch (err) {
    console.error('❌ 测试失败:', err.message)
    console.error(err)
    process.exit(1)
  }
})()
