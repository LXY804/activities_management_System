<template>
  <div v-if="visible" class="ranking-modal-overlay" @click.self="closeModal">
    <div class="ranking-modal-content">
      <div class="modal-header">
        <h2>积分排行榜</h2>
        <button class="close-btn" @click="closeModal" title="关闭">✕</button>
      </div>

      <div class="modal-body">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>加载排行榜中...</p>
        </div>

        <div v-else-if="rankingData.length === 0" class="empty-state">
          <span class="empty-icon">🏆</span>
          <p>暂无用户积分数据</p>
        </div>

        <div v-else class="ranking-list">
          <div class="ranking-header">
            <div class="rank-col">排名</div>
            <div class="user-col">用户</div>
            <div class="points-col">积分</div>
          </div>

          <div v-for="(item, index) in rankingData" :key="item.userId" class="ranking-row" :class="getRankClass(item.rank)">
            <div class="rank-col">
              <div class="rank-badge" :class="getRankBadgeClass(item.rank)">
                <span v-if="item.rank <= 3" class="medal">{{ getMedalEmoji(item.rank) }}</span>
                <span v-else>{{ item.rank }}</span>
              </div>
            </div>
            <div class="user-col">
              <div class="user-info">
                <img v-if="item.avatar" :src="item.avatar" :alt="item.username" class="user-avatar" />
                <div v-else class="user-avatar-placeholder">
                  {{ item.username?.charAt(0)?.toUpperCase() || '?' }}
                </div>
                <div class="user-detail">
                  <p class="username">{{ item.username || '未知用户' }}</p>
                  <p class="user-type">{{ mapUserType(item.userType) }}</p>
                </div>
              </div>
            </div>
            <div class="points-col">
              <span class="points-value">{{ item.totalPoints }}</span>
            </div>
          </div>
        </div>

        <!-- 分页 -->
        <div v-if="!loading && pagination.pageCount > 1" class="pagination">
          <button 
            class="pagination-btn" 
            @click="previousPage" 
            :disabled="pagination.offset === 0"
          >
            ← 上一页
          </button>
          <span class="page-info">
            第 {{ currentPage }} / {{ pagination.pageCount }} 页
          </span>
          <button 
            class="pagination-btn" 
            @click="nextPage" 
            :disabled="!hasNextPage"
          >
            下一页 →
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { fetchPointsRanking } from '@/api/reward'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const loading = ref(false)
const rankingData = ref([])
const errorMessage = ref('')
const pagination = ref({
  total: 0,
  limit: 10,
  offset: 0,
  pageCount: 0
})

const currentPage = computed(() => Math.floor(pagination.value.offset / pagination.value.limit) + 1)
const hasNextPage = computed(() => currentPage.value < pagination.value.pageCount)

const closeModal = () => {
  emit('close')
}

const getRankClass = (rank) => {
  if (rank === 1) return 'rank-first'
  if (rank === 2) return 'rank-second'
  if (rank === 3) return 'rank-third'
  return ''
}

const getRankBadgeClass = (rank) => {
  if (rank <= 3) return `rank-top-${rank}`
  return 'rank-normal'
}

const getMedalEmoji = (rank) => {
  const medals = ['🥇', '🥈', '🥉']
  return medals[rank - 1] || ''
}

const mapUserType = (type) => {
  const typeMap = {
    'student': '学生',
    'organizer': '组织者',
    'admin': '管理员',
    'teacher': '教师'
  }
  return typeMap[type] || type
}

const loadRanking = async () => {
  try {
    loading.value = true
    const response = await fetchPointsRanking({
      limit: pagination.value.limit,
      offset: pagination.value.offset
    })
    rankingData.value = response.ranking || []
    pagination.value = { ...pagination.value, ...response.pagination }
  } catch (err) {
    console.error('加载排行榜失败:', err)
    rankingData.value = []
  } finally {
    loading.value = false
  }
}

const previousPage = () => {
  if (pagination.value.offset > 0) {
    pagination.value.offset -= pagination.value.limit
    loadRanking()
  }
}

const nextPage = () => {
  if (hasNextPage.value) {
    pagination.value.offset += pagination.value.limit
    loadRanking()
  }
}

