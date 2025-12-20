const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const { callDeepseek } = require('../utils/deepseekClient')
const path = require('path')

const registrationStatusExpr = `
  CASE ua.apply_status
    WHEN 0 THEN 'pending'
    WHEN 1 THEN 'approved'
    WHEN 2 THEN 'rejected'
    WHEN 3 THEN 'cancelled'
    ELSE 'pending'
  END
`

const eventStatusExpr = `
  CASE
    WHEN NOW() < a.start_time THEN 'upcoming'
    WHEN NOW() BETWEEN a.start_time AND a.end_time THEN 'open'
    ELSE 'ended'
  END
`

const buildBaseEventQuery = () => `
  SELECT 
    a.activity_id AS id,
    a.activity_code AS code,
    a.activity_name AS title,
    a.Activity_description AS description,
    a.location,
    a.start_time,
    a.end_time,
    a.capacity,
    a.type_id,
    CASE
      WHEN NOW() < a.start_time THEN 'upcoming'
      WHEN NOW() BETWEEN a.start_time AND a.end_time THEN 'open'
      ELSE 'ended'
    END AS status,
    u.username AS organizer_name,
    c.college_name AS target_college_name,
    (
      SELECT COUNT(*)
      FROM user_activity_apply ua
      WHERE ua.activity_id = a.activity_id
        AND ua.apply_status IN (0,1)
    ) AS signed_up,
    COALESCE(a.cover_image, '') AS cover_url
  FROM activities a
  LEFT JOIN users u ON a.organizer_id = u.user_id
  LEFT JOIN colleges c ON a.target_college_id = c.college_id
  LEFT JOIN organizer_activity_creation oac ON oac.activity_id = a.activity_id
  WHERE COALESCE(oac.admin_check, 1) = 1
`

const pad = (value) => String(value).padStart(2, '0')

