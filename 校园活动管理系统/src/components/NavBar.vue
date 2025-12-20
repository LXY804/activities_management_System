<template>
  <div class="nav-shell" :class="isNight ? 'night-theme' : 'day-theme'">
    <aside class="side-nav">
      <div class="side-nav__brand">
        <div class="side-nav__brand-icon" aria-hidden="true">
          <span></span>
          <span></span>
        </div>
        <div class="side-nav__brand-info">
          <p class="side-nav__brand-title">校园活动管理系统</p>
          <small class="side-nav__brand-tag">Activity Suite</small>
        </div>
      </div>

      <div class="side-nav__scroller" ref="sideNavScroller">
        <template v-for="group in navGroups" :key="group.title">
          <p class="side-nav__title">{{ group.title }}</p>
          <div class="side-nav__items">
            <button
              v-for="item in group.items"
              :key="item.label"
              type="button"
              class="side-nav__link"
              :class="{
                active: isItemActive(item),
                'is-disabled': isItemDisabled(item)
              }"
              @click="handleNav(item)"
            >
              <span class="side-nav__icon">{{ item.icon }}</span>
              <div class="side-nav__text-group">
                <p class="side-nav__label">{{ item.label }}</p>
                <small v-if="item.badge" class="side-nav__badge">{{ item.badge }}</small>
              </div>
            </button>
          </div>
        </template>
      </div>
    </aside>

    <header class="topbar">
      <div class="topbar__inner">
        <div class="topbar__title" @click="router.push('/')">
          <p class="title-main">活动导航空间</p>
        </div>

        <form class="search" @submit.prevent="handleSearch">
          <div class="search-inner">
            <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input
              v-model.trim="searchTerm"
              type="search"
              placeholder="搜索感兴趣的活动..."
              aria-label="站内搜索"
            />
          </div>
        </form>

        <div class="actions">
          <button
            v-if="!isLoggedIn"
            class="pill-action"
            type="button"
            @click="goLogin"
          >
            登录/注册
          </button>
          
          <button
            v-else
            class="pill-action outline"
            type="button"
            @click="goPersonalCenter"
          >
            个人中心
          </button>

          <button v-if="isLoggedIn" class="icon-btn-exit" @click="handleLogout" title="退出登录">
             <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4m7 14 5-5-5-5m5 5H9"/>
             </svg>
          </button>
        </div>
      </div>
    </header>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
let savedSideNavScrollTop = 0

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')

// 时间判断：18:00 - 06:00 为夜晚
const isNight = computed(() => {
  const hour = new Date().getHours()
  return hour >= 18 || hour < 6
})

const searchTerm = ref('')
const isLoggedIn = ref(false)
const userRole = ref('')

const navGroups = computed(() => [
  {
    title: '首页入口',
    items: [{ label: '首页', icon: '🏡', to: '/' }]
  },
  {
    title: '系统功能',
    items: [
      { label: '活动宣传', icon: '🎉', to: '/promotion' },
      { label: '论坛交流', icon: '💬', to: '/forum'},
      { label: '积分礼品', icon: '🎁', to: '/rewards' },
      { label: '活动信息', icon: '🗂️', to: '/events' },
      { label: '校园资讯', icon: '📰', to: '/news' }
    ]
  },
  {
    title: '管理专区',
    items: [
      { label: '个人中心', icon: '💫', to: '/personal/activities', requiresLogin: true },
      // 已加回：组织者工作台，仅限 organizer 角色访问
      { label: '组织者工作台', icon: '🧭', to: '/organizer/manage', roles: ['organizer'] },
      { label: '管理后台', icon: '🏛️', to: '/admin/dashboard', roles: ['admin'] }
    ]
  }
])

const checkLoginStatus = () => {
  const token = localStorage.getItem('token')
  isLoggedIn.value = !!token
  userRole.value = localStorage.getItem('userRole') || ''
}

const isItemDisabled = (item) => {
  if (item.disabled) return true
  // 核心权限：如果该项有 roles 限制，且当前用户角色不匹配，则禁用（包括管理者访问组织者后台）
  if (item.roles && !item.roles.includes(userRole.value)) return true
  return false
}

const isItemActive = (item) => item.to && (route.path === item.to || route.path.startsWith(`${item.to}/`))

const handleNav = (item) => {
  if (isItemDisabled(item)) return window.alert(`您无权访问或功能暂未开放`)
  if (item.requiresLogin && !isLoggedIn.value) return router.push('/login')
  if (item.to) router.push(item.to)
}

const handleSearch = () => {
  if (!searchTerm.value) return
  router.push({ path: '/events', query: { keyword: searchTerm.value } })
}

const goPersonalCenter = () => router.push('/personal/activities')
const goLogin = () => router.push('/login')

const handleLogout = () => {
  localStorage.clear()
  isLoggedIn.value = false
  router.push('/login')
}

onMounted(() => {
  checkLoginStatus()
  window.addEventListener('storage', checkLoginStatus)
  document.body.classList.add('has-side-nav-layout')
})

onUnmounted(() => {
  window.removeEventListener('storage', checkLoginStatus)
  document.body.classList.remove('has-side-nav-layout')
})

watch(() => route.path, checkLoginStatus)
</script>

