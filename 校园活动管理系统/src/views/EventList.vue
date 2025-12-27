<template>
  <div class="page events-dashboard">
    <div class="background-atmosphere">
      <div class="glow-orb orb-1"></div>
      <div class="glow-orb orb-2"></div>
    </div>

    <NavBar style="position: relative; z-index: 100;" />
    
    <main class="dashboard-wrapper">
      <div class="dashboard-inner">
        <header class="dashboard-header glass-soft">
          <div class="header-top">
            <div class="brand-section">
              <span class="hub-tag">🌱 Activity Hub</span>
              <h1 class="page-title">清新活动<span class="accent-text">宇宙</span></h1>
            </div>
            
            <div class="stats-overview">
              <div class="stat-item">
                <span class="stat-label">总量</span>
                <span class="stat-num">{{ totalCount }}</span>
              </div>
              <div class="stat-item highlight">
                <span class="stat-label">进行中</span>
                <span class="stat-num">{{ liveCount }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">未开始</span>
                <span class="stat-num">{{ upcomingCount }}</span>
              </div>
            </div>
          </div>

          <div class="header-filters">
            <div class="tab-group">
              <button
                v-for="(t, idx) in tabs"
                :key="t"
                class="filter-tab"
                :class="{ active: activeTab === idx }"
                @click="setTab(idx)"
              >
                {{ t }}
              </button>
            </div>
            <div class="select-wrapper">
              <select v-model="selectedTypeId" class="minimal-select" @change="handleTypeChange">
                <option value="">所有分类</option>
                <option v-for="type in activityTypes" :key="type.id" :value="type.id">
                  {{ type.name }}
                </option>
              </select>
            </div>
          </div>
        </header>

        <section class="scroll-viewport">
          <div class="cards-layout" v-if="!loading && filteredEvents.length">
            <article 
              v-for="(ev, index) in filteredEvents" 
              :key="ev.id" 
              class="event-card-compact glass-soft-hover"
              @click="open(ev.id)"
            >
              <div class="thumb-box">
                <OptimizedImage
                  :src="ev.image"
                  :alt="ev.title"
                  :lazy="index >= 3"
                  :priority="index < 3 ? 'high' : 'auto'"
                  width="100%"
                  height="200px"
                />
                <div class="tag-overlay">
                  <span class="status-pill" :data-status="ev.status">{{ ev.statusText }}</span>
                </div>
              </div>
              
              <div class="content-box">
                <h3 class="event-name">{{ ev.title }}</h3>
                <div class="event-meta">
                  <span>📍 {{ ev.location }}</span>
                  <span class="dot">·</span>
                  <span>👥 {{ ev.signed_up }}人参与</span>
                </div>
                <div class="card-action">
                  <span class="date-tag">{{ ev.time.split(' ')[0] }}...</span>
                  <button class="cta-mini-btn" @click.stop="cta(ev)">{{ ev.cta }}</button>
                </div>
              </div>
            </article>
          </div>

          <div v-else class="dashboard-state">
            <div v-if="loading" class="pulse-loader">正在呼吸绿意...</div>
            <div v-else-if="errorMsg" class="error-msg">{{ errorMsg }}</div>
            <div v-else class="empty-msg">暂时没有新活动，休息一下吧 🍃</div>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
import OptimizedImage from '@/components/OptimizedImage.vue'
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { fetchEvents, fetchActivityTypes } from '@/api/event'

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')
const DEFAULT_COVER = `${API_ORIGIN}/uploads/3b72bdb5a6ca17d85131e816c9fdd0b1.jpg`

const buildImageUrl = (coverUrl) => {
  if (!coverUrl || coverUrl === '' || coverUrl === 'null') return DEFAULT_COVER
  if (coverUrl.startsWith('http')) return coverUrl
  return API_ORIGIN + (coverUrl.startsWith('/') ? coverUrl : '/' + coverUrl.replace(/\\/g, '/'))
}

const router = useRouter()
const tabs = ['全部', '进行中', '未开始', '已结束']
const activeTab = ref(0)
const events = ref([])
const loading = ref(false)
const errorMsg = ref('')
const activityTypes = ref([])
const selectedTypeId = ref('')

const statusLabelMap = { open: '进行中', ongoing: '进行中', upcoming: '未开始', finished: '已结束', ended: '已结束' }
const ctaMap = { open: '立即报名', upcoming: '查看详情', finished: '查看评价', ended: '已结束' }

const loadEvents = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchEvents(selectedTypeId.value ? { category_id: selectedTypeId.value } : {})
    events.value = data?.list?.map(item => ({
      ...item,
      image: buildImageUrl(item.cover_url),
      statusText: statusLabelMap[item.status] || '进行中',
      cta: ctaMap[item.status] || '查看',
      time: formatTimeRange(item.start_time, item.end_time)
    })) || []
    
    // 如果没有数据，显示提示
    if (!events.value.length && !loading.value) {
      errorMsg.value = '暂无活动数据'
    }
  } catch (err) { 
    console.error('加载活动列表失败:', err)
    errorMsg.value = err?.message || err?.response?.data?.message || '加载失败，请检查网络连接或稍后重试'
  } 
  finally { loading.value = false }
}

const formatTimeRange = (start) => start ? `${new Date(start).getMonth() + 1}月${new Date(start).getDate()}日` : ''

onMounted(() => {
  fetchActivityTypes().then(res => activityTypes.value = res || [])
  loadEvents()
})

