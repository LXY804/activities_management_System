const sequelize = require('../config/database')
const { QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const multer = require('multer')
const path = require('path')
const fs = require('fs')

// 配置 multer 用于上传帖子图片
const uploadDir = path.join(__dirname, '..', 'uploads', 'forum')
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
    cb(null, `forum_${timestamp}_${Math.random().toString(36).substring(7)}${ext}`)
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

// 发帖
exports.createPost = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const userId = req.user.id
      const { title, content, categoryId } = req.body

      if (!title || !content) {
        return error(res, '标题和内容不能为空', 400)
      }

      let imageUrl = null
      if (req.file) {
        imageUrl = path.posix.join('/uploads/forum', req.file.filename)
      }

      const categoryIdValue = categoryId ? parseInt(categoryId, 10) : 0

      // 新发布的帖子默认状态为待审核（status=0, admin_check=0），需要管理员审核通过后才能显示
      const sql = `
        INSERT INTO forum_posts (user_id, title, content, image_url, category_id, status, admin_check)
        VALUES (?, ?, ?, ?, ?, 0, 0)
      `
      const [postId] = await sequelize.query(sql, {
        replacements: [userId, title, content, imageUrl, categoryIdValue],
        type: QueryTypes.INSERT
      })

      success(res, { postId }, '帖子已提交，等待管理员审核通过后即可显示')
    } catch (err) {
      console.error('发帖错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 获取帖子列表（支持搜索和分页）
exports.getPosts = async (req, res) => {
  try {
    const { page = 1, pageSize = 10, keyword } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    // 只显示已审核通过的帖子（status=1 且 admin_check=1）
    let whereClause = 'WHERE p.status = 1 AND p.admin_check = 1'
    const replacements = []

    if (keyword) {
      whereClause += ' AND (p.title LIKE ? OR p.content LIKE ?)'
      const keywordPattern = `%${keyword}%`
      replacements.push(keywordPattern, keywordPattern)
    }

    const listSql = `
      SELECT 
        p.post_id AS id,
        p.title,
        p.content,
        p.image_url,
        p.category_id,
        p.created_at,
        p.status,
        u.username AS author,
        u.user_id AS author_id,
        COUNT(DISTINCT c.comment_id) AS comment_count,
        COUNT(DISTINCT f.favorite_id) AS favorite_count,
        (
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', fc.comment_id,
              'userName', u2.username,
              'content', fc.content,
              'created_at', fc.created_at
            )
          )
          FROM forum_comments fc
          INNER JOIN users u2 ON fc.user_id = u2.user_id
          WHERE fc.post_id = p.post_id
          ORDER BY fc.created_at ASC
          LIMIT 10
        ) AS comments
      FROM forum_posts p
      INNER JOIN users u ON p.user_id = u.user_id
      LEFT JOIN forum_comments c ON p.post_id = c.post_id
      LEFT JOIN forum_favorites f ON p.post_id = f.post_id
      ${whereClause}
      GROUP BY p.post_id
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM forum_posts p
      ${whereClause}
    `

    const [countResult] = await sequelize.query(countSql, {
      replacements: replacements.slice(0, replacements.length - 2),
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
    console.error('获取帖子列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取帖子详情
exports.getPostDetail = async (req, res) => {
  try {
    const { id } = req.params

    const sql = `
      SELECT 
        p.post_id AS id,
        p.title,
        p.content,
        p.image_url,
        p.created_at,
        p.updated_at,
        u.username AS author,
        u.user_id AS author_id,
        COUNT(DISTINCT c.comment_id) AS comment_count,
        COUNT(DISTINCT f.favorite_id) AS favorite_count
      FROM forum_posts p
      INNER JOIN users u ON p.user_id = u.user_id
      LEFT JOIN forum_comments c ON p.post_id = c.post_id
      LEFT JOIN forum_favorites f ON p.post_id = f.post_id
      WHERE p.post_id = ?
      GROUP BY p.post_id
    `

    const [post] = await sequelize.query(sql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    success(res, post)
  } catch (err) {
    console.error('获取帖子详情错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 更新帖子（只能更新自己的）
exports.updatePost = async (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return error(res, err.message, 400)
    }

    try {
      const userId = req.user.id
      const { id } = req.params
      const { title, content } = req.body

      // 检查帖子是否存在且属于当前用户
      const checkSql = 'SELECT user_id FROM forum_posts WHERE post_id = ?'
      const [post] = await sequelize.query(checkSql, {
        replacements: [id],
        type: QueryTypes.SELECT
      })

      if (!post) {
        return error(res, '帖子不存在', 404)
      }

      if (post.user_id !== userId) {
        return error(res, '无权修改此帖子', 403)
      }

      let updateSql = 'UPDATE forum_posts SET title = ?, content = ?'
      const replacements = [title, content]

      if (req.file) {
        const imageUrl = path.posix.join('/uploads/forum', req.file.filename)
        updateSql += ', image_url = ?'
        replacements.push(imageUrl)
      }

      updateSql += ' WHERE post_id = ?'
      replacements.push(id)

      await sequelize.query(updateSql, {
        replacements,
        type: QueryTypes.UPDATE
      })

      success(res, null, '更新成功')
    } catch (err) {
      console.error('更新帖子错误:', err)
      error(res, '服务器错误', 500)
    }
  })
}

// 删除帖子（只能删除自己的）
exports.deletePost = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    // 检查帖子是否存在且属于当前用户
    const checkSql = 'SELECT user_id FROM forum_posts WHERE post_id = ?'
    const [post] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    if (post.user_id !== userId) {
      return error(res, '无权删除此帖子', 403)
    }

    await sequelize.query('DELETE FROM forum_posts WHERE post_id = ?', {
      replacements: [id],
      type: QueryTypes.DELETE
    })

    success(res, null, '删除成功')
  } catch (err) {
    console.error('删除帖子错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取我的发帖统计
exports.getMyStats = async (req, res) => {
  try {
    const userId = req.user.id

    // 获取我的帖子数量
    const myPostsSql = 'SELECT COUNT(*) AS count FROM forum_posts WHERE user_id = ?'
    const [myPostsResult] = await sequelize.query(myPostsSql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    // 获取我的评论数量（对他人帖子的评论）
    const myCommentsSql = `
      SELECT COUNT(*) AS count 
      FROM forum_comments c
      INNER JOIN forum_posts p ON c.post_id = p.post_id
      WHERE c.user_id = ? AND p.user_id != ?
    `
    const [myCommentsResult] = await sequelize.query(myCommentsSql, {
      replacements: [userId, userId],
      type: QueryTypes.SELECT
    })

    success(res, {
      myPostsCount: myPostsResult.count || 0,
      myCommentsCount: myCommentsResult.count || 0
    })
  } catch (err) {
    console.error('获取我的统计错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取我的发帖列表
exports.getMyPosts = async (req, res) => {
  try {
    const userId = req.user.id
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT 
        p.post_id AS id,
        p.title,
        p.content,
        p.image_url,
        p.category_id,
        p.status,
        p.created_at,
        u.username AS author,
        u.user_id AS author_id,
        COUNT(DISTINCT c.comment_id) AS comment_count,
        COUNT(DISTINCT f.favorite_id) AS favorite_count,
        (
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', fc.comment_id,
              'userName', u2.username,
              'content', fc.content,
              'created_at', fc.created_at
            )
          )
          FROM forum_comments fc
          INNER JOIN users u2 ON fc.user_id = u2.user_id
          WHERE fc.post_id = p.post_id
          ORDER BY fc.created_at ASC
          LIMIT 10
        ) AS comments
      FROM forum_posts p
      INNER JOIN users u ON p.user_id = u.user_id
      LEFT JOIN forum_comments c ON p.post_id = c.post_id
      LEFT JOIN forum_favorites f ON p.post_id = f.post_id
      WHERE p.user_id = ?
      GROUP BY p.post_id
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM forum_posts
      WHERE user_id = ?
    `

    const [countResult] = await sequelize.query(countSql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    const list = await sequelize.query(listSql, {
      replacements: [userId, limit, offset],
      type: QueryTypes.SELECT
    })

    success(res, {
      list,
      total: countResult.total,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取我的发帖错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取我评论的帖子列表
exports.getMyCommentedPosts = async (req, res) => {
  try {
    const userId = req.user.id
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT DISTINCT
        p.post_id AS id,
        p.title,
        p.content,
        p.image_url,
        p.category_id,
        p.status,
        p.created_at,
        u.username AS author,
        u.user_id AS author_id,
        COUNT(DISTINCT c2.comment_id) AS comment_count,
        COUNT(DISTINCT f.favorite_id) AS favorite_count,
        MAX(c.created_at) AS my_comment_time,
        (
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', fc.comment_id,
              'userName', u3.username,
              'content', fc.content,
              'created_at', fc.created_at
            )
          )
          FROM forum_comments fc
          INNER JOIN users u3 ON fc.user_id = u3.user_id
          WHERE fc.post_id = p.post_id
          ORDER BY fc.created_at ASC
          LIMIT 10
        ) AS comments
      FROM forum_comments c
      INNER JOIN forum_posts p ON c.post_id = p.post_id
      INNER JOIN users u ON p.user_id = u.user_id
      LEFT JOIN forum_comments c2 ON p.post_id = c2.post_id
      LEFT JOIN forum_favorites f ON p.post_id = f.post_id
      WHERE c.user_id = ?
      GROUP BY p.post_id
      ORDER BY my_comment_time DESC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(DISTINCT post_id) AS total
      FROM forum_comments
      WHERE user_id = ?
    `

    const [countResult] = await sequelize.query(countSql, {
      replacements: [userId],
      type: QueryTypes.SELECT
    })

    const list = await sequelize.query(listSql, {
      replacements: [userId, limit, offset],
      type: QueryTypes.SELECT
    })

    success(res, {
      list,
      total: countResult.total,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取我评论的帖子错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 添加评论
exports.addComment = async (req, res) => {
  try {
    const userId = req.user.id
    const { postId } = req.params
    const { content } = req.body

    if (!content) {
      return error(res, '评论内容不能为空', 400)
    }

    // 检查帖子是否存在
    const checkSql = 'SELECT post_id FROM forum_posts WHERE post_id = ?'
    const [post] = await sequelize.query(checkSql, {
      replacements: [postId],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    const sql = `
      INSERT INTO forum_comments (post_id, user_id, content)
      VALUES (?, ?, ?)
    `
    const [commentId] = await sequelize.query(sql, {
      replacements: [postId, userId, content],
      type: QueryTypes.INSERT
    })

    success(res, { commentId }, '评论成功')
  } catch (err) {
    console.error('添加评论错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取帖子评论列表
exports.getPostComments = async (req, res) => {
  try {
    const { postId } = req.params
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const listSql = `
      SELECT 
        c.comment_id AS id,
        c.content,
        c.created_at,
        u.username AS author,
        u.user_id AS author_id
      FROM forum_comments c
      INNER JOIN users u ON c.user_id = u.user_id
      WHERE c.post_id = ?
      ORDER BY c.created_at ASC
      LIMIT ? OFFSET ?
    `

    const countSql = `
      SELECT COUNT(*) AS total
      FROM forum_comments
      WHERE post_id = ?
    `

    const [countResult] = await sequelize.query(countSql, {
      replacements: [postId],
      type: QueryTypes.SELECT
    })

    const list = await sequelize.query(listSql, {
      replacements: [postId, limit, offset],
      type: QueryTypes.SELECT
    })

    success(res, {
      list,
      total: countResult.total,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取评论列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 收藏/取消收藏帖子
exports.toggleFavorite = async (req, res) => {
  try {
    const userId = req.user.id
    const { postId } = req.params

    // 检查帖子是否存在
    const checkSql = 'SELECT post_id FROM forum_posts WHERE post_id = ?'
    const [post] = await sequelize.query(checkSql, {
      replacements: [postId],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    // 检查是否已收藏
    const checkFavoriteSql = `
      SELECT favorite_id FROM forum_favorites 
      WHERE post_id = ? AND user_id = ?
    `
    const [favorite] = await sequelize.query(checkFavoriteSql, {
      replacements: [postId, userId],
      type: QueryTypes.SELECT
    })

    if (favorite) {
      // 取消收藏
      await sequelize.query(
        'DELETE FROM forum_favorites WHERE post_id = ? AND user_id = ?',
        {
          replacements: [postId, userId],
          type: QueryTypes.DELETE
        }
      )
      success(res, { favorited: false }, '已取消收藏')
    } else {
      // 添加收藏
      await sequelize.query(
        'INSERT INTO forum_favorites (post_id, user_id) VALUES (?, ?)',
        {
          replacements: [postId, userId],
          type: QueryTypes.INSERT
        }
      )
      success(res, { favorited: true }, '收藏成功')
    }
  } catch (err) {
    console.error('收藏操作错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 检查是否已收藏
exports.checkFavorite = async (req, res) => {
  try {
    const userId = req.user.id
    const { postId } = req.params

    const sql = `
      SELECT favorite_id FROM forum_favorites 
      WHERE post_id = ? AND user_id = ?
    `
    const [favorite] = await sequelize.query(sql, {
      replacements: [postId, userId],
      type: QueryTypes.SELECT
    })

    success(res, { favorited: !!favorite })
  } catch (err) {
    console.error('检查收藏状态错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取待审核帖子列表
exports.getPendingPosts = async (req, res) => {
  try {
    const sql = `
      SELECT 
        p.post_id AS id,
        p.title,
        p.content,
        p.image_url,
        p.created_at,
        u.username AS author,
        u.user_id AS author_id
      FROM forum_posts p
      INNER JOIN users u ON p.user_id = u.user_id
      WHERE p.status = 0 AND p.admin_check = 0
      ORDER BY p.created_at DESC
    `

    const list = await sequelize.query(sql, {
      type: QueryTypes.SELECT
    })

    success(res, list)
  } catch (err) {
    console.error('获取待审核帖子错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：审核通过帖子
exports.approvePost = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params

    const checkSql = `
      SELECT post_id, status, admin_check
      FROM forum_posts
      WHERE post_id = ?
    `
    const [post] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    if (post.status === 1) {
      return success(res, null, '该帖子已发布')
    }

    const updateSql = `
      UPDATE forum_posts
      SET status = 1,
          admin_check = 1,
          checked_by = ?,
          checked_at = NOW()
      WHERE post_id = ?
    `

    await sequelize.query(updateSql, {
      replacements: [adminId, id],
      type: QueryTypes.UPDATE
    })

    success(res, null, '帖子审核通过')
  } catch (err) {
    console.error('审核通过帖子错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：驳回帖子
exports.rejectPost = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params
    const { remark } = req.body

    const checkSql = `
      SELECT post_id, status, admin_check
      FROM forum_posts
      WHERE post_id = ?
    `
    const [post] = await sequelize.query(checkSql, {
      replacements: [id],
      type: QueryTypes.SELECT
    })

    if (!post) {
      return error(res, '帖子不存在', 404)
    }

    if (post.status === 2) {
      return success(res, null, '该帖子已被驳回')
    }

    const updateSql = `
      UPDATE forum_posts
      SET status = 2,
          admin_check = 2,
          checked_by = ?,
          checked_at = NOW(),
          check_remark = ?
      WHERE post_id = ?
    `

    await sequelize.query(updateSql, {
      replacements: [adminId, remark || null, id],
      type: QueryTypes.UPDATE
    })

    success(res, null, '帖子已驳回')
  } catch (err) {
    console.error('驳回帖子错误:', err)
    error(res, '服务器错误', 500)
  }
}

