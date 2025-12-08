const express = require('express')
const router = express.Router()
const controller = require('../controllers/recommendationController')

// 用户推荐列表
router.get('/recommendations', controller.getUserRecommendations)

// 相似活动
router.get('/recommendations/similar', controller.getSimilarActivities)

module.exports = router

