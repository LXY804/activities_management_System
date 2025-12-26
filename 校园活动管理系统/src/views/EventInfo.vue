<template>
  <div class="page event-info">
    <NavBar />

    <main class="event-info__content">
      <button class="back" @click="goBack">← 返回活动清单</button>

      <section class="hero">
        <span class="hero-cloud hero-cloud--left" aria-hidden="true"></span>
        <span class="hero-cloud hero-cloud--right" aria-hidden="true"></span>
        <div class="hero-left glass-panel">
          <div class="hero-chip">🌿 活力活动</div>
          <div class="image-container">
            <img 
              v-if="event.image"
              :src="event.image" 
              alt="封面"
              loading="eager"
              fetchpriority="high"
              @load="onImageLoad"
              @error="onImageError"
              :class="{ 'image-loaded': imageLoaded, 'image-error': imageError }"
            />
            <div v-if="!imageLoaded && !imageError" class="image-skeleton">
              <div class="skeleton-shimmer"></div>
            </div>
            <div v-if="imageError" class="image-placeholder">
              <span class="placeholder-icon">🖼️</span>
              <span class="placeholder-text">图片加载失败</span>
            </div>
          </div>
        </div>

        <aside class="hero-right">
          <div class="date-card glass-panel">
            <div class="day">{{ day }}</div>
            <div class="month-year">{{ month }}<br/>{{ year }}</div>
          </div>

          <div class="info-card glass-panel">
            <h1 class="title">{{ event.title }}</h1>
            <p class="meta">{{ formattedDate }} · {{ event.location }}</p>
            <p class="excerpt">{{ event.excerpt }}</p>

            <div class="stats">
              <span>已报名 {{ event.signed_up || 0 }}</span>
              <span v-if="event.capacity"> / {{ event.capacity }} 人</span>
            </div>

            <div class="actions">
              <button class="btn primary" :disabled="isFull" @click="handleRegister">{{ isFull ? '已满员' : '我要报名' }}</button>
            </div>
          </div>

          <div class="small-card glass-panel">
            <p>主办：{{ event.organizer || '学校' }}</p>
          </div>
          <div class="mood-card glass-panel">
            <p>今日氛围：元气满满 ☀️</p>
          </div>
        </aside>
      </section>

      <article class="description" v-html="event.description_html || '<p>暂无详细信息</p>'"></article>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import { fetchEventDetail, registerEvent } from '@/api/event'

const router = useRouter()
const route = useRoute()
const id = route.params.id

// 后端基础地址，用于拼接封面图片等静态资源完整 URL
const API_ORIGIN = (
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api'
).replace(/\/api\/?$/, '')

const DEFAULT_COVER = `${API_ORIGIN}/uploads/3b72bdb5a6ca17d85131e816c9fdd0b1.jpg`

// 构建图片URL
const buildImageUrl = (coverUrl) => {
  if (!coverUrl) return DEFAULT_COVER
  // 如果已经是完整URL，直接返回
  if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
    return coverUrl
  }
  let normalized = coverUrl.replace(/\\/g, '/')
  if (!normalized.startsWith('/')) {
    normalized = '/' + normalized
  }
  // 如果是相对路径，拼接API基础地址
  return API_ORIGIN + normalized
}

const event = ref({})
const loading = ref(false)
const errorMsg = ref('')
const imageLoaded = ref(false)
const imageError = ref(false)

const formattedDate = computed(() => {
  if (!event.value.start_time) return ''
  return new Date(event.value.start_time).toLocaleString()
})

const day = computed(() =>
  event.value.start_time ? new Date(event.value.start_time).getDate() : ''
)
const month = computed(() =>
  event.value.start_time ? (new Date(event.value.start_time).getMonth() + 1) + '月' : ''
)
const year = computed(() =>
  event.value.start_time ? new Date(event.value.start_time).getFullYear() : ''
)

const isFull = computed(
  () => event.value.capacity && event.value.signed_up >= event.value.capacity
)

