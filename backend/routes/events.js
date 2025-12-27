const router = require('express').Router()
const eventController = require('../controllers/eventController')
const organizerController = require('../controllers/organizerController')
const { authenticate, authorize } = require('../middleware/auth')
const multer = require('multer')
const path = require('path')
const fs = require('fs')
const { compressImage, generateThumbnail } = require('../middleware/imageCompress')

// 确保上传目录存在
const uploadDir = path.join(__dirname, '..', 'uploads')
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

// 配置 multer 保存路径和文件名（用于活动封面图片）
const coverStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir)
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg'
    const timestamp = Date.now()
    cb(null, `cover_${timestamp}_${Math.random().toString(36).substring(7)}${ext}`)
  }
})

const uploadCover = multer({ 
  storage: coverStorage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 限制文件大小为 5MB
  },
  fileFilter: (req, file, cb) => {
    // 只接受图片文件
    if (file.mimetype.startsWith('image/')) {
      cb(null, true)
    } else {
      cb(new Error('只允许上传图片文件'), false)
    }
  }
})

// 学生 / 公共接口
// 注意：具体路径必须放在参数路径（/:id）之前，否则会被参数路由捕获
router.get('/types', eventController.getActivityTypes) // 获取活动类型列表
router.get('/highlights', eventController.getHighlightedEvents) // 获取精选活动
router.get('/week', eventController.getWeeklyEvents) // 获取本周活动

// 组织者/管理员：AI 生成活动文案
router.post(
  '/generate-copy',
  authenticate,
  authorize('organizer', 'admin'),
  eventController.generateEventCopy
)

// 组织者：获取自己提交的活动及审核状态（必须在 /:id 之前）
router.get(
  '/organizer/mine',
  authenticate,
  authorize('organizer', 'admin'),
  organizerController.getMyActivities
)

// 管理员审核队列（必须在 /:id 之前）
router.get(
  '/admin/pending',
  authenticate,
  authorize('admin'),
  eventController.getPendingEventsForAdmin
)
router.post(
  '/admin/:id/approve',
  authenticate,
  authorize('admin'),
  eventController.approveEvent
)
router.post(
  '/admin/:id/reject',
  authenticate,
  authorize('admin'),
  eventController.rejectEvent
)

// 通用路由（放在最后）
router.get('/', eventController.getEventList)
router.get('/:id', eventController.getEventDetail)
router.post('/:id/register', authenticate, eventController.registerEvent)

// 图片压缩中间件
async function compressUploadedImage(req, res, next) {
  if (req.file) {
    try {
      const originalPath = req.file.path
      const ext = path.extname(originalPath)
      const baseName = path.basename(originalPath, ext)
      const dir = path.dirname(originalPath)
      
      // 压缩后的图片路径（用于详情页，最大1920px宽）
      const compressedPath = path.join(dir, `${baseName}_compressed.jpg`)
      
      // 压缩图片
      const success = await compressImage(originalPath, compressedPath, {
        maxWidth: 1920,
        quality: 85
      })
      
      if (success) {
        // 生成缩略图（用于列表页，400px宽）
        const thumbnailPath = path.join(dir, `${baseName}_thumb.jpg`)
        await generateThumbnail(compressedPath, thumbnailPath, 400)
        
        // 更新文件信息，使用压缩后的图片
        req.file.filename = path.basename(compressedPath)
        req.file.originalFilename = req.file.filename
        req.file.thumbnail = path.basename(thumbnailPath)
      }
    } catch (error) {
      console.error('图片压缩处理失败:', error)
      // 压缩失败不影响上传，继续使用原图
    }
  }
  next()
}

// 组织者：提交活动（待管理员审核）
router.post('/', 
  authenticate, 
  authorize('organizer', 'admin'), 
  uploadCover.single('coverImage'),
  compressUploadedImage,
  eventController.createEvent
)

module.exports = router
