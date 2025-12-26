const { Announcement, User, AnnouncementConfirmation } = require('../models')
const { Op } = require('sequelize')
const { success, error } = require('../utils/response')

// 管理员：直接发布公告
exports.createAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { title, content } = req.body

    if (!title || !content) {
      return error(res, '标题和内容不能为空', 400)
    }

    const announcement = await Announcement.create({
      title,
      content,
      publisherId: adminId,
      publisherType: 'admin',
      status: 1,
      publishedAt: new Date()
    })

    success(res, { announcementId: announcement.announcementId }, '公告发布成功')
  } catch (err) {
    console.error('发布公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 组织者：申请发布公告（待审核）
exports.applyAnnouncement = async (req, res) => {
  try {
    const organizerId = req.user.id
    const { title, content } = req.body

    if (!title || !content) {
      return error(res, '标题和内容不能为空', 400)
    }

    const announcement = await Announcement.create({
      title,
      content,
      publisherId: organizerId,
      publisherType: 'organizer',
      status: 0,
      adminCheck: 0
    })

    success(res, { announcementId: announcement.announcementId }, '公告申请已提交，等待管理员审核')
  } catch (err) {
    console.error('申请公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取待审核公告列表
exports.getPendingAnnouncements = async (req, res) => {
  try {
    const list = await Announcement.findAll({
      attributes: [
        'announcementId',
        'title',
        'content',
        'createdAt'
      ],
      include: [{
        model: User,
        as: 'publisher',
        attributes: ['userId', 'username'],
        required: true
      }],
      where: {
        status: 0,
        adminCheck: 0
      },
      order: [['createdAt', 'DESC']]
    })

    const formattedList = list.map(item => ({
      id: item.announcementId,
      title: item.title,
      content: item.content,
      created_at: item.createdAt,
      publisher_name: item.publisher?.username,
      publisher_id: item.publisher?.userId
    }))

    success(res, formattedList)
  } catch (err) {
    console.error('获取待审核公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：审核通过公告
exports.approveAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params

    const announcement = await Announcement.findByPk(id)

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status === 1) {
      return success(res, null, '该公告已发布')
    }

    await announcement.update({
      status: 1,
      adminCheck: 1,
      checkedBy: adminId,
      checkedAt: new Date(),
      publishedAt: new Date()
    })

    success(res, null, '公告审核通过')
  } catch (err) {
    console.error('审核通过公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：驳回公告
exports.rejectAnnouncement = async (req, res) => {
  try {
    const adminId = req.user.id
    const { id } = req.params
    const { remark } = req.body

    const announcement = await Announcement.findByPk(id)

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status === 2) {
      return success(res, null, '该公告已被驳回')
    }

    await announcement.update({
      status: 2,
      adminCheck: 2,
      checkedBy: adminId,
      checkedAt: new Date(),
      checkRemark: remark || null
    })

    success(res, null, '公告已驳回')
  } catch (err) {
    console.error('驳回公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 获取已发布的公告列表（所有用户可见）
exports.getPublishedAnnouncements = async (req, res) => {
  try {
    const { page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const { count, rows } = await Announcement.findAndCountAll({
      attributes: [
        'announcementId',
        'title',
        'content',
        'createdAt',
        'publishedAt',
        'publisherType'
      ],
      include: [{
        model: User,
        as: 'publisher',
        attributes: ['userId', 'username'],
        required: true
      }],
      where: {
        status: 1
      },
      order: [['publishedAt', 'DESC']],
      limit,
      offset
    })

    const list = rows.map(item => ({
      id: item.announcementId,
      title: item.title,
      content: item.content,
      created_at: item.createdAt,
      published_at: item.publishedAt,
      publisher_name: item.publisher?.username,
      publisher_type: item.publisherType
    }))

    success(res, {
      list,
      total: count,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取公告列表错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 用户：确认公告（已读）
exports.confirmAnnouncement = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    // 检查公告是否存在且已发布
    const announcement = await Announcement.findByPk(id)

    if (!announcement) {
      return error(res, '公告不存在', 404)
    }

    if (announcement.status !== 1) {
      return error(res, '该公告未发布，无法确认', 400)
    }

    // 检查是否已确认
    const existing = await AnnouncementConfirmation.findOne({
      where: {
        announcementId: id,
        userId: userId
      }
    })

    if (existing) {
      return success(res, null, '您已确认过此公告')
    }

    // 插入确认记录
    await AnnouncementConfirmation.create({
      announcementId: id,
      userId: userId,
      confirmedAt: new Date()
    })

    success(res, null, '确认成功')
  } catch (err) {
    console.error('确认公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 检查用户是否已确认公告
exports.checkConfirmation = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const confirmation = await AnnouncementConfirmation.findOne({
      where: {
        announcementId: id,
        userId: userId
      }
    })

    success(res, { confirmed: !!confirmation })
  } catch (err) {
    console.error('检查确认状态错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取所有公告的确认数统计
exports.getAdminConfirmationStats = async (req, res) => {
  try {
    const announcements = await Announcement.findAll({
      attributes: [
        'announcementId',
        'title',
        'publishedAt'
      ],
      include: [
        {
          model: User,
          as: 'publisher',
          attributes: ['userId', 'username'],
          required: true
        }
      ],
      where: {
        status: 1
      },
      order: [['publishedAt', 'DESC']]
    })

    // 获取每个公告的确认数
    const list = await Promise.all(announcements.map(async (announcement) => {
      const count = await AnnouncementConfirmation.count({
        where: {
          announcementId: announcement.announcementId
        }
      })

      return {
        id: announcement.announcementId,
        title: announcement.title,
        published_at: announcement.publishedAt,
        publisher_name: announcement.publisher?.username,
        confirmation_count: count
      }
    }))

    success(res, list)
  } catch (err) {
    console.error('获取确认统计错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 组织者：获取自己申请发布的公告确认数
exports.getOrganizerConfirmationStats = async (req, res) => {
  try {
    const organizerId = req.user.id

    const announcements = await Announcement.findAll({
      where: {
        publisherId: organizerId,
        publisherType: 'organizer'
      },
      order: [['createdAt', 'DESC']]
    })

    const list = await Promise.all(announcements.map(async (announcement) => {
      const count = await AnnouncementConfirmation.count({
        where: {
          announcementId: announcement.announcementId
        }
      })

      return {
        id: announcement.announcementId,
        title: announcement.title,
        published_at: announcement.publishedAt,
        status: announcement.status,
        admin_check: announcement.adminCheck,
        check_remark: announcement.checkRemark,
        confirmation_count: count
      }
    }))

    success(res, list)
  } catch (err) {
    console.error('获取组织者确认统计错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 用户：获取未确认公告数量
exports.getUnconfirmedCount = async (req, res) => {
  try {
    const userId = req.user.id

    // 获取所有已发布的公告ID
    const publishedAnnouncements = await Announcement.findAll({
      attributes: ['announcementId'],
      where: {
        status: 1
      }
    })

    const publishedIds = publishedAnnouncements.map(a => a.announcementId)

    // 获取用户已确认的公告ID
    const confirmed = await AnnouncementConfirmation.findAll({
      attributes: ['announcementId'],
      where: {
        userId: userId,
        announcementId: { [Op.in]: publishedIds }
      }
    })

    const confirmedIds = confirmed.map(c => c.announcementId)
    const unconfirmedCount = publishedIds.length - confirmedIds.length

    success(res, { count: unconfirmedCount })
  } catch (err) {
    console.error('获取未确认公告数量错误:', err)
    error(res, '服务器错误', 500)
  }
}

// 管理员：获取所有公告列表（包括待审核、已发布、已驳回）
exports.getAllAnnouncements = async (req, res) => {
  try {
    const { status, page = 1, pageSize = 10 } = req.query
    const offset = (parseInt(page, 10) - 1) * parseInt(pageSize, 10)
    const limit = parseInt(pageSize, 10)

    const where = {}
    if (status !== undefined) {
      where.status = parseInt(status, 10)
    }

    const { count, rows } = await Announcement.findAndCountAll({
      attributes: [
        'announcementId',
        'title',
        'content',
        'status',
        'adminCheck',
        'checkRemark',
        'createdAt',
        'publishedAt',
        'publisherType'
      ],
      include: [
        {
          model: User,
          as: 'publisher',
          attributes: ['username'],
          required: true
        },
        {
          model: User,
          as: 'checker',
          attributes: ['username'],
          required: false
        }
      ],
      where,
      order: [['createdAt', 'DESC']],
      limit,
      offset
    })

    const list = rows.map(item => ({
      id: item.announcementId,
      title: item.title,
      content: item.content,
      status: item.status,
      admin_check: item.adminCheck,
      check_remark: item.checkRemark,
      created_at: item.createdAt,
      published_at: item.publishedAt,
      publisher_name: item.publisher?.username,
      publisher_type: item.publisherType,
      checker_name: item.checker?.username
    }))

    success(res, {
      list,
      total: count,
      page: parseInt(page, 10),
      pageSize: parseInt(pageSize, 10)
    })
  } catch (err) {
    console.error('获取所有公告错误:', err)
    error(res, '服务器错误', 500)
  }
}

