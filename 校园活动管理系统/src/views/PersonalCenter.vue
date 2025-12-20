<template>
  <div class="personal-center fresh-theme">
    <div class="background-container">
      <div class="glow-sphere sphere-1"></div>
      <div class="glow-sphere sphere-2"></div>
      <div class="glow-sphere sphere-3"></div>
    </div>

    <main class="page-container">
      <NavBar />

      <div class="dashboard-core">
        <section class="identity-card glass-morph">
          <div class="profile-main">
            <div class="avatar-hex-wrapper">
              <div class="avatar-hex">
                <img v-if="avatarUrl" :src="avatarUrl" alt="Avatar" />
                <span v-else>{{ username.slice(0, 1) }}</span>
              </div>
              <div class="online-tag">Verified</div>
            </div>
            
            <div class="user-meta">
              <p class="role-tag">🌿 校园共创者</p>
              <h1>{{ username }}</h1>
              <div class="meta-badges">
                <span>📍 校园中心</span>
                <span class="dot">·</span>
                <span>📅 2025 元气满满</span>
              </div>
            </div>
          </div>

          <div class="quick-stats-row">
            <div class="stat-pill">
              <span class="v green-text">{{ stats.participationCount }}</span>
              <span class="l">参与活动</span>
            </div>
            <div class="stat-pill">
              <span class="v green-text">{{ stats.commentedCount }}</span>
              <span class="l">发表评价</span>
            </div>
            <div class="stat-pill">
              <span class="v green-text">{{ stats.toEvaluateCount }}</span>
              <span class="l">待评价</span>
            </div>
          </div>
        </section>

        <nav class="central-nav glass-morph">
          <router-link 
            v-for="nav in navItems" 
            :key="nav.path"
            :to="nav.path"
            class="nav-link"
            :class="{ active: $route.path === nav.path }"
          >
            <component :is="nav.icon" class="nav-icon" />
            <span>{{ nav.name }}</span>
          </router-link>
        </nav>

        <div class="content-hub">
          <router-view v-slot="{ Component }">
            <transition name="page-fade" mode="out-in">
              <component :is="Component" class="view-inner glass-morph-light" />
            </transition>
          </router-view>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import { fetchProfile, fetchPersonalStats } from '@/api/user'

// 图标组件 (SVG保持不变)
const IconUser = { template: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>` }
const IconAct = { template: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>` }
const IconMsg = { template: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>` }
const IconStat = { template: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>` }

const router = useRouter()
const username = ref('用户名')
const avatarUrl = ref('')
const stats = ref({
  participationCount: 0,
  commentedCount: 0,
  toEvaluateCount: 0
})
const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')

const navItems = [
  { name: '个人信息', path: '/personal/info', icon: markRaw(IconUser) },
  { name: '我的活动', path: '/personal/activities', icon: markRaw(IconAct) },
  { name: '我的评论', path: '/personal/comments', icon: markRaw(IconMsg) },
  { name: '数据统计', path: '/personal/statistics', icon: markRaw(IconStat) }
]

const loadPersonalStats = async () => {
  try {
    const data = await fetchPersonalStats()
    stats.value = {
      participationCount: data?.participationCount || 0,
      commentedCount: data?.commentedCount || 0,
      toEvaluateCount: data?.toEvaluateCount || 0
    }
  } catch (err) {
    console.error('获取个人统计失败:', err)
  }
}

onMounted(async () => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) { router.push('/login'); return }
  
  username.value = localStorage.getItem('username') || '用户名'
  try {
    const profile = await fetchProfile()
    if (profile) {
      username.value = profile.real_name || profile.username
      if (profile.image) avatarUrl.value = API_ORIGIN + profile.image
    }
  } catch (e) {
    console.error('获取个人信息失败:', e)
  }
  await loadPersonalStats()

  if (router.currentRoute.value.path === '/personal') router.replace('/personal/activities')
})
</script>

<style scoped>
/* --- 定义清新主题色板 --- */
:root {
  --fresh-primary: #0db18c;
  --fresh-secondary: #34d399;
  --fresh-accent: #ecfdf5;
  --text-main: #1e293b;
  --text-muted: #64748b;
}

