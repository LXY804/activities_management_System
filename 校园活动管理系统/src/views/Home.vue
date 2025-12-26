<template>
  <div class="page home-view">
    <div class="deco-blobs">
      <div class="blob blob-1"></div>
      <div class="blob blob-2"></div>
      <div class="blob blob-3"></div>
    </div>

    <NavBar />

    <main class="home-container">
      <div class="bento-grid">
        
        <section class="bento-item hero-box glass-panel">
          <div class="hero-content">
            <div class="mini-badge">✨ Campus Spark v2.0</div>
            <h1 class="compact-title">
              轻盈活泼的<br /><span class="gradient-text">活动宇宙</span>
            </h1>
            <p class="compact-lead">发现伙伴、收集能量，让每一天都闪耀绿光。</p>
            <div class="hero-actions">
              <button class="primary-btn">立即加入</button>
              <div class="user-stack">
                <span class="avatar-dot"></span>
                <span class="stack-text">1.2w+ 伙伴已上线</span>
              </div>
            </div>
          </div>
        </section>

        <section class="bento-item stats-box glass-panel">
          <div v-for="stat in stats" :key="stat.label" class="stat-mini">
            <span class="stat-v">{{ stat.value }}</span>
            <span class="stat-l">{{ stat.label }}</span>
          </div>
        </section>

        <section class="bento-item focus-box glass-panel">
          <div class="box-header">
            <span class="eyebrow">本周焦点</span>
            <span class="status-dot-live">LIVE</span>
          </div>
          <h2 class="focus-title">校园艺术节 · <span class="mint">绿意巡礼</span></h2>
          <ul class="compact-list">
            <li><span>乐队舞台</span> <time>18:30</time></li>
            <li><span>手作交换</span> <time>全天</time></li>
          </ul>
          <div class="progress-container">
            <div class="progress-label">预约进度 85%</div>
            <div class="progress-bar"><div class="fill" style="width: 85%"></div></div>
          </div>
        </section>

        <section v-for="(card, index) in heroCards" 
          :key="card.label" 
          class="bento-item insight-box glass-panel"
          :class="'insight-' + index">
          <span class="box-icon">{{ card.icon }}</span>
          <h3 class="box-label">{{ card.label }}</h3>
          <p class="box-value">{{ card.value }}</p>
          <small class="box-desc">{{ card.desc }}</small>
        </section>

        <section class="bento-item nav-pills-box glass-panel">
          <span v-for="pill in ['跨学院联动', '兴趣小组', '志愿项目', '艺术快闪']" 
            :key="pill" class="mini-pill">{{ pill }}</span>
        </section>

      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import NavBar from '../components/NavBar.vue'
import { fetchEvents } from '@/api/event'
import { fetchUserStats } from '@/api/user'

const heroCards = ref([
  { label: '正在进行', value: '0 场', desc: '今日新增 0', icon: '🎨' },
  { label: '结识伙伴', value: '0', desc: '活跃 0', icon: '👋' }
])

const stats = ref([
  { value: '0+', label: '资源' },
  { value: '0+', label: '活动' },
  { value: '0+', label: '人数' }
])

const loadHomeData = async () => {
  try {
    // 获取活动数据
    const eventsData = await fetchEvents({})
    const events = eventsData?.list || []
    
    // 计算进行中的活动（当前时间在开始和结束时间之间）
    const now = new Date()
    const ongoingEvents = events.filter(ev => {
      if (!ev.start_time || !ev.end_time) return false
      try {
        const start = new Date(ev.start_time)
        const end = new Date(ev.end_time)
        return now >= start && now <= end
      } catch (e) {
        return false
      }
    })
    
    // 计算今日新增（今天创建的活动，使用 created_at 字段）
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    today.setMinutes(0, 0, 0)
    today.setSeconds(0, 0)
    today.setMilliseconds(0)
    
    const todayEvents = events.filter(ev => {
      if (!ev.created_at) return false
      try {
        const created = new Date(ev.created_at)
        return created >= today
      } catch (e) {
        return false
      }
    })
    
    heroCards.value[0].value = `${ongoingEvents.length} 场`
    heroCards.value[0].desc = `今日新增 ${todayEvents.length}`
    
    // 获取用户统计数据
    try {
      const userStats = await fetchUserStats()
      if (userStats) {
        const totalUsers = userStats.total || 0
        const activeUsers = userStats.active || 0 // 活跃用户数（最近30天有活动的用户）
        
        stats.value[0].value = `${totalUsers}+`
        stats.value[1].value = `${events.length}+`
        heroCards.value[1].value = totalUsers.toLocaleString()
        heroCards.value[1].desc = `活跃 ${activeUsers}`
      } else {
        stats.value[0].value = `${0}+`
        stats.value[1].value = `${events.length}+`
        heroCards.value[1].value = '0'
        heroCards.value[1].desc = '活跃 0'
      }
    } catch (err) {
      // 如果未登录或API失败，使用默认值
      console.warn('获取用户统计失败:', err)
      stats.value[0].value = `${0}+`
      stats.value[1].value = `${events.length}+`
      heroCards.value[1].value = '0'
      heroCards.value[1].desc = '活跃 0'
    }
  } catch (err) {
    console.error('加载首页数据失败:', err)
  }
}