<style scoped>
/* --- 主题配色定义 --- */
.day-theme {
  --nav-bg: #ffffff;
  --topbar-bg: rgba(255, 255, 255, 0.85);
  --text-main: #1e293b;
  --text-muted: #64748b;
  --text-title: #94a3b8;
  --brand-color: #0db18c; /* 森林绿 */
  --shimmer-bg: linear-gradient(90deg, rgba(13, 177, 140, 0.05) 0%, rgba(13, 177, 140, 0.15) 50%, rgba(13, 177, 140, 0.05) 100%);
  --search-bg: #f1f5f9;
  --border-color: rgba(15, 42, 66, 0.05);
}

.night-theme {
  --nav-bg: #1e293b;
  --topbar-bg: rgba(30, 41, 59, 0.9);
  --text-main: #f1f5f9;
  --text-muted: #94a3b8;
  --text-title: #64748b;
  --brand-color: #2dd4bf; /* 蓝绿色荧光调 */
  --shimmer-bg: linear-gradient(90deg, rgba(45, 212, 191, 0.08) 0%, rgba(45, 212, 191, 0.22) 50%, rgba(45, 212, 191, 0.08) 100%);
  --search-bg: #0f172a;
  --border-color: rgba(255, 255, 255, 0.08);
}

:global(:root) {
  --sidebar-width: 210px;
  --topbar-height: 64px;
  --z-index-topbar: 1000;
  --z-index-sidebar: 1001;
}

:global(body.has-side-nav-layout) {
  padding-left: var(--sidebar-width);
  padding-top: var(--topbar-height); 
}

@keyframes shimmer-flow {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.nav-shell { position: relative; }

/* --- 侧边栏 --- */
.side-nav {
  position: fixed;
  top: 0; left: 0;
  width: var(--sidebar-width);
  height: 100vh;
  background: var(--nav-bg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  z-index: var(--z-index-sidebar);
  transition: all 0.4s ease;
}

.side-nav__brand { padding: 0 20px; display: flex; align-items: center; gap: 12px; height: var(--topbar-height); }
.side-nav__brand-icon { width: 32px; height: 32px; border-radius: 8px; background: linear-gradient(135deg, #ccf8e1, #e9f4ff); }
.side-nav__brand-title { margin: 0; font-size: 15px; font-weight: 800; color: var(--text-main); }
.side-nav__brand-tag { font-size: 10px; color: var(--text-muted); }

.side-nav__scroller { flex: 1; overflow-y: auto; padding: 10px 12px; }
.side-nav__title { margin: 20px 0 8px 12px; font-size: 11px; font-weight: 700; color: var(--text-title); text-transform: uppercase; letter-spacing: 1px; }

.side-nav__link {
  position: relative;
  display: flex; align-items: center; gap: 10px;
  padding: 12px 14px;
  border: none; background: transparent;
  border-radius: 12px;
  cursor: pointer; color: var(--text-muted);
  transition: all 0.3s ease;
  width: 100%;
  overflow: hidden;
}

.side-nav__link:hover:not(.is-disabled) { background: var(--search-bg); color: var(--text-main); }

.side-nav__link.active {
  color: var(--brand-color);
  font-weight: 700;
  background: var(--shimmer-bg);
  background-size: 200% 100%;
  animation: shimmer-flow 3s infinite linear;
}

.side-nav__link.active::before {
  content: '';
  position: absolute;
  left: 0; top: 25%;
  width: 4px; height: 50%;
  background: var(--brand-color);
  border-radius: 0 4px 4px 0;
  box-shadow: 0 0 12px var(--brand-color);
}

.side-nav__icon { font-size: 16px; width: 22px; }
.side-nav__label { margin: 0; font-size: 14px; flex: 1; text-align: left; }
.side-nav__badge { font-size: 10px; background: var(--search-bg); padding: 2px 6px; border-radius: 6px; color: var(--text-muted); }

.side-nav__link.is-disabled { opacity: 0.35; cursor: not-allowed; }

/* --- 顶栏 --- */
.topbar {
  position: fixed; 
  top: 0; left: var(--sidebar-width); right: 0; 
  height: var(--topbar-height);
  z-index: var(--z-index-topbar);
  background: var(--topbar-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border-color);
  padding: 0 32px;
  transition: all 0.4s ease;
}

.topbar__inner { display: flex; align-items: center; justify-content: space-between; height: 100%; gap: 40px; }
.title-main { font-weight: 700; font-size: 14px; color: var(--text-title); cursor: pointer; transition: color 0.3s; }
.title-main:hover { color: var(--text-main); }

/* 搜索框 */
.search { flex: 1; max-width: 480px; }
.search-inner {
  display: flex; align-items: center;
  background: var(--search-bg);
  padding: 0 16px; height: 40px;
  border-radius: 12px;
  border: 1.5px solid transparent;
  transition: 0.3s;
}
.search-inner input { flex: 1; border: none; background: transparent; font-size: 14px; outline: none; color: var(--text-main); }
.search:focus-within .search-inner { background: var(--nav-bg); border-color: var(--brand-color); box-shadow: 0 8px 24px -8px rgba(0,0,0,0.3); }
.search-icon { width: 18px; height: 18px; color: var(--text-muted); margin-right: 12px; }

/* 动作区域按钮 */
.actions { display: flex; align-items: center; gap: 12px; }

.pill-action {
  background: var(--brand-color);
  color: #fff;
  border: none;
  padding: 8px 20px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: 0.3s;
}
.night-theme .pill-action { color: #ffffff; }

.pill-action.outline {
  background: transparent;
  border: 2px solid var(--brand-color);
  color: var(--brand-color);
}

.icon-btn-exit {
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  transition: 0.2s;
}
.icon-btn-exit:hover { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

.fade-enter-active, .fade-leave-active { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }
</style>