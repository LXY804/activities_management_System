<template>
  <NavBar />
  <div class="admin-layout">
    <aside class="sidebar">
      <div class="sidebar__title">管理后台</div>
      <nav class="sidebar__menu">
        <a 
          class="sidebar__item" 
          :class="{ active: activeMenu === 'review' }"
          @click="activeMenu = 'review'"
        >审核活动发布</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'rewards' }"
          @click.prevent="switchToRewards"
        >积分管理</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'users' }"
          @click.prevent="switchToUsers"
        >用户管理</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'config' }"
          @click.prevent="switchToConfig"
        >系统配置</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'stats' }"
          @click.prevent="switchToStats"
        >数据统计</a>
      </nav>
    </aside>

    <main class="admin-content">
      <header class="admin-header">
        <div>
          <h1>管理后台</h1>
          <p>系统审核、用户管理与平台统计</p>
        </div>
        <div class="admin-user">
          <div class="avatar">管理员</div>
        </div>
      </header>

      <section class="admin-grid">
        <article class="admin-card">
          <h3>待审核活动</h3>
          <p class="admin-card__value">{{ reviewList.length }}</p>
          <p class="admin-card__desc">提交待审核，需尽快处理</p>
        </article>
        <article class="admin-card">
          <h3>本月新增用户</h3>
          <p class="admin-card__value">{{ newUsersThisMonth.count }}</p>
          <p class="admin-card__desc" v-if="newUsersThisMonth.growthRate > 0">
            较上月提升 {{ newUsersThisMonth.growthRate }}%
          </p>
          <p class="admin-card__desc" v-else-if="newUsersThisMonth.growthRate < 0">
            较上月下降 {{ Math.abs(newUsersThisMonth.growthRate) }}%
          </p>
          <p class="admin-card__desc" v-else>
            与上月持平
          </p>
        </article>
        <article class="admin-card">
          <h3>系统运行状态</h3>
          <p class="admin-card__value status good">正常</p>
          <p class="admin-card__desc">服务全部可用</p>
        </article>
      </section>

      <section class="admin-panels">
        <!-- 审核活动发布面板 -->
        <div v-if="activeMenu === 'review'" class="review-container">
          <article class="panel">
            <header>
              <h2>活动审核队列</h2>
              <button>查看全部</button>
            </header>
            <ul>
              <li v-for="(item, idx) in reviewList" :key="item.name">
                <div>
                  <h3>{{ item.name }}</h3>
                  <p>{{ item.club }} · {{ item.time }}</p>
                </div>
                <div class="review-actions">
                  <button 
                    class="btn btn-approve" 
                    @click="approveActivity(idx)"
                    title="通过审核"
                  >✓ 通过</button>
                  <button 
                    class="btn btn-reject" 
                    @click="rejectActivity(idx)"
                    title="驳回审核"
                  >✗ 驳回</button>
                </div>
              </li>
            </ul>
          </article>

          <!-- 用户概览（仅在审核活动时显示） -->
          <article class="panel">
            <header>
              <h2>用户概览</h2>
              <span>{{ userStats.total }} 人</span>
            </header>
            <div class="user-summary">
              <div>
                <div class="value">{{ userStats.students }}</div>
                <div class="label">学生用户</div>
              </div>
              <div>
                <div class="value">{{ userStats.organizers }}</div>
                <div class="label">组织者</div>
              </div>
              <div>
                <div class="value">{{ userStats.admins }}</div>
                <div class="label">管理员</div>
              </div>
            </div>
          </article>
        </div>

        <!-- 用户管理面板 -->
        <article class="panel" v-if="activeMenu === 'users'">
          <header>
            <h2>用户管理</h2>
            <button>导出用户数据</button>
          </header>
          <div class="user-management">
            <div class="user-stat">
              <div class="stat-box">
                <div class="stat-value">{{ userStats.students || 0 }}</div>
                <div class="stat-label">学生用户</div>
              </div>
              <div class="stat-box">
                <div class="stat-value">{{ userStats.organizers || 0 }}</div>
                <div class="stat-label">组织者</div>
              </div>
              <div class="stat-box">
                <div class="stat-value">{{ userStats.admins || 0 }}</div>
                <div class="stat-label">管理员</div>
              </div>
            </div>

            <!-- 搜索和过滤器 -->
            <div class="user-filters">
              <div class="filter-row">
                <input 
                  v-model="userSearchKey" 
                  type="text" 
                  placeholder="搜索用户名..." 
                  class="search-input"
                  @input="debouncedLoadUsers"
                />
                <select 
                  v-model="userFilterRole"
                  class="role-select"
                  @change="loadUsers"
                >
                  <option value="全部">全部角色</option>
                  <option value="学生用户">学生用户</option>
                  <option value="组织者">组织者</option>
                  <option value="管理员">管理员</option>
                </select>
              </div>
            </div>

            <!-- 过滤结果统计 -->
            <div class="filter-result">
              找到 <strong>{{ filteredUsers.length }}</strong> 条结果
            </div>

            <!-- 用户列表 -->
            <ul class="user-list">
              <li v-if="loadingUsers" class="no-result">
                <p>加载中...</p>
              </li>
              <li v-else v-for="(user, idx) in filteredUsers" :key="user.id || idx">
                <div class="user-info">
                  <div class="user-avatar">{{ user.name.charAt(0) }}</div>
                  <div>
                    <h4>{{ user.name }}</h4>
                    <p>{{ user.role }}</p>
                  </div>
                </div>
                <div class="user-meta">
                  <span>{{ user.joinDate }}</span>
                </div>
              </li>
              <li v-if="!loadingUsers && filteredUsers.length === 0" class="no-result">
                <p>没有找到匹配的用户</p>
              </li>
            </ul>
          </div>
        </article>

        <!-- 积分管理面板 -->
        <article class="panel rewards-panel" v-if="activeMenu === 'rewards'">
          <header>
            <div>
              <h2>积分与礼品看板</h2>
              <p>审核礼品、维护库存、监控兑换与积分调整</p>
            </div>
            <div class="panel-actions">
              <button class="ghost-link" @click="refreshRewardPanel">刷新数据</button>
            </div>
          </header>

          <div v-if="loadingRewardOverview" class="loading-block">加载积分数据中...</div>
          <div v-else class="reward-metrics">
            <div class="metric-block">
              <p class="metric-label">累计发放</p>
              <strong>{{ rewardOverview.totalPointsIssued }}</strong>
              <small>总发放积分</small>
            </div>
            <div class="metric-block">
              <p class="metric-label">累计消耗</p>
              <strong>{{ rewardOverview.totalPointsConsumed }}</strong>
              <small>兑换礼品所消耗</small>
            </div>
            <div class="metric-block">
              <p class="metric-label">兑换订单</p>
              <strong>{{ rewardOverview.totalOrders }}</strong>
              <small>历史订单总数</small>
            </div>
          </div>

          <div class="reward-board">
            <section class="sub-panel">
              <div class="panel-head">
                <div>
                  <p class="eyebrow">礼品申请</p>
                  <h3>待审核</h3>
                </div>
                <button class="ghost-link" @click="loadManagedGifts">刷新</button>
              </div>
              <div v-if="loadingManagedGifts" class="loading small">加载礼品中...</div>
              <ul v-else-if="pendingGiftApplications.length" class="reward-list">
                <li v-for="gift in pendingGiftApplications" :key="gift.id">
                  <div>
                    <h4>{{ gift.title }}</h4>
                    <p>{{ gift.pointsCost }} 分 · 库存 {{ gift.stock }}</p>
                  </div>
                  <div class="reward-actions">
                    <button class="btn-mini approve" @click="approveGift(gift)">通过</button>
                    <button class="btn-mini reject" @click="rejectGift(gift)">驳回</button>
                  </div>
                </li>
              </ul>
              <p v-else class="empty">暂无待审核礼品</p>
            </section>

            <section class="sub-panel">
              <div class="panel-head">
                <div>
                  <p class="eyebrow">礼品库维护</p>
                  <h3>新增系统礼品</h3>
                </div>
                <button class="ghost-link" @click="resetGiftForm">清空</button>
              </div>
              <form class="stack-form" @submit.prevent="createSystemGift">
                <label>
                  礼品名称
                  <input v-model.trim="newGiftForm.title" type="text" placeholder="如 校园周边礼包" required />
                </label>
                <label>
                  礼品描述
                  <textarea v-model.trim="newGiftForm.description" rows="2" placeholder="简单描述" />
                </label>
                <div class="inline-inputs">
                  <label>
                    积分成本
                    <input v-model.number="newGiftForm.pointsCost" type="number" min="1" />
                  </label>
                  <label>
                    库存
                    <input v-model.number="newGiftForm.stock" type="number" min="1" />
                  </label>
                </div>
                <label>
                  交付方式
                  <select v-model="newGiftForm.deliveryType">
                    <option value="offline">线下领取</option>
                    <option value="online">线上发放</option>
                    <option value="both">线上/线下皆可</option>
                  </select>
                </label>
                <label>
                  封面图片
                  <input v-model.trim="newGiftForm.coverImage" type="text" placeholder="/uploads/gift.jpg" />
                </label>
                <button class="btn" type="submit" :disabled="submittingGift">
                  {{ submittingGift ? '提交中...' : '添加礼品' }}
                </button>
              </form>
            </section>
          </div>

          <div class="reward-board">
            <section class="sub-panel">
              <div class="panel-head">
                <div>
                  <p class="eyebrow">库存预警</p>
                  <h3>低于阈值</h3>
                </div>
                <button class="ghost-link" @click="loadRewardOverview">刷新</button>
              </div>
              <ul v-if="lowStockGifts.length" class="low-stock-list">
                <li v-for="gift in lowStockGifts" :key="gift.id">
                  <div>
                    <h4>{{ gift.title }}</h4>
                    <p>剩余 {{ gift.stock }} 件</p>
                  </div>
                  <span class="badge warning">补货</span>
                </li>
              </ul>
              <p v-else class="empty">库存全部在安全范围</p>
            </section>

            <section class="sub-panel">
              <div class="panel-head">
                <div>
                  <p class="eyebrow">积分规则</p>
                  <h3>调整活动积分</h3>
                </div>
                <button class="ghost-link" @click="loadPointRules">刷新</button>
              </div>
              <div v-if="loadingRules" class="loading small">加载规则中...</div>
              <div v-else class="rule-list" v-show="pointRules.length">
                <div
                  v-for="rule in pointRules.slice(0, 5)"
                  :key="rule.id"
                  class="rule-row"
                  @click="editRule(rule)"
                >
                  <div>
                    <h4>{{ rule.actionLabel }}</h4>
                    <p>活动 {{ rule.activityId }} · {{ rule.pointsValue }} 分</p>
                  </div>
                  <span class="badge" :class="{ success: rule.isActive }">
                    {{ rule.isActive ? '启用' : '停用' }}
                  </span>
                </div>
              </div>
              <form class="stack-form" @submit.prevent="submitRule">
                <div class="inline-inputs">
                  <input v-model.number="ruleForm.activityId" type="number" min="1" placeholder="活动 ID" required />
                  <input v-model.trim="ruleForm.actionLabel" type="text" placeholder="规则标题" required />
                  <input v-model.number="ruleForm.pointsValue" type="number" min="1" placeholder="积分" required />
                </div>
                <textarea v-model.trim="ruleForm.description" rows="2" placeholder="规则描述"></textarea>
                <label class="checkbox-inline">
                  <input type="checkbox" v-model="ruleForm.isActive" /> 启用规则
                </label>
                <button class="btn" type="submit" :disabled="savingRule">
                  {{ savingRule ? '保存中...' : '保存/更新规则' }}
                </button>
              </form>
            </section>
          </div>

          <section class="sub-panel full-width">
            <div class="panel-head">
              <div>
                <p class="eyebrow">兑换订单</p>
                <h3>异常与进度跟踪</h3>
              </div>
              <div class="order-filters">
                <select v-model="orderStatusFilter">
                  <option value="pending">待处理</option>
                  <option value="processing">处理中</option>
                  <option value="shipped">已发货</option>
                  <option value="received">已完成</option>
                  <option value="cancelled">已取消</option>
                  <option value="all">全部</option>
                </select>
                <input
                  v-model.trim="orderKeyword"
                  type="text"
                  placeholder="搜索礼品/姓名"
                  @keyup.enter="loadAdminOrders"
                />
                <button class="ghost-link" @click="loadAdminOrders">筛选</button>
              </div>
            </div>
            <div v-if="loadingRewardOrders" class="loading small">加载订单中...</div>
            <div v-else-if="rewardOrders.length" class="order-table">
              <div class="order-row" v-for="order in rewardOrders.slice(0, 6)" :key="order.id">
                <div>
                  <h4>{{ order.giftTitle }}</h4>
                  <p>{{ order.realName || order.username || '未知用户' }} · {{ formatOrderTime(order.createdAt) }}</p>
                  <small>数量 {{ order.quantity }} · 消耗 {{ order.totalPoints }} 分</small>
                </div>
                <div class="order-controls">
                  <span class="status-pill" :class="`status-${order.status}`">{{ mapStatus(order.status) }}</span>
                  <div class="order-buttons">
                    <button
                      v-if="order.status === 'pending'"
                      class="btn-mini approve"
                      @click="markOrderProcessing(order)"
                    >受理</button>
                    <button
                      v-if="order.status === 'processing'"
                      class="btn-mini approve"
                      @click="markOrderShipped(order)"
                    >发货</button>
                    <button
                      v-if="order.status === 'shipped'"
                      class="btn-mini approve"
                      @click="markOrderCompleted(order)"
                    >完成</button>
                    <button
                      class="btn-mini reject"
                      @click="markOrderCancelled(order)"
                    >取消订单</button>
                  </div>
                </div>
              </div>
            </div>
            <p v-else class="empty">没有符合筛选条件的订单</p>
          </section>

          <section class="sub-panel full-width">
            <div class="panel-head">
              <div>
                <p class="eyebrow">积分调节</p>
                <h3>异常补偿 / 扣减</h3>
              </div>
            </div>
            <form class="stack-form" @submit.prevent="submitAdjustment">
              <div class="inline-inputs">
                <input v-model.trim="adjustmentForm.userId" type="number" min="1" placeholder="用户 ID" required />
                <input v-model.trim="adjustmentForm.amount" type="number" placeholder="调整积分 (+/-)" required />
              </div>
              <textarea v-model.trim="adjustmentForm.reason" rows="2" placeholder="备注，如 系统补发"></textarea>
              <button class="btn" type="submit" :disabled="adjustingPoints">
                {{ adjustingPoints ? '调节中...' : '提交调整' }}
              </button>
            </form>
          </section>
        </article>

        <!-- 系统配置面板 -->
        <article class="panel" v-if="activeMenu === 'config'">
          <header>
            <h2>系统配置</h2>
            <button @click="saveConfig" class="btn-save">💾 保存设置</button>
          </header>
          <div class="config-panel">
            <div class="config-item">
              <label>最大活动人数限制</label>
              <input 
                v-model.number="configForm.maxActivityPeople" 
                type="number" 
                min="10"
                max="10000"
              />
            </div>
            <div class="config-item">
              <label>审核活动超时时间（小时）</label>
              <input 
                v-model.number="configForm.reviewTimeout" 
                type="number"
                min="1"
                max="168"
              />
            </div>
            <div class="config-item">
              <label>启用邮件通知</label>
              <input 
                v-model="configForm.emailNotification" 
                type="checkbox" 
              />
            </div>
            <div class="config-item">
              <label>维护模式</label>
              <input 
                v-model="configForm.maintenanceMode" 
                type="checkbox" 
              />
            </div>
          </div>
        </article>

        <!-- 数据统计面板 -->
        <article class="panel" v-if="activeMenu === 'stats'">
          <header>
            <h2>数据统计</h2>
            <button class="btn-export">导出报告</button>
          </header>

          <!-- 时间范围选择 -->
          <div class="stats-date-picker">
            <div class="month-control">
              <label class="month-info" for="month-selector">
                <span class="label-text">选择月份</span>
                <strong class="label-value">{{ selectedMonthLabel }}</strong>
              </label>
              <input 
                id="month-selector"
                v-model="selectedMonth" 
                type="month"
                @change="updateStatsData"
                class="month-input"
              />
            </div>
            <button @click="showAllData" class="btn-show-all">显示全部数据</button>
          </div>

          <!-- 统计数据卡片 -->
          <div class="stats-panel">
            <div class="stat-card">
              <h4>本月活动统计</h4>
              <div class="stat-numbers">
                <div class="number">{{ currentStats.activities }}</div>
                <p>新增活动</p>
              </div>
            </div>
            <div class="stat-card">
              <h4>用户参与度</h4>
              <div class="stat-numbers">
                <div class="number">{{ currentStats.participation }}%</div>
                <p>参与率</p>
              </div>
            </div>
            <div class="stat-card">
              <h4>平均评分</h4>
              <div class="stat-numbers">
                <div class="number">{{ currentStats.rating }}</div>
                <p>★</p>
              </div>
            </div>
          </div>
        </article>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive, watch } from 'vue'