onMounted(() => {
  if (props.visible) {
    loadRanking()
  }
})

// 监听 visible 属性变化
import { watch } from 'vue'
watch(
  () => props.visible,
  (newVal) => {
    if (newVal) {
      loadRanking()
    }
  }
)
</script>

<style scoped>
.ranking-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s ease-out;
  backdrop-filter: blur(4px);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.ranking-modal-content {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-header h2 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  color: #0f172a;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #64748b;
  transition: color 0.2s ease;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #0f172a;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #64748b;
}

.loading-state .spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e2e8f0;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
  display: block;
}

.ranking-list {
  display: flex;
  flex-direction: column;
}

.ranking-header {
  display: grid;
  grid-template-columns: 60px 1fr 100px;
  gap: 16px;
  padding: 12px 0;
  border-bottom: 2px solid #e2e8f0;
  font-weight: 600;
  color: #64748b;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.ranking-row {
  display: grid;
  grid-template-columns: 60px 1fr 100px;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid #f1f5f9;
  align-items: center;
  transition: background-color 0.2s ease;
}

.ranking-row:hover {
  background-color: #f8fafc;
  border-radius: 8px;
  padding: 16px 12px;
}

.ranking-row.rank-first {
  background: linear-gradient(135deg, #fef3c7 0%, #fef08a 100%);
  border-radius: 8px;
  padding: 16px 12px;
}

.ranking-row.rank-second {
  background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
  border-radius: 8px;
  padding: 16px 12px;
}

.ranking-row.rank-third {
  background: linear-gradient(135deg, #fed7aa 0%, #fed7aa 100%);
  border-radius: 8px;
  padding: 16px 12px;
}

.rank-col {
  display: flex;
  justify-content: center;
}

.rank-badge {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
  background: #f1f5f9;
  color: #0f172a;
}

.rank-badge.rank-top-1 {
  background: #fbbf24;
  color: #fff;
  font-size: 20px;
}

.rank-badge.rank-top-2 {
  background: #c0c0c0;
  color: #fff;
  font-size: 20px;
}

.rank-badge.rank-top-3 {
  background: #d97706;
  color: #fff;
  font-size: 20px;
}

.rank-badge.rank-normal {
  background: #e2e8f0;
  color: #64748b;
}

.user-col {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.user-avatar,
.user-avatar-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  flex-shrink: 0;
  background: linear-gradient(135deg, #3b82f6, #8b5cf6);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: white;
  font-size: 14px;
}

.user-avatar {
  object-fit: cover;
}

.user-detail {
  min-width: 0;
  flex: 1;
}

.username {
  margin: 0;
  font-weight: 600;
  color: #0f172a;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-type {
  margin: 4px 0 0 0;
  color: #64748b;
  font-size: 12px;
}

.points-col {
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.points-value {
  font-weight: 700;
  font-size: 18px;
  color: #3b82f6;
  display: flex;
  align-items: center;
  gap: 4px;
}

.points-value::after {
  content: 'P';
  font-size: 12px;
  color: #64748b;
  font-weight: 600;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 24px 0;
  border-top: 1px solid #e2e8f0;
  margin-top: 24px;
}

.pagination-btn {
  padding: 8px 16px;
  border: 1px solid #e2e8f0;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  color: #3b82f6;
  transition: all 0.2s ease;
}

.pagination-btn:hover:not(:disabled) {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  color: #64748b;
}

.page-info {
  color: #64748b;
  font-size: 14px;
  font-weight: 600;
  min-width: 120px;
  text-align: center;
}

@media (max-width: 600px) {
  .ranking-modal-content {
    width: 95%;
    max-height: 90vh;
  }

  .modal-header {
    padding: 16px;
  }

  .modal-body {
    padding: 16px;
  }

  .ranking-header,
  .ranking-row {
    grid-template-columns: 50px 1fr 80px;
    gap: 12px;
    padding: 12px 0;
  }

  .rank-badge {
    width: 36px;
    height: 36px;
    font-size: 14px;
  }

  .user-avatar,
  .user-avatar-placeholder {
    width: 36px;
    height: 36px;
  }

  .points-value {
    font-size: 16px;
  }
}
</style>
