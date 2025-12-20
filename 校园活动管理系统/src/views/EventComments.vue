<template>
  <div class="page event-comments">
    <NavBar />

    <div class="container">
      <button class="back" @click="goBack">← 返回</button>

      <div class="header">
        <h1 class="title">{{ eventTitle || '活动评论' }}</h1>
        <p class="subtitle" v-if="eventTitle">查看所有用户对该活动的评价</p>
      </div>

      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="errorMsg" class="error">{{ errorMsg }}</div>
      <div v-else>
        <div class="stats" v-if="commentsData.total > 0">
          <span>共 {{ commentsData.total }} 条评论</span>
        </div>

        <div v-if="comments.length === 0" class="empty-state">
          <p>暂无评论</p>
        </div>

        <div v-else class="comments-list">
          <div v-for="comment in comments" :key="comment.id" class="comment-card">
            <div class="comment-header">
              <div class="user-info">
                <span class="username">{{ comment.username || '匿名用户' }}</span>
                <span class="rating">
                  <span class="stars">{{ '★'.repeat(comment.rating) }}{{ '☆'.repeat(5 - comment.rating) }}</span>
                  <span class="rating-num">{{ comment.rating }}分</span>
                </span>
              </div>
              <span class="date">{{ formatDate(comment.created_at) }}</span>
            </div>
            <p class="comment-content">{{ comment.content }}</p>
          </div>
        </div>

        <!-- 分页 -->
        <div v-if="commentsData.total > commentsData.pageSize" class="pagination">
          <button 
            @click="loadComments(commentsData.page - 1)" 
            :disabled="commentsData.page <= 1"
            class="page-btn"
          >
            上一页
          </button>
          <span class="page-info">
            第 {{ commentsData.page }} / {{ Math.ceil(commentsData.total / commentsData.pageSize) }} 页
          </span>
          <button 
            @click="loadComments(commentsData.page + 1)" 
            :disabled="commentsData.page >= Math.ceil(commentsData.total / commentsData.pageSize)"
            class="page-btn"
          >
            下一页
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import { fetchEventComments } from '@/api/comment'
import { fetchEventDetail } from '@/api/event'

const router = useRouter()
const route = useRoute()
const eventId = route.params.id

const eventTitle = ref('')
const comments = ref([])
const commentsData = ref({
  list: [],
  total: 0,
  page: 1,
  pageSize: 10
})
const loading = ref(false)
const errorMsg = ref('')

function goBack() {
  router.back()
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN')
}

const loadEventInfo = async () => {
  try {
    const data = await fetchEventDetail(eventId)
    eventTitle.value = data.title || ''
  } catch (err) {
    console.error('加载活动信息失败:', err)
  }
}

const loadComments = async (page = 1) => {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchEventComments(eventId, { page, pageSize: commentsData.value.pageSize })
    comments.value = data?.list || []
    commentsData.value = {
      list: data?.list || [],
      total: data?.total || 0,
      page: data?.page || 1,
      pageSize: data?.pageSize || 10
    }
  } catch (err) {
    console.error(err)
    errorMsg.value = err?.message || '加载评论失败'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadEventInfo()
  loadComments()
})
</script>

<style scoped>
.container {
  max-width: 1100px;
  margin: 24px auto 80px;
  padding: 0 18px;
}

.back {
  background: transparent;
  border: none;
  color: #23a971;
  font-weight: 600;
  cursor: pointer;
  margin-bottom: 12px;
}

.header {
  margin-bottom: 28px;
}

.title {
  margin: 0;
  font-size: 32px;
  font-family: var(--font-display);
  color: var(--brand-deep);
}

.subtitle {
  margin: 6px 0 0;
  color: rgba(15, 29, 51, 0.6);
}

.stats {
  margin-bottom: 18px;
  font-weight: 600;
  color: rgba(15, 29, 51, 0.65);
}

.loading,
.error,
.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: rgba(15, 29, 51, 0.6);
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.comment-card {
  border-radius: 26px;
  padding: 20px 24px;
  box-shadow: var(--shadow-card);
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(255, 255, 255, 0.5);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 12px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.username {
  font-weight: 700;
  color: var(--brand-deep);
}

.rating {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.6);
  padding: 4px 12px;
  border-radius: 999px;
}

.stars {
  color: #ffb74d;
}

.date {
  color: rgba(15, 29, 51, 0.45);
}

.comment-content {
  margin: 0;
  color: rgba(15, 29, 51, 0.75);
  line-height: 1.7;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  padding: 24px 0;
}

.page-btn {
  border-radius: 999px;
  border: none;
  padding: 10px 18px;
  background: linear-gradient(120deg, var(--brand-lime), var(--brand-emerald));
  color: var(--brand-deep);
  font-weight: 600;
  cursor: pointer;
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .comment-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>







