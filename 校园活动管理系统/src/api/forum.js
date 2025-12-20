import request from './request'

// 获取帖子列表
export const fetchPosts = (params) =>
  request.get('/forum/posts', { params })

// 获取帖子详情
export const fetchPostDetail = (id) =>
  request.get(`/forum/posts/${id}`)

// 发帖
export const createPost = (data) => {
  const formData = new FormData()
  formData.append('title', data.title)
  formData.append('content', data.content)
  formData.append('categoryId', data.categoryId || 0)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.post('/forum/posts', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 更新帖子
export const updatePost = (id, data) => {
  const formData = new FormData()
  formData.append('title', data.title)
  formData.append('content', data.content)
  if (data.image) {
    formData.append('image', data.image)
  }
  return request.put(`/forum/posts/${id}`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 删除帖子
export const deletePost = (id) =>
  request.delete(`/forum/posts/${id}`)

// 获取我的统计
export const fetchMyStats = () =>
  request.get('/forum/my/stats')

// 获取我的发帖列表
export const fetchMyPosts = (params) =>
  request.get('/forum/my/posts', { params })

// 获取我评论的帖子列表
export const fetchMyCommentedPosts = (params) =>
  request.get('/forum/my/commented-posts', { params })

// 添加评论
export const addComment = (postId, content) =>
  request.post(`/forum/posts/${postId}/comments`, { content })

// 获取帖子评论列表
export const fetchPostComments = (postId, params) =>
  request.get(`/forum/posts/${postId}/comments`, { params })

// 收藏/取消收藏
export const toggleFavorite = (postId) =>
  request.post(`/forum/posts/${postId}/favorite`)

// 检查收藏状态
export const checkFavorite = (postId) =>
  request.get(`/forum/posts/${postId}/favorite`)

// 管理员：获取待审核帖子列表
export const fetchPendingPosts = () =>
  request.get('/forum/admin/pending')

// 管理员：审核通过帖子
export const approvePost = (id) =>
  request.post(`/forum/admin/posts/${id}/approve`)

// 管理员：驳回帖子
export const rejectPost = (id, remark) =>
  request.post(`/forum/admin/posts/${id}/reject`, { remark })

