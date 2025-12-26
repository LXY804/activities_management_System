const express = require('express')
const router = express.Router()
const newsController = require('../controllers/newsController')
const { authenticate, authorize } = require('../middleware/auth')

// 获取资讯列表（公开，无需登录）
router.get('/', newsController.getNewsList)

// 获取资讯详情（公开，无需登录）
router.get('/:id', newsController.getNewsDetail)

// 管理员：创建资讯
router.post('/', authenticate, authorize('admin'), newsController.createNews)

// 管理员：获取所有资讯列表（用于管理）
router.get('/admin/all', authenticate, authorize('admin'), newsController.getAllNews)

// 管理员：更新资讯
router.put('/:id', authenticate, authorize('admin'), newsController.updateNews)

// 管理员：删除资讯
router.delete('/:id', authenticate, authorize('admin'), newsController.deleteNews)

module.exports = router

