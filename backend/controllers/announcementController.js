const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')

// 管理员：直接发布公告
exports.createAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { title, content } = req.body

    if (!title || !content) {
      return error(res, '标题和内容不能为空', 400)
    }

    const sql = `
      INSERT INTO announcements (title, content, publisher_id, publisher_type, status, published_at)
      VALUES (?, ?, ?, 'admin', 1, NOW())
    `
    const [announcementId] = await sequelize.query(sql, {
      replacements: [title, content, adminId],
      type: QueryTypes.INSERT
    })

    success(res, { announcementId }, '公告发布成功')
  } catch (err) {
    console.error('发布公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 组织者：申请发布公告（待审核）
exports.applyAnnouncement = async (req, res) => {
  try {
    const organizerId = req.user.id
    const { title, content } = req.body

    if (!title || !content) {
      return error(res, '标题和内容不能为空', 400)
    }

    const sql = `
      INSERT INTO announcements (title, content, publisher_id, publisher_type, status, admin_check)
      VALUES (?, ?, ?, 'organizer', 0, 0)
    `
    const [announcementId] = await sequelize.query(sql, {
      replacements: [title, content, organizerId],
      type: QueryTypes.INSERT
    })

    success(res, { announcementId }, '公告申请已提交，等待管理员审核')
  } catch (err) {
    console.error('申请公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取待审核公告列表
exports.getPendingAnnouncements = async (req, res) => {
  try {
    const sql = `
      SELECT 
        a.announcement_id AS id,
        a.title,
        a.content,
        a.created_at,
        u.username AS publisher_name,
        u.user_id AS publisher_id
      FROM announcements a
      INNER JOIN users u ON a.publisher_id = u.user_id
      WHERE a.status = 0 AND a.admin_check = 0
      ORDER BY a.created_at DESC
    `

    const list = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取待审核公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：审核通过公告
exports.approveAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params

    const checkSql = `
      SELECT announcement_id, status, admin_check
      FROM announcements
      WHERE announcement_id = ?
    `
    const [announcement] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status === 1) {
      return success(res, null, '该公告已发布')
    }

    const updateSql = `
      UPDATE announcements
      SET status = 1,
          admin_check = 1,
          checked_by = ?,
          checked_at = NOW(),
          published_at = NOW()
      WHERE announcement_id = ?
    `

    await sequelize.query(updateSql, {
      replacements: [adminId, id],
      type: QueryTypes.UPDATE
    })

    success(res, null, '公告审核通过')
  } catch (err) {
    console.error('审核通过公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：驳回公告
exports.rejectAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params
    const { remark } = req.body

    const checkSql = `
      SELECT announcement_id, status, admin_check
      FROM announcements
      WHERE announcement_id = ?
    `
    const [announcement] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status === 2) {
      return success(res, null, '该公告已被驳回')
    }

    const updateSql = `
      UPDATE announcements
      SET status = 2,
          admin_check = 2,
          checked_by = ?,
          checked_at = NOW(),
          check_remark = ?
      WHERE announcement_id = ?
    `

    await sequelize.query(updateSql, {
      replacements: [adminId, remark || null, id],
      type: QueryTypes.UPDATE
    })

    success(res, null, '公告已驳回')
  } catch (err) {
    console.error('驳回公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取已发布的公告列表（所有用户可见）
exports.getPublishedAnnouncements = async (req, res) => {
  try {
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT 
        a.announcement_id AS id,
        a.title,
        a.content,
        a.created_at,
        a.published_at,
        u.username AS publisher_name,
        a.publisher_type
      FROM announcements a
      INNER JOIN users u ON a.publisher_id = u.user_id
      WHERE a.status = 1
      ORDER BY a.published_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM announcements
      WHERE status = 1
    `

    const [countResult] = await sequelize.query(countSql, {
      type: QueryTypes.SELECT
    })

    const list = await sequelize.query(listSql, {
      replacements: [limit, offset],
      type: QueryTypes.SELECT
    })

    success(res, {
      list,
      total: countResult.total,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取公告列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 用户：确认公告（已读）
exports.confirmAnnouncement = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    // 检查公告是否存在且已发布
    const checkSql = `
      SELECT announcement_id, status
      FROM announcements
      WHERE announcement_id = ?
    `
    const [announcement] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status !== 1) {
      return error(res, '该公告未发布，无法确认', 400)
    }

    // 检查是否已确认
    const checkConfirmSql = `
      SELECT confirmation_id
      FROM announcement_confirmations
      WHERE announcement_id = ? AND user_id = ?
    `
    const [existing] = await sequelize.query(checkConfirmSql, {
      replacements: [id, userId],
      type: QueryTypes.SELECT
    })

    if (existing) {
      return success(res, null, '您已确认过此公告')
    }

    // 插入确认记录
    const insertSql = `
      INSERT INTO announcement_confirmations (announcement_id, user_id)
      VALUES (?, ?)
    `
    await sequelize.query(insertSql, {
      replacements: [id, userId],
      type: QueryTypes.INSERT
    })

    success(res, null, '确认成功')
  } catch (err) {
    console.error('确认公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 检查用户是否已确认公告
exports.checkConfirmation = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const sql = `
      SELECT confirmation_id
      FROM announcement_confirmations
      WHERE announcement_id = ? AND user_id = ?
    `
    const [confirmation] = await sequelize.query(sql, {
      replacements: [id, userId],
      type: QueryTypes.SELECT
    })

    success(res, { confirmed: !!confirmation })
  } catch (err) {
    console.error('检查确认状态错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取所有公告的确认数统计
exports.getAdminConfirmationStats = async (req, res) => {
  try {
    const sql = `
      SELECT 
        a.announcement_id AS id,
        a.title,
        a.published_at,
        u.username AS publisher_name,
        COUNT(ac.confirmation_id) AS confirmation_count
      FROM announcements a
      INNER JOIN users u ON a.publisher_id = u.user_id
      LEFT JOIN announcement_confirmations ac ON a.announcement_id = ac.announcement_id
      WHERE a.status = 1
      GROUP BY a.announcement_id
      ORDER BY a.published_at DESC
    `

    const list = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取确认统计错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 组织者：获取自己申请发布的公告确认数
exports.getOrganizerConfirmationStats = async (req, res) => {
  try {
    const organizerId = req.user.id

    const sql = `
      SELECT 
        a.announcement_id AS id,
        a.title,
        a.published_at,
        a.status,
        a.admin_check,
        a.check_remark,
        COUNT(ac.confirmation_id) AS confirmation_count
      FROM announcements a
      LEFT JOIN announcement_confirmations ac ON a.announcement_id = ac.announcement_id
      WHERE a.publisher_id = ? AND a.publisher_type = 'organizer'
      GROUP BY a.announcement_id
      ORDER BY a.created_at DESC
    `

    const list = await sequelize.query(sql, {
      replacements: [organizerId],
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取组织者确认统计错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 用户：获取未确认公告数量
exports.getUnconfirmedCount = async (req, res) => {
  try {
    const userId = req.user.id

    const sql = `
      SELECT COUNT(*) AS unconfirmedCount
      FROM announcements a
      WHERE a.status = 1
        AND a.announcement_id NOT IN (
          SELECT announcement_id
          FROM announcement_confirmations
          WHERE user_id = ?
        )
    `

    const [result] = await sequelize.query(sql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    success(res, { count: result?.unconfirmedCount || 0 })
  } catch (err) {
    console.error('获取未确认公告数量错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取所有公告列表（包括待审核、已发布、已驳回）
exports.getAllAnnouncements = async (req, res) => {
  try {
    const { status, page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    let whereClause = 'WHERE 1=1'
    const replacements = []

    if (status !== undefined) {
      whereClause += ' AND a.status = ?'
      replacements.push(status)
    }

    const listSql = `
      SELECT 
        a.announcement_id AS id,
        a.title,
        a.content,
        a.status,
        a.admin_check,
        a.check_remark,
        a.created_at,
        a.published_at,
        u.username AS publisher_name,
        a.publisher_type,
        checker.username AS checker_name
      FROM announcements a
      INNER JOIN users u ON a.publisher_id = u.user_id
      LEFT JOIN users checker ON a.checked_by = checker.user_id
      ${whereClause}
      ORDER BY a.created_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM announcements a
      ${whereClause}
    `

    const [countResult] = await sequelize.query(countSql, {
      replacements: replacements.slice(0, replacements.length),
      type: QueryTypes.SELECT
    })

    const list = await sequelize.query(listSql, {
      replacements: [...replacements, limit, offset],
      type: QueryTypes.SELECT
    })

    success(res, {
      list,
      total: countResult.total,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取所有公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

