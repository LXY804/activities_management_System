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
          :class="{ active: activeMenu === 'users' }"
          @click.prevent="switchToUsers"
        >用户管理</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'forum' }"
          @click="activeMenu = 'forum'"
        >论坛管理</a>
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
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'news' }"
          @click="activeMenu = 'news'"
        >发布资讯</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'announcements' }"
          @click="activeMenu = 'announcements'"
        >系统公告</a>
        <a 
          class="sidebar__item"
          :class="{ active: activeMenu === 'gifts' }"
          @click="activeMenu = 'gifts'"
        >积分礼品</a>
      </nav>
    </aside>

    <main class="admin-content">
      <header class="admin-header" v-if="activeMenu !== 'announcements' && activeMenu !== 'gifts' && activeMenu !== 'news'">
        <div>
          <h1>管理后台</h1>
          <p>系统审核、用户管理与平台统计</p>
        </div>
        <div class="admin-user">
          <div class="avatar">管理员</div>
        </div>
      </header>

      <section class="admin-grid" v-if="activeMenu !== 'announcements' && activeMenu !== 'gifts' && activeMenu !== 'news'">
        <article class="admin-card">
          <h3>待审核活动</h3>
          <p class="admin-card__value">{{ reviewList.length }}</p>
        </article>
        <article class="admin-card">
          <h3>待审核帖子</h3>
          <p class="admin-card__value">{{ pendingPostsCount }}</p>
        </article>
        <article class="admin-card">
          <h3>待审核公告</h3>
          <p class="admin-card__value">{{ pendingAnnouncementsCount }}</p>
        </article>
        <article class="admin-card">
          <h3>新增用户</h3>
          <p class="admin-card__value">{{ newUsersThisMonth.count }}</p>
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
          <header class="panel-header-actions">
            <h2>用户管理</h2>
            <div class="header-actions">
              <button>导出用户数据</button>
              <button class="secondary-btn" @click="onBackup" :disabled="backingUp">
                {{ backingUp ? '备份中...' : '手动备份数据库' }}
              </button>
            </div>
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
                  <button class="danger-btn" @click="onDeleteUser(user)" :disabled="deletingUserId === user.id">
                    {{ deletingUserId === user.id ? '删除中...' : '删除' }}
                  </button>
                </div>
              </li>
              <li v-if="!loadingUsers && filteredUsers.length === 0" class="no-result">
                <p>没有找到匹配的用户</p>
              </li>
            </ul>
          </div>
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
            <label>选择月份：</label>
            <input 
              v-model="selectedMonth" 
              type="month"
              @change="updateStatsData"
              class="month-input"
            />
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

        <!-- 发布资讯面板 -->
        <div v-if="activeMenu === 'news'" class="news-container">
          <article class="panel">
            <header>
              <h2>发布资讯</h2>
            </header>
            <div class="news-form">
              <input 
                v-model="newsForm.title" 
                type="text" 
                placeholder="请输入资讯标题" 
                class="form-input"
              />
              <textarea 
                v-model="newsForm.content" 
                placeholder="请输入资讯内容" 
                class="form-textarea"
              ></textarea>
              <div class="form-actions">
                <button class="btn btn-primary" @click="handleCreateNews">发布资讯</button>
              </div>
            </div>
          </article>

          <article class="panel">
            <header>
              <h2>已发布资讯列表</h2>
            </header>
            <div v-if="newsList.length" class="news-list">
              <div v-for="item in newsList" :key="item.id" class="news-item">
                <div>
                  <h3>{{ item.title }}</h3>
                  <p class="news-meta">{{ formatTime(item.created_at) }}</p>
                  <p class="news-content">{{ item.content }}</p>
                </div>
                <div class="news-actions">
                  <button class="btn btn-edit" @click="handleEditNews(item)">编辑</button>
                  <button class="btn btn-delete" @click="handleDeleteNews(item.id)">删除</button>
                </div>
              </div>
            </div>
            <p v-else class="empty-text">暂无资讯</p>
          </article>
        </div>

        <!-- 系统公告管理面板 -->
        <div v-if="activeMenu === 'announcements'" class="announcement-container">
          <article class="panel">
            <header>
              <h2>发布系统公告</h2>
            </header>
            <div class="announcement-form">
              <input 
                v-model="announcementForm.title" 
                type="text" 
                placeholder="请输入公告标题" 
                class="form-input"
              />
              <textarea 
                v-model="announcementForm.content" 
                placeholder="请输入公告内容" 
                class="form-textarea"
              ></textarea>
              <button class="btn btn-primary" @click="handleCreateAnnouncement">发布公告</button>
            </div>
          </article>

          <article class="panel">
            <header>
              <h2>待审核公告</h2>
              <p class="panel-desc">仅显示组织者申请的公告，管理员发布的公告无需审核</p>
            </header>
            <ul v-if="pendingAnnouncements.length">
              <li v-for="item in pendingAnnouncements" :key="item.id">
                <div>
                  <h3>{{ item.title }}</h3>
                  <p>{{ item.publisher_name }} · {{ formatTime(item.created_at) }}</p>
                  <p class="announcement-content">{{ item.content }}</p>
                </div>
                <div class="review-actions">
                  <button 
                    class="btn btn-approve" 
                    @click="handleApproveAnnouncement(item.id)"
                  >✓ 通过</button>
                  <button 
                    class="btn btn-reject" 
                    @click="handleRejectAnnouncement(item.id)"
                  >✗ 驳回</button>
                </div>
              </li>
            </ul>
            <p v-else class="empty-text">暂无待审核公告</p>
          </article>

          <article class="panel">
            <header>
              <h2>公告确认统计</h2>
            </header>
            <table class="stats-table">
              <thead>
                <tr>
                  <th>公告标题</th>
                  <th>发布者</th>
                  <th>发布时间</th>
                  <th>确认数</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in announcementStats" :key="item.id">
                  <td>{{ item.title }}</td>
                  <td>{{ item.publisher_name }}</td>
                  <td>{{ formatTime(item.published_at) }}</td>
                  <td>{{ item.confirmation_count }}</td>
                </tr>
              </tbody>
            </table>
            <p v-if="!announcementStats.length" class="empty-text">暂无公告数据</p>
          </article>
        </div>

        <!-- 积分礼品管理面板 -->
        <div v-if="activeMenu === 'gifts'" class="gifts-container">
          <article class="panel">
            <header class="panel-header-with-btn">
              <h2>礼品列表</h2>
              <button class="btn btn-primary" @click="showGiftForm = true">新增礼品</button>
            </header>
            <div v-if="giftsList.length" class="gifts-list">
              <div v-for="item in giftsList" :key="item.id" class="gift-item">
                <div class="gift-image" v-if="item.image_url">
                  <img :src="buildImageUrl(item.image_url)" alt="礼品图片" />
                </div>
                <div class="gift-info">
                  <h3>{{ item.name }}</h3>
                  <p class="gift-desc">{{ item.description || '暂无描述' }}</p>
                  <div class="gift-meta">
                    <span>所需积分：{{ item.points_required }}</span>
                    <span>库存：{{ item.stock }}</span>
                  </div>
                </div>
                <div class="gift-actions">
                  <button class="btn btn-add-stock" @click="handleAddStock(item)">增加库存</button>
                  <button class="btn btn-delete" @click="handleDeleteGift(item.id)">删除</button>
                </div>
              </div>
            </div>
            <p v-else class="empty-text">暂无礼品</p>
          </article>
        </div>

        <!-- 新增礼品弹窗 -->
        <div v-if="showGiftForm" class="modal-overlay" @click="closeGiftForm">
          <div class="modal-content" @click.stop>
            <div class="modal-header">
              <h2>新增礼品</h2>
              <button class="modal-close" @click="closeGiftForm">×</button>
            </div>
            <div class="modal-body">
              <div class="gift-form">
                <div class="form-group">
                  <label>礼品名称 <span>*</span></label>
                  <input 
                    v-model="giftForm.name" 
                    type="text" 
                    placeholder="请输入礼品名称" 
                    class="form-input"
                  />
                </div>
                <div class="form-group">
                  <label>礼品描述</label>
                  <textarea 
                    v-model="giftForm.description" 
                    placeholder="请输入礼品描述" 
                    class="form-textarea"
                  ></textarea>
                </div>
                <div class="form-row">
                  <div class="form-group">
                    <label>所需积分 <span>*</span></label>
                    <input 
                      v-model.number="giftForm.points_required" 
                      type="number" 
                      placeholder="请输入所需积分" 
                      class="form-input"
                      min="1"
                    />
                  </div>
                  <div class="form-group">
                    <label>库存数量 <span>*</span></label>
                    <input 
                      v-model.number="giftForm.stock" 
                      type="number" 
                      placeholder="请输入库存数量" 
                      class="form-input"
                      min="0"
                    />
                  </div>
                </div>
                <div class="form-group">
                  <label>礼品图片</label>
                  <input 
                    type="file" 
                    accept="image/*" 
                    @change="handleGiftImageChange"
                    class="file-input"
                  />
                  <div v-if="giftImagePreview" class="image-preview">
                    <img :src="giftImagePreview" alt="预览" />
                  </div>
                </div>
                <div class="form-actions">
                  <button class="btn btn-secondary" @click="closeGiftForm">取消</button>
                  <button class="btn btn-primary" @click="handleCreateGift">确认新增</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 增加库存弹窗 -->
        <div v-if="showAddStockModal" class="modal-overlay" @click="closeAddStockModal">
          <div class="modal-content modal-small" @click.stop>
            <div class="modal-header">
              <h2>增加库存</h2>
              <button class="modal-close" @click="closeAddStockModal">×</button>
            </div>
            <div class="modal-body">
              <div class="form-group">
                <label>礼品名称</label>
                <input 
                  :value="currentGift?.name" 
                  type="text" 
                  class="form-input"
                  disabled
                />
              </div>
              <div class="form-group">
                <label>当前库存</label>
                <input 
                  :value="currentGift?.stock" 
                  type="number" 
                  class="form-input"
                  disabled
                />
              </div>
              <div class="form-group">
                <label>增加数量 <span>*</span></label>
                <input 
                  v-model.number="addStockAmount" 
                  type="number" 
                  placeholder="请输入要增加的数量" 
                  class="form-input"
                  min="1"
                />
              </div>
              <div class="form-actions">
                <button class="btn btn-secondary" @click="closeAddStockModal">取消</button>
                <button class="btn btn-primary" @click="handleConfirmAddStock">确认增加</button>
              </div>
            </div>
          </div>
        </div>

        <!-- 论坛管理面板 -->
        <div v-if="activeMenu === 'forum'" class="forum-management-container">
          <article class="panel">
            <header>
              <h2>待审核帖子</h2>
            </header>
            <ul v-if="pendingPosts.length">
              <li v-for="item in pendingPosts" :key="item.id">
                <div>
                  <h3>{{ item.title }}</h3>
                  <p>{{ item.author }} · {{ formatTime(item.created_at) }}</p>
                  <p class="post-content">{{ item.content }}</p>
                  <div v-if="item.image_url" class="post-image-preview">
                    <img :src="buildImageUrl(item.image_url)" alt="帖子图片" />
                  </div>
                </div>
                <div class="review-actions">
                  <button 
                    class="btn btn-approve" 
                    @click="handleApprovePost(item.id)"
                  >✓ 通过</button>
                  <button 
                    class="btn btn-reject" 
                    @click="handleRejectPost(item.id)"
                  >✗ 驳回</button>
                </div>
              </li>
            </ul>
            <p v-else class="empty-text">暂无待审核帖子</p>
          </article>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import NavBar from '../components/NavBar.vue'
