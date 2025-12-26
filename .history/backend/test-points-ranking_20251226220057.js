/**
 * 测试积分排行榜功能的完整流程
 * 验证：
 * 1. v_user_points 视图能否正确查询
 * 2. 用户表的 role 字段能否正确获取
 * 3. 排行榜查询返回的数据结构是否与前端期望匹配
 */

const sequelize = require('./config/database')
const { QueryTypes } = require('sequelize')

async function testPointsRanking() {
  try {
    console.log('\n========== 积分排行榜流程验证 ==========\n')

    // 测试1: 验证 v_user_points 视图
    console.log('【测试1】验证 v_user_points 视图数据:')
    const viewData = await sequelize.query(
      'SELECT * FROM v_user_points ORDER BY total_points DESC LIMIT 5',
      { type: QueryTypes.SELECT }
    )
    console.log('视图数据行数:', viewData.length)
    console.log('前5条数据:', JSON.stringify(viewData, null, 2))

    // 测试2: 验证 users 表的 role 字段
    console.log('\n【测试2】验证 users 表的 role 字段:')
    const usersWithRole = await sequelize.query(
      'SELECT user_id, username, role, avatar FROM users LIMIT 5',
      { type: QueryTypes.SELECT }
    )
    console.log('用户数据（含role字段）:', JSON.stringify(usersWithRole, null, 2))

    // 测试3: 验证完整的排行榜查询
    console.log('\n【测试3】执行完整排行榜查询:')
    const sql = `
      SELECT 
        sub.userId,
        sub.username,
        sub.userType,  
        sub.avatar,
        sub.totalPoints,
        sub.rankNum AS \`rank\`
      FROM (
        SELECT 
          vup.user_id AS userId,
          u.username,
          u.role AS userType, 
          u.avatar,
          vup.total_points AS totalPoints,
          RANK() OVER (ORDER BY vup.total_points DESC, vup.user_id ASC) AS rankNum
        FROM v_user_points vup
        LEFT JOIN users u ON vup.user_id = u.user_id
        WHERE vup.total_points > 0
      ) sub
      ORDER BY sub.rankNum ASC
      LIMIT 10 OFFSET 0
    `
    
    const ranking = await sequelize.query(sql, { type: QueryTypes.SELECT })
    console.log('排行榜查询结果数:', ranking.length)
    console.log('排行榜数据示例:', JSON.stringify(ranking.slice(0, 3), null, 2))

    // 测试4: 验证总数统计
    console.log('\n【测试4】验证总数统计:')
    const [totalResult] = await sequelize.query(
      'SELECT COUNT(*) AS total FROM v_user_points WHERE total_points > 0',
      { type: QueryTypes.SELECT }
    )
    const total = totalResult ? totalResult.total : 0
    const limit = 10
    const pageCount = Math.ceil(total / limit)
    
    console.log('总记录数:', total)
    console.log('每页记录数:', limit)
    console.log('总页数:', pageCount)

    // 测试5: 验证返回结构是否与前端期望匹配
    console.log('\n【测试5】验证返回结构与前端期望匹配:')
    const responseStructure = {
      ranking: ranking.slice(0, 2),
      pagination: {
        total,
        limit,
        offset: 0,
        pageCount
      }
    }
    console.log('完整响应结构:', JSON.stringify(responseStructure, null, 2))
    
    // 验证前端期望的字段
    console.log('\n【验证】前端期望的字段:')
    if (ranking.length > 0) {
      const item = ranking[0]
      console.log('✓ userId:', item.userId)
      console.log('✓ username:', item.username)
      console.log('✓ userType:', item.userType)
      console.log('✓ avatar:', item.avatar)
      console.log('✓ totalPoints:', item.totalPoints)
      console.log('✓ rank:', item.rank)
    }

    // 测试6: 验证 point_transactions 表的数据
    console.log('\n【测试6】验证 point_transactions 表的数据:')
    const transactionCount = await sequelize.query(
      'SELECT COUNT(*) AS total FROM point_transactions',
      { type: QueryTypes.SELECT }
    )
    console.log('总交易记录数:', transactionCount[0].total)
    
    const sampleTransactions = await sequelize.query(
      'SELECT * FROM point_transactions LIMIT 3',
      { type: QueryTypes.SELECT }
    )
    console.log('交易记录示例:', JSON.stringify(sampleTransactions, null, 2))

    console.log('\n========== 测试完成 ==========\n')

  } catch (err) {
    console.error('测试失败:', err)
  } finally {
    await sequelize.close()
  }
}

testPointsRanking()