import NavBar from '../components/NavBar.vue'
import { fetchPendingEvents, approveEvent, rejectEvent } from '@/api/event'
import { 
  fetchUserList, 
  fetchUserStats, 
  fetchNewUsersThisMonth,
  fetchSystemConfig,
  saveSystemConfig as saveSystemConfigApi,
  fetchActivityStats
} from '@/api/user'
import {
  fetchAdminRewardOverview,
  fetchManagedGifts,
  updateGiftStatus,
  createGift,
  fetchPointRules,
  savePointRule,
  adjustRewardPoints,
  fetchAdminRewardOrders,
  updateAdminOrderStatus
} from '@/api/reward'

// 当前活动菜单
const activeMenu = ref('review')

// 审核队列（从后端获取）
const reviewList = ref([])

// 概览统计数据
const newUsersThisMonth = ref({
  count: 0,
  growthRate: 0
})

// 积分管理状态
const rewardOverview = ref({
  totalPointsIssued: 0,
  totalPointsConsumed: 0,
  totalOrders: 0,
  lowStock: []
})
const loadingRewardOverview = ref(false)
const managedGifts = ref([])
const loadingManagedGifts = ref(false)
const pointRules = ref([])
const loadingRules = ref(false)
const savingRule = ref(false)
const rewardOrders = ref([])
const loadingRewardOrders = ref(false)
const orderStatusFilter = ref('pending')
const orderKeyword = ref('')
const submittingGift = ref(false)
const newGiftForm = reactive({
  title: '',
  description: '',
  pointsCost: 120,
  stock: 50,
  deliveryType: 'offline',
  coverImage: ''
})
const ruleForm = reactive({
  activityId: '',
  actionLabel: '',
  pointsValue: '',
  description: '',
  isActive: true
})
const adjustmentForm = reactive({
  userId: '',
  amount: '',
  reason: ''
})
const adjustingPoints = ref(false)
const rewardPanelInitialized = ref(false)

