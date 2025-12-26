<template>
  <div class="my-commented-posts-page">
    <NavBar />
    
    <div class="container">
      <h1 class="page-title">我评论的帖子</h1>

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
            <span class="comment-time">我的评论时间：{{ formatTime(post.my_comment_time) }}</span>
          </div>
        </div>
      </div>

      <div v-else-if="loading" class="loading">加载中...</div>
      <div v-else-if="errorMsg" class="error">{{ errorMsg }}</div>
      <div v-else class="empty">暂无评论的帖子</div>

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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '@/components/NavBar.vue'
import { fetchMyCommentedPosts } from '@/api/forum'

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

const posts = ref([])
const loading = ref(false)
const errorMsg = ref('')
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

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

const loadPosts = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchMyCommentedPosts({
      page: page.value,
      pageSize: pageSize.value
    })
    posts.value = data?.list || []
    total.value = data?.total || 0
  } catch (err) {
    console.error(err)
    errorMsg.value = err?.message || '加载失败'
  } finally {
    loading.value = false
  }
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
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    router.push('/login')
    return
  }
  loadPosts()
})
</script>

<style scoped>
.my-commented-posts-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 40px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px 16px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin-bottom: 20px;
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

.comment-time {
  margin-left: auto;
  color: #0b4ea2;
  font-weight: 500;
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

