/**
 * 离线计算推荐结果（Node 版）
 * 用法：node scripts/recalc_reco.js
 * 依赖：mysql2（项目已有）
 */

// 加载环境变量（数据库配置等）
require('dotenv').config()
const mysql = require('mysql2/promise')

// ============ 配置参数（从.env文件读取或使用默认值）============
const DAYS = parseInt(process.env.REC_WINDOW_DAYS || '30', 10)         // 只看最近多少天的数据（时间窗口）
const TOPK_SIM = parseInt(process.env.REC_TOPK_SIM || '50', 10)       // 每个活动最多保留多少个相似活动
const TOPN_USER = parseInt(process.env.REC_TOPN_USER || '30', 10)     // 给每个用户最多推荐多少个活动
const WEIGHT_SIM = parseFloat(process.env.REC_WEIGHT_SIM || '0.7')    // 相似度权重（占70%）
const WEIGHT_POP = parseFloat(process.env.REC_WEIGHT_POP || '0.3')    // 热度权重（占30%）
const BATCH_SIZE = 2000  // 批量写入数据库时，每次写多少条记录

// ============ 创建数据库连接池 ============
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'activity_management',
  waitForConnections: true,
  connectionLimit: 10
})

// ============ 函数1：从数据库获取报名记录 ============
/**
 * 查询最近DAYS天内有效的报名记录
 * 只查：报名成功的、活动还没结束的、活动还有名额的
 */
async function fetchEvents() {
  const sql = `
    SELECT 
      ua.user_id,          -- 用户ID
      ua.activity_id,      -- 活动ID
      ua.applied_at,       -- 报名时间
      ua.apply_status,     -- 报名状态（0待审核，1已通过）
      a.start_time,        -- 活动开始时间
      a.end_time,          -- 活动结束时间
      a.capacity           -- 活动名额
    FROM user_activity_apply ua
    JOIN activities a ON a.activity_id = ua.activity_id
    WHERE ua.applied_at >= DATE_SUB(NOW(), INTERVAL ? DAY)  -- 只看最近?天的记录
      AND ua.apply_status IN (0, 1)      -- 状态是待审核或已通过
      AND a.end_time > NOW()             -- 活动还没结束
      AND a.capacity > 0                 -- 活动还有名额
  `
  const [rows] = await pool.query(sql, [DAYS])
  return rows  // 返回查询结果数组
}

// ============ 函数2：构建共现矩阵 ============
/**
 * 核心函数：分析哪些活动经常被同一个人报名
 * 输入：报名记录数组
 * 输出：三个重要的数据结构
 */
function buildCooccurrence(events) {
  // 1. userItems: 记录每个用户报名了哪些活动
  //    格式：{用户ID: Set{活动ID1, 活动ID2, ...}}
  const userItems = new Map()
  
  // 2. freq: 记录每个活动被报名的总次数
  //    格式：{活动ID: 次数}
  const freq = new Map()
  
  // 3. cooc: 共现矩阵，记录两个活动被同一个人报名的次数
  //    格式：{活动ID1: {活动ID2: 次数, 活动ID3: 次数}}
  const cooc = new Map()

  // 第一步：遍历所有报名记录，填充userItems和freq
  for (const e of events) {
    // 如果这个用户还没记录，创建一个新的Set
    if (!userItems.has(e.user_id)) {
      userItems.set(e.user_id, new Set())
    }
    // 把这个活动加入到用户的报名集合中
    userItems.get(e.user_id).add(e.activity_id)
  }

  // 第二步：统计每个活动的总报名次数
  for (const set of userItems.values()) {
    const arr = [...set]  // 把Set转成数组
    for (const activityId of arr) {
      // 活动ID每出现一次，次数+1
      freq.set(activityId, (freq.get(activityId) || 0) + 1)
    }
  }

  // 第三步：计算共现矩阵（核心！）
  // 遍历每个用户报名的活动集合
  for (const set of userItems.values()) {
    const arr = [...set]  // 用户报名的所有活动ID数组
    
    // 双重循环：计算这个用户报名的每对活动
    for (let a = 0; a < arr.length; a++) {
      for (let b = a + 1; b < arr.length; b++) {
        const activityIdA = arr[a]
        const activityIdB = arr[b]
        
        // 初始化map（如果不存在的话）
        if (!cooc.has(activityIdA)) cooc.set(activityIdA, new Map())
        if (!cooc.has(activityIdB)) cooc.set(activityIdB, new Map())
        
        // A和B被同一个人报名，共现次数+1
        cooc.get(activityIdA).set(activityIdB, (cooc.get(activityIdA).get(activityIdB) || 0) + 1)
        // B和A也+1（对称的）
        cooc.get(activityIdB).set(activityIdA, (cooc.get(activityIdB).get(activityIdA) || 0) + 1)
      }
    }
  }

  // 返回三个重要的数据结构
  return { userItems, freq, cooc }
}

