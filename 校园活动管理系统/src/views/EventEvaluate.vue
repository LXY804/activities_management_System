<template>
  <div class="page event-evaluate">
    <NavBar />

    <div class="container">
      <button class="back" @click="goBack">← 返回</button>

      <div class="header">
        <h1 class="title">活动评价</h1>
        <p class="subtitle" v-if="eventTitle">{{ eventTitle }}</p>
      </div>

      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="errorMsg" class="error">{{ errorMsg }}</div>
      <div v-else class="evaluate-form">
        <div class="form-section">
          <label class="form-label">评分 <span class="required">*</span></label>
          <div class="rating-selector">
            <button
              v-for="star in 5"
              :key="star"
              :class="['star-btn', { active: rating >= star }]"
              @click="rating = star"
            >
              ★
            </button>
            <span class="rating-text">{{ rating > 0 ? `${rating}分` : '请选择评分' }}</span>
          </div>
        </div>

        <div class="form-section">
          <label class="form-label">评价内容 <span class="required">*</span></label>
          <textarea
            v-model="content"
            class="content-input"
            placeholder="请输入您的评价内容..."
            rows="8"
            maxlength="500"
          ></textarea>
          <div class="char-count">{{ content.length }}/500</div>
        </div>

        <div class="form-actions">
          <button class="btn btn-cancel" @click="goBack">取消</button>
          <button 
            class="btn btn-submit" 
            :disabled="!canSubmit || submitting"
            @click="handleSubmit"
          >
            {{ submitting ? '提交中...' : '提交评价' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import NavBar from '../components/NavBar.vue'
import { fetchEventDetail } from '@/api/event'
import { submitComment } from '@/api/comment'

const router = useRouter()
const route = useRoute()
const eventId = route.params.id

const eventTitle = ref('')
const rating = ref(0)
const content = ref('')
const loading = ref(false)
const submitting = ref(false)
const errorMsg = ref('')

const canSubmit = computed(() => {
  return rating.value >= 1 && rating.value <= 5 && content.value.trim().length > 0
})

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

const loadEventInfo = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchEventDetail(eventId)
    eventTitle.value = data.title || ''
  } catch (err) {
    console.error('加载活动信息失败:', err)
    errorMsg.value = err?.message || '加载活动信息失败'
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  if (!requireLogin()) return
  if (!canSubmit.value) return

  submitting.value = true
  try {
    await submitComment(eventId, {
      rating: rating.value,
      content: content.value.trim()
    })
    alert('评价提交成功！')
    // 返回上一页或跳转到我的评论页面
    router.push('/personal/comments')
  } catch (err) {
    console.error(err)
    const msg = err?.response?.data?.message || err?.message || '提交评价失败'
    alert(msg)
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadEventInfo()
})
</script>

<style scoped>
.container {
  max-width: 820px;
  margin: 24px auto 80px;
  padding: 0 18px;
}

.back {
  background: transparent;
  border: none;
  color: #23a971;
  font-weight: 600;
  cursor: pointer;
  margin-bottom: 12px;
}

.header {
  margin-bottom: 32px;
}

.title {
  font-size: 34px;
  margin: 0 0 8px;
  font-family: var(--font-display);
  color: var(--brand-deep);
}

.subtitle {
  color: rgba(15, 29, 51, 0.6);
}

.loading,
.error {
  text-align: center;
  padding: 50px 20px;
  color: rgba(15, 29, 51, 0.6);
}

.evaluate-form {
  border-radius: 30px;
  padding: 32px;
  box-shadow: var(--shadow-card);
  background: rgba(255, 255, 255, 0.95);
}

.form-section {
  margin-bottom: 32px;
}

.form-label {
  font-weight: 700;
  color: var(--brand-deep);
  margin-bottom: 12px;
}

.required {
  color: #ff6b6b;
}

.rating-selector {
  display: flex;
  align-items: center;
  gap: 12px;
}

.star-btn {
  background: transparent;
  border: none;
  font-size: 38px;
  color: #e0e0e0;
  cursor: pointer;
  transition: transform 0.2s ease, color 0.2s ease;
}

.star-btn.active {
  color: #ffd166;
  transform: translateY(-2px);
}

.rating-text {
  color: rgba(15, 29, 51, 0.65);
}

.content-input {
  width: 100%;
  border-radius: 20px;
  border: 1px solid rgba(15, 29, 51, 0.08);
  padding: 16px;
  font-size: 15px;
  line-height: 1.7;
  background: rgba(255, 255, 255, 0.9);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.content-input:focus {
  outline: none;
  border-color: var(--brand-emerald);
  box-shadow: 0 0 0 3px rgba(102, 231, 177, 0.25);
}

.char-count {
  text-align: right;
  font-size: 12px;
  color: rgba(15, 29, 51, 0.45);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  border-top: 1px dashed rgba(15, 29, 51, 0.1);
  padding-top: 24px;
}

.btn {
  border-radius: 999px;
  border: none;
  padding: 12px 32px;
  font-weight: 700;
  cursor: pointer;
}

.btn-cancel {
  background: rgba(15, 29, 51, 0.05);
  color: rgba(15, 29, 51, 0.7);
}

.btn-submit {
  background: linear-gradient(120deg, var(--brand-lime), var(--brand-emerald));
  color: var(--brand-deep);
  box-shadow: 0 18px 26px rgba(102, 231, 177, 0.35);
}

.btn-submit:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  box-shadow: none;
}

@media (max-width: 768px) {
  .evaluate-form {
    padding: 24px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }
}
</style>







