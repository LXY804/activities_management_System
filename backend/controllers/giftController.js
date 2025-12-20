const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const multer = require('multer')
const path = require('path')
const fs = require('fs')

// 配置 multer 用于上传礼品图片
const uploadDir = path.join(__dirname, '..', 'uploads', 'gifts')
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir)
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg'
    const timestamp = Date.now()
    cb(null, `gift_${timestamp}_${Math.random().toString(36).substring(7)}${ext}`)
  }
})

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true)
    } else {
      cb(new Error('只允许上传图片文件'), false)
    }
  }
}).single('image')

// 获取礼品列表（公开，无需登录）
exports.getGifts = async (req, res) => {
  try {
    const sql = `
      SELECT 
        gift_id AS id,
        title AS name,
        description,
        cover_image AS image_url,
        points_cost AS points_required,
        stock
      FROM gift_items
      WHERE stock > 0 AND status = 'active'
      ORDER BY points_cost ASC
    `

    const list = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取礼品列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取礼品详情
exports.getGiftDetail = async (req, res) => {
  try {
    const { id } = req.params

    const sql = `
      SELECT 
        gift_id AS id,
        title AS name,
        description,
        cover_image AS image_url,
        points_cost AS points_required,
        stock
      FROM gift_items
      WHERE gift_id = ?
    `

    const [gift] = await sequelize.query(sql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!gift) {
      return error(res, '礼品不存在', 404)
    }

    success(res, gift)
  } catch (err) {
    console.error('获取礼品详情错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：创建礼品
exports.createGift = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const { name, description, points_required, stock } = req.body

      if (!name || !points_required || stock === undefined) {
        return error(res, '礼品名称、所需积分和库存数量不能为空', 400)
      }

      const points = parseInt(points_required, 10)
      const stockNum = parseInt(stock, 10)

      if (isNaN(points) || points <= 0) {
        return error(res, '所需积分必须大于0', 400)
      }

      if (isNaN(stockNum) || stockNum < 0) {
        return error(res, '库存数量不能为负数', 400)
      }

      let imageUrl = null
      if (req.file) {
        imageUrl = path.posix.join('/uploads/gifts', req.file.filename)
      }

      const adminId = req.user.id
      const sql = `
      INSERT INTO gift_items (title, description, cover_image, points_cost, stock, status, created_by)
      VALUES (?, ?, ?, ?, ?, 'pending', ?)
      `
      const [giftId] = await sequelize.query(sql, {
        replacements: [name, description || '', imageUrl, points, stockNum, adminId],
        type: QueryTypes.INSERT
      })

      success(res, { giftId }, '礼品创建成功')
    } catch (err) {
      console.error('创建礼品错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 管理员：获取所有礼品列表（包括库存为0的）
exports.getAllGifts = async (req, res) => {
  try {
      const sql = `
      SELECT 
        gift_id AS id,
        title AS name,
        description,
        cover_image AS image_url,
        points_cost AS points_required,
        stock,
        created_at,
        updated_at
      FROM gift_items
      ORDER BY created_at DESC
    `

    const list = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取礼品列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：更新礼品
exports.updateGift = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const { id } = req.params
      const { name, description, points_required, stock } = req.body

      // 检查礼品是否存在
      const checkSql = 'SELECT gift_id FROM gift_items WHERE gift_id = ?'
      const [gift] = await sequelize.query(checkSql, {
        replacements: [id],
        type: QueryTypes.SELECT
      })

      if (!gift) {
        return error(res, '礼品不存在', 404)
      }

      const points = parseInt(points_required, 10)
      const stockNum = parseInt(stock, 10)

      if (isNaN(points) || points <= 0) {
        return error(res, '所需积分必须大于0', 400)
      }

      if (isNaN(stockNum) || stockNum < 0) {
        return error(res, '库存数量不能为负数', 400)
      }

      let updateSql = 'UPDATE gift_items SET title = ?, description = ?, points_cost = ?, stock = ?'
      const replacements = [name, description || '', points, stockNum]

      if (req.file) {
        const imageUrl = path.posix.join('/uploads/gifts', req.file.filename)
        updateSql += ', cover_image = ?'
        replacements.push(imageUrl)
      }

      updateSql += ' WHERE gift_id = ?'
      replacements.push(id)

      await sequelize.query(updateSql, {
        replacements,
        type: QueryTypes.UPDATE
      })

      success(res, null, '更新成功')
    } catch (err) {
      console.error('更新礼品错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 管理员：删除礼品
exports.deleteGift = async (req, res) => {
  try {
    const { id } = req.params

    // 检查礼品是否存在
    const checkSql = 'SELECT gift_id FROM gifts WHERE gift_id = ?'
    const [gift] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!gift) {
      return error(res, '礼品不存在', 404)
    }

    await sequelize.query('DELETE FROM gift_items WHERE gift_id = ?', {
      replacements: [id],
      type: QueryTypes.DELETE
    })

    success(res, null, '删除成功')
  } catch (err) {
    console.error('删除礼品错误:', err)
    error(res, '服务器错误', 500)
  }
}