const loadPendingEvents = async () => {
  try {
    const list = await fetchPendingEvents()
    reviewList.value = list.map((item) => ({
      creationId: item.creation_id,
      name: item.title,
      club: item.organizer_college || item.organizer_name || '组织者',
      time: item.submitted_at,
      raw: item
    }))
  } catch (e) {
    console.error('获取待审核活动失败:', e)
    showNotification('获取待审核活动失败，请稍后重试', 'warning')
  }
}

const switchToRewards = () => {
  activeMenu.value = 'rewards'
  if (!rewardPanelInitialized.value) {
    rewardPanelInitialized.value = true
  }
  refreshRewardPanel()
}

// 切换到用户管理
const switchToUsers = () => {
  activeMenu.value = 'users'
  // 延迟加载，确保菜单切换先完成
  setTimeout(() => {
    // 如果还没有加载过用户数据，则加载
    if (userList.value.length === 0 && !loadingUsers.value) {
      loadUsers()
    }
    if (userStats.value.total === 0 && userStats.value.students === 0) {
      loadUserStats()
    }
  }, 0)
}

// 切换到系统配置
const switchToConfig = () => {
  activeMenu.value = 'config'
  // 如果还没有加载过配置，则加载
  if (configForm.value.maxActivityPeople === 500 && configForm.value.reviewTimeout === 48) {
    loadSystemConfig()
  }
}

