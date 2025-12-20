<template>
  <div class="my-activities-page">
    <div class="halo halo-1"></div>
    <div class="halo halo-2"></div>

    <div class="activities-shell">
      <section class="activities-intro glass-panel">
        <div class="intro-content">
          <div class="intro-text">
            <p class="intro-eyebrow">Participation Log</p>
            <h2>我的活动轨迹</h2>
            <p class="intro-desc">记录你每一次的奔赴，让校园生活闪闪发光。</p>
          </div>
          <ul class="intro-stats">
            <li>
              <span>报名总数</span>
              <strong>{{ activities.length }}</strong>
            </li>
            <li>
              <span>待评价</span>
              <strong>{{ toEvaluateCount }}</strong>
            </li>
          </ul>
        </div>
      </section>

      <section class="activities-controls glass-panel">
        <div class="tabs-wrapper">
          <button 
            v-for="tab in tabs" 
            :key="tab.key"
            :class="['tab-pill', { active: activeTab === tab.key }]"
            @click="activeTab = tab.key"
          >
            {{ tab.label }}
          </button>
        </div>
        <div class="filter-wrapper">
          <select v-model="selectedTypeId" class="type-select-custom">
            <option value="">全部类型</option>
            <option v-for="type in activityTypes" :key="type.id" :value="type.id">
              {{ type.name }}
            </option>
          </select>
        </div>
      </section>

      <section class="activities-stream">
        <div v-if="loading" class="empty-state">✨ 正在努力加载活动...</div>
        <div v-else-if="errorMsg" class="empty-state error">{{ errorMsg }}</div>
        
        <div v-else-if="filteredActivities.length" class="activity-list">
          <div 
            v-for="activity in filteredActivities" 
            :key="activity.id"
            class="activity-row glass-panel"
          >
            <div class="row-main">
              <div class="activity-thumb">
                <img :src="buildImageUrl(activity.image)" alt="cover" @error="handleImageError($event)" />
                <span :class="['status-badge', activity.eventStatus]">{{ activity.status }}</span>
              </div>
              
              <div class="activity-info">
                <div class="info-head">
                  <h3 class="activity-name">{{ activity.name }}</h3>
                  <span class="registration-label" :class="activity.registrationStatus">
                    {{ registrationStatusLabelMap[activity.registrationStatus] || '未知' }}
                  </span>
                </div>
                
                <div class="meta-grid">
                  <span>🕒 {{ activity.time }}</span>
                  <span>📍 {{ activity.location }}</span>
                  <span>🏫 {{ activity.college }}</span>
                  <span>👥 参与人数: {{ activity.participants }}</span>
                </div>
              </div>
            </div>

            <div class="row-actions">
              <button
                v-if="['pending','approved'].includes(activity.registrationStatus) && !['ended', 'finished'].includes(activity.eventStatus)"
                class="btn-vibe btn-cancel-reg"
                @click="openCancelModal(activity.id)"
              >
                {{ activity.registrationStatus === 'pending' ? '撤回申请' : '取消报名' }}
              </button>
              
              <button 
                v-if="activity.canEvaluate" 
                class="btn-vibe btn-eval"
                @click="handleEvaluate(activity.eventId)"
              >
                去评价
              </button>

              <span v-if="activity.registrationStatus === 'cancelled'" class="text-hint">已成功取消</span>
            </div>
          </div>
        </div>

        <div v-else class="empty-state">
          <p>📭 这里空空如也，快去报名参加活动吧！</p>
        </div>
      </section>
    </div>

    <transition name="fade">
      <div v-if="cancelModalVisible" class="modal-overlay">
        <div class="modal-card glass-panel">
          <div class="modal-header">
            <h3>取消确认</h3>
            <button class="close-icon" @click="closeCancelModal">×</button>
          </div>
          <div class="modal-body">
            <p>您是否要取消活动报名？</p>
            <small>温馨提示：本学期无故取消超过3次将限制后续报名权益。</small>
          </div>
          <div class="modal-footer">
            <button class="btn-cancel" @click="closeCancelModal">再想想</button>
            <button class="btn-confirm" @click="confirmCancel">确认取消</button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { fetchMyRegistrations, cancelRegistration } from '@/api/registration'
import { fetchActivityTypes } from '@/api/event'

const router = useRouter()
const activeTab = ref('all')
const activities = ref([])
const loading = ref(false)
const errorMsg = ref('')
const activityTypes = ref([])
const selectedTypeId = ref('')
const cancelModalVisible = ref(false)
const selectedActivityId = ref(null)

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')
const DEFAULT_COVER = `${API_ORIGIN}/uploads/3b72bdb5a6ca17d85131e816c9fdd0b1.jpg`

