<template>
  <div class="auth-container">
    <div class="tab-switcher">
      <button 
        class="tab-item" 
        :class="{ active: isLogin }" 
        @click="isLogin = true"
      >登录</button>
      <button 
        class="tab-item" 
        :class="{ active: !isLogin }" 
        @click="isLogin = false"
      >注册</button>
      <div class="active-bg" :style="{ transform: isLogin ? 'translateX(0)' : 'translateX(100%)' }"></div>
    </div>

    <div class="form-scroll-area">
      <transition name="page-fade" mode="out-in">
        <form :key="isLogin ? 'login' : 'reg'" @submit.prevent="isLogin ? handleLogin() : handleRegister()">
          
          <div class="input-group">
            <div class="field">
              <span class="icon-wrap">👤</span>
              <input v-model="currentForm.username" type="text" placeholder="用户名" required />
            </div>

            <div v-if="!isLogin" class="field">
              <span class="icon-wrap">📞</span>
              <input v-model="registerForm.phone" type="tel" placeholder="手机号码" required />
            </div>

            <div class="field">
              <span class="icon-wrap">🔒</span>
              <input v-model="currentForm.password" type="password" placeholder="密码" required />
            </div>

            <div v-if="!isLogin" class="field">
              <span class="icon-wrap">🛡️</span>
              <input v-model="registerForm.confirmPassword" type="password" placeholder="确认密码" required />
            </div>
          </div>

          <div class="role-selector">
            <p class="label">选择身份空间</p>
            <div class="role-chips">
              <label v-for="r in ['student', 'organizer', 'admin']" :key="r" class="chip">
                <input type="radio" :value="r" v-model="currentForm.role" />
                <span class="chip-text">
                  {{ r === 'student' ? '学生' : r === 'organizer' ? '组织者' : '管理员' }}
                </span>
              </label>
            </div>
          </div>

          <button type="submit" class="submit-btn" :disabled="loading">
            <span v-if="loading" class="loading-spinner"></span>
            {{ loading ? '同步中...' : (isLogin ? '开启元气之旅' : '加入宇宙') }}
          </button>
        </form>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { login, register } from '@/api/auth'

const router = useRouter()
const isLogin = ref(true)
const loading = ref(false)

const loginForm = ref({ username: '', password: '', role: 'student' })
const registerForm = ref({ username: '', phone: '', password: '', confirmPassword: '', role: 'student' })

const currentForm = computed(() => isLogin.value ? loginForm.value : registerForm.value)

const persistSession = (payload, fallbackRole = 'student', fallbackUsername = '') => {
  if (!payload) return
  localStorage.setItem('token', payload.token || '')
  localStorage.setItem('isLoggedIn', 'true')
  localStorage.setItem('username', payload.username || fallbackUsername)
  localStorage.setItem('userRole', payload.role || fallbackRole)
}

const handleLogin = async () => {
  loading.value = true
  try {
    const data = await login(loginForm.value)
    persistSession(data, loginForm.value.role, loginForm.value.username)
    router.push('/')
  } catch (err) {
    alert(err?.message || '登录失败，请检查账号密码')
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (registerForm.value.password !== registerForm.value.confirmPassword) {
    alert('两次输入的密码不一致')
    return
  }
  loading.value = true
  try {
    const data = await register(registerForm.value)
    persistSession(data, 'student', registerForm.value.username)
    router.push('/')
  } catch (err) {
    alert(err?.message || '注册失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 核心配色变量 */
.auth-container {
  --fresh-primary: #0db18c;
  --fresh-primary-light: #34d399;
  --fresh-bg: #f0fdfa;
  --text-main: #1e293b;
  --text-muted: #64748b;
  width: 100%;
}

/* 切换器：胶囊设计 */
.tab-switcher {
  position: relative;
  display: flex;
  background: rgba(15, 23, 42, 0.04);
  border-radius: 16px;
  padding: 4px;
  margin-bottom: 32px;
}
.tab-item {
  flex: 1;
  z-index: 2;
  padding: 12px;
  border: none;
  background: none;
  font-weight: 700;
  font-size: 15px;
  cursor: pointer;
  color: var(--text-muted);
  transition: all 0.3s ease;
}
.tab-item.active {
  color: var(--fresh-primary);
}
.active-bg {
  position: absolute;
  top: 4px; left: 4px;
  width: calc(50% - 4px);
  height: calc(100% - 8px);
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1;
}

/* 输入框组合 */
.input-group { display: flex; flex-direction: column; gap: 16px; }
.field {
  display: flex;
  align-items: center;
  background: var(--fresh-bg);
  padding: 4px 16px;
  border-radius: 16px;
  border: 1px solid rgba(13, 177, 140, 0.1);
  transition: all 0.3s ease;
}
.field:focus-within {
  background: white;
  border-color: var(--fresh-primary);
  box-shadow: 0 0 0 4px rgba(13, 177, 140, 0.08);
  transform: translateY(-1px);
}
.icon-wrap {
  font-size: 18px;
  margin-right: 12px;
  filter: grayscale(0.2);
}
.field input {
  flex: 1;
  padding: 12px 0;
  border: none;
  outline: none;
  background: transparent;
  font-size: 15px;
  color: var(--text-main);
  font-weight: 500;
}
.field input::placeholder {
  color: #94a3b8;
}

/* 身份选择器 */
.role-selector { margin-top: 28px; }
.role-selector .label { 
  font-size: 13px; 
  font-weight: 800; 
  color: var(--text-muted); 
  margin-bottom: 12px;
  letter-spacing: 0.5px;
}
.role-chips { display: flex; gap: 10px; }
.chip { flex: 1; cursor: pointer; }
.chip input { display: none; }
.chip-text {
  display: block;
  text-align: center;
  padding: 10px 4px;
  background: white;
  border: 1px solid rgba(0, 0, 0, 0.03);
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
  transition: all 0.2s ease;
}
.chip:hover .chip-text {
  background: var(--fresh-bg);
}
.chip input:checked + .chip-text {
  background: var(--fresh-primary);
  color: white;
  border-color: var(--fresh-primary);
  box-shadow: 0 4px 12px rgba(13, 177, 140, 0.3);
}

/* 提交按钮 */
.submit-btn {
  width: 100%;
  margin-top: 32px;
  padding: 16px;
  border: none;
  border-radius: 18px;
  background: linear-gradient(135deg, var(--fresh-primary), var(--fresh-primary-light));
  color: white;
  font-weight: 800;
  font-size: 16px;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 20px -5px rgba(13, 177, 140, 0.4);
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}
.submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 25px -5px rgba(13, 177, 140, 0.5);
  filter: brightness(1.05);
}
.submit-btn:active { transform: translateY(0); }
.submit-btn:disabled { 
  background: #cbd5e1; 
  box-shadow: none; 
  cursor: not-allowed; 
}

/* 动画效果 */
.page-fade-enter-active, .page-fade-leave-active { 
  transition: all 0.3s ease; 
}
.page-fade-enter-from { opacity: 0; transform: translateY(10px); }
.page-fade-leave-to { opacity: 0; transform: translateY(-10px); }
</style>