// 切换到数据统计
const switchToStats = () => {
  activeMenu.value = 'stats'
  // 如果当前统计数据为空，则加载
  if (currentStats.value.activities === 0 && currentStats.value.participation === 0) {
    loadActivityStats(selectedMonth.value)
  }
}

onMounted(() => {
  loadPendingEvents()
  loadUserStats() // 加载用户统计（用于概览卡片）
  loadNewUsersThisMonth() // 加载本月新增用户
  loadSystemConfig() // 加载系统配置
  loadActivityStats(selectedMonth.value) // 加载当前月份的统计数据
  // 如果初始菜单是用户管理，则加载数据
  if (activeMenu.value === 'users') {
    loadUsers()
  }
  if (activeMenu.value === 'rewards') {
    rewardPanelInitialized.value = true
    refreshRewardPanel()
  }
})

// 通过审核
const approveActivity = async (index) => {
  const activity = reviewList.value[index]
  try {
    await approveEvent(activity.creationId)
    reviewList.value.splice(index, 1)
    showNotification(`✓ 已通过 "${activity.name}" 的审核`, 'success')
  } catch (e) {
    console.error('审核通过失败:', e)
    showNotification('审核通过失败，请稍后重试', 'warning')
  }
}

// 驳回审核
const rejectActivity = async (index) => {
  const activity = reviewList.value[index]

  const remark = window.prompt(`请输入驳回 "${activity.name}" 的原因（可选）：`) || ''

  try {
    await rejectEvent(activity.creationId, remark)
    reviewList.value.splice(index, 1)
    showNotification(`✗ 已驳回 "${activity.name}" 的审核请求`, 'warning')
  } catch (e) {
    console.error('驳回审核失败:', e)
    showNotification('驳回审核失败，请稍后重试', 'warning')
  }
}

// 全局通知（临时实现，后续会用 Toast 组件替代）
const showNotification = (message, type = 'info') => {
  const notification = document.createElement('div')
  notification.className = `notification notification-${type}`
  notification.textContent = message
  document.body.appendChild(notification)
  
  // 自动消失
  setTimeout(() => {
    notification.classList.add('notification-hide')
    setTimeout(() => notification.remove(), 300)
  }, 2500)
}

// 用户管理的搜索和过滤
const userSearchKey = ref('')
const userFilterRole = ref('全部')
const userList = ref([])
const userStats = ref({
  total: 0,
  students: 0,
  organizers: 0,
  admins: 0
})
const loadingUsers = ref(false)

// 加载用户列表
const loadUsers = async () => {
  if (loadingUsers.value) return // 防止重复加载
  loadingUsers.value = true
  try {
    // 构建查询参数，只包含有值的参数
    const params = {}
    if (userSearchKey.value) {
      params.search = userSearchKey.value
    }
    if (userFilterRole.value && userFilterRole.value !== '全部') {
      params.role = userFilterRole.value
    }
    params.page = 1
    params.pageSize = 100
    
    console.log('请求用户列表，参数:', params)
    const data = await fetchUserList(params)
    console.log('用户列表响应数据:', data)
    
    // 确保正确处理返回的数据
    if (data && Array.isArray(data.list)) {
      userList.value = data.list
    } else if (Array.isArray(data)) {
      // 如果直接返回数组
      userList.value = data
    } else {
      userList.value = []
    }
    console.log('设置后的用户列表:', userList.value, '数量:', userList.value.length)
  } catch (e) {
    console.error('加载用户列表失败:', e)
    console.error('错误详情:', e.response?.data || e.message)
    console.error('错误状态码:', e.response?.status)
    // 显示错误通知，帮助调试
    const errorMsg = e.response?.data?.message || e.message || '未知错误'
    showNotification(`加载用户列表失败: ${errorMsg}`, 'warning')
    userList.value = [] // 确保设置为空数组
  } finally {
    loadingUsers.value = false
  }
}

// 加载用户统计
const loadUserStats = async () => {
  try {
    console.log('请求用户统计')
    const stats = await fetchUserStats()
    console.log('用户统计响应数据:', stats)
    userStats.value = stats || {
      total: 0,
      students: 0,
      organizers: 0,
      admins: 0
    }
    console.log('设置后的用户统计:', userStats.value)
  } catch (e) {
    console.error('加载用户统计失败:', e)
    console.error('错误详情:', e.response?.data || e.message)
    // 设置默认值，避免显示错误
    userStats.value = {
      total: 0,
      students: 0,
      organizers: 0,
      admins: 0
    }
  }
}

// 加载本月新增用户
const loadNewUsersThisMonth = async () => {
  try {
    const data = await fetchNewUsersThisMonth()
    newUsersThisMonth.value = {
      count: data?.newUsersThisMonth || 0,
      growthRate: data?.growthRate || 0
    }
  } catch (e) {
    console.error('加载本月新增用户失败:', e)
    newUsersThisMonth.value = {
      count: 0,
      growthRate: 0
    }
  }
}