const tabs = [
  { key: 'all', label: '全部' },
  { key: 'in-progress', label: '进行中' },
  { key: 'not-started', label: '未开始' },
  { key: 'to-evaluate', label: '待评价' },
  { key: 'completed', label: '已结束' }
]

const registrationStatusLabelMap = {
  pending: '待审核',
  approved: '报名成功',
  rejected: '审核未通过',
  cancelled: '已取消'
}

const statusLabelMap = {
  open: '进行中',
  ongoing: '进行中',
  upcoming: '预热中',
  finished: '已结束',
  ended: '已结束',
  cancelled: '已取消'
}

const buildImageUrl = (coverUrl) => {
  if (!coverUrl || coverUrl === '' || coverUrl === 'null' || coverUrl === 'undefined') return DEFAULT_COVER
  if (coverUrl.startsWith('http')) return coverUrl
  let normalized = coverUrl.replace(/\\/g, '/')
  return API_ORIGIN + (normalized.startsWith('/') ? normalized : '/' + normalized)
}

const statusToTab = (eventStatus, registrationStatus, hasComment) => {
  if (registrationStatus === 'pending') return 'all'
  if (['open', 'ongoing'].includes(eventStatus)) return 'in-progress'
  if (['upcoming'].includes(eventStatus)) return 'not-started'
  if (['finished', 'ended'].includes(eventStatus) && ['approved', 'checked_in'].includes(registrationStatus)) {
    return hasComment ? 'completed' : 'to-evaluate'
  }
  return 'completed'
}

const loadActivities = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    if (confirm('此操作需要登录，是否前往登录？')) router.push('/login')
    return
  }
  loading.value = true
  try {
    const data = await fetchMyRegistrations()
    activities.value = data?.list?.map((item) => ({
      id: item.registration_id,
      eventId: item.event_id,
      name: item.event_title,
      image: item.cover_url || '',
      participants: item.capacity || 0,
      status: statusLabelMap[item.event_status] || '进行中',
      eventStatus: item.event_status,
      registrationStatus: item.registration_status,
      college: item.organizer_name || '',
      location: item.location,
      time: item.start_time ? new Date(item.start_time).toLocaleString().split(':').slice(0, 2).join(':') : '',
      type_id: item.type_id,
      canEvaluate: ['finished', 'ended'].includes(item.event_status) && ['approved', 'checked_in'].includes(item.registration_status) && !item.has_comment,
      tab: statusToTab(item.event_status, item.registration_status, item.has_comment)
    })) || []
  } catch (err) {
    errorMsg.value = err?.message || '无法获取活动列表'
  } finally {
    loading.value = false
  }
}

const loadActivityTypes = async () => {
  try {
    const types = await fetchActivityTypes()
    activityTypes.value = types || []
  } catch (err) { console.error(err) }
}

const filteredActivities = computed(() => {
  let result = activities.value
  if (activeTab.value !== 'all') result = result.filter((a) => a.tab === activeTab.value)
  if (selectedTypeId.value) result = result.filter((a) => a.type_id === parseInt(selectedTypeId.value))
  return result
})

const toEvaluateCount = computed(() => activities.value.filter(a => a.tab === 'to-evaluate').length)

const openCancelModal = (id) => { selectedActivityId.value = id; cancelModalVisible.value = true }
const closeCancelModal = () => { cancelModalVisible.value = false; selectedActivityId.value = null }
const confirmCancel = async () => {
  try {
    await cancelRegistration(selectedActivityId.value)
    await loadActivities()
    closeCancelModal()
  } catch (err) { alert(err?.message || '取消失败') }
}

const handleEvaluate = (id) => router.push({ name: 'EventEvaluate', params: { id } })
const handleImageError = (e) => { e.target.src = DEFAULT_COVER }

onMounted(() => {
  loadActivityTypes()
  loadActivities()
})
</script>

<style scoped>
/* 核心布局参考评论界面 */
.my-activities-page {
  --mint: #0db18c;
  --ink: #0f172a;
  --indigo: #6366f1;
  min-height: 100vh;
  padding: 80px 20px 48px;
  background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 40%, #ffffff 100%);
  position: relative;
  overflow: hidden;
}

