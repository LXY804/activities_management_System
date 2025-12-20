const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const path = require('path')

const STATUS_ACTIVE = 'active'
const STUDENT_ROLES = ['student']
const MANAGER_ROLES = ['organizer', 'admin']

const parsePositiveInt = (value, fallback = 0, allowZero = false) => {
  const parsed = Number.parseInt(value, 10)
  if (!Number.isFinite(parsed)) return fallback
  if (allowZero && parsed === 0) return 0
  return parsed > 0 ? parsed : fallback
}

const getUserPointTotal = async (userId, transaction) => {
  const sql = 'SELECT COALESCE(SUM(change_amount), 0) AS total FROM point_transactions WHERE user_id = ?'
  const [row] = await sequelize.query(sql, {
    replacements: [userId],
    type: QueryTypes.SELECT,
    transaction
  })
  return row?.total || 0
}

exports.getGiftList = async (req, res) => {
  try {
    const status = req.query.status || STATUS_ACTIVE
    const sql = `
      SELECT 
        gift_id AS id,
        title,
        description,
        cover_image AS coverImage,
        points_cost AS pointsCost,
        stock,
        delivery_type AS deliveryType,
        status,
        created_at AS createdAt,
        updated_at AS updatedAt
      FROM gift_items
      WHERE status = ?
      ORDER BY status = 'active' DESC, created_at DESC
    `

    const gifts = await sequelize.query(sql, {
      replacements: [status],
      type: QueryTypes.SELECT
    })

    success(res, gifts)
  } catch (err) {
    console.error('获取礼品列表失败:', err)
    error(res, '获取礼品列表失败', 500)
  }
}

exports.getManagedGifts = async (req, res) => {
  try {
    const { role, id } = req.user
    let whereClause = ''
    const replacements = []

    if (role === 'organizer') {
      whereClause = 'WHERE created_by = ?'
      replacements.push(id)
    }

    const sql = `
      SELECT 
        gift_id AS id,
        title,
        description,
        cover_image AS coverImage,
        points_cost AS pointsCost,
        stock,
        delivery_type AS deliveryType,
        status,
        review_note AS reviewNote,
        created_at AS createdAt,
        updated_at AS updatedAt
      FROM gift_items
      ${whereClause}
      ORDER BY created_at DESC
    `

    const rows = await sequelize.query(sql, {
      replacements,
      type: QueryTypes.SELECT
    })

    success(res, rows)
  } catch (err) {
    console.error('获取礼品管理列表失败:', err)
    error(res, '获取礼品管理列表失败', 500)
  }
}

exports.getMySummary = async (req, res) => {
  try {
    const userId = req.user.id

    const [pointRow] = await sequelize.query(
      'SELECT total_points AS total FROM v_user_points WHERE user_id = ?',
      { replacements: [userId], type: QueryTypes.SELECT }
    )

    const transactions = await sequelize.query(
      `SELECT 
        transaction_id AS id,
        change_amount AS changeAmount,
        action_type AS actionType,
        remark,
        created_at AS createdAt
      FROM point_transactions
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT 8`,
      { replacements: [userId], type: QueryTypes.SELECT }
    )

    const orders = await sequelize.query(
      `SELECT 
        go.order_id AS id,
        go.status,
        go.total_points AS totalPoints,
        go.created_at AS createdAt,
        gi.title AS giftTitle
      FROM gift_orders go
      LEFT JOIN gift_items gi ON go.gift_id = gi.gift_id
      WHERE go.user_id = ?
      ORDER BY go.created_at DESC
      LIMIT 5`,
      { replacements: [userId], type: QueryTypes.SELECT }
    )

    success(res, {
      totalPoints: pointRow?.total || 0,
      recentTransactions: transactions,
      recentOrders: orders
    })
  } catch (err) {
    console.error('获取积分概览失败:', err)
    error(res, '获取积分概览失败', 500)
  }
}