const refreshRewardPanel = () => {
  loadRewardOverview()
  loadManagedGifts()
  loadPointRules()
  loadAdminOrders()
}

const loadRewardOverview = async () => {
  loadingRewardOverview.value = true
  try {
    const data = await fetchAdminRewardOverview()
    rewardOverview.value = {
      totalPointsIssued: data?.totalPointsIssued || 0,
      totalPointsConsumed: data?.totalPointsConsumed || 0,
      totalOrders: data?.totalOrders || 0,
      lowStock: data?.lowStock || []
    }
  } catch (e) {
    console.error('加载积分概览失败:', e)
    showNotification('获取积分概览失败，请稍后再试', 'warning')
  } finally {
    loadingRewardOverview.value = false
  }
}

const loadManagedGifts = async () => {
  loadingManagedGifts.value = true
  try {
    managedGifts.value = await fetchManagedGifts()
  } catch (e) {
    console.error('加载礼品管理列表失败:', e)
    showNotification('加载礼品列表失败', 'warning')
    managedGifts.value = []
  } finally {
    loadingManagedGifts.value = false
  }
}

const resetGiftForm = () => {
  newGiftForm.title = ''
  newGiftForm.description = ''
  newGiftForm.pointsCost = 120
  newGiftForm.stock = 50
  newGiftForm.deliveryType = 'offline'
  newGiftForm.coverImage = ''
}

const createSystemGift = async () => {
  if (!newGiftForm.title || newGiftForm.pointsCost <= 0 || newGiftForm.stock <= 0) {
    showNotification('请填写完整的礼品信息', 'warning')
    return
  }

  submittingGift.value = true
  try {
    await createGift({ ...newGiftForm })
    showNotification('✓ 礼品已添加并待上架', 'success')
    resetGiftForm()
    loadManagedGifts()
  } catch (e) {
    console.error('创建礼品失败:', e)
    showNotification('添加礼品失败，请检查数据', 'warning')
  } finally {
    submittingGift.value = false
  }
}

const approveGift = async (gift) => {
  try {
    await updateGiftStatus(gift.id, { status: 'active', reviewNote: '管理员审核通过' })
    showNotification(`✓ 已上架「${gift.title}」`, 'success')
    loadManagedGifts()
  } catch (e) {
    console.error('审核礼品失败:', e)
    showNotification('礼品审核失败，请稍后重试', 'warning')
  }
}

const rejectGift = async (gift) => {
  const reason = window.prompt(`请输入驳回 "${gift.title}" 的原因：`, '') || '信息不完整'
  try {
    await updateGiftStatus(gift.id, { status: 'rejected', reviewNote: reason })
    showNotification(`✗ 已驳回「${gift.title}」`, 'warning')
    loadManagedGifts()
  } catch (e) {
    console.error('驳回礼品失败:', e)
    showNotification('驳回操作失败，请稍后再试', 'warning')
  }
}

const loadPointRules = async () => {
  loadingRules.value = true
  try {
    pointRules.value = await fetchPointRules()
  } catch (e) {
    console.error('加载积分规则失败:', e)
    showNotification('获取积分规则失败', 'warning')
    pointRules.value = []
  } finally {
    loadingRules.value = false
  }
}

const editRule = (rule) => {
  ruleForm.activityId = rule.activityId
  ruleForm.actionLabel = rule.actionLabel
  ruleForm.pointsValue = rule.pointsValue
  ruleForm.description = rule.description || ''
  ruleForm.isActive = Boolean(rule.isActive)
}

const submitRule = async () => {
  if (!ruleForm.activityId || !ruleForm.actionLabel || !ruleForm.pointsValue) {
    showNotification('请填写完整规则信息', 'warning')
    return
  }
  savingRule.value = true
  try {
    await savePointRule({ ...ruleForm })
    showNotification('✓ 积分规则已保存', 'success')
    loadPointRules()
  } catch (e) {
    console.error('保存积分规则失败:', e)
    showNotification('保存积分规则失败', 'warning')
  } finally {
    savingRule.value = false
  }
}

const loadAdminOrders = async () => {
  loadingRewardOrders.value = true
  try {
    const params = {}
    if (orderStatusFilter.value && orderStatusFilter.value !== 'all') {
      params.status = orderStatusFilter.value
    }
    const keyword = orderKeyword.value.trim()
    if (keyword) {
      params.keyword = keyword
    }
    rewardOrders.value = await fetchAdminRewardOrders(params)
  } catch (e) {
    console.error('加载兑换订单失败:', e)
    showNotification('获取兑换订单失败', 'warning')
    rewardOrders.value = []
  } finally {
    loadingRewardOrders.value = false
  }
}

const formatOrderTime = (value) => {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return `${date.getMonth() + 1}/${date.getDate()} ${String(date.getHours()).padStart(2, '0')}:${String(
    date.getMinutes()
  ).padStart(2, '0')}`
}

const mapStatus = (status) => {
  const dict = {
    pending: '待处理',
    processing: '处理中',
    shipped: '已发货',
    received: '已完成',
    cancelled: '已取消'
  }
  return dict[status] || status
}

const handleOrderStatus = async (order, status, extra = {}) => {
  try {
    await updateAdminOrderStatus(order.id, { status, ...extra })
    showNotification('订单状态已更新', 'success')
    loadAdminOrders()
  } catch (e) {
    console.error('更新订单状态失败:', e)
    showNotification('更新订单状态失败', 'warning')
  }
}

const markOrderProcessing = (order) => handleOrderStatus(order, 'processing')
const markOrderShipped = (order) => handleOrderStatus(order, 'shipped')
const markOrderCompleted = (order) => handleOrderStatus(order, 'received')
const markOrderCancelled = (order) => {
  const remark = window.prompt('请输入取消原因：', '积分异常') || '管理员取消'
  handleOrderStatus(order, 'cancelled', { refundPoints: true, restockStock: true, adminRemark: remark })
}

const submitAdjustment = async () => {
  const amount = Number.parseInt(adjustmentForm.amount, 10)
  if (!adjustmentForm.userId || !amount) {
    showNotification('请填写用户 ID 和调整积分', 'warning')
    return
  }
  adjustingPoints.value = true
  try {
    await adjustRewardPoints({
      userId: adjustmentForm.userId,
      amount,
      reason: adjustmentForm.reason || '管理员调整'
    })
    showNotification('积分已调整', 'success')
    adjustmentForm.userId = ''
    adjustmentForm.amount = ''
    adjustmentForm.reason = ''
    loadRewardOverview()
  } catch (e) {
    console.error('调整积分失败:', e)
    showNotification('调整积分失败，请稍后再试', 'warning')
  } finally {
    adjustingPoints.value = false
  }
}

