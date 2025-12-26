const express = require('express')
const router = express.Router()
const authController = require('../controllers/authController')
const { authenticate } = require('../middleware/auth')
// 登录、注册、获取当前用户路由
router.post('/login', authController.login) // 登录
router.post('/register', authController.register) //    注册
router.get('/register', authController.registerByQuery)     // 注册（通过查询参数）
router.get('/me', authenticate, authController.getCurrentUser) // 获取当前用户 通过认证中间件

module.exports = router
