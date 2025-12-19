import request from './request'

// 获取已发布的公告列表
export const fetchPublishedAnnouncements = (params) =>
  request.get('/announcements/published', { params })

// 确认公告（已读）
export const confirmAnnouncement = (id) =>
  request.post(`/announcements/${id}/confirm`)

// 检查是否已确认
export const checkConfirmation = (id) =>
  request.get(`/announcements/${id}/confirm`)

// 管理员：直接发布公告
export const createAnnouncement = (data) =>
  request.post('/announcements', data)

// 管理员：获取所有公告列表
export const fetchAllAnnouncements = (params) =>
  request.get('/announcements/admin/all', { params })

// 管理员：获取待审核公告列表
export const fetchPendingAnnouncements = () =>
  request.get('/announcements/admin/pending')

// 管理员：审核通过公告
export const approveAnnouncement = (id) =>
  request.post(`/announcements/admin/${id}/approve`)

// 管理员：驳回公告
export const rejectAnnouncement = (id, remark) =>
  request.post(`/announcements/admin/${id}/reject`, { remark })

// 管理员：获取所有公告的确认数统计
export const fetchAdminConfirmationStats = () =>
  request.get('/announcements/admin/stats')

// 组织者：申请发布公告
export const applyAnnouncement = (data) =>
  request.post('/announcements/apply', data)

// 组织者：获取自己申请发布的公告确认数
export const fetchOrganizerConfirmationStats = () =>
  request.get('/announcements/organizer/stats')

