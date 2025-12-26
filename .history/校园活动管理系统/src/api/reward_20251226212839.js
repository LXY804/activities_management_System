import request from './request'

export const fetchRewardsSummary = () => request.get('/rewards/summary')

export const fetchGiftLibrary = (params) => request.get('/rewards/gifts', { params })

export const redeemGift = (giftId, payload) =>
  request.post(`/rewards/gifts/${giftId}/redeem`, payload)

export const fetchRewardOrders = () => request.get('/rewards/orders/mine')

export const submitGiftFeedback = (orderId, payload) =>
  request.post(`/rewards/orders/${orderId}/feedback`, payload)

export const fetchManagedGifts = () => request.get('/rewards/gifts/manage')

export const createGift = (payload) => {
  if (payload instanceof FormData) {
    return request.post('/rewards/gifts', payload, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
  return request.post('/rewards/gifts', payload)
}

export const updateGift = (id, payload) => {
  if (payload instanceof FormData) {
    return request.patch(`/rewards/gifts/${id}`, payload, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
  return request.patch(`/rewards/gifts/${id}`, payload)
}

export const updateGiftStatus = (id, payload) =>
  request.patch(`/rewards/gifts/${id}/status`, payload)

export const fetchOrganizerRewardStats = () =>
  request.get('/rewards/organizer/analytics')

export const fetchAdminRewardOverview = () =>
  request.get('/rewards/admin/overview')

export const fetchPointRules = (params) => request.get('/rewards/rules', { params })

export const savePointRule = (payload) => request.post('/rewards/rules', payload)

export const deletePointRule = (id) => request.delete(`/rewards/rules/${id}`)

export const adjustRewardPoints = (payload) =>
  request.post('/rewards/transactions/adjust', payload)

export const fetchAdminRewardOrders = (params) =>
  request.get('/rewards/admin/orders', { params })

export const updateAdminOrderStatus = (orderId, payload) =>
  request.patch(`/rewards/admin/orders/${orderId}/status`, payload)

export const fetchPointsRanking = (params) =>
  request.get('/rewards/ranking/points', { params })

// 在 reward.js 末尾或合适位置添加
export const fetchPointsRanking = (params) => request.get('/rewards/ranking', { params })