// 计算过滤后的用户列表（现在后端已经过滤，这里直接返回）
const filteredUsers = computed(() => {
  return userList.value
})

const pendingGiftApplications = computed(() =>
  managedGifts.value.filter((gift) => gift.status === 'pending')
)

const lowStockGifts = computed(() => rewardOverview.value.lowStock || [])

const selectedMonthLabel = computed(() => {
  if (!selectedMonth.value) return '全部月份'
  const [year, month] = selectedMonth.value.split('-')
  if (!year || !month) return selectedMonth.value
  return `${year} 年 ${month} 月`
})

// 防抖函数，用于搜索
let searchTimer = null
const debouncedLoadUsers = () => {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    loadUsers()
  }, 500)
}

// 系统配置表单
const configForm = ref({
  maxActivityPeople: 500,
  reviewTimeout: 48,
  emailNotification: true,
  maintenanceMode: false
})

// 加载系统配置
const loadSystemConfig = async () => {
  try {
    const data = await fetchSystemConfig()
    if (data) {
      configForm.value = {
        maxActivityPeople: data.maxActivityPeople || 500,
        reviewTimeout: data.reviewTimeout || 48,
        emailNotification: data.emailNotification !== undefined ? data.emailNotification : true,
        maintenanceMode: data.maintenanceMode || false
      }
    }
  } catch (e) {
    console.error('加载系统配置失败:', e)
    // 使用默认值
    configForm.value = {
      maxActivityPeople: 500,
      reviewTimeout: 48,
      emailNotification: true,
      maintenanceMode: false
    }
  }
}

// 保存系统配置
const saveConfig = async () => {
  // 验证表单
  if (configForm.value.maxActivityPeople < 10 || configForm.value.maxActivityPeople > 10000) {
    showNotification('最大活动人数必须在 10-10000 之间', 'warning')
    return
  }
  if (configForm.value.reviewTimeout < 1 || configForm.value.reviewTimeout > 168) {
    showNotification('审核超时时间必须在 1-168 小时之间', 'warning')
    return
  }
  
  try {
    await saveSystemConfigApi(configForm.value)
    showNotification('✓ 系统配置已保存', 'success')
  } catch (e) {
    console.error('保存系统配置失败:', e)
    showNotification('保存系统配置失败: ' + (e.response?.data?.message || e.message || '未知错误'), 'warning')
  }
}

// 数据统计相关
// 获取当前年月（格式：YYYY-MM）
const getCurrentMonth = () => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  return `${year}-${month}`
}

// 选中的月份
const selectedMonth = ref(getCurrentMonth())

// 当前统计数据
const currentStats = ref({
  activities: 0,
  participation: 0,
  rating: '0.0'
})

// 加载统计数据
const loadActivityStats = async (month = null) => {
  try {
    const params = month ? { month } : {}
    const data = await fetchActivityStats(params)
    currentStats.value = {
      activities: data?.activities || 0,
      participation: data?.participation || 0,
      rating: data?.rating || '0.0'
    }
  } catch (e) {
    console.error('加载活动统计失败:', e)
    currentStats.value = {
      activities: 0,
      participation: 0,
      rating: '0.0'
    }
  }
}

// 更新统计数据
const updateStatsData = () => {
  if (selectedMonth.value) {
    loadActivityStats(selectedMonth.value)
    showNotification(`已切换到 ${selectedMonth.value} 的数据`, 'info')
  } else {
    loadActivityStats() // 不传月份参数，获取全部数据
  }
}

// 显示全部数据（统计所有月份的数据）
const showAllData = () => {
  selectedMonth.value = ''
  loadActivityStats() // 不传月份参数，获取全部数据
  showNotification('已显示全部数据统计', 'success')
}

watch(orderStatusFilter, () => {
  if (activeMenu.value === 'rewards') {
    loadAdminOrders()
  }
})

watch(activeMenu, (value) => {
  if (value === 'rewards' && !rewardPanelInitialized.value) {
    rewardPanelInitialized.value = true
    refreshRewardPanel()
  }
})

</script>