/* 装饰光晕 */
.halo {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.3;
}
.halo-1 { width: 500px; height: 500px; background: #d1fae5; top: -200px; left: -100px; }
.halo-2 { width: 400px; height: 400px; background: #e0e7ff; bottom: -150px; right: -50px; }

.activities-shell {
  position: relative;
  z-index: 1;
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.glass-panel {
  background: rgba(255, 255, 255, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.9);
  border-radius: 28px;
  box-shadow: 0 10px 40px rgba(15, 23, 42, 0.05);
  backdrop-filter: blur(16px);
  padding: 30px;
}

/* 顶部概览 */
.activities-intro .intro-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
}

.intro-eyebrow {
  text-transform: uppercase;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--mint);
  font-weight: 700;
  margin-bottom: 8px;
}

.intro-text h2 {
  font-size: 32px;
  font-weight: 800;
  color: var(--ink);
  margin: 0 0 10px;
}

.intro-desc {
  color: #64748b;
  margin: 0;
}

.intro-stats {
  list-style: none;
  display: flex;
  gap: 16px;
}

.intro-stats li {
  min-width: 110px;
  padding: 16px;
  border-radius: 20px;
  background: rgba(13, 177, 140, 0.06);
  border: 1px solid rgba(13, 177, 140, 0.1);
  text-align: center;
}

.intro-stats span {
  display: block;
  font-size: 12px;
  color: #64748b;
  margin-bottom: 4px;
}

.intro-stats strong {
  font-size: 26px;
  color: var(--ink);
  font-weight: 800;
}

/* 控制层 */
.activities-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  border-radius: 20px;
}

.tabs-wrapper {
  display: flex;
  gap: 8px;
  overflow-x: auto;
}

.tab-pill {
  border: none;
  background: transparent;
  padding: 8px 18px;
  border-radius: 99px;
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.tab-pill.active {
  background: var(--ink);
  color: #fff;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.2);
}

.tab-pill:hover:not(.active) {
  background: rgba(15, 23, 42, 0.05);
}

.type-select-custom {
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 8px 16px;
  font-size: 14px;
  outline: none;
  background: #fff;
  color: var(--ink);
  cursor: pointer;
}

/* 活动卡片行 */
.activities-stream {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.activity-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  transition: transform 0.3s;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.activity-row:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
}

.row-main {
  display: flex;
  gap: 20px;
  align-items: center;
}

.activity-thumb {
  position: relative;
  width: 140px;
  height: 90px;
  border-radius: 16px;
  overflow: hidden;
  background: #f1f5f9;
}

.activity-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.status-badge {
  position: absolute;
  top: 8px;
  left: 8px;
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 10px;
  font-weight: 800;
  color: #fff;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
}

.status-badge.open, .status-badge.ongoing { background: #059669; }
.status-badge.upcoming { background: var(--indigo); }

.info-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.activity-name {
  font-size: 18px;
  font-weight: 700;
  margin: 0;
  color: var(--ink);
}

.registration-label {
  font-size: 11px;
  font-weight: 700;
  padding: 2px 10px;
  border-radius: 6px;
  background: #f1f5f9;
  color: #64748b;
}

.registration-label.approved { background: #d1fae5; color: #065f46; }
.registration-label.pending { background: #e0e7ff; color: #3730a3; }

.meta-grid {
  display: grid;
  grid-template-columns: repeat(2, auto);
  gap: 6px 20px;
  font-size: 13px;
  color: #64748b;
}

/* 按钮操作 */
.btn-vibe {
  border: none;
  padding: 10px 24px;
  border-radius: 14px;
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel-reg {
  background: #fff;
  border: 1px solid #fee2e2;
  color: #ef4444;
}

.btn-cancel-reg:hover { background: #fef2f2; }

.btn-eval {
  background: linear-gradient(135deg, var(--mint), #34d399);
  color: #fff;
  box-shadow: 0 4px 15px rgba(13, 177, 140, 0.2);
}

.btn-eval:hover { transform: scale(1.05); }

.text-hint { font-size: 13px; color: #94a3b8; font-style: italic; }

/* 弹窗设计 */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-card {
  width: 400px;
  padding: 24px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.modal-header h3 { margin: 0; font-size: 20px; font-weight: 800; }
.close-icon { border: none; background: none; font-size: 24px; color: #94a3b8; cursor: pointer; }

.modal-body p { margin: 0 0 8px; color: var(--ink); font-weight: 600; }
.modal-body small { color: #ef4444; line-height: 1.5; display: block; }

.modal-footer {
  margin-top: 24px;
  display: flex;
  gap: 12px;
}

.btn-confirm {
  flex: 1;
  background: #ef4444;
  color: #fff;
  border: none;
  padding: 12px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
}

.btn-cancel {
  flex: 1;
  background: #f1f5f9;
  border: none;
  padding: 12px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
}

/* 响应式适配 */
@media (max-width: 768px) {
  .activities-intro .intro-content { flex-direction: column; align-items: flex-start; }
  .activity-row { flex-direction: column; align-items: flex-start; gap: 16px; }
  .meta-grid { grid-template-columns: 1fr; }
  .row-actions { width: 100%; display: flex; gap: 10px; }
  .btn-vibe { flex: 1; }
}

.empty-state {
  padding: 100px 0;
  text-align: center;
  color: #94a3b8;
  font-weight: 600;
}
</style>