const handleTypeChange = () => loadEvents()
const setTab = (idx) => activeTab.value = idx
const open = (id) => router.push({ name: 'EventInfo', params: { id } })

// 图片错误处理已由 OptimizedImage 组件处理

const filteredEvents = computed(() => {
  if (activeTab.value === 0) return events.value
  const statusMatch = { 1: ['open', 'ongoing'], 2: ['upcoming'], 3: ['finished', 'ended'] }
  return events.value.filter(e => statusMatch[activeTab.value].includes(e.status))
})

const totalCount = computed(() => events.value.length)
const liveCount = computed(() => events.value.filter(e => ['open', 'ongoing'].includes(e.status)).length)
const upcomingCount = computed(() => events.value.filter(e => e.status === 'upcoming').length)
</script>

<style scoped>
/* --- 全局布局优化 --- */
.events-dashboard {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f8fafc;
  position: relative;
  overflow: hidden;
}

.background-atmosphere {
  position: fixed;
  inset: 0;
  z-index: 0;
  background: radial-gradient(at 0% 0%, #f0fdf4 0%, transparent 50%),
              radial-gradient(at 100% 100%, #eff6ff 0%, transparent 50%);
  pointer-events: none;
}

.glow-orb {
  position: absolute;
  filter: blur(100px);
  border-radius: 50%;
  opacity: 0.4;
}
.orb-1 { width: 500px; height: 500px; background: #d1fae5; top: -100px; right: -100px; }
.orb-2 { width: 400px; height: 400px; background: #e0f2fe; bottom: -50px; left: -50px; }

.dashboard-wrapper {
  position: relative;
  z-index: 1; /* 确保主体在背景之上，但在 NavBar 之下 */
  flex: 1;
  display: flex;
  justify-content: center;
  padding: 24px 24px 20px; /* 移除了多余的顶部偏移，由内容自行撑开 */
  overflow: hidden;
}

.dashboard-inner {
  width: 100%;
  max-width: 1100px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  height: calc(100vh - 100px); 
}

/* --- 看板组件 --- */
.glass-soft {
  background: rgba(255, 255, 255, 0.65);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 24px 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.5);
}

.dashboard-header {
  position: sticky;
  top: 0; /* 修复点：粘性定位设为0，确保不向上冲破布局 */
  z-index: 10;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 24px;
}

.hub-tag { font-size: 12px; font-weight: 800; color: #10b981; background: #f0fdf4; padding: 4px 12px; border-radius: 100px; }
.page-title { font-size: 32px; margin: 8px 0 0; color: #1e293b; letter-spacing: -1px; }
.accent-text { color: #10b981; margin-left: 4px; }

.stats-overview { display: flex; gap: 32px; }
.stat-item { text-align: right; }
.stat-label { font-size: 12px; color: #94a3b8; display: block; }
.stat-num { font-size: 26px; font-weight: 900; color: #1e293b; }
.stat-item.highlight .stat-num { color: #10b981; }

.header-filters {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 18px;
  border-top: 1px solid rgba(0, 0, 0, 0.04);
}

.filter-tab {
  padding: 8px 20px;
  border-radius: 100px;
  border: none;
  background: transparent;
  color: #64748b;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}
.filter-tab.active { background: #10b981; color: white; box-shadow: 0 4px 15px rgba(16, 185, 129, 0.2); }

.minimal-select {
  padding: 8px 16px;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  background: white;
  font-size: 14px;
  color: #1e293b;
  outline: none;
}

/* --- 滚动区 --- */
.scroll-viewport {
  flex: 1;
  overflow-y: auto;
  padding-bottom: 20px;
  min-height: 0;
  scrollbar-width: none;
}
.scroll-viewport::-webkit-scrollbar { width: 0; display: none; }

.cards-layout {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
}

/* --- 卡片设计 --- */
.event-card-compact {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.8);
  transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
  cursor: pointer;
}

.event-card-compact:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 32px rgba(15, 42, 66, 0.06);
}

.thumb-box { 
  position: relative; 
  height: 120px; 
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  overflow: hidden;
}
.thumb-box img { 
  width: 100%; 
  height: 100%; 
  object-fit: cover;
  opacity: 0;
  transition: opacity 0.3s ease;
}
.thumb-box img[src] {
  opacity: 1;
}

.tag-overlay { position: absolute; top: 8px; right: 8px; }
.status-pill {
  font-size: 9px; font-weight: 800; padding: 3px 8px; border-radius: 6px;
  background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(4px); color: #1e293b;
}
.status-pill[data-status="open"] { color: #10b981; border: 1px solid rgba(16, 185, 129, 0.1); }

.content-box { padding: 12px; }
.event-name { font-size: 15px; margin: 0 0 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #1e293b; font-weight: 700; }
.event-meta { font-size: 11px; color: #94a3b8; display: flex; align-items: center; gap: 4px; margin-bottom: 10px; }
.card-action { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f8fafc; padding-top: 10px; }
.date-tag { font-size: 11px; color: #10b981; font-weight: 700; }

.cta-mini-btn {
  background: #f0fdf4; color: #10b981; border: none; padding: 5px 12px;
  border-radius: 6px; font-size: 10px; font-weight: 700; cursor: pointer; transition: 0.2s;
}
.cta-mini-btn:hover { background: #10b981; color: white; }

@media (max-width: 768px) {
  .dashboard-wrapper { padding: 20px 16px; }
  .header-top { flex-direction: column; align-items: flex-start; gap: 16px; }
  .stats-overview { width: 100%; justify-content: space-between; }
}
</style>