const { Comment, Activity, User, UserActivityApply } = require('../models')
const { Op } = require('sequelize')
const { success, error } = require('../utils/response')

// 删除自己的评论（允许删除任何状态的评论）
exports.deleteMyComment = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params // comment_id

    // 确认评论存在且属于当前用户
    const comment = await Comment.findOne({
      where: {
        commentId: id,
        userId: userId
      }
    })

    if (!comment) {
      return error(res, '评论不存在或无权删除', 404)
    }

    // 直接删除
    await comment.destroy()

    success(res, null, '删除成功')
  } catch (err) {
    console.error('删除评论错误:', err)
    error(res, '服务器错误: ' + err.message, 500)
  }
}

exports.submitComment = async (req, res) => {
  try {
    const { eventId } = req.params
    const userId = req.user.id
    const { rating, content } = req.body

    if (!rating || !content) {
      return error(res, '评分和评论内容不能为空', 400)
    }

    if (rating < 1 || rating > 5) {
      return error(res, '评分必须在1-5之间', 400)
    }

    // 检查活动是否存在
    const event = await Activity.findByPk(eventId)
    if (!event) {
      return error(res, '活动不存在', 404)
    }

    // 检查是否已报名且通过
    const registration = await UserActivityApply.findOne({
      where: {
        activityId: eventId,
        userId: userId,
        applyStatus: 1
      }
    })

    if (!registration) {
      return error(res, '您未参与此活动，无法评论', 403)
    }

    // 检查是否已评论
    const existing = await Comment.findOne({
      where: {
        activityId: eventId,
        userId: userId
      }
    })

    if (existing) {
      return error(res, '您已评论过此活动', 400)
    }

    // 创建评论
    const comment = await Comment.create({
      activityId: parseInt(eventId, 10),
      userId: userId,
      rating: parseInt(rating, 10),
      content: content
    })

    // 获取完整评论信息
    const fullComment = await Comment.findByPk(comment.commentId, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['username']
        },
        {
          model: Activity,
          as: 'activity',
          attributes: ['activityName', 'location', 'startTime']
        }
      ]
    })

    const result = {
      comment_id: fullComment.commentId,
      activity_id: fullComment.activityId,
      user_id: fullComment.userId,
      rating: fullComment.rating,
      content: fullComment.content,
      created_at: fullComment.createdAt,
      username: fullComment.user?.username,
      event_title: fullComment.activity?.activityName,
      location: fullComment.activity?.location,
      start_time: fullComment.activity?.startTime,
      status: 1
    }

    success(res, result, '评论提交成功')
  } catch (err) {
    console.error('提交评论错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.getEventComments = async (req, res) => {
  try {
    const { eventId } = req.params
    const { page = 1, pageSize = 10 } = req.query

    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const { count, rows } = await Comment.findAndCountAll({
      attributes: [
        ['comment_id', 'id'],
        'rating',
        'content',
        'createdAt',
        ['created_at', 'created_at']
      ],
      include: [{
        model: User,
        as: 'user',
        attributes: ['username'],
        required: true
      }],
      where: {
        activityId: eventId
      },
      order: [['createdAt', 'DESC']],
      limit,
      offset
    })

    const list = rows.map(item => ({
      id: item.commentId,
      rating: item.rating,
      content: item.content,
      created_at: item.createdAt,
      status: 1,
      username: item.user?.username
    }))

    success(res, {
      list,
      total: count,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取评论列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.getMyComments = async (req, res) => {
  try {
    const userId = req.user.id
    const { page = 1, pageSize = 10 } = req.query

    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const { count, rows } = await Comment.findAndCountAll({
      attributes: [
        ['comment_id', 'id'],
        'rating',
        'content',
        'createdAt',
        ['created_at', 'created_at'],
        ['activity_id', 'event_id']
      ],
      include: [{
        model: Activity,
        as: 'activity',
        attributes: ['activityName', 'location', 'startTime'],
        required: true
      }],
      where: {
        userId: userId
      },
      order: [['createdAt', 'DESC']],
      limit,
      offset
    })

    const list = rows.map(item => ({
      id: item.commentId,
      rating: item.rating,
      content: item.content,
      created_at: item.createdAt,
      status: 1,
      event_id: item.activityId,
      event_title: item.activity?.activityName,
      location: item.activity?.location,
      start_time: item.activity?.startTime
    }))

    success(res, {
      list,
      total: count,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取我的评论错误:', err)
    error(res, '服务器错误', 500)
  }
}
