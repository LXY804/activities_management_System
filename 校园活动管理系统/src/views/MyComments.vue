<template>
  <div class="comment-page">
    <div class="halo halo-1"></div>
    <div class="halo halo-2"></div>

    <div class="comment-shell">
      <section class="comment-intro glass-panel">
        <div class="intro-text">
          <p class="intro-eyebrow">Feedback Log</p>
          <h2>我的互动轨迹</h2>
        </div>
        <ul class="intro-stats">
          <li>
            <span>全部记录</span>
            <strong>{{ comments.length }}</strong>
          </li>
          <li>
            <span>已通过</span>
            <strong>{{ publishedCount }}</strong>
          </li>
          <li>
            <span>审核中</span>
            <strong>{{ pendingCount }}</strong>
          </li>
        </ul>
      </section>

      <section class="comment-stream glass-panel">
        <div v-if="loading" class="empty-state">
          正在加载评论...
        </div>

        <div v-else-if="errorMsg" class="empty-state">
          {{ errorMsg }}
        </div>

        <ul v-else-if="comments.length" class="comment-list">
          <li v-for="comment in comments" :key="comment.id" class="comment-row">
            <div class="row-head">
              <div class="title-block">
                <p class="activity-name">{{ comment.activityName }}</p>
                <div class="meta-line">
                  <span>🕒 {{ comment.time || '时间待定' }}</span>
                  <span>📍 {{ comment.location || '地点待定' }}</span>
                </div>
              </div>
              <span class="score-chip">{{ comment.score }}分</span>
            </div>
            <p class="row-content">{{ comment.content }}</p>
            <div class="row-footer">
              <span>评论时间 {{ comment.date || '——' }}</span>
              <span :class="['status-pill', comment.statusType]">{{ comment.status }}</span>
            </div>
          </li>
        </ul>

        <div v-else class="empty-state">
          <p>暂无评论数据</p>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { fetchMyComments } from '@/api/comment'
import { useRouter } from 'vue-router'

const router = useRouter()
const comments = ref([])
const loading = ref(false)
const errorMsg = ref('')

const mapStatus = (value) => {
  if (value === 1) return { label: '已通过', type: 'approved' }
  if (value === 0) return { label: '审核中', type: 'pending' }
  return { label: '已隐藏', type: 'hidden' }
}

const requireLogin = () => {
  if (!localStorage.getItem('token')) {
    if (confirm('此操作需要登录，是否前往登录？')) {
      router.push('/login')
    }
    return false
  }
  return true
}

const loadComments = async () => {
  if (!requireLogin()) return
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchMyComments()
    comments.value =
      data?.list?.map((item) => {
        const { label, type } = mapStatus(item.status)
        return {
          id: item.id,
          activityName: item.event_title,
          time: item.start_time ? new Date(item.start_time).toLocaleString() : '',
          location: item.location || '',
          score: item.rating,
          content: item.content,
          date: item.created_at ? new Date(item.created_at).toLocaleString() : '',
          status: label,
          statusType: type
        }
      }) || []
  } catch (err) {
    console.error(err)
    errorMsg.value = err?.message || '加载评论失败'
  } finally {
    loading.value = false
  }
}

const publishedCount = computed(() => comments.value.filter((item) => item.statusType === 'approved').length)
const pendingCount = computed(() => comments.value.filter((item) => item.statusType === 'pending').length)

onMounted(loadComments)
</script>

<style scoped>
.comment-page {
  --mint: #0db18c;
  --ink: #0f172a;
  min-height: 100vh;
  padding: 72px 20px 48px;
  background: linear-gradient(180deg, #f8fafc 0%, #eef5ff 40%, #ffffff 100%);
  position: relative;
  overflow: hidden;
}

.halo {
  position: absolute;
  border-radius: 50%;
  filter: blur(70px);
  opacity: 0.35;
}

.halo-1 { width: 420px; height: 320px; background: #d1fae5; top: -120px; left: -80px; }
.halo-2 { width: 360px; height: 360px; background: #c7d2fe; bottom: -140px; right: -40px; }

.comment-shell {
  position: relative;
  z-index: 1;
  max-width: 900px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.glass-panel {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(255, 255, 255, 0.9);
  border-radius: 26px;
  box-shadow: 0 12px 40px rgba(15, 23, 42, 0.08);
  backdrop-filter: blur(16px);
  padding: 28px;
}

.comment-intro {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.intro-text h2 {
  margin: 6px 0 8px;
  font-size: 30px;
  font-weight: 800;
  color: var(--ink);
}

.intro-text p {
  margin: 0;
  color: #64748b;
  line-height: 1.5;
}

.intro-eyebrow {
  text-transform: uppercase;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--mint);
  font-weight: 700;
}

.intro-stats {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  gap: 16px;
}

.intro-stats li {
  min-width: 120px;
  padding: 14px 18px;
  border-radius: 18px;
  background: rgba(13, 177, 140, 0.08);
  border: 1px solid rgba(13, 177, 140, 0.2);
  text-align: center;
}

.intro-stats span {
  display: block;
  font-size: 12px;
  color: #64748b;
}

.intro-stats strong {
  font-size: 24px;
  color: var(--ink);
  font-weight: 800;
}

.comment-stream {
  min-height: 360px;
}

.empty-state {
  text-align: center;
  padding: 72px 16px;
  color: #94a3b8;
  font-size: 16px;
}

.comment-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-height: 520px;
  overflow-y: auto;
  padding-right: 6px;
}

.comment-list::-webkit-scrollbar { width: 6px; }
.comment-list::-webkit-scrollbar-thumb { background: rgba(13, 177, 140, 0.35); border-radius: 999px; }

.comment-row {
  border-radius: 20px;
  border: 1px solid rgba(148, 163, 184, 0.25);
  padding: 20px;
  background: linear-gradient(120deg, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.85));
  box-shadow: 0 8px 24px rgba(15, 23, 42, 0.05);
}

.row-head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
}

.activity-name {
  font-size: 18px;
  font-weight: 700;
  color: var(--ink);
  margin: 0 0 6px;
}

.meta-line {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  font-size: 13px;
  color: #64748b;
}

.score-chip {
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(99, 102, 241, 0.15);
  color: #4338ca;
  font-weight: 700;
}

.row-content {
  margin: 14px 0;
  font-size: 15px;
  color: #475569;
  line-height: 1.7;
}

.row-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  color: #94a3b8;
}

.status-pill {
  padding: 6px 14px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.status-pill.approved { background: rgba(13, 177, 140, 0.18); color: #047857; }
.status-pill.pending { background: rgba(99, 102, 241, 0.18); color: #3730a3; }
.status-pill.hidden { background: rgba(148, 163, 184, 0.25); color: #475569; }

@media (max-width: 768px) {
  .comment-intro { flex-direction: column; align-items: flex-start; }
  .intro-stats { width: 100%; flex-wrap: wrap; }
  .row-footer { flex-direction: column; gap: 8px; align-items: flex-start; }
}
</style>

