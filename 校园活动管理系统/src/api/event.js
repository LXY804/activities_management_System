import request from './request'

// 公共活动接口
export const fetchEvents = (params) =>
  request.get('/events', { params })

export const fetchEventHighlights = (params) =>
  request.get('/events/highlights', { params })

export const fetchWeeklyEvents = (params) =>
  request.get('/events/week', { params })

export const fetchEventDetail = (id) =>
  request.get(`/events/${id}`)

// 推荐列表（按用户）
export const fetchRecommendations = (params) =>
  request.get('/recommendations', { params })

// 相似活动（按活动）
export const fetchSimilarActivities = (activityId) =>
  request.get('/recommendations/similar', { params: { activity_id: activityId } })

// 获取活动类型列表
export const fetchActivityTypes = () =>
  request.get('/events/types')

export const registerEvent = (id) =>
  request.post(`/events/${id}/register`)

// 组织者提交活动（进入审核队列）
export const createEvent = (data) => {
  if (data instanceof FormData) {
    return request.post('/events', data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
  return request.post('/events', data)
}

// 组织者：使用大模型生成活动文案
export const generateEventCopy = (payload) =>
  request.post('/events/generate-copy', payload)

// 组织者：获取自己提交的活动及审核状态
export const fetchOrganizerEvents = () =>
  request.get('/events/organizer/mine')

// 管理员：获取待审核活动列表
export const fetchPendingEvents = () =>
  request.get('/events/admin/pending')

// 管理员：审核通过活动
export const approveEvent = (creationId) =>
  request.post(`/events/admin/${creationId}/approve`)

// 管理员：驳回活动
export const rejectEvent = (creationId, remark) =>
  request.post(`/events/admin/${creationId}/reject`, { remark })