function goBack() {
  router.back()
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

const loadEventDetail = async () => {
  loading.value = true
  errorMsg.value = ''
  imageLoaded.value = false
  imageError.value = false
  
  try {
    const data = await fetchEventDetail(id)
    const imageUrl = buildImageUrl(data.cover_url)
    
    // 预加载图片
    if (imageUrl) {
      preloadImage(imageUrl)
    }
    
    event.value = {
      id: data.id,
      title: data.title,
      start_time: data.start_time,
      end_time: data.end_time,
      location: data.location,
      image: imageUrl,
      organizer: data.organizer_name || '学校',
      capacity: data.capacity || 0,
      signed_up: data.signed_up || 0,
      excerpt: data.description || '',
      description_html: data.description_html || data.description || ''
    }
  } catch (e) {
    console.error(e)
    errorMsg.value = e?.message || '加载活动详情失败'
  } finally {
    loading.value = false
  }
}

// 预加载图片
const preloadImage = (url) => {
  const img = new Image()
  img.onload = () => {
    imageLoaded.value = true
  }
  img.onerror = () => {
    imageError.value = true
  }
  img.src = url
}

// 图片加载成功
const onImageLoad = () => {
  imageLoaded.value = true
  imageError.value = false
}

// 图片加载失败
const onImageError = (e) => {
  imageError.value = true
  imageLoaded.value = false
  // 尝试使用默认图片
  if (e.target.src !== DEFAULT_COVER) {
    e.target.src = DEFAULT_COVER
    imageError.value = false
  }
}

async function handleRegister() {
  if (isFull.value) return
  if (!requireLogin()) return

  try {
    await registerEvent(id)
    alert('报名成功，等待审核')
    await loadEventDetail()
  } catch (e) {
    console.error(e)
    const msg =
      e?.response?.data?.message ||
      e?.message ||
      '报名失败'
    alert(msg)
  }
}

onMounted(() => {
  loadEventDetail()
})
</script>

<style scoped>
.page.event-info {
  min-height: 100vh;
  background: linear-gradient(180deg, #e9fff7, #f4f7ff 60%, #fff1f9);
  position: relative;
  overflow: hidden;
}

.page.event-info::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg width='160' height='160' viewBox='0 0 160 160' xmlns='http://www.w3.org/2000/svg'%3E%3Ccircle cx='20' cy='20' r='6' fill='%23d8f8ff'/%3E%3Ccircle cx='120' cy='80' r='10' fill='%23ffe1f2'/%3E%3Ccircle cx='60' cy='130' r='8' fill='%23c8ffe0'/%3E%3C/svg%3E");
  opacity: 0.4;
  pointer-events: none;
}

.event-info__content {
  max-width: 1200px;
  margin: 0 auto;
  padding: calc(var(--topbar-height) + 32px) clamp(18px, 4vw, 64px) 100px;
  position: relative;
  z-index: 1;
}

.back {
  background: rgba(255, 255, 255, 0.7);
  border: none;
  color: #1c7f64;
  cursor: pointer;
  margin-bottom: 18px;
  font-weight: 600;
  padding: 8px 16px;
  border-radius: 999px;
  box-shadow: 0 12px 30px rgba(28, 127, 100, 0.15);
}

.hero {
  display: grid;
  grid-template-columns: minmax(280px, 1fr) minmax(280px, 360px);
  gap: clamp(20px, 4vw, 32px);
  align-items: stretch;
  position: relative;
}

.hero-cloud {
  position: absolute;
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.65);
  filter: blur(0px);
}

.hero-cloud--left {
  top: -40px;
  left: -60px;
}

.hero-cloud--right {
  top: 120px;
  right: -70px;
}

.glass-panel {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 28px;
  box-shadow: 0 25px 60px rgba(20, 78, 87, 0.12);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.glass-panel:hover {
  transform: translateY(-4px);
  box-shadow: 0 30px 70px rgba(20, 78, 87, 0.18);
}

.hero-left {
  flex: 1;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.image-container {
  position: relative;
  width: 100%;
  height: 420px;
  border-radius: 24px;
  overflow: hidden;
  background: #f0f0f0;
}

.hero-left img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 24px;
  transition: opacity 0.3s ease;
  opacity: 0;
}

.hero-left img.image-loaded {
  opacity: 1;
}

.hero-left img.image-error {
  display: none;
}

.image-skeleton {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

.image-placeholder {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e0e0e0 0%, #f5f5f5 100%);
  color: #999;
}

.placeholder-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

.placeholder-text {
  font-size: 14px;
  font-weight: 500;
}

.hero-chip {
  align-self: flex-start;
  background: rgba(255, 255, 255, 0.9);
  padding: 6px 18px;
  border-radius: 999px;
  font-weight: 600;
  color: #1d3e5b;
  box-shadow: 0 15px 30px rgba(29, 62, 91, 0.12);
}

.hero-right {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.date-card {
  display: flex;
  align-items: center;
  gap: 16px;
  color: var(--brand-deep);
  padding: 24px;
}

.date-card .day {
  font-size: 56px;
  font-weight: 700;
}

.info-card {
  color: var(--brand-deep);
  padding: 28px;
}

.info-card .title {
  margin: 0 0 8px;
  font-size: 30px;
  font-family: var(--font-display);
}

.meta {
  color: rgba(15, 29, 51, 0.6);
  margin-bottom: 10px;
}

.excerpt {
  margin-bottom: 14px;
  color: rgba(15, 29, 51, 0.7);
}

.stats {
  display: inline-flex;
  gap: 6px;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(182, 255, 130, 0.35);
  font-weight: 600;
}

.actions {
  margin-top: 16px;
}

.btn {
  border: none;
  border-radius: 999px;
  padding: 12px 24px;
  font-weight: 600;
  cursor: pointer;
}

.btn.primary {
  background: linear-gradient(120deg, var(--brand-lime), var(--brand-emerald));
  color: var(--brand-deep);
  box-shadow: 0 18px 30px rgba(102, 231, 177, 0.35);
  transition: transform 0.2s ease;
}

.btn.primary:hover:not(:disabled) {
  transform: translateY(-2px);
}

.btn.primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.small-card,
.mood-card {
  font-weight: 600;
  padding: 18px 24px;
}

.mood-card {
  background: rgba(255, 248, 219, 0.9);
  color: #c47a00;
}

.description {
  margin-top: 32px;
  padding: clamp(28px, 4vw, 40px);
  border-radius: 32px;
  background: linear-gradient(120deg, rgba(255, 255, 255, 0.92), rgba(222, 245, 255, 0.9)),
    url('https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=1200&q=60');
  background-size: cover;
  background-position: center;
  box-shadow: 0 30px 60px rgba(16, 45, 61, 0.1);
}

@media (max-width: 900px) {
  .hero-left img {
    height: 260px;
  }

  .hero {
    grid-template-columns: 1fr;
  }
}
</style>