import { fetchPendingEvents, approveEvent, rejectEvent } from '@/api/event'
import { 
  fetchUserList, 
  fetchUserStats, 
  fetchNewUsersThisMonth,
  fetchSystemConfig,
  saveSystemConfig as saveSystemConfigApi,
  fetchActivityStats,
  deleteUser as fetchDeleteUser
} from '@/api/user'
import { manualBackup } from '@/api/admin'
import {
  createAnnouncement,
  fetchPendingAnnouncements,
  approveAnnouncement,
  rejectAnnouncement,
  fetchAdminConfirmationStats
} from '@/api/announcement'
import {
  fetchPendingPosts,
  approvePost,
  rejectPost
} from '@/api/forum'
import {
  createNews,
  fetchAllNews,
  updateNews,
  deleteNews
} from '@/api/news'
import {
  createGift,
  fetchAllGifts,
  updateGift,
  deleteGift
} from '@/api/gift'

// 当前活动菜单
const activeMenu = ref('review')

// 公告相关
const announcementForm = ref({
  title: '',
  content: ''
})
const pendingAnnouncements = ref([])
const announcementStats = ref([])

// 论坛管理相关
const pendingPosts = ref([])
const pendingPostsCount = ref(0)
const pendingAnnouncementsCount = ref(0)

