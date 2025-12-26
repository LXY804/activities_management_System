const router = require('express').Router()
const chatController = require('../controllers/chatController')

// 聊天接口
router.post('/chat/ask', chatController.chatAsk)
router.get('/chat/history', chatController.getChatHistory)

module.exports = router

