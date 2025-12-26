const express = require('express')
const router = express.Router()
const giftController = require('../controllers/giftController')
const { authenticate, authorize } = require('../middleware/auth')

// 获取礼品列表（公开，无需登录）
router.get('/', giftController.getGifts)

// 获取礼品详情（公开，无需登录）
router.get('/:id', giftController.getGiftDetail)

// 管理员：创建礼品
router.post('/', authenticate, authorize('admin'), giftController.createGift)

// 管理员：获取所有礼品列表（包括库存为0的）
router.get('/admin/all', authenticate, authorize('admin'), giftController.getAllGifts)

// 管理员：更新礼品
router.put('/:id', authenticate, authorize('admin'), giftController.updateGift)

// 管理员：删除礼品
router.delete('/:id', authenticate, authorize('admin'), giftController.deleteGift)

module.exports = router