// 资讯管理相关
const newsForm = ref({
  title: '',
  content: ''
})
const newsList = ref([])

// 积分礼品管理相关
const giftForm = ref({
  name: '',
  description: '',
  points_required: 0,
  stock: 0
})
const giftImageFile = ref(null)
const giftImagePreview = ref(null)
const giftsList = ref([])
const showGiftForm = ref(false)
const showAddStockModal = ref(false)
const currentGift = ref(null)
const addStockAmount = ref(0)

const API_ORIGIN = (
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api'
).replace(/\/api\/?$/, '')

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

// 审核队列（从后端获取）
const reviewList = ref([])

// 概览统计数据
const newUsersThisMonth = ref({
  count: 0,
  growthRate: 0
})

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
  loadPendingPosts() // 加载待审核帖子数量
  loadPendingAnnouncements() // 加载待审核公告数量
  // 如果初始菜单是用户管理，则加载数据
  if (activeMenu.value === 'users') {
    loadUsers()
  }
})

// 通过审核
const approveActivity = async (index) => {
  const activity = reviewList.value[index]
  try {
    await approveEvent(activity.creationId)
    reviewList.value.splice(index, 1)
    showNotification(`✓ 已通过 "${activity.name}" 的审核`, 'success')
    // 重新加载待审核活动列表以更新计数
    loadPendingEvents()
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
    // 重新加载待审核活动列表以更新计数
    loadPendingEvents()
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
const backingUp = ref(false)

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

// 计算过滤后的用户列表（现在后端已经过滤，这里直接返回）
const deletingUserId = ref(null)

const filteredUsers = computed(() => {
  return userList.value
})

const onDeleteUser = async (user) => {
  if (!user?.id) {
    showNotification('用户 ID 缺失，无法删除', 'warning')
    return
  }
  if (!confirm(`确认删除用户「${user.name}」吗？该操作不可恢复。`)) return
  deletingUserId.value = user.id
  try {
    await fetchDeleteUser(user.id)
    showNotification('删除成功', 'success')
    userList.value = userList.value.filter(u => u.id !== user.id)
    loadUserStats()
  } catch (e) {
    console.error('删除用户失败:', e)
    const msg = e.response?.data?.message || e.message || '删除失败'
    showNotification(msg, 'error')
  } finally {
    deletingUserId.value = null
  }
}

const onBackup = async () => {
  if (!confirm('确认手动备份数据库吗？可能需要几秒钟时间。')) return
  backingUp.value = true
  try {
    const res = await manualBackup()
    const file = res?.file || res?.data?.file
    showNotification(file ? `备份成功：${file}` : '备份成功', 'success')
  } catch (e) {
    console.error('备份失败:', e)
    const msg = e.response?.data?.message || e.message || '备份失败'
    showNotification(msg, 'error')
  } finally {
    backingUp.value = false
  }
}

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

// 公告管理功能
const loadPendingAnnouncements = async () => {
  try {
    const list = await fetchPendingAnnouncements()
    pendingAnnouncements.value = list || []
    pendingAnnouncementsCount.value = list?.length || 0
  } catch (err) {
    console.error('获取待审核公告失败:', err)
    showNotification('获取待审核公告失败', 'error')
    pendingAnnouncementsCount.value = 0
  }
}

const loadAnnouncementStats = async () => {
  try {
    const list = await fetchAdminConfirmationStats()
    announcementStats.value = list
  } catch (err) {
    console.error('获取公告统计失败:', err)
  }
}

const handleCreateAnnouncement = async () => {
  if (!announcementForm.value.title || !announcementForm.value.content) {
    showNotification('请填写标题和内容', 'warning')
    return
  }
  try {
    await createAnnouncement(announcementForm.value)
    showNotification('公告发布成功', 'success')
    announcementForm.value = { title: '', content: '' }
    loadAnnouncementStats()
  } catch (err) {
    showNotification(err?.message || '发布失败', 'error')
  }
}

const handleApproveAnnouncement = async (id) => {
  try {
    await approveAnnouncement(id)
    showNotification('审核通过', 'success')
    loadPendingAnnouncements()
    loadAnnouncementStats()
    // 更新统计数据
    pendingAnnouncementsCount.value = Math.max(0, pendingAnnouncementsCount.value - 1)
  } catch (err) {
    showNotification(err?.message || '操作失败', 'error')
  }
}

const handleRejectAnnouncement = async (id) => {
  const remark = prompt('请输入驳回原因（可选）')
  try {
    await rejectAnnouncement(id, remark)
    showNotification('已驳回', 'success')
    loadPendingAnnouncements()
    // 更新统计数据
    pendingAnnouncementsCount.value = Math.max(0, pendingAnnouncementsCount.value - 1)
  } catch (err) {
    showNotification(err?.message || '操作失败', 'error')
  }
}

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 论坛管理功能
const loadPendingPosts = async () => {
  try {
    const list = await fetchPendingPosts()
    pendingPosts.value = list || []
    pendingPostsCount.value = list?.length || 0
  } catch (err) {
    console.error('获取待审核帖子失败:', err)
    pendingPostsCount.value = 0
    showNotification('获取待审核帖子失败', 'error')
  }
}

const handleApprovePost = async (id) => {
  try {
    await approvePost(id)
    showNotification('审核通过', 'success')
    loadPendingPosts()
    // 更新统计数据
    pendingPostsCount.value = Math.max(0, pendingPostsCount.value - 1)
  } catch (err) {
    showNotification(err?.message || '操作失败', 'error')
  }
}

const handleRejectPost = async (id) => {
  const remark = prompt('请输入驳回原因（可选）')
  try {
    await rejectPost(id, remark)
    showNotification('已驳回', 'success')
    loadPendingPosts()
    // 更新统计数据
    pendingPostsCount.value = Math.max(0, pendingPostsCount.value - 1)
  } catch (err) {
    showNotification(err?.message || '操作失败', 'error')
  }
}

// 资讯管理功能
const loadNewsList = async () => {
  try {
    const data = await fetchAllNews()
    newsList.value = data?.list || []
  } catch (err) {
    console.error('加载资讯列表失败:', err)
    showNotification('加载资讯列表失败', 'error')
  }
}

const handleCreateNews = async () => {
  if (!newsForm.value.title || !newsForm.value.content) {
    showNotification('请填写标题和内容', 'warning')
    return
  }
  try {
    await createNews(newsForm.value)
    showNotification('资讯发布成功', 'success')
    newsForm.value = { title: '', content: '' }
    loadNewsList()
  } catch (err) {
    showNotification(err?.message || '发布失败', 'error')
  }
}

const handleEditNews = async (item) => {
  const newTitle = prompt('请输入新标题', item.title)
  if (!newTitle) return
  
  const newContent = prompt('请输入新内容', item.content)
  if (!newContent) return

  try {
    await updateNews(item.id, {
      title: newTitle,
      content: newContent
    })
    showNotification('更新成功', 'success')
    loadNewsList()
  } catch (err) {
    showNotification(err?.message || '更新失败', 'error')
  }
}

const handleDeleteNews = async (id) => {
  if (!confirm('确认删除此资讯吗？')) return
  try {
    await deleteNews(id)
    showNotification('删除成功', 'success')
    loadNewsList()
  } catch (err) {
    showNotification(err?.message || '删除失败', 'error')
  }
}

// 积分礼品管理功能
const loadGiftsList = async () => {
  try {
    const list = await fetchAllGifts()
    giftsList.value = list || []
  } catch (err) {
    console.error('加载礼品列表失败:', err)
    showNotification('加载礼品列表失败', 'error')
  }
}

const handleGiftImageChange = (event) => {
  const file = event.target.files?.[0]
  if (file) {
    giftImageFile.value = file
    if (giftImagePreview.value) {
      URL.revokeObjectURL(giftImagePreview.value)
    }
    giftImagePreview.value = URL.createObjectURL(file)
  }
}

const closeGiftForm = () => {
  showGiftForm.value = false
  giftForm.value = {
    name: '',
    description: '',
    points_required: 0,
    stock: 0
  }
  giftImageFile.value = null
  if (giftImagePreview.value) {
    URL.revokeObjectURL(giftImagePreview.value)
    giftImagePreview.value = null
  }
}

const handleCreateGift = async () => {
  if (!giftForm.value.name || !giftForm.value.points_required || giftForm.value.stock === undefined) {
    showNotification('请填写礼品名称、所需积分和库存数量', 'warning')
    return
  }

  if (giftForm.value.points_required <= 0) {
    showNotification('所需积分必须大于0', 'warning')
    return
  }

  if (giftForm.value.stock < 0) {
    showNotification('库存数量不能为负数', 'warning')
    return
  }

  try {
    await createGift({
      ...giftForm.value,
      image: giftImageFile.value
    })
    showNotification('礼品创建成功', 'success')
    closeGiftForm()
    loadGiftsList()
  } catch (err) {
    showNotification(err?.message || '创建失败', 'error')
  }
}

const handleAddStock = (item) => {
  currentGift.value = item
  addStockAmount.value = 0
  showAddStockModal.value = true
}

const closeAddStockModal = () => {
  showAddStockModal.value = false
  currentGift.value = null
  addStockAmount.value = 0
}

const handleConfirmAddStock = async () => {
  if (!addStockAmount.value || addStockAmount.value <= 0) {
    showNotification('请输入有效的增加数量', 'warning')
    return
  }

  if (!currentGift.value) {
    return
  }

  try {
    const newStock = currentGift.value.stock + addStockAmount.value
    await updateGift(currentGift.value.id, {
      name: currentGift.value.name,
      description: currentGift.value.description || '',
      points_required: currentGift.value.points_required,
      stock: newStock
    })
    showNotification('库存增加成功', 'success')
    closeAddStockModal()
    loadGiftsList()
  } catch (err) {
    showNotification(err?.message || '增加库存失败', 'error')
  }
}

const handleDeleteGift = async (id) => {
  if (!confirm('确认删除此礼品吗？')) return
  try {
    await deleteGift(id)
    showNotification('删除成功', 'success')
    loadGiftsList()
  } catch (err) {
    showNotification(err?.message || '删除失败', 'error')
  }
}

// 监听菜单切换，加载对应数据
watch(() => activeMenu.value, (newMenu) => {
  if (newMenu === 'announcements') {
    loadPendingAnnouncements()
    loadAnnouncementStats()
  } else if (newMenu === 'forum') {
    loadPendingPosts()
  } else if (newMenu === 'news') {
    loadNewsList()
  } else if (newMenu === 'gifts') {
    loadGiftsList()
  }
})

</script>

<style scoped>
.admin-layout{
  display:flex;
  min-height:100vh;
  background:#f7f7fb;
  color:#2c2c2c;
}
.sidebar{
  width:220px;
  background:#fff;
  box-shadow:5px 0 20px rgba(0,0,0,.05);
  padding:30px 18px;
}
.sidebar__title{
  font-size:22px;
  font-weight:700;
  color:#6a5cf8;
  margin-bottom:24px;
}
.sidebar__menu{
  display:flex;
  flex-direction:column;
  gap:12px;
}
.sidebar__item{
  padding:12px 14px;
  border-radius:10px;
  color:#666;
  text-decoration:none;
  font-size:15px;
  cursor:pointer;
  transition:all .2s;
}
.sidebar__item.active,
.sidebar__item:hover{
  background:#6a5cf8;
  color:#fff;
  font-weight:600;
}
.admin-content{
  flex:1;
  padding:32px;
}
.admin-header{
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:24px;
}
.admin-user{
  display:flex;
  gap:16px;
  align-items:center;
}
.bell{
  border:none;
  background:#fff;
  border-radius:12px;
  width:44px;
  height:44px;
  font-size:20px;
  cursor:pointer;
  box-shadow:0 5px 20px rgba(0,0,0,0.08);
}
.avatar{
  padding:10px 18px;
  border-radius:999px;
  background:#6e60f9;
  color:#fff;
  font-weight:600;
  box-shadow:0 8px 20px rgba(110,96,249,.3);
}
.admin-grid{
  display:grid;
  grid-template-columns:repeat(4,minmax(0,1fr));
  gap:16px;
}
.admin-card{
  background:#fff;
  border-radius:12px;
  padding:16px;
  box-shadow:0 4px 12px rgba(0,0,0,0.05);
}
.admin-card h3{
  font-size:14px;
  font-weight:500;
  color:#666;
  margin:0 0 8px 0;
}
.admin-card__value{
  font-size:24px;
  font-weight:700;
  margin:0;
  color:#333;
}
.admin-card__desc{
  color:#888;
  font-size:12px;
  margin-top:4px;
}
.admin-card .status{
  display:inline-block;
  padding:4px 14px;
  border-radius:999px;
  font-size:15px;
}
.status.good{
  background:#d0ffe8;
  color:#0f9961;
}
.admin-panels{
  margin-top:30px;
}

.review-container {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}
.panel{
  background:#fff;
  border-radius:18px;
  padding:22px;
  box-shadow:0 10px 30px rgba(0,0,0,0.06);
}
.panel header{
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:18px;
}
.panel header button{
  border:none;
  background:#f1efff;
  color:#6a5cf8;
  padding:6px 16px;
  border-radius:999px;
  cursor:pointer;
  font-weight:600;
}
.panel ul{
  list-style:none;
  margin:0;
  padding:0;
  display:flex;
  flex-direction:column;
  gap:16px;
}
.panel li{
  display:flex;
  justify-content:space-between;
  align-items:center;
  padding:14px;
  border-radius:10px;
  background:#f9f9fd;
  transition:all 0.2s;
  border-bottom:none;
  margin-bottom:0;
  gap:16px;
}

.panel li:hover {
  background: #f0f0ff;
  transform: translateX(4px);
}

.panel li:last-child{
  border-bottom:none;
  padding-bottom:14px;
}
.panel li h3{
  margin-bottom:6px;
}
.panel li p{
  color:#999;
  font-size:13px;
}

/* 审核操作按钮 */
.review-actions {
  display: flex;
  gap: 8px;
}

.btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.btn-approve {
  background: #d0ffe8;
  color: #0f9961;
}

.btn-approve:hover {
  background: #a8f5d0;
  transform: scale(1.05);
}

.btn-reject {
  background: #ffe9e2;
  color: #f2662f;
}

.btn-reject:hover {
  background: #ffd4c4;
  transform: scale(1.05);
}
.status-tag{
  padding:6px 14px;
  border-radius:999px;
  font-size:13px;
  font-weight:600;
}
.status-tag.warn{
  background:#ffe9e2;
  color:#f2662f;
}
.status-tag.info{
  background:#eef2ff;
  color:#5b62f4;
}
.header-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}
.secondary-btn {
  padding: 6px 12px;
  border-radius: 4px;
  border: 1px solid #ccc;
  background: #f5f5f5;
  cursor: pointer;
}
.secondary-btn:disabled {
  opacity: 0.6;
  cursor: default;
}
.user-summary{
  display:flex;
  justify-content:space-between;
  text-align:center;
}
.user-summary .value{
  font-size:24px;
  font-weight:700;
}
.user-summary .label{
  color:#8a8a9c;
  margin-top:4px;
}

/* 用户管理面板样式 */
.user-management {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.user-stat {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.stat-box {
  background: #f8f8fc;
  border-radius: 12px;
  padding: 16px;
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #6a5cf8;
}

.stat-label {
  color: #8a8a9c;
  font-size: 13px;
  margin-top: 6px;
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
  padding: 12px;
  border-radius: 10px;
  background: #f8f8fc;
  transition: all 0.2s;
}

.user-list li:hover {
  background: #eef2ff;
  transform: translateX(4px);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #6a5cf8;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
}

.user-list h4 {
  margin: 0;
  font-size: 14px;
}

.user-list p {
  color: #999;
  font-size: 12px;
  margin: 4px 0 0 0;
}

.user-meta {
  color: #999;
  font-size: 12px;
}

/* 用户搜索和过滤 */
/* 用户搜索和过滤 */
.user-filters {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-bottom: 16px;
  padding: 16px;
  background: #fff;
  border-radius: 12px;
  border: 1px solid #f0f0f5;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.filter-row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.search-input {
  flex: 1;
  padding: 11px 14px 11px 40px;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: linear-gradient(135deg, #ffffff 0%, #f9f9fd 100%);
  color: #2c2c2c;
  position: relative;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path></svg>');
  background-repeat: no-repeat;
  background-position: 12px center;
  background-size: 18px;
  padding-left: 40px;
}

.search-input:hover {
  border-color: #d0d0d0;
  background-color: #fafafc;
}

.search-input:focus {
  border-color: #6a5cf8;
  background-color: #fff;
  box-shadow: 0 0 0 3px rgba(106, 92, 248, 0.08), 0 4px 12px rgba(106, 92, 248, 0.12);
}

.search-input::placeholder {
  color: #999;
}

.role-select {
  padding: 10px 14px;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  font-size: 14px;
  background: linear-gradient(135deg, #ffffff 0%, #f9f9fd 100%);
  color: #2c2c2c;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  outline: none;
  min-width: 140px;
  appearance: none;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>');
  background-repeat: no-repeat;
  background-position: right 10px center;
  background-size: 18px;
  padding-right: 38px;
}

.role-select:hover {
  border-color: #d0d0d0;
  background-color: #fafafc;
}

.role-select:focus {
  border-color: #6a5cf8;
  background-color: #fff;
  box-shadow: 0 0 0 3px rgba(106, 92, 248, 0.08), 0 4px 12px rgba(106, 92, 248, 0.12);
}

.role-select option {
  padding: 8px 12px;
  background: #fff;
  color: #2c2c2c;
}

/* 过滤结果统计 */
.filter-result {
  font-size: 13px;
  color: #666;
  margin-bottom: 12px;
  padding: 8px 12px;
  background: #f9f9fd;
  border-radius: 8px;
  border-left: 3px solid #6a5cf8;
}

.filter-result strong {
  color: #6a5cf8;
  font-weight: 700;
  font-size: 14px;
}

/* 没有结果提示 */
.no-result {
  text-align: center;
  padding: 40px 0 !important;
  color: #999 !important;
  background: none !important;
  border: none !important;
}

.no-result:hover {
  transform: none !important;
}

/* 系统配置面板样式 */
.config-panel {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.config-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  background: #f9f9fd;
  border-radius: 10px;
  border: 1px solid #f0f0f5;
  transition: all 0.2s;
}

.config-item:hover {
  background: #fff;
  border-color: #e5e5e5;
}

.config-item label {
  color: #2c2c2c;
  font-weight: 500;
  font-size: 14px;
  min-width: 160px;
}

.config-item input[type="number"] {
  padding: 9px 12px;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  font-size: 14px;
  min-width: 140px;
  outline: none;
  transition: all 0.2s;
  background: linear-gradient(135deg, #ffffff 0%, #f9f9fd 100%);
}

.config-item input[type="number"]:focus {
  border-color: #6a5cf8;
  box-shadow: 0 0 0 3px rgba(106, 92, 248, 0.08);
}

.config-item input[type="checkbox"] {
  width: 22px;
  height: 22px;
  cursor: pointer;
  accent-color: #6a5cf8;
}

/* 保存按钮 */
.btn-save {
  background: linear-gradient(135deg, #6a5cf8 0%, #7c5cf8 100%);
  color: #fff;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 12px rgba(106, 92, 248, 0.3);
}

.btn-save:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(106, 92, 248, 0.4);
}

.btn-save:active {
  transform: translateY(0);
}

/* 月份选择器样式 */
.stats-date-picker {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding: 14px 16px;
  background: #f9f9fd;
  border-radius: 10px;
  border: 1px solid #f0f0f5;
}

.stats-date-picker label {
  color: #2c2c2c;
  font-weight: 500;
  font-size: 14px;
  min-width: 80px;
}

.month-input {
  padding: 9px 12px;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: all 0.2s;
  background: linear-gradient(135deg, #ffffff 0%, #f9f9fd 100%);
  color: #2c2c2c;
  cursor: pointer;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

.month-input:hover {
  border-color: #d0d0d0;
  background-color: #fafafc;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.month-input:focus {
  border-color: #6a5cf8;
  box-shadow: 0 0 0 3px rgba(106, 92, 248, 0.08);
  background: #fff;
}

/* 导出按钮 */
.btn-export {
  background: linear-gradient(135deg, #6a5cf8 0%, #7c5cf8 100%);
  color: #fff;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 12px rgba(106, 92, 248, 0.3);
}

.btn-export:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(106, 92, 248, 0.4);
}

.btn-export:active {
  transform: translateY(0);
}

/* 显示全部数据按钮 */
.btn-show-all {
  background: linear-gradient(135deg, #0d47a1 0%, #1565c0 100%);
  color: #fff;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 12px rgba(13, 71, 161, 0.3);
  margin-left: 12px;
}

.btn-show-all:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(13, 71, 161, 0.4);
}

.btn-show-all:active {
  transform: translateY(0);
}

/* 数据统计面板样式 */
.stats-panel {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.stat-card {
  background: #f8f8fc;
  border-radius: 12px;
  padding: 18px;
  text-align: center;
}

.stat-card h4 {
  margin: 0 0 14px 0;
  color: #666;
  font-size: 14px;
  font-weight: 500;
}

.stat-numbers {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-numbers .number {
  font-size: 28px;
  font-weight: 700;
  color: #6a5cf8;
}

.stat-numbers p {
  color: #999;
  font-size: 12px;
  margin: 6px 0 0 0;
}

/* 全局通知样式 */
:global(.notification) {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 14px 20px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  z-index: 9999;
  animation: slideInRight 0.3s ease-out;
  max-width: 400px;
  word-break: break-word;
}

:global(.notification-success) {
  background: #d0ffe8;
  color: #0f9961;
  border-left: 4px solid #0f9961;
}

:global(.notification-warning) {
  background: #ffe9e2;
  color: #f2662f;
  border-left: 4px solid #f2662f;
}

:global(.notification-info) {
  background: #eef2ff;
  color: #5b62f4;
  border-left: 4px solid #5b62f4;
}

:global(.notification-hide) {
  animation: slideOutRight 0.3s ease-in forwards;
}

@keyframes slideInRight {
  from {
    transform: translateX(400px);
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
    transform: translateX(400px);
    opacity: 0;
  }
}

@media (max-width:1200px){
  .admin-layout{
    flex-direction:column;
  }
  .sidebar{
    width:100%;
    display:flex;
    flex-direction:row;
    gap:10px;
    align-items:center;
    justify-content:space-between;
  }
  .sidebar__menu{
    flex-direction:row;
    flex-wrap:wrap;
  }
  .admin-grid{
    grid-template-columns:repeat(2,minmax(0,1fr));
  }
}

@media (max-width: 768px) {
  .admin-grid{
    grid-template-columns:repeat(2,minmax(0,1fr));
  }
  .review-container{
    grid-template-columns:1fr;
  }
}

.announcement-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.announcement-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.announcement-form .form-input {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
}

.announcement-form .form-textarea {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  min-height: 200px;
  resize: vertical;
}

.announcement-content {
  color: #666;
  margin-top: 8px;
  line-height: 1.6;
}

.stats-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 16px;
}

.stats-table th,
.stats-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.stats-table th {
  background: #f5f5f5;
  font-weight: 600;
  color: #333;
}

.empty-text {
  text-align: center;
  color: #999;
  padding: 20px;
}

.panel-desc {
  font-size: 13px;
  color: #999;
  margin-top: 4px;
  font-weight: normal;
}

.forum-management-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.post-content {
  color: #666;
  margin-top: 8px;
  line-height: 1.6;
  max-height: 200px;
  overflow-y: auto;
}

.post-image-preview {
  margin-top: 12px;
}

.post-image-preview img {
  max-width: 300px;
  max-height: 200px;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.news-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.news-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-form .form-input {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
}

.news-form .form-textarea {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  min-height: 200px;
  resize: vertical;
}

.news-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.news-item {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.news-item h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.news-meta {
  font-size: 14px;
  color: #999;
  margin-bottom: 8px;
}

.news-content {
  color: #666;
  line-height: 1.6;
  max-height: 100px;
  overflow-y: auto;
}

.news-actions {
  display: flex;
  gap: 8px;
}

.btn-edit {
  padding: 6px 12px;
  background: #0b4ea2;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}

.btn-edit:hover {
  opacity: 0.9;
}

.btn-delete {
  padding: 6px 12px;
  background: #f44336;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}

.btn-delete:hover {
  opacity: 0.9;
}

.gifts-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.panel-header-with-btn {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.gift-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.form-group label span {
  color: #f44336;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-input {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
}

.form-input:focus {
  outline: none;
  border-color: #0b4ea2;
}

.form-input:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.file-input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.image-preview {
  margin-top: 12px;
}

.image-preview img {
  max-width: 200px;
  max-height: 150px;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.gifts-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.gift-item {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.gift-image {
  width: 100%;
  height: 150px;
  overflow: hidden;
  border-radius: 4px;
  background: #f5f5f5;
}

.gift-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.gift-info {
  flex: 1;
}

.gift-info h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.gift-desc {
  font-size: 14px;
  color: #666;
  line-height: 1.6;
  margin-bottom: 8px;
}

.gift-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  color: #999;
}

.gift-actions {
  display: flex;
  gap: 8px;
  margin-top: auto;
}

.btn-add-stock {
  background: #4caf50;
  color: #fff;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.3s;
}

.btn-add-stock:hover {
  background: #45a049;
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: #fff;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

.modal-small {
  max-width: 400px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.modal-close {
  background: none;
  border: none;
  font-size: 28px;
  color: #999;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.modal-close:hover {
  color: #333;
}

.modal-body {
  padding: 20px;
}

.btn-secondary {
  background: #999;
  color: #fff;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.3s;
}

.btn-secondary:hover {
  background: #777;
}
</style>

