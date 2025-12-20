<template>
  <div 
    class="login-wrapper" 
    :style="{ backgroundImage: `url(${currentBg})` }"
    :class="isDaytime ? 'theme-day' : 'theme-night'"
  >
    <div class="overlay"></div>
    
    <NavBar />

    <main class="login-main">
      <div class="hero-section">
        <div class="glass-container">
          <div class="welcome-text">
            <span class="badge">Hi~ 2025 元气满满</span>
            <h1>{{ greetingTitle }}</h1>
            <p>在这里，遇见更有趣的校园生活</p>
          </div>
          
          <div class="auth-card">
            <AuthForm />
          </div>
        </div>
      </div>
    </main>

    <footer class="login-footer">
      Campus Spark © 2025 · 开启温暖校园时光
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import NavBar from '@/components/NavBar.vue'
import AuthForm from '@/components/AuthForm.vue'

// 导入本地图片
import dayBg from '@/assets/day-bg.png'
import nightBg from '@/assets/night-bg.png'

const currentBg = ref('')
const hour = new Date().getHours()

// 计算当前是否为白天
const isDaytime = computed(() => hour >= 6 && hour < 18)

// 根据时间判断标题
const greetingTitle = computed(() => {
  if (hour >= 6 && hour < 12) return '早安，开启新的一天'
  if (hour >= 12 && hour < 18) return '午后，发现新精彩'
  return '晚安，探索星光校园'
})

onMounted(() => {
  // 设置初始背景
  currentBg.value = isDaytime.value ? dayBg : nightBg
})
</script>

<style scoped>
.login-wrapper {
  min-height: 100vh;
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  position: relative;
  display: flex;
  flex-direction: column;
  transition: all 1s ease-in-out;
}

/* --- 核心修改：主题色控制 --- */

/* 白天主题：深灰色文字 */
.theme-day {
  color: #1e293b;
}
.theme-day .overlay {
  background: rgba(255, 255, 255, 0.2); /* 浅色遮罩让图片清爽 */
}
.theme-day .welcome-text h1 { color: #1e293b; }
.theme-day .welcome-text p { color: #64748b; }
.theme-day .login-footer { color: #64748b; }

/* 夜晚主题：纯白色文字 */
.theme-night {
  color: #ffffff;
}
.theme-night .overlay {
  background: rgba(0, 0, 0, 0.4); /* 深色遮罩让白色文字更显眼 */
}
.theme-night .welcome-text h1 { 
  color: #ffffff;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3); /* 增加文字阴影提高辨识度 */
}
.theme-night .welcome-text p { color: #cbd5e1; }
.theme-night .login-footer { color: #94a3b8; }

/* ----------------------- */

.overlay {
  position: absolute;
  inset: 0;
  backdrop-filter: blur(2px);
  z-index: 0;
  transition: background 1s ease;
}

.login-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 1;
  padding: 40px 20px;
}

.glass-container {
  display: flex;
  align-items: center;
  gap: 80px;
  max-width: 1100px;
  width: 100%;
}

.welcome-text {
  flex: 1;
}

.badge {
  background: #0db18c;
  color: white;
  padding: 6px 16px;
  border-radius: 100px;
  font-size: 14px;
  font-weight: 600;
  display: inline-block;
}

.welcome-text h1 {
  font-size: 48px;
  font-weight: 800;
  margin: 20px 0 10px;
  letter-spacing: -1px;
  transition: color 0.5s ease;
}

.welcome-text p {
  font-size: 18px;
  transition: color 0.5s ease;
}

.auth-card {
  width: 420px;
  background: rgba(255, 255, 255, 0.75);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 32px;
  padding: 40px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
  /* 确保表单内的文字不受父级白色文字影响，保持深色以便输入 */
  color: #1e293b; 
}

.login-footer {
  position: relative;
  z-index: 1;
  text-align: center;
  padding: 20px;
  font-size: 12px;
  transition: color 0.5s ease;
}

@media (max-width: 1024px) {
  .glass-container { flex-direction: column; gap: 40px; text-align: center; }
  .welcome-text h1 { font-size: 32px; }
}
</style>