const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const multer = require('multer')
const path = require('path')
const fs = require('fs')

// 配置 multer 用于上传资讯图片
const uploadDir = path.join(__dirname, '..', 'uploads', 'news')
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
    cb(null, `news_${timestamp}_${Math.random().toString(36).substring(7)}${ext}`)
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

// 管理员：创建资讯
exports.createNews = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const adminId = req.user.id
      const { title, content } = req.body

      if (!title || !content) {
        return error(res, '标题和内容不能为空', 400)
      }

      let imageUrl = null
      if (req.file) {
        imageUrl = path.posix.join('/uploads/news', req.file.filename)
      }

      const sql = `
        INSERT INTO news (title, content, image_url, publisher_id)
        VALUES (?, ?, ?, ?)
      `
      const [newsId] = await sequelize.query(sql, {
        replacements: [title, content, imageUrl, adminId],
        type: QueryTypes.INSERT
      })

      success(res, { newsId }, '资讯发布成功')
    } catch (err) {
      console.error('发布资讯错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 获取资讯列表（公开，无需登录）
exports.getNewsList = async (req, res) => {
  try {
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT 
        n.news_id AS id,
        n.title,
        n.content,
        n.image_url,
        n.created_at,
        u.username AS publisher_name
      FROM news n
      INNER JOIN users u ON n.publisher_id = u.user_id
      ORDER BY n.created_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM news
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
    console.error('获取资讯列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取资讯详情
exports.getNewsDetail = async (req, res) => {
  try {
    const { id } = req.params

    const sql = `
      SELECT 
        n.news_id AS id,
        n.title,
        n.content,
        n.image_url,
        n.created_at,
        n.updated_at,
        u.username AS publisher_name
      FROM news n
      INNER JOIN users u ON n.publisher_id = u.user_id
      WHERE n.news_id = ?
    `

    const [news] = await sequelize.query(sql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!news) {
      return error(res, '资讯不存在', 404)
    }

    success(res, news)
  } catch (err) {
    console.error('获取资讯详情错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：更新资讯
exports.updateNews = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const adminId = req.user.id
      const { id } = req.params
      const { title, content } = req.body

      // 检查资讯是否存在
      const checkSql = 'SELECT news_id FROM news WHERE news_id = ?'
      const [news] = await sequelize.query(checkSql, {
        replacements: [id],
        type: QueryTypes.SELECT
      })

      if (!news) {
        return error(res, '资讯不存在', 404)
      }

      let updateSql = 'UPDATE news SET title = ?, content = ?'
      const replacements = [title, content]

      if (req.file) {
        const imageUrl = path.posix.join('/uploads/news', req.file.filename)
        updateSql += ', image_url = ?'
        replacements.push(imageUrl)
      }

      updateSql += ' WHERE news_id = ?'
      replacements.push(id)

      await sequelize.query(updateSql, {
        replacements,
        type: QueryTypes.UPDATE
      })

      success(res, null, '更新成功')
    } catch (err) {
      console.error('更新资讯错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 管理员：删除资讯
exports.deleteNews = async (req, res) => {
  try {
    const { id } = req.params

    // 检查资讯是否存在
    const checkSql = 'SELECT news_id FROM news WHERE news_id = ?'
    const [news] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!news) {
      return error(res, '资讯不存在', 404)
    }

    await sequelize.query('DELETE FROM news WHERE news_id = ?', {
      replacements: [id],
      type: QueryTypes.DELETE
    })

    success(res, null, '删除成功')
  } catch (err) {
    console.error('删除资讯错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取所有资讯列表（用于管理）
exports.getAllNews = async (req, res) => {
  try {
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT 
        n.news_id AS id,
        n.title,
        n.content,
        n.image_url,
        n.created_at,
        n.updated_at,
        u.username AS publisher_name
      FROM news n
      INNER JOIN users u ON n.publisher_id = u.user_id
      ORDER BY n.created_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM news
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
    console.error('获取资讯列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

