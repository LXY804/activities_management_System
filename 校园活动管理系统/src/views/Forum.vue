<template>
  <div class="forum-page">
    <NavBar />
    
    <div class="forum-container">
      <!-- 标题 -->
      <h1 class="forum-title">欢迎来到校园论坛系统</h1>

      <!-- 导航标签 -->
      <div class="forum-tabs">
        <router-link 
          to="/forum" 
          class="tab-item"
          :class="{ active: $route.path === '/forum' }"
        >
          首页
        </router-link>
        <router-link 
          to="/forum/post" 
          class="tab-item"
          :class="{ active: $route.path === '/forum/post' }"
        >
          论坛发帖
        </router-link>
        <router-link 
          to="/forum/my-posts" 
          class="tab-item"
          :class="{ active: $route.path === '/forum/my-posts' }"
        >
          我的发帖
        </router-link>
        <router-link 
          to="/forum/my-commented" 
          class="tab-item"
          :class="{ active: $route.path === '/forum/my-commented' }"
        >
          我评论的帖子
        </router-link>
        <div class="user-info" v-if="isLoggedIn">
          <span>{{ username }}</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M19 9l-7 7-7-7"/>
          </svg>
        </div>
      </div>

      <!-- 发帖区域 -->
      <div class="post-form-section" v-if="showPostForm">
        <div class="form-column">
          <input 
            v-model="postForm.title" 
            type="text" 
            placeholder="请输入标题" 
            class="form-input"
          />
          <textarea 
            v-model="postForm.content" 
            placeholder="请输入简介" 
            class="form-textarea"
          ></textarea>
        </div>
        <div class="form-actions">
          <button class="post-btn" @click="handlePost">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="22" y1="2" x2="11" y2="13"></line>
              <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
            </svg>
            发帖
          </button>
        </div>
      </div>

      <!-- 搜索区域 -->
      <div class="search-section" v-if="!showPostForm">
        <div class="search-box">
          <input 
            v-model="searchKeyword" 
            type="text" 
            placeholder="搜索帖子..." 
            class="search-input"
            @keyup.enter="handleSearch"
          />
          <button class="search-btn" @click="handleSearch">搜索</button>
          <button class="reset-btn" @click="handleReset">重置</button>
        </div>
      </div>

      <!-- 帖子列表 -->
      <div class="posts-list" v-if="!loading && !errorMsg && posts.length">
        <div v-for="post in posts" :key="post.id" class="post-card">
          <div class="post-header">
            <div class="post-title">{{ post.title }}</div>
            <div class="post-meta">
              <span>作者：{{ post.author }}</span>
              <span>{{ formatTime(post.created_at) }}</span>
            </div>
          </div>
          <div class="post-content">{{ post.content }}</div>
          <div class="post-image" v-if="post.image_url">
            <img :src="buildImageUrl(post.image_url)" alt="帖子图片" />
          </div>
          <div class="post-footer">
            <span>评论 {{ post.comment_count }}</span>
            <span>收藏 {{ post.favorite_count }}</span>
            <div class="post-actions" v-if="isMyPost(post)">
              <button class="edit-btn" @click="handleEdit(post)">编辑</button>
              <button class="delete-btn" @click="handleDelete(post.id)">删除</button>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="loading" class="loading">加载中...</div>
      <div v-else-if="errorMsg" class="error">{{ errorMsg }}</div>
      <div v-else class="empty">暂无帖子</div>

      <!-- 分页 -->
      <div class="pagination" v-if="totalPages > 1 && !loading">
        <button 
          class="pager-btn" 
          :disabled="page === 1" 
          @click="changePage(page - 1)"
        >
          &lt;
        </button>
        <span class="pager-info">第 {{ page }} / {{ totalPages }} 页</span>
        <button 
          class="pager-btn" 
          :disabled="page === totalPages" 
          @click="changePage(page + 1)"
        >
          &gt;
        </button>
        <div class="page-size-selector">
          <select v-model="pageSize" @change="handlePageSizeChange">
            <option :value="10">10条/页</option>
            <option :value="20">20条/页</option>
            <option :value="50">50条/页</option>
          </select>
        </div>
        <span class="total-info">共 {{ total }} 条</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import NavBar from '@/components/NavBar.vue'
import { fetchPosts, createPost, deletePost } from '@/api/forum'

const route = useRoute()
const router = useRouter()

const API_ORIGIN = (
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api'
).replace(/\/api\/?$/, '')

const buildImageUrl = (imageUrl) => {
  if (!imageUrl) return ''
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl
  }
  let normalized = imageUrl.replace(/\\/g, '/')
  if (!normalized.startsWith('/')) {
    normalized = '/' + normalized
  }
  return API_ORIGIN + normalized
}

const isLoggedIn = ref(false)
const username = ref('')
const showPostForm = ref(false)
const posts = ref([])
const loading = ref(false)
const errorMsg = ref('')
const searchKeyword = ref('')
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const postForm = ref({
  title: '',
  content: ''
})

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(total.value / pageSize.value))
})

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const isMyPost = (post) => {
  const userId = localStorage.getItem('userId')
  return isLoggedIn.value && post.author_id && String(post.author_id) === userId
}

