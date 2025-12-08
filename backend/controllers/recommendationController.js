const { QueryTypes } = require('sequelize')
const sequelize = require('../config/database')
const { success, error } = require('../utils/response')

// 获取用户推荐列表（优先读离线表，无则回退热门）
exports.getUserRecommendations = async (req, res) => {
  try {
    const userId = Number(req.query.user_id || req.user?.id)
    if (!userId) {
      return error(res, 'user_id 必填', 400)
    }

    // 读取离线计算结果
    const recSql = `
      SELECT 
        r.activity_id,
        r.score,
        a.activity_name AS title,
        a.cover_image AS cover_url,
        a.start_time,
        a.end_time,
        a.location,
        a.type_id
      FROM rec_user_topn r
      JOIN activities a ON a.activity_id = r.activity_id
      WHERE r.user_id = ?
        AND a.end_time > NOW()
      ORDER BY r.score DESC
      LIMIT 20
    `
    const recRows = await sequelize.query(recSql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    if (recRows.length > 0) {
      return success(res, recRows)
    }

    // 回退：近 30 天热门（报名数）
    const fallbackSql = `
      SELECT 
        a.activity_id,
        a.activity_name AS title,
        a.cover_image AS cover_url,
        a.start_time,
        a.end_time,
        a.location,
        a.type_id,
        COALESCE(cnt.cnt, 0) AS hot_score
      FROM activities a
      LEFT JOIN (
        SELECT activity_id, COUNT(*) AS cnt
        FROM user_activity_apply
        WHERE applied_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
          AND apply_status IN (0, 1)
        GROUP BY activity_id
      ) cnt ON cnt.activity_id = a.activity_id
      WHERE a.end_time > NOW()
        AND a.capacity > 0
      ORDER BY cnt.cnt DESC
      LIMIT 20
    `
    const fallbackRows = await sequelize.query(fallbackSql, {
      type: QueryTypes.SELECT
    })

    return success(res, fallbackRows)
  } catch (err) {
    console.error('获取推荐列表错误:', err)
    return error(res, '服务器错误', 500)
  }
}

// 获取相似活动列表
exports.getSimilarActivities = async (req, res) => {
  try {
    const activityId = Number(req.query.activity_id)
    if (!activityId) {
      return error(res, 'activity_id 必填', 400)
    }

    const sql = `
      SELECT 
        s.sim_activity_id AS activity_id,
        s.sim_score,
        a.activity_name AS title,
        a.cover_image AS cover_url,
        a.start_time,
        a.end_time,
        a.location,
        a.type_id
      FROM rec_activity_sim s
      JOIN activities a ON a.activity_id = s.sim_activity_id
      WHERE s.activity_id = ?
        AND a.end_time > NOW()
      ORDER BY s.sim_score DESC
      LIMIT 20
    `

    const rows = await sequelize.query(sql, {
      replacements: [activityId],
      type: QueryTypes.SELECT
    })

    return success(res, rows)
  } catch (err) {
    console.error('获取相似活动错误:', err)
    return error(res, '服务器错误', 500)
  }
}

