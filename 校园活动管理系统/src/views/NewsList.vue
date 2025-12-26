<template>
  <div class="page news-view">
    <div class="deco-blobs">
      <div class="blob blob-1"></div>
      <div class="blob blob-2"></div>
    </div>

    <NavBar />

    <main class="news-container">
      <div class="bento-grid">
        
        <section class="bento-item info-hero glass-panel">
          <div class="mini-badge">🌼 Campus News</div>
          <h1 class="compact-title">清新<span class="gradient-text">资讯画报</span></h1>
          <p class="compact-lead">每天三分钟，速览校园新鲜事。</p>
          <div class="hero-pills">
            <span v-for="p in ['活动', '考试', '政策']" :key="p" class="mini-pill">{{ p }}</span>
          </div>
          <ul class="compact-list">
            <li><span>重大考试提醒</span><i class="dot"></i></li>
            <li><span>留学政策速览</span><i class="dot"></i></li>
          </ul>
        </section>

        <section class="bento-item carousel-box glass-panel" v-if="newsList.length > 0">
          <div class="carousel-wrapper">
            <img :src="currentImage" alt="资讯图片" class="carousel-img" />
            <div class="carousel-overlay">
              <div class="meta-tag">{{ currentNewsDate }}</div>
              <h3>{{ currentNewsTitle }}</h3>
            </div>
            <div class="carousel-nav" v-if="newsList.length > 1">
              <button @click="prevImage" class="nav-btn">‹</button>
              <button @click="nextImage" class="nav-btn">›</button>
            </div>
          </div>
        </section>
        <section class="bento-item carousel-box glass-panel" v-else-if="loading">
          <div class="carousel-wrapper" style="display: flex; align-items: center; justify-content: center;">
            <p style="color: #64748b;">加载中...</p>
          </div>
        </section>

        <section class="bento-item board-box">
          <div class="board-grid" v-if="cards.length > 0">
            <article 
              v-for="(card, idx) in cards" 
              :key="card.id || idx" 
              class="news-card-mini glass-panel"
              :class="{ 'accent-card': idx === 1 }"
            >
              <div class="card-header">
                <span class="card-day">{{ card.day }}</span>
                <span class="card-month">{{ card.month }}</span>
              </div>
              <p class="card-text">{{ card.text }}</p>
              <button class="text-link">详情 →</button>
            </article>
          </div>
          <div v-else-if="loading" style="padding: 40px; text-align: center; color: #64748b;">
            加载中...
          </div>
          <div v-else style="padding: 40px; text-align: center; color: #64748b;">
            暂无资讯
          </div>
        </section>

      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import NavBar from '../components/NavBar.vue'
import { fetchNewsList } from '@/api/news'

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')

const newsList = ref([])
const loading = ref(false)
const currentIndex = ref(0)

// 从数据库获取资讯列表
const loadNews = async () => {
  loading.value = true
  try {
    const data = await fetchNewsList({ page: 1, pageSize: 10 })
    newsList.value = data?.list || []
  } catch (err) {
    console.error('加载资讯失败:', err)
    newsList.value = []
  } finally {
    loading.value = false
  }
}

// 构建图片URL
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

// 当前轮播图（使用第一条资讯的图片，如果没有则使用默认图片）
const currentImage = computed(() => {
  if (newsList.value.length > 0 && newsList.value[currentIndex.value]?.image_url) {
    return buildImageUrl(newsList.value[currentIndex.value].image_url)
  }
  // 如果没有图片，使用默认占位图
  return 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iODAwIiBoZWlnaHQ9IjQwMCIgZmlsbD0iI2Y4ZmFmYyIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMjQiIGZpbGw9IiM5NGExOGIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj7lm77niYfliqDovb3lpLHotKU8L3RleHQ+PC9zdmc+'
})

// 轮播卡片数据（从数据库获取的资讯转换而来）
const cards = computed(() => {
  return newsList.value.slice(0, 3).map(news => {
    const date = new Date(news.created_at)
    const day = String(date.getDate()).padStart(2, '0')
    const month = `${date.getFullYear()}.${String(date.getMonth() + 1).padStart(2, '0')}`
    return {
      day,
      month,
      text: news.title,
      id: news.id
    }
  })
})

// 当前轮播显示的资讯标题
const currentNewsTitle = computed(() => {
  if (newsList.value.length > 0 && newsList.value[currentIndex.value]) {
    return newsList.value[currentIndex.value].title
  }
  return '四、六级笔试将于 12 月 13 日举行'
})

// 当前轮播显示的资讯日期
const currentNewsDate = computed(() => {
  if (newsList.value.length > 0 && newsList.value[currentIndex.value]) {
    const date = new Date(newsList.value[currentIndex.value].created_at)
    return `${date.getFullYear()}.${String(date.getMonth() + 1).padStart(2, '0')}.${String(date.getDate()).padStart(2, '0')}`
  }
  return '2025.10.12'
})

const nextImage = () => {
  if (newsList.value.length === 0) return
  currentIndex.value = (currentIndex.value + 1) % newsList.value.length
}