exports.getMyOrders = async (req, res) => {
  try {
    const userId = req.user.id

    const sql = `
      SELECT 
        go.order_id AS id,
        go.status,
        go.total_points AS totalPoints,
        go.quantity,
        go.contact_name AS contactName,
        go.delivery_method AS deliveryMethod,
        go.pickup_location AS pickupLocation,
        go.created_at AS createdAt,
        gi.title AS giftTitle,
        gi.cover_image AS coverImage
      FROM gift_orders go
      LEFT JOIN gift_items gi ON go.gift_id = gi.gift_id
      WHERE go.user_id = ?
      ORDER BY go.created_at DESC
    `

    const rows = await sequelize.query(sql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    success(res, rows)
  } catch (err) {
    console.error('获取订单列表失败:', err)
    error(res, '获取订单失败', 500)
  }
}

exports.createGift = async (req, res) => {
  try {
    const creatorId = req.user.id
    const { title, description = '', coverImage = '', pointsCost, stock, deliveryType = 'offline' } = req.body

    const cost = parsePositiveInt(pointsCost)
    const inventory = parsePositiveInt(stock)

    if (!title || cost <= 0 || inventory <= 0) {
      return error(res, '请填写礼品名称、积分需求和库存', 400)
    }

    const status = req.user.role === 'admin' ? STATUS_ACTIVE : 'pending'

    let coverImagePath = coverImage
    if (req.file) {
      coverImagePath = path.posix.join('/uploads', req.file.filename)
    }

    const insertSql = `
      INSERT INTO gift_items 
        (title, description, cover_image, points_cost, stock, delivery_type, status, created_by, approved_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `

    const [giftId] = await sequelize.query(insertSql, {
      replacements: [title.trim(), description, coverImagePath, cost, inventory, deliveryType, status, creatorId, req.user.role === 'admin' ? creatorId : null],
      type: QueryTypes.INSERT
    })

    const [gift] = await sequelize.query(
      'SELECT gift_id AS id, title, description, points_cost AS pointsCost, stock, status FROM gift_items WHERE gift_id = ?',
      { replacements: [giftId], type: QueryTypes.SELECT }
    )

    success(res, gift, '礼品已提交')
  } catch (err) {
    console.error('创建礼品失败:', err)
    error(res, '创建礼品失败', 500)
  }
}

exports.updateGift = async (req, res) => {
  try {
    const giftId = req.params.id
    const { role, id } = req.user

    const [gift] = await sequelize.query(
      'SELECT gift_id, created_by, status FROM gift_items WHERE gift_id = ?',
      { replacements: [giftId], type: QueryTypes.SELECT }
    )

    if (!gift) {
      return error(res, '礼品不存在', 404)
    }

    if (role !== 'admin' && gift.created_by !== id) {
      return error(res, '无权编辑该礼品', 403)
    }

    const fields = []
    const replacements = []

    if (req.body.title) {
      fields.push('title = ?')
      replacements.push(req.body.title.trim())
    }
    if (req.body.description !== undefined) {
      fields.push('description = ?')
      replacements.push(req.body.description)
    }
    const uploadedCoverPath = req.file ? path.posix.join('/uploads', req.file.filename) : null
    if (req.file || req.body.coverImage !== undefined) {
      const coverValue = req.file ? uploadedCoverPath : req.body.coverImage
      fields.push('cover_image = ?')
      replacements.push(coverValue)
    }
    if (req.body.pointsCost !== undefined) {
      const cost = parsePositiveInt(req.body.pointsCost, -1)
      if (cost <= 0) {
        return error(res, '积分值需为正整数', 400)
      }
      fields.push('points_cost = ?')
      replacements.push(cost)
    }
    if (req.body.stock !== undefined) {
      const inventory = parsePositiveInt(req.body.stock, -1, true)
      if (inventory < 0) {
        return error(res, '库存需为正整数', 400)
      }
      fields.push('stock = ?')
      replacements.push(inventory)
    }
    if (req.body.deliveryType) {
      fields.push('delivery_type = ?')
      replacements.push(req.body.deliveryType)
    }

    if (!fields.length) {
      return error(res, '没有可更新字段', 400)
    }

    fields.push('updated_at = NOW()')

    const sql = `UPDATE gift_items SET ${fields.join(', ')} WHERE gift_id = ?`
    replacements.push(giftId)

    await sequelize.query(sql, {
      replacements,
      type: QueryTypes.UPDATE
    })

    success(res, { id: giftId }, '礼品信息已更新')
  } catch (err) {
    console.error('更新礼品失败:', err)
    error(res, '更新礼品失败', 500)
  }
}

exports.updateGiftStatus = async (req, res) => {
  try {
    const giftId = req.params.id
    const { status, reviewNote = '', approvedBy } = req.body

    if (!['pending', 'active', 'inactive', 'rejected', 'archived'].includes(status)) {
      return error(res, '状态参数不正确', 400)
    }

    const [gift] = await sequelize.query(
      'SELECT gift_id, created_by, approved_by FROM gift_items WHERE gift_id = ?',
      { replacements: [giftId], type: QueryTypes.SELECT }
    )

    if (!gift) {
      return error(res, '礼品不存在', 404)
    }

    if (req.user.role !== 'admin' && gift.created_by !== req.user.id) {
      return error(res, '无权调整该礼品状态', 403)
    }

    if (req.user.role === 'organizer' && !['active', 'inactive'].includes(status)) {
      return error(res, '仅可对已审核礼品执行上下架', 403)
    }

    const approver = req.user.role === 'admin' ? (approvedBy || req.user.id) : gift.approved_by

    const sql = `
      UPDATE gift_items
      SET status = ?, review_note = ?, approved_by = ?, updated_at = NOW()
      WHERE gift_id = ?
    `

    await sequelize.query(sql, {
      replacements: [status, reviewNote, approver, giftId],
      type: QueryTypes.UPDATE
    })

    success(res, { id: giftId, status }, '状态已更新')
  } catch (err) {
    console.error('更新礼品状态失败:', err)
    error(res, '更新礼品状态失败', 500)
  }
}

exports.redeemGift = async (req, res) => {
  const giftId = req.params.id
  const {
    quantity = 1,
    contactName = '',
    contactPhone = '',
    deliveryMethod = 'offline',
    pickupLocation = '',
    note = ''
  } = req.body

  const qty = parsePositiveInt(quantity, 0)
  if (qty <= 0) {
    return error(res, '兑换数量不正确', 400)
  }

  const t = await sequelize.transaction()
  try {
    const giftSql = `
      SELECT gift_id, title, stock, points_cost, status
      FROM gift_items
      WHERE gift_id = ?
      FOR UPDATE
    `

    const [gift] = await sequelize.query(giftSql, {
      replacements: [giftId],
      type: QueryTypes.SELECT,
      transaction: t
    })

    if (!gift) {
      await t.rollback()
      return error(res, '礼品不存在', 404)
    }

    if (gift.status !== STATUS_ACTIVE) {
      await t.rollback()
      return error(res, '礼品尚未上架', 400)
    }

    if (gift.stock < qty) {
      await t.rollback()
      return error(res, '库存不足', 400)
    }

    const totalCost = gift.points_cost * qty
    const currentPoints = await getUserPointTotal(req.user.id, t)

    if (currentPoints < totalCost) {
      await t.rollback()
      return error(res, '积分不足', 400)
    }

    const insertOrderSql = `
      INSERT INTO gift_orders 
        (gift_id, user_id, quantity, total_points, status, contact_name, contact_phone, delivery_method, pickup_location, note)
      VALUES (?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?)
    `

    const [orderId] = await sequelize.query(insertOrderSql, {
      replacements: [giftId, req.user.id, qty, totalCost, contactName, contactPhone, deliveryMethod, pickupLocation, note],
      type: QueryTypes.INSERT,
      transaction: t
    })

    await sequelize.query('UPDATE gift_items SET stock = stock - ? WHERE gift_id = ?', {
      replacements: [qty, giftId],
      type: QueryTypes.UPDATE,
      transaction: t
    })

    await sequelize.query(
      `INSERT INTO point_transactions (user_id, change_amount, action_type, related_gift_id, order_id, remark)
       VALUES (?, ?, 'spend', ?, ?, ?)`,
      {
        replacements: [req.user.id, -totalCost, giftId, orderId, `兑换 ${gift.title}`],
        type: QueryTypes.INSERT,
        transaction: t
      }
    )

    await t.commit()

    const [order] = await sequelize.query(
      `SELECT go.order_id AS id, go.status, go.total_points AS totalPoints, gi.title AS giftTitle
       FROM gift_orders go
       LEFT JOIN gift_items gi ON go.gift_id = gi.gift_id
       WHERE go.order_id = ?`,
      { replacements: [orderId], type: QueryTypes.SELECT }
    )

    success(res, order, '兑换申请已提交')
  } catch (err) {
    await t.rollback()
    console.error('兑换礼品失败:', err)
    error(res, '兑换礼品失败', 500)
  }
}

exports.getPointRules = async (req, res) => {
  try {
    const { role, id } = req.user
    const { activityId, organizerId } = req.query
    const replacements = []
    let whereClause = ''

    if (role === 'organizer') {
      whereClause = 'WHERE organizer_id = ?'
      replacements.push(id)
    } else if (organizerId) {
      whereClause = 'WHERE organizer_id = ?'
      replacements.push(organizerId)
    }

    if (activityId) {
      whereClause += whereClause ? ' AND activity_id = ?' : 'WHERE activity_id = ?'
      replacements.push(activityId)
    }

    const sql = `
      SELECT 
        rule_id AS id,
        activity_id AS activityId,
        action_label AS actionLabel,
        points_value AS pointsValue,
        description,
        is_active AS isActive
      FROM activity_point_rules
      ${whereClause}
      ORDER BY updated_at DESC
    `

    const rows = await sequelize.query(sql, {
      replacements,
      type: QueryTypes.SELECT
    })

    success(res, rows)
  } catch (err) {
    console.error('获取积分规则失败:', err)
    error(res, '获取积分规则失败', 500)
  }
}

exports.savePointRule = async (req, res) => {
  try {
    const organizerId = req.user.role === 'admin' ? (req.body.organizerId || req.user.id) : req.user.id
    const { activityId, actionLabel, pointsValue, description = '', isActive = true } = req.body

    if (!activityId || !actionLabel) {
      return error(res, '请提供活动及规则名称', 400)
    }

    const points = parsePositiveInt(pointsValue)
    if (points <= 0) {
      return error(res, '积分值需为正整数', 400)
    }

    if (req.user.role === 'organizer') {
      const [activity] = await sequelize.query(
        'SELECT activity_id FROM activities WHERE activity_id = ? AND organizer_id = ?',
        { replacements: [activityId, organizerId], type: QueryTypes.SELECT }
      )

      if (!activity) {
        return error(res, '只能为自己发布的活动配置规则', 403)
      }
    }

    const sql = `
      INSERT INTO activity_point_rules (activity_id, organizer_id, action_label, points_value, description, is_active)
      VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        points_value = VALUES(points_value),
        description = VALUES(description),
        is_active = VALUES(is_active),
        updated_at = NOW()
    `

    await sequelize.query(sql, {
      replacements: [activityId, organizerId, actionLabel, points, description, isActive ? 1 : 0],
      type: QueryTypes.INSERT
    })

    success(res, null, '积分规则已保存')
  } catch (err) {
    console.error('保存积分规则失败:', err)
    error(res, '保存积分规则失败', 500)
  }
}

exports.adjustPoints = async (req, res) => {
  try {
    const { userId, amount, reason = '', relatedActivityId = null } = req.body
    const delta = Number.parseInt(amount, 10)

    if (!userId || !Number.isFinite(delta) || delta === 0) {
      return error(res, '请提供有效的用户与积分变动值', 400)
    }

    const actionType = delta > 0 ? 'earn' : 'adjust'

    await sequelize.query(
      `INSERT INTO point_transactions (user_id, change_amount, action_type, related_activity_id, remark)
       VALUES (?, ?, ?, ?, ?)`,
      {
        replacements: [userId, delta, actionType, relatedActivityId, reason || '管理员调整'],
        type: QueryTypes.INSERT
      }
    )

    success(res, null, '积分已调整')
  } catch (err) {
    console.error('调整积分失败:', err)
    error(res, '调整积分失败', 500)
  }
}

exports.getOrganizerAnalytics = async (req, res) => {
  try {
    const organizerId = req.user.id

    const [pointsRow] = await sequelize.query(
      `SELECT COALESCE(SUM(pt.change_amount), 0) AS total
       FROM point_transactions pt
       WHERE pt.change_amount > 0
         AND pt.related_activity_id IN (
           SELECT activity_id FROM activities WHERE organizer_id = ?
         )`,
      { replacements: [organizerId], type: QueryTypes.SELECT }
    )

    const giftHeat = await sequelize.query(
      `SELECT gi.gift_id AS id, gi.title, COALESCE(SUM(go.quantity), 0) AS redeemed
       FROM gift_items gi
       LEFT JOIN gift_orders go ON gi.gift_id = go.gift_id
       WHERE gi.created_by = ?
       GROUP BY gi.gift_id, gi.title
       ORDER BY redeemed DESC
       LIMIT 5`,
      { replacements: [organizerId], type: QueryTypes.SELECT }
    )

    const [pendingGift] = await sequelize.query(
      `SELECT COUNT(*) AS pending
       FROM gift_items
       WHERE created_by = ? AND status = 'pending'`,
      { replacements: [organizerId], type: QueryTypes.SELECT }
    )

    success(res, {
      totalPointsIssued: pointsRow?.total || 0,
      pendingGifts: pendingGift?.pending || 0,
      giftHeat
    })
  } catch (err) {
    console.error('获取组织者看板失败:', err)
    error(res, '获取数据失败', 500)
  }
}

exports.getAdminOrders = async (req, res) => {
  try {
    const { status, keyword, limit = 80 } = req.query
    const clauses = []
    const replacements = []

    if (status) {
      clauses.push('go.status = ?')
      replacements.push(status)
    }

    if (keyword) {
      const like = `%${keyword.trim()}%`
      clauses.push('(u.real_name LIKE ? OR u.username LIKE ? OR gi.title LIKE ? OR go.contact_name LIKE ? )')
      replacements.push(like, like, like, like)
    }

    const whereClause = clauses.length ? `WHERE ${clauses.join(' AND ')}` : ''
    const rowLimit = Math.min(Math.max(parsePositiveInt(limit, 80), 20), 200)

    const sql = `
      SELECT 
        go.order_id AS id,
        go.status,
        go.total_points AS totalPoints,
        go.quantity,
        go.created_at AS createdAt,
        go.updated_at AS updatedAt,
        go.contact_name AS contactName,
        go.contact_phone AS contactPhone,
        go.delivery_method AS deliveryMethod,
        go.pickup_location AS pickupLocation,
        gi.title AS giftTitle,
        gi.cover_image AS coverImage,
        gi.points_cost AS giftCost,
        gi.stock,
        u.username,
        u.real_name AS realName,
        u.student_id AS studentId
      FROM gift_orders go
      LEFT JOIN gift_items gi ON go.gift_id = gi.gift_id
      LEFT JOIN users u ON go.user_id = u.user_id
      ${whereClause}
      ORDER BY go.created_at DESC
      LIMIT ?
    `

    replacements.push(rowLimit)

    const rows = await sequelize.query(sql, {
      replacements,
      type: QueryTypes.SELECT
    })

    success(res, rows)
  } catch (err) {
    console.error('获取管理员订单失败:', err)
    error(res, '获取订单列表失败', 500)
  }
}

exports.getAdminOverview = async (req, res) => {
  try {
    const [pointsRow] = await sequelize.query(
      `SELECT COALESCE(SUM(CASE WHEN change_amount > 0 THEN change_amount ELSE 0 END), 0) AS issued,
              COALESCE(SUM(CASE WHEN change_amount < 0 THEN change_amount ELSE 0 END), 0) AS spent
       FROM point_transactions`,
      { type: QueryTypes.SELECT }
    )

    const [ordersRow] = await sequelize.query(
      `SELECT COUNT(*) AS totalOrders
       FROM gift_orders`,
      { type: QueryTypes.SELECT }
    )

    const lowStock = await sequelize.query(
      `SELECT gift_id AS id, title, stock
       FROM gift_items
       WHERE status = 'active' AND stock < 20
       ORDER BY stock ASC
       LIMIT 10`,
      { type: QueryTypes.SELECT }
    )

    success(res, {
      totalPointsIssued: pointsRow?.issued || 0,
      totalPointsConsumed: Math.abs(pointsRow?.spent || 0),
      totalOrders: ordersRow?.totalOrders || 0,
      lowStock
    })
  } catch (err) {
    console.error('获取管理员概览失败:', err)
    error(res, '获取管理员概览失败', 500)
  }
}

exports.updateOrderStatus = async (req, res) => {
  const orderId = req.params.id
  const { status, refundPoints, restockStock, adminRemark = '' } = req.body
  const allowed = ['pending', 'processing', 'shipped', 'received', 'cancelled']

  if (!allowed.includes(status)) {
    return error(res, '状态参数不正确', 400)
  }

  const t = await sequelize.transaction()
  try {
    const orderSql = `
      SELECT go.order_id, go.status, go.gift_id, go.user_id, go.quantity, go.total_points, gi.title, gi.stock
      FROM gift_orders go
      LEFT JOIN gift_items gi ON go.gift_id = gi.gift_id
      WHERE go.order_id = ?
      FOR UPDATE
    `

    const [order] = await sequelize.query(orderSql, {
      replacements: [orderId],
      type: QueryTypes.SELECT,
      transaction: t
    })

    if (!order) {
      await t.rollback()
      return error(res, '订单不存在', 404)
    }

    if (order.status === status) {
      await t.rollback()
      return success(res, { id: orderId, status }, '状态未发生变化')
    }

    await sequelize.query(
      'UPDATE gift_orders SET status = ?, updated_at = NOW() WHERE order_id = ?',
      {
        replacements: [status, orderId],
        type: QueryTypes.UPDATE,
        transaction: t
      }
    )

    const shouldRefund = status === 'cancelled' && refundPoints !== false
    const shouldRestock = status === 'cancelled' && restockStock !== false

    if (shouldRestock) {
      await sequelize.query('UPDATE gift_items SET stock = stock + ? WHERE gift_id = ?', {
        replacements: [order.quantity, order.gift_id],
        type: QueryTypes.UPDATE,
        transaction: t
      })
    }

    if (shouldRefund) {
      await sequelize.query(
        `INSERT INTO point_transactions (user_id, change_amount, action_type, related_gift_id, order_id, remark)
         VALUES (?, ?, 'adjust', ?, ?, ?)`,
        {
          replacements: [order.user_id, order.total_points, order.gift_id, orderId, adminRemark || '订单取消退款'],
          type: QueryTypes.INSERT,
          transaction: t
        }
      )
    }

    await t.commit()
    success(res, { id: orderId, status }, '订单状态已更新')
  } catch (err) {
    await t.rollback()
    console.error('更新订单状态失败:', err)
    error(res, '订单状态更新失败', 500)
  }
}

exports.createFeedback = async (req, res) => {
  try {
    const userId = req.user.id
    const orderId = req.params.id
    const { rating, content = '' } = req.body

    const score = parsePositiveInt(rating, 0)
    if (score < 1 || score > 5) {
      return error(res, '评分需在 1-5 之间', 400)
    }

    const [order] = await sequelize.query(
      'SELECT order_id, user_id FROM gift_orders WHERE order_id = ?',
      { replacements: [orderId], type: QueryTypes.SELECT }
    )

    if (!order || order.user_id !== userId) {
      return error(res, '无法评价该订单', 403)
    }

    const [exists] = await sequelize.query(
      'SELECT feedback_id FROM gift_feedback WHERE order_id = ?',
      { replacements: [orderId], type: QueryTypes.SELECT }
    )

    if (exists) {
      return error(res, '已评价过该订单', 400)
    }

    await sequelize.query(
      'INSERT INTO gift_feedback (order_id, user_id, rating, content) VALUES (?, ?, ?, ?)',
      { replacements: [orderId, userId, score, content], type: QueryTypes.INSERT }
    )

    success(res, null, '感谢你的反馈')
  } catch (err) {
    console.error('提交礼品反馈失败:', err)
    error(res, '提交礼品反馈失败', 500)
  }
}