// ============ 函数3：计算活动热度 ============
/**
 * 计算每个活动的相对热度（归一化到0-1之间）
 * 最近被报名次数越多，热度越高
 */
function computePop(events) {
  const popCount = new Map()
  
  // 统计每个活动被报名的次数
  for (const e of events) {
    popCount.set(e.activity_id, (popCount.get(e.activity_id) || 0) + 1)
  }
  
  // 找到最大的报名次数（用于归一化）
  const maxPop = Math.max(...popCount.values(), 1)  // 至少为1，避免除0
  
  // 归一化：每个活动的热度 = 该活动次数 / 最大次数
  const popRecent = new Map()
  for (const [activityId, count] of popCount.entries()) {
    popRecent.set(activityId, count / maxPop)  // 结果在0-1之间
  }
  
  return popRecent
}

// ============ 函数4：计算活动相似度 ============
/**
 * 基于共现矩阵计算活动之间的相似度
 * 使用余弦相似度公式的变种：sim = 共现次数 / sqrt(活动A次数 * 活动B次数)
 */
function computeSim(freq, cooc) {
  // simMap: 存储每个活动的相似活动列表
  // 格式：{活动ID: [{id: 相似活动ID, score: 相似度}, ...]}
  const simMap = new Map()
  
  // 遍历共现矩阵中的每个活动
  for (const [activityIdA, coocMap] of cooc.entries()) {
    const similarities = []  // 存储这个活动所有的相似活动
    
    // 遍历与活动A共现的所有活动B
    for (const [activityIdB, coocCount] of coocMap.entries()) {
      // 计算相似度（Jaccard相似度的一种变体）
      // 公式：两个活动共现次数 / sqrt(活动A总次数 * 活动B总次数)
      const similarity = coocCount / Math.sqrt((freq.get(activityIdA) || 1) * (freq.get(activityIdB) || 1))
      
      similarities.push({ id: activityIdB, score: similarity })
    }
    
    // 按相似度从高到低排序
    similarities.sort((a, b) => b.score - a.score)
    
    // 只保留最相似的TOPK_SIM个活动
    simMap.set(activityIdA, similarities.slice(0, TOPK_SIM))
  }
  
  return simMap
}

// ============ 函数5：保存相似度结果到数据库 ============
/**
 * 将计算好的活动相似度写入rec_activity_sim表
 */
async function writeActivitySim(simMap) {
  // 先清空旧数据
  await pool.query('TRUNCATE TABLE rec_activity_sim')
  
  // 准备要插入的数据
  const rows = []
  for (const [activityId, similarities] of simMap.entries()) {
    for (const sim of similarities) {
      // 每行：[活动ID, 相似活动ID, 相似度分数]
      rows.push([activityId, sim.id, sim.score])
    }
  }
  
  // 批量写入（每次BATCH_SIZE条）
  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE)
    await pool.query(
      'INSERT INTO rec_activity_sim (activity_id, sim_activity_id, sim_score) VALUES ?',
      [batch]
    )
  }
  
  console.log(`rec_activity_sim 表写入 ${rows.length} 行数据`)
}

// ============ 函数6：为每个用户生成推荐 ============
/**
 * 核心推荐函数：为每个用户计算推荐活动
 * 算法：基于用户历史报名的活动，找到相似活动，加权排序
 */
