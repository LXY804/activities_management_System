const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')

const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/
const ALLOWED_STATUS = ['pending', 'done']

const getTodayString = () => {
  const now = new Date()
  const y = now.getFullYear()
  const m = String(now.getMonth() + 1).padStart(2, '0')
  const d = String(now.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

const normalizeDate = (value) => (DATE_REGEX.test(value || '') ? value : getTodayString())

exports.getSchedules = async (req, res) => {
  try {
    const userId = req.user.id
    const date = normalizeDate(req.query.date)

    const sql = `
      SELECT
        schedule_id AS id,
        title,
        description,
        schedule_date AS scheduleDate,
        TIME_FORMAT(start_time, '%H:%i') AS startTime,
        TIME_FORMAT(end_time, '%H:%i') AS endTime,
        status
      FROM user_schedules
      WHERE user_id = ? AND schedule_date = ?
      ORDER BY
        CASE WHEN start_time IS NULL THEN 1 ELSE 0 END,
        start_time ASC,
        created_at ASC
    `

    const rows = await sequelize.query(sql, {
      replacements: [userId, date],
      type: QueryTypes.SELECT
    })

    success(res, rows)
  } catch (err) {
    console.error('获取日程失败:', err)
    error(res, '获取日程失败', 500)
  }
}

exports.createSchedule = async (req, res) => {
  try {
    const userId = req.user.id
    const {
      title,
      description = '',
      scheduleDate,
      startTime = null,
      endTime = null
    } = req.body

    if (!title || !title.trim()) {
      return error(res, '请填写日程标题', 400)
    }

    const normalizedDate = normalizeDate(scheduleDate)

    const insertSql = `
      INSERT INTO user_schedules (
        user_id, title, description, schedule_date, start_time, end_time, status
      ) VALUES (?, ?, ?, ?, ?, ?, 'pending')
    `

    const [result] = await sequelize.query(insertSql, {
      replacements: [
        userId,
        title.trim().slice(0, 120),
        description.trim(),
        normalizedDate,
        startTime || null,
        endTime || null
      ],
      type: QueryTypes.INSERT
    })

    const selectSql = `
      SELECT
        schedule_id AS id,
        title,
        description,
        schedule_date AS scheduleDate,
        TIME_FORMAT(start_time, '%H:%i') AS startTime,
        TIME_FORMAT(end_time, '%H:%i') AS endTime,
        status
      FROM user_schedules
      WHERE schedule_id = ?
    `

    const [row] = await sequelize.query(selectSql, {
      replacements: [result],
      type: QueryTypes.SELECT
    })

    success(res, row, '日程创建成功')
  } catch (err) {
    console.error('创建日程失败:', err)
    error(res, '创建日程失败', 500)
  }
}

exports.updateScheduleStatus = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params
    const { status } = req.body

    if (!ALLOWED_STATUS.includes(status)) {
      return error(res, '状态参数不正确', 400)
    }

    const checkSql = 'SELECT schedule_id FROM user_schedules WHERE schedule_id = ? AND user_id = ?'
    const [exists] = await sequelize.query(checkSql, {
      replacements: [id, userId],
      type: QueryTypes.SELECT
    })

    if (!exists) {
      return error(res, '日程不存在', 404)
    }

    const updateSql = 'UPDATE user_schedules SET status = ? WHERE schedule_id = ?'
    await sequelize.query(updateSql, {
      replacements: [status, id],
      type: QueryTypes.UPDATE
    })

    success(res, { id, status }, '状态已更新')
  } catch (err) {
    console.error('更新日程状态失败:', err)
    error(res, '更新日程状态失败', 500)
  }
}

exports.deleteSchedule = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const checkSql = 'SELECT schedule_id FROM user_schedules WHERE schedule_id = ? AND user_id = ?'
    const [exists] = await sequelize.query(checkSql, {
      replacements: [id, userId],
      type: QueryTypes.SELECT
    })

    if (!exists) {
      return error(res, '日程不存在或已被删除', 404)
    }

    const deleteSql = 'DELETE FROM user_schedules WHERE schedule_id = ?'
    await sequelize.query(deleteSql, {
      replacements: [id],
      type: QueryTypes.DELETE
    })

    success(res, { id }, '日程已删除')
  } catch (err) {
    console.error('删除日程失败:', err)
    error(res, '删除日程失败', 500)
  }
}