const formatDateTime = (date) => {
  const year = date.getFullYear()
  const month = pad(date.getMonth() + 1)
  const day = pad(date.getDate())
  const hours = pad(date.getHours())
  const minutes = pad(date.getMinutes())
  const seconds = pad(date.getSeconds())
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

// 获取活动类型列表
exports.getActivityTypes = async (req, res) => {
  try {
    const sql = `
      SELECT 
        type_id AS id,
        type_name AS name,
        description
      FROM activity_types
      ORDER BY type_id ASC
    `
    const types = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })
    success(res, types)
  } catch (err) {
    console.error('获取活动类型列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 工具函数：根据名称获取ID
const getTypeIdByName = async (typeName) => {
  if (!typeName) return 1
  const sql = 'SELECT type_id FROM activity_types WHERE type_name = ? LIMIT 1'
  const [row] = await sequelize.query(sql, { replacements: [typeName], type: QueryTypes.SELECT })
  return row?.type_id || 1
}

const getCollegeIdByName = async (collegeName) => {
  if (!collegeName) return null
  const sql = 'SELECT college_id FROM colleges WHERE college_name = ? LIMIT 1'
  const [row] = await sequelize.query(sql, { replacements: [collegeName], type: QueryTypes.SELECT })
  return row?.college_id || null
}

const generateActivityCode = () => {
  const now = new Date()
  const y = now.getFullYear().toString().slice(-2)
  const m = String(now.getMonth() + 1).padStart(2, '0')
  const d = String(now.getDate()).padStart(2, '0')
  const ts = now.getTime().toString().slice(-4)
  return `ACT${y}${m}${d}${ts}`
}

// 使用 DeepSeek 生成活动宣传文案
exports.generateEventCopy = async (req, res) => {
  try {
    const { title, activityType, location, startTime, endTime, belongCollege, description } = req.body

    const prompt = `
你是校园活动宣传文案助手，请为下面的活动生成一段简短、有吸引力的中文宣传文案（80~120字）：

活动名称：${title || '未命名活动'}
活动类型：${activityType || '综合活动'}
活动地点：${location || '地点待定'}
活动时间：${startTime || '时间待定'} ${endTime ? `- ${endTime}` : ''}
面向学院：${belongCollege || '全体学院'}
已有简介：${description || '无'}

要求：
1. 面向大学生，语气积极、自然，有号召力，但不要夸张。
2. 用第二人称（你/大家）来写，不要出现"我是某某大模型"之类的自我介绍。
3. 不要输出标题，只输出正文一段话。
    `.trim()

    const messages = [
      { role: 'system', content: '你是校园活动宣传文案助手。' },
      { role: 'user', content: prompt }
    ]

    const copy = await callDeepseek(messages)

    success(res, { copy: (copy || '').trim() }, '生成成功')
  } catch (err) {
    console.error('生成活动文案错误:', err)
    error(res, '生成活动文案失败', 500)
  }
}

// 组织者创建活动（提交审核）
exports.createEvent = async (req, res) => {
  try {
    const organizerId = req.user.id
    const { title, description, activityType, belongCollege, location, startTime, endTime, maxParticipants } = req.body
    if (!title || !activityType || !startTime || !endTime) {
      return error(res, '请完善必填字段', 400)
    }
    const typeId = await getTypeIdByName(activityType)
    const targetCollegeId = await getCollegeIdByName(belongCollege)
    const activityCode = generateActivityCode()
    let coverImagePath = req.file ? path.posix.join('/uploads', req.file.filename) : null

    const [activityId] = await sequelize.query(`
      INSERT INTO activities (activity_name, activity_code, Activity_description, type_id, start_time, end_time, location, target_college_id, capacity, organizer_id, cover_image)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, 
      { replacements: [title, activityCode, description || '', typeId, startTime, endTime, location || '', targetCollegeId, maxParticipants || 0, organizerId, coverImagePath], type: QueryTypes.INSERT }
    )

    await sequelize.query(`INSERT INTO organizer_activity_creation (organizer_id, activity_id, admin_check) VALUES (?, ?, 0)`, { replacements: [organizerId, activityId], type: QueryTypes.INSERT })
    success(res, { id: activityId, code: activityCode }, '活动已提交审核')
  } catch (err) {
    error(res, '服务器错误', 500)
  }
}

exports.getEventList = async (req, res) => {
  try {
    const { status, category_id, keyword, page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)
    let filters = ''
    const replacements = []

    if (status) {
      const normalized = status === 'ongoing' ? 'open' : status
      if (['finished', 'ended'].includes(normalized)) {
        filters += ` AND ${eventStatusExpr} = 'ended'`
      } else {
        filters += ` AND ${eventStatusExpr} = ?`
        replacements.push(normalized)
      }
    }

    if (category_id) {
      filters += ' AND a.type_id = ?'
      replacements.push(category_id)
    }

    if (keyword) {
      filters += ' AND a.activity_name LIKE ?'
      replacements.push(`%${keyword}%`)
    }

    const baseQuery = buildBaseEventQuery()
    const listSql = `${baseQuery} ${filters} ORDER BY a.start_time DESC LIMIT ? OFFSET ?`
    const countSql = `
      SELECT COUNT(*) AS total
      FROM activities a
      LEFT JOIN organizer_activity_creation oac ON oac.activity_id = a.activity_id
      WHERE COALESCE(oac.admin_check, 1) = 1
        ${filters}
    `

    const list = await sequelize.query(listSql, {
      replacements: [...replacements, limit, offset],
      type: QueryTypes.SELECT
    })
    const [count] = await sequelize.query(countSql, {
      replacements,
      type: QueryTypes.SELECT
    })
    success(res, { list, total: count.total, page: parseInt(page, 10), pageSize: limit })
  } catch (err) {
    console.error('获取活动列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.getEventDetail = async (req, res) => {
  try {
    const baseQuery = buildBaseEventQuery()
    const [event] = await sequelize.query(`${baseQuery} AND a.activity_id = ?`, {
      replacements: [req.params.id],
      type: QueryTypes.SELECT
    })
    if (!event) return error(res, '活动不存在', 404)
    success(res, event)
  } catch (err) {
    error(res, '服务器错误', 500)
  }
}

// 近期精选：按 Capacity（容量）前五展示
exports.getHighlightedEvents = async (req, res) => {
  try {
    // 逻辑：筛选未取消的活动，按容量倒序取前 5
    const baseQuery = buildBaseEventQuery()
    const sql = `${baseQuery} AND a.start_time IS NOT NULL ORDER BY a.capacity DESC LIMIT 5`
    const highlights = await sequelize.query(sql, { type: QueryTypes.SELECT })
    success(res, highlights)
  } catch (err) {
    console.error('获取精选活动错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 【修改点】元气雷达：展示 start_time 在未来 7 天内的活动
exports.getWeeklyEvents = async (req, res) => {
  try {
    const now = new Date()
    const sevenDaysLater = new Date()
    sevenDaysLater.setDate(now.getDate() + 7)

    const baseQuery = buildBaseEventQuery()
    const sql = `${baseQuery} AND a.start_time BETWEEN ? AND ? ORDER BY a.start_time ASC`

    const list = await sequelize.query(sql, {
      replacements: [formatDateTime(now), formatDateTime(sevenDaysLater)],
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取本周活动错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.registerEvent = async (req, res) => {
  const t = await sequelize.transaction()
  try {
    const userId = req.user.id
    const { id } = req.params

    // 1) 检查用户信息是否完善
    const userInfoSql = `
      SELECT user_id, student_id, real_name, college_id
      FROM users
      WHERE user_id = ?
    `
    const [userInfo] = await sequelize.query(userInfoSql, {
      replacements: [userId],
      type: QueryTypes.SELECT,
      transaction: t
    })
    if (!userInfo) {
      await t.rollback()
      return error(res, '用户不存在', 404)
    }
    const missingFields = []
    if (!userInfo.student_id) missingFields.push('学号')
    if (!userInfo.real_name) missingFields.push('真实姓名')
    if (!userInfo.college_id) missingFields.push('学院')
    if (missingFields.length > 0) {
      await t.rollback()
      return error(res, `请先完善个人信息：${missingFields.join('、')}`, 400, {
        requiresProfileCompletion: true,
        missingFields
      })
    }

    // 2) 锁定活动行，读取容量/时间（FOR UPDATE）
    const eventSql = `
      SELECT activity_id AS id, capacity, start_time, end_time
      FROM activities
      WHERE activity_id = ?
      FOR UPDATE
    `
    const [event] = await sequelize.query(eventSql, {
      replacements: [id],
      type: QueryTypes.SELECT,
      transaction: t
    })
    if (!event) {
      await t.rollback()
      return error(res, '活动不存在', 404)
    }
    const now = new Date()
    if (event.start_time && new Date(event.start_time) <= now) {
      await t.rollback()
      return error(res, '活动已开始，无法报名', 400)
    }

    // 3) 防重复报名（行锁检查）
    const existingSql = `
      SELECT apply_id FROM user_activity_apply 
      WHERE activity_id = ? AND user_id = ? AND apply_status IN (0, 1)
      FOR UPDATE
    `
    const [existing] = await sequelize.query(existingSql, {
      replacements: [id, userId],
      type: QueryTypes.SELECT,
      transaction: t
    })
    if (existing) {
      await t.rollback()
      return error(res, '您已报名此活动', 400)
    }

    // 4) 容量检查（行锁统计）
    if (event.capacity) {
      const countSql = `
        SELECT COUNT(*) AS count
        FROM user_activity_apply
        WHERE activity_id = ? AND apply_status IN (0, 1)
        FOR UPDATE
      `
      const [count] = await sequelize.query(countSql, {
        replacements: [id],
        type: QueryTypes.SELECT,
        transaction: t
      })
      if (count.count >= event.capacity) {
        await t.rollback()
        return error(res, '活动已满员', 400)
      }
    }

    // 5) 插入报名
    const insertSql = `
      INSERT INTO user_activity_apply (activity_id, user_id, apply_status, applied_at)
      VALUES (?, ?, 0, NOW())
    `
    const [registrationId] = await sequelize.query(insertSql, {
      replacements: [id, userId],
      type: QueryTypes.INSERT,
      transaction: t
    })

    // 6) 查询结果返回
    const selectSql = `
      SELECT 
        ua.apply_id AS registration_id,
        ua.activity_id AS event_id,
        ua.user_id,
        ${registrationStatusExpr} AS registration_status,
        ua.applied_at
      FROM user_activity_apply ua
      WHERE ua.apply_id = ?
    `
    const [registration] = await sequelize.query(selectSql, {
      replacements: [registrationId],
      type: QueryTypes.SELECT,
      transaction: t
    })

    await t.commit()
    success(res, registration, '报名成功，等待审核')
  } catch (err) {
    await t.rollback()
    console.error('报名错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.getPendingEventsForAdmin = async (req, res) => {
  try {
    const sql = `SELECT oac.creation_id, a.activity_id AS id, a.activity_name AS title, u.username AS organizer_name FROM organizer_activity_creation oac INNER JOIN activities a ON oac.activity_id = a.activity_id INNER JOIN users u ON oac.organizer_id = u.user_id WHERE oac.admin_check = 0`
    const list = await sequelize.query(sql, { type: QueryTypes.SELECT })
    success(res, list)
  } catch (err) {
    error(res, '服务器错误', 500)
  }
}

exports.approveEvent = async (req, res) => {
  try {
    await sequelize.query(`UPDATE organizer_activity_creation SET admin_check = 1 WHERE creation_id = ?`, { replacements: [req.params.id], type: QueryTypes.UPDATE })
    success(res, null, '审核通过')
  } catch (err) {
    error(res, '服务器错误', 500)
  }
}

exports.rejectEvent = async (req, res) => {
  try {
    await sequelize.query(`UPDATE organizer_activity_creation SET admin_check = 2, check_remark = ? WHERE creation_id = ?`, { replacements: [req.body.remark, req.params.id], type: QueryTypes.UPDATE })
    success(res, null, '已驳回')
  } catch (err) {
    error(res, '服务器错误', 500)
  }
}