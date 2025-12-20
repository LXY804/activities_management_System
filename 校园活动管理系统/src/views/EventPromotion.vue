<template>
  <div class="premium-page">
    <NavBar />

    <main class="dashboard-wrapper">
      <section class="bento-item hero-main">
        <div class="carousel-container">
          <transition name="fade-scale" mode="out-in">
            <div :key="currentHeroIndex" class="hero-content">
              <div class="hero-image-overlay">
                <img :src="currentHero.image" :alt="currentHero.title" />
                <div class="image-scrim"></div>
              </div>
              
              <div class="hero-info-layer">
                <div class="tag-row">
                  <span class="vibe-badge">{{ heroMood }}</span>
                  <span class="hot-badge">HOT 热门</span>
                </div>
                <h1 class="display-title">{{ currentHero.title }}</h1>
                <p class="hero-subtitle" v-html="currentHero.description"></p>
                
                <div class="hero-footer-meta">
                  <div class="meta-item">
                    <i class="icon">📍</i>
                    <span>{{ currentHero.location || '校园活动中心' }}</span>
                  </div>
                  <div class="meta-item">
                    <i class="icon">📅</i>
                    <span>{{ formatDate(currentHero.start_time) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </transition>
        </div>
      </section>

      <section class="bento-item activity-radar">
        <header class="section-header">
          <div class="header-text">
            <h3>元气雷达</h3>
            <p>本周共有 {{ events.length }} 场精彩</p>
          </div>
          <button 
            class="refresh-trigger" 
            :class="{ 'is-spinning': loading }" 
            @click="loadEvents"
            title="刷新活动"
          >
            <svg class="refresh-svg" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C14.8273 3 17.3509 4.30051 19 6.33333M19 6.33333V3M19 6.33333H15.6667" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
        </header>

        <div class="scroll-list custom-scrollbar">
          <div v-if="loading && events.length === 0" class="state-msg">精彩活动加载中...</div>
          <div v-for="event in events" :key="event.id" class="event-mini-card" @click="gotoEvent(event.id)">
            <div class="date-box">
              <span class="d-day">{{ event.date?.split('-')[2] }}</span>
              <span class="d-month">{{ event.weekday }}</span>
            </div>
            <div class="event-brief">
              <h4>{{ event.title }}</h4>
              <p>{{ event.location }}</p>
            </div>
            <div class="event-status">{{ event.statusText }}</div>
          </div>
          <div v-if="!loading && events.length === 0" class="state-msg">未来一周暂无活动</div>
        </div>
      </section>

      <section class="bento-item stats-grid">
        <div v-for="stat in heroStats" :key="stat.label" class="stat-tile">
          <span class="stat-label">{{ stat.label }}</span>
          <span class="stat-val">{{ stat.value }}</span>
        </div>
      </section>

      <section class="bento-item action-cta">
        <div class="cta-inner" :style="{ backgroundImage: `url(${currentHero.image})` }">
          <div class="cta-content">
            <p>准备好解锁新故事了吗？</p>
            <button class="primary-btn" @click="gotoEvent(currentHero.id)">
              立即报名参与 <span class="arrow-icon">↗</span>
            </button>
          </div>
        </div>
      </section>
    </main>
    
    <div class="bg-glow blob-1"></div>
    <div class="bg-glow blob-2"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import { fetchEventHighlights, fetchWeeklyEvents } from '@/api/event'

const router = useRouter()
const heroEvents = ref([])
const currentHeroIndex = ref(0)
const events = ref([])
const loading = ref(false)

const VIBE_LABELS = ['能量补给', '社交现场', '灵感工坊', '律动打卡', '硬核交流']
const STATUS_TEXT = { open: '进行中', upcoming: '预热中', ended: '已结束' }

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')
const DEFAULT_COVER = `${API_ORIGIN}/uploads/default.jpg`
const DEFAULT_HERO = {
  title: '校园活动热浪',
  description: '更多武汉理工校园活动正在筹备中，敬请期待。',
  image: DEFAULT_COVER,
  location: '校园活动中心',
  start_time: null
}

const buildImageUrl = (url) => {
  if (!url || url === 'null' || url === '') return DEFAULT_COVER
  return url.startsWith('http') ? url : API_ORIGIN + (url.startsWith('/') ? url : '/' + url)
}

const formatDate = (d) => d ? new Date(d).toISOString().split('T')[0] : '待定'
const getWeekday = (d) => ['周日','周一','周二','周三','周四','周五','周六'][new Date(d).getDay()] || '待定'

const currentHero = computed(() => heroEvents.value[currentHeroIndex.value] || DEFAULT_HERO)
const heroMood = computed(() => VIBE_LABELS[currentHeroIndex.value % VIBE_LABELS.length])
const totalCapacity = computed(() => events.value.reduce((sum, item) => sum + (Number(item.capacity) || 0), 0))
const participationHeat = computed(() => {
  const seats = totalCapacity.value
  if (!seats) return 0
  const signed = events.value.reduce((sum, item) => sum + (Number(item.signed_up) || 0), 0)
  return Math.min(100, Math.round((signed / seats) * 100))
})
const heroStats = computed(() => [
  { label: '容量前五', value: `${heroEvents.value.length} 场` },
  { label: '活跃指数', value: `${participationHeat.value}%` },
  { label: '招募席位', value: totalCapacity.value ? `${totalCapacity.value}+` : '0' }
])

// 加载容量前五的活动
const loadHeroEvents = async () => {
  try {
    const list = await fetchEventHighlights({ limit: 5 })
    heroEvents.value = list.map(item => ({
      ...item,
      image: buildImageUrl(item.cover_url)
    }))
    currentHeroIndex.value = 0
  } catch (err) {
    console.error('加载精选活动失败:', err)
  }
}

// 加载未来七天的活动
const loadRadarList = async () => {
  try {
    const list = await fetchWeeklyEvents()
    events.value = (list || []).map(item => ({
      ...item,
      date: formatDate(item.start_time),
      weekday: getWeekday(item.start_time),
      statusText: STATUS_TEXT[item.status] || '进行中'
    }))
  } catch (err) {
    console.error('加载活动列表失败:', err)
  }
}

const loadEvents = async () => {
  loading.value = true
  try {
    await Promise.all([loadHeroEvents(), loadRadarList()])
  } catch (err) {
    console.error(err)
  } finally {
    setTimeout(() => { loading.value = false }, 600)
  }
}

const gotoEvent = (id) => id && router.push({ name: 'EventInfo', params: { id } })

onMounted(loadEvents)
</script>

<style scoped>
/* 此处保持您原有的所有 CSS 样式不变 */
:root {
  --glass: rgba(255, 255, 255, 0.75);
  --border: rgba(255, 255, 255, 0.4);
  --accent: #2dd4bf;
  --text-main: #1e293b;
  --text-muted: #64748b;
}

.premium-page {
  height: 100vh;
  background: #f8fafc;
  position: relative;
  overflow: hidden; 
  color: var(--text-main);
  padding: 80px 24px 24px;
  box-sizing: border-box;
}

.dashboard-wrapper {
  max-width: 1400px;
  height: calc(100% - 20px);
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1.8fr 1fr;
  grid-template-rows: minmax(300px, 1fr) 180px;
  gap: 24px;
  position: relative;
  z-index: 1;
}

.bento-item {
  background: var(--glass);
  backdrop-filter: blur(24px);
  border-radius: 32px;
  border: 1px solid var(--border);
  box-shadow: 0 20px 50px rgba(0,0,0,0.04);
}

.hero-main { position: relative; overflow: hidden; }
.hero-content { height: 100%; position: relative; }
.hero-image-overlay { position: absolute; inset: 0; }
.hero-image-overlay img { width: 100%; height: 100%; object-fit: cover; }
.image-scrim {
  position: absolute;
  inset: 0;
  background: linear-gradient(to right, rgba(255,255,255,0.95) 15%, transparent 75%);
}

.hero-info-layer {
  position: relative;
  height: 100%;
  padding: 40px 60px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 55%;
}

.display-title {
  font-size: clamp(2rem, 4vw, 3.2rem);
  font-weight: 800;
  line-height: 1.1;
  margin: 16px 0;
  color: #0f172a;
}

.tag-row { display: flex; gap: 12px; }
.vibe-badge { background: #f1f5f9; padding: 6px 16px; border-radius: 100px; font-size: 13px; font-weight: 600; }
.hot-badge { background: #fee2e2; color: #ef4444; padding: 6px 16px; border-radius: 100px; font-size: 13px; font-weight: 600; }

.hero-footer-meta { display: flex; gap: 20px; color: var(--text-muted); font-size: 14px; }
.hero-footer-meta .icon { margin-right: 4px; font-style: normal; }

.activity-radar { 
  padding: 32px; 
  display: flex; 
  flex-direction: column;
  overflow: hidden; 
}
.section-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; flex-shrink: 0; }
.header-text h3 { font-size: 20px; font-weight: 800; margin: 0; }
.header-text p { font-size: 14px; color: var(--text-muted); margin: 4px 0 0; }

.refresh-trigger {
  width: 42px; height: 42px; display: flex; align-items: center; justify-content: center;
  background: rgba(255, 255, 255, 0.6); border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 14px; color: #64748b; cursor: pointer; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.is-spinning .refresh-svg { animation: rotate-animation 0.8s infinite linear; }
@keyframes rotate-animation { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.scroll-list { flex: 1; overflow-y: auto; margin-top: 10px; padding-right: 8px; }
.state-msg { text-align: center; color: var(--text-muted); padding: 20px; font-size: 14px; }

.event-mini-card {
  display: flex; align-items: center; gap: 16px; padding: 18px; border-radius: 22px; margin-bottom: 14px;
  background: rgba(255,255,255,0.4); cursor: pointer; transition: all 0.25s; border: 1px solid transparent;
}
.event-mini-card:hover { background: white; transform: translateX(6px); border-color: rgba(45, 212, 191, 0.2); }

.date-box { text-align: center; background: white; padding: 10px; border-radius: 14px; min-width: 54px; }
.d-day { display: block; font-size: 20px; font-weight: 800; color: #0f172a; }
.d-month { font-size: 11px; color: #94a3b8; font-weight: 600; }

.event-brief h4 { font-size: 15px; font-weight: 700; margin: 0; color: #334155; }
.event-brief p { font-size: 12px; color: #64748b; margin: 4px 0 0; }
.event-status { margin-left: auto; font-size: 11px; color: #0d9488; font-weight: 700; background: #f0fdfa; padding: 4px 10px; border-radius: 8px; }

.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); padding: 24px; gap: 20px; }
.stat-tile { background: rgba(255,255,255,0.5); border-radius: 24px; display: flex; flex-direction: column; justify-content: center; align-items: center; transition: background 0.3s; }
.stat-tile:hover { background: white; }
.stat-label { font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 4px; }
.stat-val { font-size: 26px; font-weight: 900; color: #0f172a; }

.action-cta .cta-inner { height: 100%; background-size: cover; background-position: center; position: relative; border-radius: 32px; overflow: hidden; }
.cta-content {
  position: absolute; inset: 0; background: rgba(45, 212, 191, 0.88); backdrop-filter: blur(6px);
  display: flex; flex-direction: column; justify-content: center; align-items: center; color: white; text-align: center; padding: 20px;
}
.primary-btn {
  margin-top: 18px; background: white; color: #0d9488; border: none; padding: 14px 36px;
  border-radius: 100px; font-weight: 800; cursor: pointer; transition: all 0.3s;
}

.bg-glow { position: absolute; border-radius: 50%; filter: blur(100px); z-index: 0; pointer-events: none; }
.blob-1 { width: 500px; height: 500px; background: rgba(45, 212, 191, 0.15); top: -100px; right: -100px; }
.blob-2 { width: 600px; height: 600px; background: rgba(99, 102, 241, 0.1); bottom: -200px; left: -100px; }

.custom-scrollbar::-webkit-scrollbar { width: 5px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

@media (max-width: 1024px) {
  .premium-page { overflow-y: auto; height: auto; }
  .dashboard-wrapper { grid-template-columns: 1fr; grid-template-rows: auto; height: auto; }
  .hero-info-layer { max-width: 100%; padding: 40px; }
}
</style>