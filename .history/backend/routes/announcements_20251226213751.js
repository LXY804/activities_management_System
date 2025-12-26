const express = require('express')
const router = express.Router()
const announcementController = require('../controllers/announcementController')
const { authenticate, authorize } = require('../middleware/auth')

// 获取已发布的公告列表（公开，无需登录）
router.get('/published', announcementController.getPublishedAnnouncements)

// 用户：获取未确认公告数量（需要登录）- 必须在 /:id 路由之前
router.get('/unconfirmed/count', authenticate, announcementController.getUnconfirmedCount)

// 用户：确认公告（需要登录）
router.post('/:id/confirm', authenticate, announcementController.confirmAnnouncement)

// 检查用户是否已确认（需要登录）
router.get('/:id/confirm', authenticate, announcementController.checkConfirmation)

// 管理员：直接发布公告
router.post('/', authenticate, authorize('admin'), announcementController.createAnnouncement)

// 管理员：获取所有公告列表
router.get('/admin/all', authenticate, authorize('admin'), announcementController.getAllAnnouncements)

// 管理员：获取待审核公告列表
router.get('/admin/pending', authenticate, authorize('admin'), announcementController.getPendingAnnouncements)

// 管理员：审核通过公告
router.post('/admin/:id/approve', authenticate, authorize('admin'), announcementController.approveAnnouncement)

// 管理员：驳回公告
router.post('/admin/:id/reject', authenticate, authorize('admin'), announcementController.rejectAnnouncement)

// 管理员：获取所有公告的确认数统计
router.get('/admin/stats', authenticate, authorize('admin'), announcementController.getAdminConfirmationStats)

// 组织者：申请发布公告
router.post('/apply', authenticate, authorize('organizer', 'admin'), announcementController.applyAnnouncement)

// 组织者：获取自己申请发布的公告确认数
router.get('/organizer/stats', authenticate, authorize('organizer', 'admin'), announcementController.getOrganizerConfirmationStats)

module.exports = router