const prevImage = () => {
  if (newsList.value.length === 0) return
  currentIndex.value = (currentIndex.value - 1 + newsList.value.length) % newsList.value.length
}

onMounted(() => {
  loadNews()
})
</script>

<style scoped>
/* --- 页面基础布局 --- */
.news-view {
  --mint: #0db18c;
  --slate: #1e293b;
  height: 100vh;
  overflow: hidden;
  background: #f8fafc;
  position: relative;
}

/* --- 背景装饰（同步首页） --- */
.deco-blobs { position: fixed; inset: 0; pointer-events: none; z-index: 0; }
.blob { position: absolute; filter: blur(70px); opacity: 0.4; border-radius: 50%; }
.blob-1 { width: 45vw; height: 45vw; background: #d1fae5; top: -10%; right: -5%; }
.blob-2 { width: 35vw; height: 35vw; background: #e0f2fe; bottom: -5%; left: -5%; }

.news-container {
  position: relative;
  z-index: 1;
  padding: 84px 24px 24px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* --- Bento 网格定义 --- */
.bento-grid {
  display: grid;
  width: 100%;
  max-width: 1200px;
  height: 85vh;
  grid-template-columns: 0.8fr 1.2fr;
  grid-template-rows: 1fr 1fr;
  gap: 20px;
  grid-template-areas: 
    "hero carousel"
    "board board";
}

/* --- 通用面板样式 --- */
.glass-panel {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 32px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.03);
  transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);
}

.bento-item { overflow: hidden; }

/* 1. Hero 细节 */
.info-hero {
  grid-area: hero;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.mini-badge { font-size: 12px; font-weight: 700; color: var(--mint); margin-bottom: 16px; letter-spacing: 1px; }
.compact-title { font-size: 38px; line-height: 1.1; margin: 0; font-weight: 900; letter-spacing: -1.5px; }
.gradient-text { background: linear-gradient(135deg, #0db18c, #34d399); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.compact-lead { font-size: 15px; color: #64748b; margin: 16px 0 24px; }
.hero-pills { display: flex; gap: 8px; margin-bottom: 24px; }
.mini-pill { padding: 6px 14px; background: rgba(13, 177, 140, 0.1); color: var(--mint); border-radius: 100px; font-size: 12px; font-weight: 700; }
.compact-list { list-style: none; padding: 0; margin: 0; border-top: 1px solid rgba(0,0,0,0.05); padding-top: 20px; }
.compact-list li { display: flex; align-items: center; justify-content: space-between; font-size: 13px; color: #94a3b8; margin-bottom: 8px; }
.dot { width: 4px; height: 4px; background: var(--mint); border-radius: 50%; }

/* 2. Carousel 细节 */
.carousel-box { grid-area: carousel; position: relative; }
.carousel-wrapper { width: 100%; height: 100%; position: relative; }
.carousel-img { width: 100%; height: 100%; object-fit: cover; }
.carousel-overlay {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  padding: 40px;
  background: linear-gradient(transparent, rgba(0,0,0,0.6));
  color: white;
}
.meta-tag { font-size: 12px; font-weight: 600; opacity: 0.8; margin-bottom: 8px; }
.carousel-overlay h3 { font-size: 22px; margin: 0; font-weight: 600; line-height: 1.4; }
.carousel-nav {
  position: absolute;
  top: 20px; right: 20px;
  display: flex; gap: 8px;
}
.nav-btn {
  width: 40px; height: 40px;
  border-radius: 50%; border: none;
  background: rgba(255,255,255,0.9);
  cursor: pointer; font-size: 20px;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.2s;
}
.nav-btn:hover { background: white; transform: scale(1.1); color: var(--mint); }

/* 3. Board 细节 */
.board-box { grid-area: board; }
.board-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  height: 100%;
}
.news-card-mini {
  padding: 24px;
  display: flex;
  flex-direction: column;
}
.accent-card { background: linear-gradient(135deg, rgba(223, 234, 255, 0.7), rgba(242, 245, 255, 0.7)); }
.card-header { margin-bottom: 12px; }
.card-day { font-size: 28px; font-weight: 900; color: var(--slate); display: block; line-height: 1; }
.card-month { font-size: 12px; color: #94a3b8; font-weight: 700; }
.card-text { font-size: 14px; color: #475569; line-height: 1.6; margin-bottom: 12px; flex-grow: 1; }
.text-link {
  align-self: flex-start;
  background: transparent; border: none;
  color: var(--mint); font-weight: 700;
  font-size: 13px; cursor: pointer;
}

/* --- 响应式微调 --- */
@media (max-width: 1024px) {
  .news-view { height: auto; overflow: visible; }
  .bento-grid {
    grid-template-areas: 
      "hero hero"
      "carousel carousel"
      "board board";
    height: auto;
    grid-template-rows: auto;
  }
  .board-grid { grid-template-columns: 1fr; }
  .news-container { padding-top: 100px; }
}
</style>