async function writeUserReco(userItems, simMap, popRecent, activityMeta) {
  // 先清空旧的推荐结果
  await pool.query('TRUNCATE TABLE rec_user_topn')
  
  const rows = []  // 存储要插入数据库的所有推荐记录

  // 遍历每个用户
  for (const [userId, userActivitySet] of userItems.entries()) {
    const alreadyApplied = userActivitySet  // 用户已经报名的活动（不再推荐）
    const scoreMap = new Map()  // 存储活动得分：{活动ID: 总得分}
    
    // 获取用户最近报名的活动（这里简化：直接用所有历史活动）
    const recentItems = [...userActivitySet]

    // 基于用户报名的每个活动，推荐相似活动
    for (const activityId of recentItems) {
      // 获取这个活动的相似活动列表
      const similarities = simMap.get(activityId) || []
      
      // 遍历每个相似活动
      for (const { id: similarActivityId, score: similarityScore } of similarities) {
        // 过滤条件：
        // 1. 用户已经报过的不再推荐
        if (alreadyApplied.has(similarActivityId)) continue
        
        // 2. 活动必须存在
        const activityMetaInfo = activityMeta.get(similarActivityId)
        if (!activityMetaInfo) continue
        
        // 3. 活动必须还没结束
        if (new Date(activityMetaInfo.end_time).getTime() <= Date.now()) continue
        
        // 4. 活动必须还有名额（如果capacity为null则不限名额）
        if (activityMetaInfo.capacity !== null && activityMetaInfo.capacity <= 0) continue
        
        // 计算这个相似活动的热度分
        const popularityScore = popRecent.get(similarActivityId) || 0
        
        // 计算最终得分：相似度分 × 权重 + 热度分 × 权重
        const finalScore = WEIGHT_SIM * similarityScore + WEIGHT_POP * popularityScore
        
        // 累加得分（可能从多个历史活动都推荐了同一个活动）
        scoreMap.set(similarActivityId, (scoreMap.get(similarActivityId) || 0) + finalScore)
      }
    }

    // 对得分进行排序，取前TOPN_USER个
    const sortedRecommendations = [...scoreMap.entries()]
      .sort((a, b) => b[1] - a[1])  // 按得分从高到低排序
      .slice(0, TOPN_USER)          // 只取前N个

    // 准备插入数据库的数据
    for (const [activityId, score] of sortedRecommendations) {
      // 每行：[用户ID, 推荐活动ID, 得分, 推荐原因]
      rows.push([userId, activityId, score, 'cf'])  // 'cf'表示协同过滤算法
    }
  }

  // 批量写入数据库
  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE)
    await pool.query(
      'INSERT INTO rec_user_topn (user_id, activity_id, score, reason) VALUES ?',
      [batch]
    )
  }
  
  console.log(`rec_user_topn 表写入 ${rows.length} 行推荐数据`)
}

// ============ 函数7：获取活动元数据 ============
/**
 * 获取所有活动的基本信息（用于过滤已结束、名额满的活动）
 */
async function fetchActivityMeta() {
  const [rows] = await pool.query(
    'SELECT activity_id, start_time, end_time, capacity FROM activities'
  )
  
  // 转成Map方便查找：{活动ID: {活动信息}}
  const map = new Map()
  for (const row of rows) {
    map.set(row.activity_id, row)
  }
  
  return map
}

// ============ 主函数 ============
/**
 * 整个推荐计算流程的入口函数
 */
async function main() {
  console.log(`[推荐计算] 开始计算，时间窗口 ${DAYS} 天`)
  
  // 步骤1：获取最近的有效报名记录
  const events = await fetchEvents()
  console.log(`[推荐计算] 获取到 ${events.length} 条有效报名记录`)
  
  if (events.length === 0) {
    console.log('[推荐计算] 没有数据，跳过计算')
    await pool.end()
    return
  }

  // 步骤2：获取活动元数据（用于过滤）
  const activityMeta = await fetchActivityMeta()
  
  // 步骤3：计算活动热度
  const popRecent = computePop(events)
  
  // 步骤4：构建共现矩阵（核心）
  const { userItems, freq, cooc } = buildCooccurrence(events)
  
  // 步骤5：计算活动相似度
  const simMap = computeSim(freq, cooc)
  
  // 步骤6：保存相似度结果到数据库
  await writeActivitySim(simMap)
  
  // 步骤7：为每个用户生成推荐并保存
  await writeUserReco(userItems, simMap, popRecent, activityMeta)

  // 步骤8：关闭数据库连接
  await pool.end()
  
  console.log('[推荐计算] 完成！')
}

// ============ 程序入口 ============
// 执行主函数，并捕获可能的错误
main().catch(async (err) => {
  console.error('[推荐计算] 计算失败:', err)
  await pool.end()  // 确保关闭数据库连接
  process.exit(1)   // 退出程序，返回错误码1
})