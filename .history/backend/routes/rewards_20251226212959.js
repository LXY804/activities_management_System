const router = require('express').Router()
const rewardController = require('../controllers/rewardController')
const { authenticate, authorize } = require('../middleware/auth')
const multer = require('multer')
const path = require('path')
const fs = require('fs')

const uploadDir = path.join(__dirname, '..', 'uploads')
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

const giftStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir)
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg'
    const timestamp = Date.now()
    const random = Math.random().toString(36).slice(2, 8)
    cb(null, `gift_${timestamp}_${random}${ext}`)
  }
})

const uploadGiftCover = multer({
  storage: giftStorage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true)
    } else {
      cb(new Error('只允许上传图片文件'), false)
    }
  }
})

// 公共：礼品列表
router.get('/gifts', rewardController.getGiftList)

// 需要登录的接口
router.get(
  '/gifts/manage',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.getManagedGifts
)
router.get('/summary', authenticate, rewardController.getMySummary)
router.get('/orders/mine', authenticate, rewardController.getMyOrders)
router.post(
  '/gifts/:id/redeem',
  authenticate,
  authorize('student', 'organizer', 'admin'),
  rewardController.redeemGift
)
router.post(
  '/gifts',
  authenticate,
  authorize('organizer', 'admin'),
  uploadGiftCover.single('coverImage'),
  rewardController.createGift
)
router.patch(
  '/gifts/:id',
  authenticate,
  authorize('organizer', 'admin'),
  uploadGiftCover.single('coverImage'),
  rewardController.updateGift
)
router.patch(
  '/gifts/:id/status',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.updateGiftStatus
)
router.get(
  '/rules',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.getPointRules
)
router.post(
  '/rules',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.savePointRule
)
router.delete(
  '/rules/:id',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.deletePointRule
)
router.post(
  '/transactions/adjust',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.adjustPoints
)
router.get(
  '/organizer/analytics',
  authenticate,
  authorize('organizer', 'admin'),
  rewardController.getOrganizerAnalytics
)
router.get(
  '/admin/overview',
  authenticate,
  authorize('admin'),
  rewardController.getAdminOverview
)
router.get(
  '/admin/orders',
  authenticate,
  authorize('admin'),
  rewardController.getAdminOrders
)
router.patch(
  '/admin/orders/:id/status',
  authenticate,
  authorize('admin'),
  rewardController.updateOrderStatus
)
router.post(
  '/orders/:id/feedback',
  authenticate,
  authorize('student', 'organizer', 'admin'),
  rewardController.createFeedback
)

// 积分排行榜 - 公开接口，无需认证
router.get('/ranking/points', rewardController.getPointsRanking)

module.exports = router
// 在 rewards.js 中添加以下代码 (建议放在 router.get('/gifts', ...) 附近)

// 获取积分排行榜 (建议需要登录)
router.get(
  '/ranking',
  authenticate, 
  rewardController.getPointsRanking
)