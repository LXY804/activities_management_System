const { QueryTypes } = require('sequelize')
const sequelize = require('../config/database')

const SENSITIVE_KEYS = ['password', 'pwd', 'newPassword', 'oldPassword', 'token', 'authorization']
const MAX_PAYLOAD_LENGTH = 2000

const sanitizePayload = (payload) => {
  if (!payload || typeof payload !== 'object') {
    return payload || null
  }

  const clone = Array.isArray(payload) ? [...payload] : { ...payload }

  const scrub = (target) => {
    if (!target || typeof target !== 'object') {
      return
    }
    Object.keys(target).forEach((key) => {
      const lowerKey = key.toLowerCase()
      if (SENSITIVE_KEYS.includes(lowerKey)) {
        target[key] = '[REDACTED]'
        return
      }
      const value = target[key]
      if (value && typeof value === 'object') {
        target[key] = Array.isArray(value) ? [...value] : { ...value }
        scrub(target[key])
      }
    })
  }

  scrub(clone)
  return clone
}

const stringifyPayload = (payload) => {
  if (!payload) {
    return null
  }
  try {
    const str = JSON.stringify(payload)
    if (str.length > MAX_PAYLOAD_LENGTH) {
      return `${str.slice(0, MAX_PAYLOAD_LENGTH - 3)}...`
    }
    return str
  } catch (err) {
    return '[无法序列化的负载]'
  }
}

const buildRequestSnapshot = (req) => {
  const contentType = req.headers['content-type'] || ''
  if (contentType.includes('multipart/form-data')) {
    return '[multipart/form-data omitted]'
  }

  const data = {}
  if (req.query && Object.keys(req.query).length) {
    data.query = sanitizePayload(req.query)
  }
  if (req.body && typeof req.body === 'object' && Object.keys(req.body).length) {
    data.body = sanitizePayload(req.body)
  }

  if (!Object.keys(data).length) {
    return null
  }

  return stringifyPayload(data)
}

module.exports = (req, res, next) => {
  const start = Date.now()
  res.on('finish', () => {
    const duration = Date.now() - start
    const route = req.originalUrl.split('?')[0]
    const ip = (req.headers['x-forwarded-for'] || '').split(',')[0].trim() || req.ip || req.connection?.remoteAddress || ''
    const userAgent = req.headers['user-agent'] || ''
    const userId = req.user?.id || null
    const username = req.user?.username || null
    const payload = buildRequestSnapshot(req)

    const sql = `
      INSERT INTO activity_logs
        (user_id, username, action, method, route, status_code, success, duration_ms, ip_address, user_agent, request_payload)
      VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `
    const replacements = [
      userId,
      username,
      `${req.method} ${route}`,
      req.method,
      route,
      res.statusCode,
      res.statusCode < 400 ? 1 : 0,
      duration,
      ip,
      userAgent.slice(0, 250),
      payload
    ]

    sequelize.query(sql, {
      replacements,
      type: QueryTypes.INSERT
    }).catch((err) => {
      console.error('[activityLogger] 记录操作日志失败:', err.message)
    })
  })

  next()
}