.fresh-theme {
  min-height: 100vh;
  background: #f8fafc; 
  background-image: linear-gradient(to bottom, #f0fdfa, #f8fafc);
  font-family: 'Inter', -apple-system, sans-serif;
  color: #1e293b;
  position: relative;
  overflow-x: hidden;
}

.background-container { position: fixed; inset: 0; z-index: 0; overflow: hidden; pointer-events: none; }
.glow-sphere { position: absolute; filter: blur(120px); opacity: 0.45; border-radius: 50%; mix-blend-mode: multiply; }
.sphere-1 { width: 45vw; height: 45vw; background: #d1fae5; top: -15vw; right: -10vw; }
.sphere-2 { width: 40vw; height: 40vw; background: #cffafe; bottom: -10vw; left: -10vw; }
.sphere-3 { width: 30vw; height: 30vw; background: #e0f2fe; top: 25vh; left: 20vw; opacity: 0.3; }

.page-container { position: relative; z-index: 1; padding: 84px 24px 60px; display: flex; justify-content: center; }
.dashboard-core { width: 100%; max-width: 1000px; display: flex; flex-direction: column; gap: 24px; }

/* 通用毛玻璃 */
.glass-morph {
  background: rgba(255, 255, 255, 0.75);
  backdrop-filter: blur(24px) saturate(180%);
  -webkit-backdrop-filter: blur(24px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4px 6px -1px rgba(13, 177, 140, 0.05), 0 10px 15px -3px rgba(0, 0, 0, 0.02);
  border-radius: 28px;
}

.glass-morph-light {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.4);
}

/* 身份卡片 */
.identity-card { padding: 40px; display: flex; justify-content: space-between; align-items: center; }
.profile-main { display: flex; align-items: center; gap: 28px; }
.avatar-hex {
  width: 100px; height: 100px; background: #f0fdfa; border-radius: 24px;
  overflow: hidden; box-shadow: 0 10px 25px rgba(13, 177, 140, 0.1);
  display: flex; align-items: center; justify-content: center;
  font-size: 32px; font-weight: 700; color: #0db18c;
}
.avatar-hex img { width: 100%; height: 100%; object-fit: cover; }
.online-tag {
  position: absolute; bottom: -10px; left: 50%; transform: translateX(-50%);
  background: #0db18c; color: white; font-size: 10px; font-weight: 800;
  padding: 3px 12px; border-radius: 100px; border: 3px solid white;
}

.user-meta h1 { font-size: 32px; margin: 6px 0; font-weight: 800; letter-spacing: -0.5px; }
.role-tag { font-size: 13px; font-weight: 700; color: #0db18c; text-transform: uppercase; letter-spacing: 1px; display: flex; align-items: center; gap: 6px;}
.meta-badges { font-size: 14px; color: #64748b; display: flex; gap: 8px; }

.quick-stats-row { display: flex; gap: 16px; }
.stat-pill {
  background: rgba(255, 255, 255, 0.8); padding: 14px 24px; border-radius: 22px;
  display: flex; flex-direction: column; align-items: center; min-width: 100px;
  border: 1px solid rgba(236, 253, 245, 0.8);
}
.stat-pill .v { font-size: 22px; font-weight: 800; }
.green-text { color: #0db18c; }
.stat-pill .l { font-size: 11px; color: #64748b; font-weight: 600; margin-top: 4px; }

/* 中央导航条 */
.central-nav { display: flex; padding: 8px; gap: 6px; background: rgba(255, 255, 255, 0.6); }
.nav-link {
  flex: 1; display: flex; align-items: center; justify-content: center; gap: 10px;
  padding: 14px; border-radius: 20px; text-decoration: none; color: #64748b;
  font-weight: 600; font-size: 15px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.nav-icon { width: 18px; height: 18px; }
.nav-link:hover { color: #1e293b; background: rgba(236, 253, 245, 0.6); }
.nav-link.active { background: white; color: #0db18c; box-shadow: 0 4px 12px rgba(13, 177, 140, 0.15); }

/* 内容区域 */
.content-hub { min-height: 500px; }
.view-inner { padding: 40px; width: 100%; border-radius: 32px; }

/* -------------------------------------------------------------------------- */
/* 新增：统计块色调修改及呼吸流光效果 */
/* -------------------------------------------------------------------------- */

/* 定义呼吸流光动画 */
@keyframes breathing-glow {
  0% {
    box-shadow: 0 0 5px rgba(13, 177, 140, 0.2), 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: rgba(13, 177, 140, 0.2);
  }
  50% {
    box-shadow: 0 0 20px rgba(52, 211, 153, 0.5), 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: rgba(52, 211, 153, 0.8);
  }
  100% {
    box-shadow: 0 0 5px rgba(13, 177, 140, 0.2), 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: rgba(13, 177, 140, 0.2);
  }
}

/* 强制修改统计块的背景色调与动画 */
:deep(.view-inner .grid > div), 
:deep(.view-inner [class*="card"]) {
  /* 修改紫色渐变为清新绿渐变 */
  background: linear-gradient(135deg, rgba(209, 250, 229, 0.8), rgba(236, 253, 245, 0.6)) !important;
  color: #1e293b !important; /* 字体改回深色以适应浅绿背景 */
  border: 2px solid rgba(13, 177, 140, 0.2) !important;
  transition: transform 0.3s ease;
  animation: breathing-glow 3s infinite ease-in-out; /* 应用呼吸动效 */
}

/* 修改统计块内的数字颜色 */
:deep(.view-inner .text-4xl),
:deep(.view-inner h3),
:deep(.view-inner .num) {
  color: #0db18c !important;
  font-weight: 800 !important;
}

/* 修改统计块内的文字标签颜色 */
:deep(.view-inner p),
:deep(.view-inner .label) {
  color: #64748b !important;
}

/* 悬停时稍微放大 */
:deep(.view-inner .grid > div:hover),
:deep(.view-inner [class*="card"]:hover) {
  transform: translateY(-5px);
}

/* -------------------------------------------------------------------------- */

/* 动画效果 */
.page-fade-enter-active, .page-fade-leave-active { transition: all 0.3s ease; }
.page-fade-enter-from { opacity: 0; transform: translateY(12px); scale: 0.98; }
.page-fade-leave-to { opacity: 0; transform: translateY(-12px); scale: 0.98; }

@media (max-width: 768px) {
  .identity-card { flex-direction: column; text-align: center; gap: 24px; padding: 32px 24px; }
  .profile-main { flex-direction: column; }
  .quick-stats-row { width: 100%; justify-content: center; }
  .central-nav { flex-wrap: wrap; }
  .nav-link { flex: none; width: calc(50% - 4px); font-size: 13px; }
}
</style>