const loadPosts = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const params = {
      page: page.value,
      pageSize: pageSize.value
    }
    if (searchKeyword.value) {
      params.keyword = searchKeyword.value
    }
    const data = await fetchPosts(params)
    posts.value = data?.list || []
    total.value = data?.total || 0
  } catch (err) {
    console.error(err)
    errorMsg.value = err?.message || '加载帖子失败'
  } finally {
    loading.value = false
  }
}

const handlePost = async () => {
  if (!isLoggedIn.value) {
    alert('请先登录')
    router.push('/login')
    return
  }

  if (!postForm.value.title || !postForm.value.content) {
    alert('请填写标题和内容')
    return
  }

  try {
    await createPost({
      title: postForm.value.title,
      content: postForm.value.content
    })
    alert('发帖成功')
    postForm.value = { title: '', content: '' }
    showPostForm.value = false
    loadPosts()
  } catch (err) {
    alert(err?.message || '发帖失败')
  }
}

const handleEdit = (post) => {
  router.push(`/forum/post/${post.id}`)
}

const handleDelete = async (postId) => {
  if (!confirm('确认删除此帖子吗？')) return
  try {
    await deletePost(postId)
    alert('删除成功')
    loadPosts()
  } catch (err) {
    alert(err?.message || '删除失败')
  }
}

const handleSearch = () => {
  page.value = 1
  loadPosts()
}

const handleReset = () => {
  searchKeyword.value = ''
  page.value = 1
  loadPosts()
}

const changePage = (p) => {
  if (p < 1 || p > totalPages.value) return
  page.value = p
  window.scrollTo({ top: 0, behavior: 'smooth' })
  loadPosts()
}

const handlePageSizeChange = () => {
  page.value = 1
  loadPosts()
}

onMounted(() => {
  isLoggedIn.value = !!localStorage.getItem('isLoggedIn')
  username.value = localStorage.getItem('username') || ''
  showPostForm.value = route.path === '/forum/post'
  loadPosts()
})

watch(() => route.path, (newPath) => {
  showPostForm.value = newPath === '/forum/post'
  if (newPath === '/forum') {
    loadPosts()
  }
})
</script>

<style scoped>
.forum-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 40px;
}

.forum-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px 16px;
}

.forum-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.forum-tabs {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
  padding: 12px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.tab-item {
  padding: 8px 16px;
  text-decoration: none;
  color: #666;
  border-radius: 4px;
  transition: all 0.2s;
  font-weight: 500;
}

.tab-item:hover {
  background: #f0f0f0;
}

.tab-item.active {
  color: #0b4ea2;
  background: #e3f2fd;
  font-weight: 600;
}

.user-info {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 4px;
  color: #333;
  font-weight: 500;
}

.user-info svg {
  width: 16px;
  height: 16px;
}

.post-form-section {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.form-input {
  width: 100%;
  max-width: 500px;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-input:focus {
  outline: none;
  border-color: #0b4ea2;
}

.form-textarea {
  width: 100%;
  max-width: 500px;
  height: 300px;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
}

.form-textarea:focus {
  outline: none;
  border-color: #0b4ea2;
}

.form-actions {
  display: flex;
  justify-content: center;
  align-items: center;
}

.post-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  background: #0b4ea2;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: opacity 0.2s;
}

.post-btn:hover {
  opacity: 0.9;
}

.post-btn svg {
  width: 16px;
  height: 16px;
}

.search-actions {
  display: flex;
  gap: 8px;
}

.search-section {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.search-box {
  display: flex;
  gap: 8px;
  align-items: center;
  justify-content: center;
}

.search-input {
  flex: 1;
  max-width: 300px;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.search-input:focus {
  outline: none;
  border-color: #0b4ea2;
}

.search-btn, .reset-btn {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.search-btn {
  background: #0b4ea2;
  color: #fff;
  border-color: #0b4ea2;
}

.search-btn:hover {
  opacity: 0.9;
}

.reset-btn:hover {
  background: #f5f5f5;
}

.posts-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.post-card {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.post-header {
  margin-bottom: 12px;
}

.post-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.post-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  color: #999;
}

.post-content {
  font-size: 15px;
  color: #666;
  line-height: 1.6;
  margin-bottom: 12px;
}

.post-image {
  margin: 12px 0;
}

.post-image img {
  max-width: 100%;
  border-radius: 4px;
}

.post-footer {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 14px;
  color: #999;
  padding-top: 12px;
  border-top: 1px solid #eee;
}

.post-actions {
  margin-left: auto;
  display: flex;
  gap: 8px;
}

.edit-btn, .delete-btn {
  padding: 4px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s;
}

.edit-btn {
  color: #0b4ea2;
  border-color: #0b4ea2;
}

.edit-btn:hover {
  background: #e3f2fd;
}

.delete-btn {
  color: #f44336;
  border-color: #f44336;
}

.delete-btn:hover {
  background: #ffebee;
}

.loading, .error, .empty {
  text-align: center;
  padding: 40px;
  color: #999;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: center;
  margin-top: 24px;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.pager-btn {
  padding: 6px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  font-size: 14px;
}

.pager-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.pager-btn:not(:disabled):hover {
  background: #f5f5f5;
}

.pager-info {
  color: #666;
  font-size: 14px;
}

.page-size-selector select {
  padding: 6px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.total-info {
  color: #666;
  font-size: 14px;
}
</style>

