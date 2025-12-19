import request from './request'

// 获取资讯列表
export const fetchNewsList = (params) =>
  request.get('/news', { params })

// 获取资讯详情
export const fetchNewsDetail = (id) =>
  request.get(`/news/${id}`)

// 管理员：创建资讯
export const createNews = (data) => {
  const formData = new FormData()
  formData.append('title', data.title)
  formData.append('content', data.content)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.post('/news', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 管理员：获取所有资讯列表
export const fetchAllNews = (params) =>
  request.get('/news/admin/all', { params })

// 管理员：更新资讯
export const updateNews = (id, data) => {
  const formData = new FormData()
  formData.append('title', data.title)
  formData.append('content', data.content)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.put(`/news/${id}`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 管理员：删除资讯
export const deleteNews = (id) =>
  request.delete(`/news/${id}`)

