import request from './request'

// 获取礼品列表
export const fetchGifts = () =>
  request.get('/gifts')

// 获取礼品详情
export const fetchGiftDetail = (id) =>
  request.get(`/gifts/${id}`)

// 管理员：创建礼品
export const createGift = (data) => {
  const formData = new FormData()
  formData.append('name', data.name)
  formData.append('description', data.description || '')
  formData.append('points_required', data.points_required)
  formData.append('stock', data.stock)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.post('/gifts', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 管理员：获取所有礼品列表
export const fetchAllGifts = () =>
  request.get('/gifts/admin/all')

// 管理员：更新礼品
export const updateGift = (id, data) => {
  const formData = new FormData()
  formData.append('name', data.name)
  formData.append('description', data.description || '')
  formData.append('points_required', data.points_required)
  formData.append('stock', data.stock)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.put(`/gifts/${id}`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 管理员：删除礼品
export const deleteGift = (id) =>
  request.delete(`/gifts/${id}`)

