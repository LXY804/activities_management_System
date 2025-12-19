const express = require('express')
const router = express.Router()
const forumController = require('../controllers/forumController')
const { authenticate, authorize } = require('../middleware/auth')

// 获取帖子列表（公开，无需登录）
router.get('/posts', forumController.getPosts)

// 获取帖子详情（公开，无需登录）
router.get('/posts/:id', forumController.getPostDetail)

// 获取帖子评论列表（公开，无需登录）
router.get('/posts/:postId/comments', forumController.getPostComments)

// 发帖（需要登录）
router.post('/posts', authenticate, forumController.createPost)

// 更新帖子（需要登录，只能更新自己的）
router.put('/posts/:id', authenticate, forumController.updatePost)

// 删除帖子（需要登录，只能删除自己的）
router.delete('/posts/:id', authenticate, forumController.deletePost)

// 添加评论（需要登录）
router.post('/posts/:postId/comments', authenticate, forumController.addComment)

// 收藏/取消收藏（需要登录）
router.post('/posts/:postId/favorite', authenticate, forumController.toggleFavorite)

// 检查收藏状态（需要登录）
router.get('/posts/:postId/favorite', authenticate, forumController.checkFavorite)

// 获取我的发帖列表（需要登录）
router.get('/my/posts', authenticate, forumController.getMyPosts)

// 获取我评论的帖子列表（需要登录）
router.get('/my/commented-posts', authenticate, forumController.getMyCommentedPosts)

// 管理员：获取待审核帖子列表
router.get('/admin/pending', authenticate, authorize('admin'), forumController.getPendingPosts)

// 管理员：审核通过帖子
router.post('/admin/posts/:id/approve', authenticate, authorize('admin'), forumController.approvePost)

// 管理员：驳回帖子
router.post('/admin/posts/:id/reject', authenticate, authorize('admin'), forumController.rejectPost)

module.exports = router

