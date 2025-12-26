const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')

const buildWhereClause = (filters) => {
  if (!filters.length) {
    return { clause: '', replacements: [] }
  }
  const clause = `WHERE ${filters.map((f) => f.statement).join(' AND ')}`
  const replacements = filters.flatMap((f) => f.values)
  return { clause, replacements }
}

const parseBoolean = (value) => {
  if (value === undefined || value === null || value === '' || value === 'all') {
    return null
  }
  if (value === true || value === 'true' || value === '1' || value === 1) {
    return 1
  }
  if (value === false || value === 'false' || value === '0' || value === 0) {
    return 0
  }
  return null
}

const parseDate = (value) => {
  if (!value) return null
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return null
  }
  return date
}

exports.getLogs = async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1)
    const pageSize = Math.min(Math.max(parseInt(req.query.pageSize, 10) || 20, 1), 200)
    const offset = (page - 1) * pageSize

    const keyword = req.query.keyword?.trim()
    const method = req.query.method?.toUpperCase()
    const successFilter = parseBoolean(req.query.success)
    const startDate = parseDate(req.query.startDate)
    const endDate = parseDate(req.query.endDate)

    const filters = []
    if (keyword) {
      filters.push({
        statement: '(username LIKE ? OR action LIKE ? OR route LIKE ? OR ip_address LIKE ?)',
        values: Array(4).fill(`%${keyword}%`)
      })
    }
    if (method && ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].includes(method)) {
      filters.push({ statement: 'method = ?', values: [method] })
    }
    if (successFilter !== null) {
      filters.push({ statement: 'success = ?', values: [successFilter] })
    }
    if (startDate) {
      filters.push({ statement: 'created_at >= ?', values: [startDate] })
    }
    if (endDate) {
      filters.push({ statement: 'created_at <= ?', values: [endDate] })
    }

    const { clause, replacements } = buildWhereClause(filters)

    const listSql = `
      SELECT 
        log_id AS id,
        user_id AS userId,
        username,
        action,
        method,
        route,
        status_code AS statusCode,
        success,
        duration_ms AS durationMs,
        ip_address AS ipAddress,
        user_agent AS userAgent,
        request_payload AS requestPayload,
        created_at AS createdAt
      FROM activity_logs
      ${clause}
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    `
    const list = await sequelize.query(listSql, {
      replacements: [...replacements, pageSize, offset],
      type: QueryTypes.SELECT
    })

    const countSql = `SELECT COUNT(*) AS total FROM activity_logs ${clause}`
    const [countRow] = await sequelize.query(countSql, {
      replacements,
      type: QueryTypes.SELECT
    })

    const statsSql = `
      SELECT 
        COUNT(*) AS total,
        SUM(success = 1) AS successCount,
        SUM(success = 0) AS failureCount,
        AVG(duration_ms) AS avgDuration
      FROM activity_logs
      ${clause}
    `
    const [statsRow] = await sequelize.query(statsSql, {
      replacements,
      type: QueryTypes.SELECT
    })

    const topUsersFilters = [...filters, {
        statement: "username IS NOT NULL AND username <> ''",
      values: []
    }]
    const { clause: topUsersClause, replacements: topUsersParams } = buildWhereClause(topUsersFilters)
    const topUsersSql = `
      SELECT username, COUNT(*) AS count
      FROM activity_logs
      ${topUsersClause}
      GROUP BY username
      ORDER BY count DESC
      LIMIT 5
    `
    const topUsers = await sequelize.query(topUsersSql, {
      replacements: topUsersParams,
      type: QueryTypes.SELECT
    })

    const topRoutesSql = `
      SELECT route, COUNT(*) AS count
      FROM activity_logs
      ${clause}
      GROUP BY route
      ORDER BY count DESC
      LIMIT 5
    `
    const topRoutes = await sequelize.query(topRoutesSql, {
      replacements,
      type: QueryTypes.SELECT
    })

    return success(res, {
      list,
      total: countRow?.total || 0,
      page,
      pageSize,
      stats: {
        total: statsRow?.total || 0,
        successCount: statsRow?.successCount || 0,
        failureCount: statsRow?.failureCount || 0,
        avgDuration: Number(statsRow?.avgDuration || 0),
        topUsers,
        topRoutes
      }
    })
  } catch (err) {
    // 如果表不存在，返回友好的错误信息
    if (err.message && err.message.includes("doesn't exist")) {
      return error(res, '操作日志表尚未创建，请联系管理员', 503)
    }
    console.error('获取操作日志失败:', err)
    return error(res, '获取操作日志失败', 500)
  }
}