<style scoped>
.admin-layout {
  display: flex;
  gap: 24px;
  min-height: 100vh;
  background: linear-gradient(150deg, #eefcf6 0%, #e6f0ff 45%, #fff3fb 100%);
  padding: 32px clamp(16px, 4vw, 48px) 60px;
  position: relative;
  overflow: hidden;
  align-items: flex-start;
}

.admin-layout::before,
.admin-layout::after {
  content: '';
  position: absolute;
  width: clamp(240px, 30vw, 420px);
  height: clamp(240px, 30vw, 420px);
  background: radial-gradient(circle, rgba(255, 255, 255, 0.75), transparent 65%);
  border-radius: 40% 60% 50% 70% / 60% 40% 60% 40%;
  z-index: 0;
}

.admin-layout::before {
  top: -140px;
  left: -80px;
}

.admin-layout::after {
  bottom: -160px;
  right: -120px;
}

.admin-layout > * {
  position: relative;
  z-index: 1;
}

.sidebar {
  width: 240px;
  flex-shrink: 0;
  background: rgba(255, 255, 255, 0.92);
  border-radius: 30px;
  padding: 32px 24px;
  border: 1px solid rgba(255, 255, 255, 0.4);
  box-shadow: 0 25px 60px rgba(53, 119, 103, 0.15);
  backdrop-filter: blur(18px);
  position: sticky;
  top: 0;
  align-self: flex-start;
  height: fit-content;
  max-height: calc(100vh - 64px);
  overflow-y: auto;
}

.sidebar::-webkit-scrollbar {
  width: 4px;
}

.sidebar::-webkit-scrollbar-thumb {
  background: rgba(93, 108, 226, 0.35);
  border-radius: 999px;
}

.sidebar__title {
  font-size: 22px;
  font-weight: 700;
  color: #5d6ce2;
  margin-bottom: 24px;
}

.sidebar__menu {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.sidebar__item {
  padding: 14px 16px;
  border-radius: 16px;
  color: #4f5978;
  text-decoration: none;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid transparent;
}

.sidebar__item:hover {
  border-color: rgba(93, 108, 226, 0.25);
  box-shadow: 0 8px 20px rgba(93, 108, 226, 0.15);
}

.sidebar__item.active {
  background: linear-gradient(120deg, #5d6ce2, #6fe2c5);
  color: #fff;
  box-shadow: 0 15px 35px rgba(96, 131, 244, 0.35);
}

.admin-content {
  flex: 1;
  background: rgba(255, 255, 255, 0.92);
  border-radius: 34px;
  padding: 32px;
  box-shadow: 0 30px 70px rgba(40, 86, 120, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.45);
  backdrop-filter: blur(18px);
}

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
}

.admin-header h1 {
  margin: 0;
  font-size: 32px;
  font-family: var(--font-display);
  color: #142c46;
}

.admin-header p {
  margin: 6px 0 0;
  color: rgba(20, 44, 70, 0.65);
}

.admin-user {
  display: flex;
  gap: 16px;
  align-items: center;
}

.avatar {
  padding: 10px 18px;
  border-radius: 999px;
  background: linear-gradient(120deg, #6fe2c5, #7aa8ff);
  color: #fff;
  font-weight: 600;
  box-shadow: 0 18px 35px rgba(88, 164, 192, 0.35);
}

.admin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
}

.admin-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 26px;
  padding: 22px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 20px 45px rgba(48, 81, 120, 0.14);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.admin-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 28px 55px rgba(48, 81, 120, 0.22);
}

.admin-card__value {
  font-size: 34px;
  font-weight: 800;
  margin: 14px 0 6px;
  color: #142c46;
}

.admin-card__desc {
  color: rgba(20, 44, 70, 0.55);
  font-size: 14px;
}

.admin-card .status {
  display: inline-flex;
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 600;
}

.status.good {
  background: rgba(123, 235, 195, 0.3);
  color: #0f7c56;
}

.admin-panels {
  margin-top: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.review-container {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}

.panel {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 26px;
  padding: 24px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 20px 45px rgba(33, 64, 110, 0.12);
  transition: transform 0.2s ease;
}

.panel:hover {
  transform: translateY(-4px);
}

.panel header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
}

.panel header button {
  border: none;
  background: rgba(111, 226, 197, 0.2);
  color: #17906e;
  padding: 6px 18px;
  border-radius: 999px;
  cursor: pointer;
  font-weight: 600;
  transition: transform 0.2s ease;
}

.panel header button:hover {
  transform: translateY(-2px);
}

.panel-actions {
  display: flex;
  gap: 10px;
}

.ghost-link {
  border: none;
  background: none;
  color: #0f7c56;
  font-weight: 600;
  cursor: pointer;
}

.rewards-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.rewards-panel > .reward-board,
.rewards-panel > .sub-panel.full-width {
  margin-top: 4px;
}

.reward-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.metric-block {
  background: rgba(239, 250, 255, 0.85);
  border-radius: 20px;
  padding: 16px;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.metric-block strong {
  font-size: 28px;
  color: #173450;
}

.reward-board {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 18px;
}

.sub-panel {
  background: rgba(248, 251, 255, 0.92);
  border-radius: 22px;
  padding: 18px;
  border: 1px solid rgba(255, 255, 255, 0.7);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.4);
}

.sub-panel.full-width {
  width: 100%;
}

.reward-list,
.low-stock-list,
.rule-list {
  list-style: none;
  margin: 16px 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reward-list li,
.low-stock-list li,
.rule-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(15, 42, 66, 0.05);
}

.reward-actions,
.order-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.btn-mini {
  border: none;
  border-radius: 999px;
  padding: 6px 14px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
}

.btn-mini.approve {
  background: rgba(111, 226, 197, 0.8);
  color: #0f5d4c;
}

.btn-mini.reject {
  background: rgba(255, 203, 196, 0.85);
  color: #8a331e;
}

.low-stock-list li h4,
.reward-list li h4,
.rule-row h4,
.order-row h4 {
  margin: 0 0 4px;
}

.badge {
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  background: rgba(111, 226, 197, 0.25);
  color: #10755a;
}

.badge.warning {
  background: rgba(255, 203, 196, 0.55);
  color: #8a331e;
}

.badge.success {
  background: rgba(120, 206, 255, 0.35);
  color: #0f2a42;
}

.stack-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stack-form label,
.stack-form textarea,
.stack-form input,
.stack-form select {
  font-size: 14px;
}

.stack-form input,
.stack-form textarea,
.stack-form select {
  border: 1px solid rgba(15, 42, 66, 0.15);
  border-radius: 12px;
  padding: 10px 12px;
  width: 100%;
  background: #fff;
}

.inline-inputs {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 10px;
}

.checkbox-inline {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: rgba(15, 42, 66, 0.7);
}

.order-table {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 16px;
}

.order-row {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 16px;
  border-radius: 16px;
  border: 1px solid rgba(15, 42, 66, 0.08);
  background: rgba(255, 255, 255, 0.92);
  flex-wrap: wrap;
}

.order-controls {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: flex-end;
}

.status-pill {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  background: rgba(15, 42, 66, 0.08);
  color: #0f2a42;
}

.status-pill.status-pending {
  background: rgba(255, 214, 130, 0.4);
  color: #a86200;
}

.status-pill.status-processing {
  background: rgba(255, 235, 168, 0.6);
  color: #a06a00;
}

.status-pill.status-shipped {
  background: rgba(154, 209, 255, 0.5);
  color: #0f4c81;
}

.status-pill.status-received {
  background: rgba(130, 236, 184, 0.6);
  color: #0f7c56;
}

.status-pill.status-cancelled {
  background: rgba(255, 181, 181, 0.55);
  color: #8a1f1f;
}

.order-filters {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}

.order-filters select,
.order-filters input {
  border-radius: 999px;
  border: 1px solid rgba(15, 42, 66, 0.15);
  padding: 8px 14px;
  background: rgba(255, 255, 255, 0.95);
}

.loading-block {
  width: 100%;
  padding: 40px 0;
  text-align: center;
  color: rgba(15, 42, 66, 0.65);
}

.loading.small {
  padding: 10px 0;
  text-align: center;
  color: rgba(15, 42, 66, 0.6);
}

.panel ul {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.panel li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-radius: 18px;
  background: rgba(235, 244, 255, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.6);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  gap: 16px;
}

.panel li:hover {
  transform: translateX(6px);
  box-shadow: 0 12px 30px rgba(70, 117, 170, 0.18);
}

.panel li h3 {
  margin: 0 0 6px;
}

.panel li p {
  color: rgba(15, 42, 66, 0.6);
  font-size: 13px;
}

.review-actions {
  display: flex;
  gap: 10px;
}

.btn {
  padding: 8px 14px;
  border: none;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  white-space: nowrap;
}

.btn-approve {
  background: linear-gradient(120deg, #8af3c9, #66d7b6);
  color: #0f5d4c;
  box-shadow: 0 10px 20px rgba(50, 160, 130, 0.22);
}

.btn-reject {
  background: linear-gradient(120deg, #ffd8d4, #ffc0b5);
  color: #a23a30;
  box-shadow: 0 10px 20px rgba(210, 92, 80, 0.18);
}

.btn:hover {
  transform: translateY(-2px);
}

.user-summary {
  display: flex;
  justify-content: space-between;
  text-align: center;
  gap: 12px;
}

.user-summary .value {
  font-size: 26px;
  font-weight: 700;
  color: #173450;
}

.user-summary .label {
  color: rgba(23, 52, 80, 0.65);
  margin-top: 4px;
}

.user-management {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.user-stat {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.stat-box {
  background: rgba(239, 250, 255, 0.8);
  border-radius: 20px;
  padding: 18px;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.stat-value {
  font-size: 26px;
  font-weight: 700;
  color: #5d6ce2;
}

.stat-label {
  color: rgba(20, 44, 70, 0.6);
  font-size: 13px;
  margin-top: 4px;
}

.user-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-list li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 10px 22px rgba(43, 72, 104, 0.1);
  transition: transform 0.2s ease;
}

.user-list li:hover {
  transform: translateX(6px);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(140deg, #6fe2c5, #7aa8ff);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
}

.user-meta {
  color: rgba(15, 42, 66, 0.6);
  font-size: 12px;
}

.user-filters {
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding: 16px;
  background: rgba(239, 250, 255, 0.8);
  border-radius: 18px;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.filter-row {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.search-input {
  flex: 1;
  padding: 12px 14px 12px 40px;
  border: 1px solid rgba(111, 226, 197, 0.4);
  border-radius: 999px;
  font-size: 14px;
  outline: none;
  background: rgba(255, 255, 255, 0.95);
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%230f2a42" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path></svg>');
  background-repeat: no-repeat;
  background-position: 14px center;
  background-size: 18px;
  transition: box-shadow 0.2s ease;
}

.search-input:focus {
  box-shadow: 0 0 0 3px rgba(111, 226, 197, 0.35);
}

.role-select {
  padding: 12px 18px;
  border-radius: 999px;
  border: 1px solid rgba(111, 226, 197, 0.4);
  background: rgba(255, 255, 255, 0.95);
  min-width: 150px;
}

.filter-result {
  font-size: 13px;
  color: rgba(15, 42, 66, 0.65);
  padding: 10px 14px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.9);
  border-left: 4px solid #6fe2c5;
}

.config-panel {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.config-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-radius: 18px;
  background: rgba(239, 250, 255, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.config-item input[type='number'] {
  padding: 10px 16px;
  border-radius: 999px;
  border: 1px solid rgba(111, 226, 197, 0.4);
  background: rgba(255, 255, 255, 0.95);
}

.btn-save,
.btn-export,
.btn-show-all {
  border: none;
  border-radius: 999px;
  padding: 10px 20px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease;
  color: #fff;
}

.btn-save,
.btn-export {
  background: linear-gradient(120deg, #5d6ce2, #7aa8ff);
  box-shadow: 0 12px 26px rgba(96, 131, 244, 0.35);
}

.btn-show-all {
  background: linear-gradient(120deg, #0d7ea1, #15b6c0);
  box-shadow: 0 12px 26px rgba(21, 146, 160, 0.35);
}

.btn-save:hover,
.btn-export:hover,
.btn-show-all:hover {
  transform: translateY(-2px);
}

.stats-date-picker {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  padding: 18px 24px;
  border-radius: 24px;
  background: rgba(239, 250, 255, 0.9);
  border: 1px solid rgba(255, 255, 255, 0.6);
  margin-bottom: 24px;
}

.month-control {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 18px;
  border-radius: 999px;
  background: #fff;
  border: 1px solid rgba(93, 108, 226, 0.25);
  box-shadow: 0 12px 28px rgba(20, 44, 70, 0.08);
}

.month-info {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
  cursor: pointer;
}

.month-info .label-text {
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: rgba(20, 44, 70, 0.55);
}

.month-info .label-value {
  font-size: 18px;
  color: #142c46;
}

.month-input {
  border: none;
  background: transparent;
  font-weight: 600;
  color: #142c46;
  font-size: 15px;
  min-width: 140px;
  cursor: pointer;
}

.month-input:focus {
  outline: none;
}

.month-input::-webkit-calendar-picker-indicator {
  cursor: pointer;
  filter: invert(40%) sepia(12%) saturate(900%) hue-rotate(185deg) brightness(95%) contrast(90%);
}

.stats-panel {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
  margin-top: 24px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 22px;
  padding: 18px;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 18px 40px rgba(20, 44, 70, 0.08);
}

.stat-card h4 {
  margin: 0 0 10px;
  color: rgba(20, 44, 70, 0.65);
}

.stat-numbers .number {
  font-size: 30px;
  font-weight: 700;
  color: #5d6ce2;
}

.stat-numbers p {
  margin: 6px 0 0;
  color: rgba(20, 44, 70, 0.5);
}

:global(.notification) {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 14px 20px;
  border-radius: 16px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 18px 30px rgba(0, 0, 0, 0.14);
  z-index: 9999;
  animation: slideInRight 0.3s ease-out;
}

:global(.notification-success) {
  background: rgba(138, 243, 201, 0.95);
  color: #064839;
}

:global(.notification-warning) {
  background: rgba(255, 217, 205, 0.95);
  color: #8a331e;
}

:global(.notification-info) {
  background: rgba(223, 232, 255, 0.95);
  color: #2f4d9b;
}

@keyframes slideInRight {
  from {
    transform: translateX(120px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOutRight {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(120px);
    opacity: 0;
  }
}

@media (max-width: 1200px) {
  .admin-layout {
    flex-direction: column;
    padding: 24px 16px 48px;
  }

  .sidebar {
    width: 100%;
    flex-direction: row;
  }

  .review-container {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .admin-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .sidebar {
    padding: 24px;
  }
}
</style>