onMounted(() => {
  loadHomeData()
})
</script>

<style scoped>
/* --- 布局变量 --- */
.page {
  --mint: #0db18c;
  --bg-soft: #f8fafc;
  height: 100vh;
  overflow: hidden; /* 强制锁定一屏 */
  background: var(--bg-soft);
  font-family: 'Inter', -apple-system, sans-serif;
}

/* --- 背景装饰 --- */
.deco-blobs { position: fixed; inset: 0; pointer-events: none; z-index: 0; }
.blob { position: absolute; filter: blur(60px); opacity: 0.4; border-radius: 50%; }
.blob-1 { width: 40vw; height: 40vw; background: #d1fae5; top: -10%; left: -5%; }
.blob-2 { width: 30vw; height: 30vw; background: #e0f2fe; bottom: 0; right: 0; }

/* --- Bento Grid 主容器 --- */
.home-container {
  position: relative;
  z-index: 1;
  padding: 80px 24px 24px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.bento-grid {
  display: grid;
  width: 100%;
  max-width: 1200px;
  height: 80vh; /* 限制高度在视口内 */
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(4, 1fr);
  gap: 16px;
  grid-template-areas: 
    "hero hero focus focus"
    "hero hero focus focus"
    "stats stats insight-0 insight-1"
    "pills pills insight-0 insight-1";
}

/* --- 通用卡片样式 --- */
.bento-item {
  padding: 24px;
  display: flex;
  flex-direction: column;
}

.glass-panel {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 28px;
  box-shadow: 0 10px 30px rgba(15, 42, 66, 0.04);
  transition: all 0.4s cubic-bezier(0.23, 1, 0.32, 1);
}

.glass-panel:hover {
  transform: scale(1.01);
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 15px 40px rgba(13, 177, 140, 0.1);
}

/* --- 各区域具体样式 --- */
.hero-box { grid-area: hero; justify-content: center; background: linear-gradient(135deg, rgba(255,255,255,0.9), rgba(209, 250, 229, 0.4)); }
.stats-box { grid-area: stats; flex-direction: row; align-items: center; justify-content: space-around; }
.focus-box { grid-area: focus; background: #1e293b; color: white; }
.insight-0 { grid-area: insight-0; }
.insight-1 { grid-area: insight-1; }
.nav-pills-box { grid-area: pills; flex-direction: row; align-items: center; gap: 10px; overflow: hidden; }

/* 1. Hero 细节 */
.mini-badge { font-size: 12px; font-weight: 700; color: var(--mint); margin-bottom: 12px; }
.compact-title { font-size: 42px; line-height: 1.1; font-weight: 900; margin: 0; letter-spacing: -1.5px; }
.compact-lead { font-size: 16px; color: #64748b; margin: 12px 0 20px; }
.gradient-text { background: linear-gradient(135deg, #0db18c, #34d399); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.primary-btn { padding: 12px 28px; background: #1e293b; color: white; border: none; border-radius: 14px; font-weight: 700; cursor: pointer; }

/* 2. Stats 细节 */
.stat-mini { text-align: center; }
.stat-v { display: block; font-size: 24px; font-weight: 800; color: var(--mint); }
.stat-l { font-size: 12px; font-weight: 600; color: #94a3b8; }

/* 3. Focus 细节 */
.focus-title { font-size: 28px; margin: 12px 0; font-weight: 800; }
.status-dot-live { background: #ff4757; padding: 2px 8px; border-radius: 6px; font-size: 10px; font-weight: 900; animation: blink 1.5s infinite; }
.compact-list { list-style: none; padding: 0; margin: 16px 0; flex-grow: 1; }
.compact-list li { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.1); font-size: 14px; }
.progress-bar { height: 6px; background: rgba(255,255,255,0.1); border-radius: 10px; overflow: hidden; margin-top: 8px; }
.progress-bar .fill { height: 100%; background: var(--mint); }

/* 4. Insights 细节 */
.box-icon { font-size: 28px; margin-bottom: 8px; }
.box-label { font-size: 14px; color: #64748b; margin: 0; }
.box-value { font-size: 28px; font-weight: 800; margin: 4px 0; }
.box-desc { color: #94a3b8; font-size: 12px; }

/* 5. Pills 细节 */
.mini-pill { padding: 6px 14px; background: white; border: 1px solid #e2e8f0; border-radius: 100px; font-size: 12px; font-weight: 600; color: #64748b; white-space: nowrap; }

@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }

/* --- 响应式处理 --- */
@media (max-width: 1024px) {
  .page { height: auto; overflow: visible; }
  .bento-grid {
    grid-template-areas: 
      "hero hero hero hero"
      "focus focus focus focus"
      "stats stats insight-0 insight-1"
      "pills pills pills pills";
    height: auto;
  }
}
</style>