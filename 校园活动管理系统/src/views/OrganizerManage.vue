<template>
  <div class="premium-manage-page">
    <NavBar />

    <div class="manage-wrapper">
      <aside class="bento-sidebar">
        <div class="sidebar-header">
          <div class="brand-icon">✨</div>
          <h3>活动工作台</h3>
        </div>
        
        <nav class="sidebar-nav">
          <a class="nav-item" :class="{ active: currentView === 'publish' }" @click="currentView = 'publish'">
            <span class="icon">✍️</span> 发布活动
          </a>
          <a class="nav-item" :class="{ active: currentView === 'review' }" @click="currentView = 'review'">
            <span class="icon">⚖️</span> 审核报名
          </a>
          <a class="nav-item" :class="{ active: currentView === 'statistics' }" @click="currentView = 'statistics'">
            <span class="icon">📊</span> 查看统计
          </a>
          <a class="nav-item" :class="{ active: currentView === 'checkin' }" @click="currentView = 'checkin'">
            <span class="icon">📍</span> 签到管理
          </a>
          <a class="nav-item" :class="{ active: currentView === 'rewards' }" @click="openRewardsView">
            <span class="icon">🎁</span> 积分礼品
          </a>
        </nav>

        <div class="sidebar-footer">
          <p>组织者管理模式</p>
        </div>
      </aside>

      <main class="manage-content">
        <div v-if="currentView === 'publish'" class="view-container">
          <form class="bento-grid-form" @submit.prevent="handleSubmit">
            <header class="view-header">
              <div class="header-text">
                <h2>新建活动计划</h2>
                <p>填写活动详情，系统将精准推送给目标学生</p>
              </div>
              <div class="header-actions">
                <button type="button" class="btn-secondary" @click="handleSaveDraft">保存草稿</button>
                <button type="submit" class="btn-primary-vibe">提交审核 ↗</button>
              </div>
            </header>

            <div class="form-layout">
              <div class="bento-item span-2">
                <h4 class="bento-title">基本信息</h4>
                <div class="form-row">
                  <div class="input-group">
                    <label>活动名称 <span>*</span></label>
                    <input v-model="form.title" type="text" placeholder="请输入活动名称" required />
                  </div>
                 <!-- AI 智能推荐活动类型 -->
<div class="input-group">
  <label>活动类型 <span>*</span></label>
  <!-- 只显示 AI 推荐结果或加载状态 -->
  <div v-if="aiSuggestedType" class="ai-suggestion-box">
    <div class="suggested-type-chip">
      <span class="ai-badge">🤖 AI</span>
      {{ aiSuggestedType }}
    </div>
    <p class="ai-explain-text">💡 基于活动内容自动识别</p>
  </div>
  <div v-else-if="form.title.trim()" class="ai-loading-hint">
    <span class="spinner"></span> 正在分析活动类型...
  </div>
  <div v-else>
    <span class="placeholder-text">请输入活动名称以自动识别类型</span>
  </div>

  <!-- 隐藏的 input 用于确保 activityType 被包含在表单中（可选） -->
  <!-- 实际上 reactive form 已包含，无需额外 input -->
</div>
</div>
                <div class="form-row">
                  <div class="input-group">
                    <label>副标题</label>
                    <input v-model="form.subtitle" type="text" placeholder="例如：打造校园创新氛围" />
                  </div>
                  <div class="input-group">
                    <label>主办学院</label>
                    <select v-model="form.belongCollege">
                      <option value="">请选择学院</option>
                      <option v-for="college in collegeOptions" :key="college" :value="college">{{ college }}</option>
                    </select>
                  </div>
                </div>
                <div class="input-group">
                  <label>活动简介</label>
                  <textarea v-model="form.description" rows="2" placeholder="简要介绍活动亮点与目标"></textarea>
                </div>
              </div>

              <div class="bento-item">
                <h4 class="bento-title">时间与地点</h4>
                <div class="input-group">
                  <label>活动地点</label>
                  <input v-model="form.location" type="text" placeholder="请输入举办地点" />
                </div>
                <div class="input-group">
                  <label>开始时间 <span>*</span></label>
                  <input v-model="form.startTime" type="datetime-local" required />
                </div>
                <div class="input-group">
                  <label>结束时间 <span>*</span></label>
                  <input v-model="form.endTime" type="datetime-local" required />
                </div>
                <div class="input-group">
                  <label>报名截止日期</label>
                  <input v-model="form.registrationDeadline" type="datetime-local" />
                </div>
              </div>

              <div class="bento-item">
                <h4 class="bento-title">人数与策略</h4>
                <div class="toggle-group">
                  <label class="toggle-card">
                    <input type="checkbox" v-model="form.needApproval" />
                    <div class="toggle-content">
                      <span class="t-title">审核报名</span>
                      <span class="t-desc">开启后需组织者审批方可参加</span>
                    </div>
                  </label>
                  <label class="toggle-card">
                    <input type="checkbox" v-model="form.enableWaitlist" />
                    <div class="toggle-content">
                      <span class="t-title">候补策略</span>
                      <span class="t-desc">报名满额后允许学生排队候补</span>
                    </div>
                  </label>
                </div>
                <div class="form-row-2 mt-15">
                  <div class="input-group">
                    <label>人数上限 (0不限)</label>
                    <input v-model.number="form.maxParticipants" type="number" min="0" />
                  </div>
                  <div class="input-group" v-if="form.enableWaitlist">
                    <label>候补人数上限</label>
                    <input v-model.number="form.waitlistLimit" type="number" min="0" />
                  </div>
                </div>
              </div>

              <div class="bento-item span-2">
                <h4 class="bento-title">报名条件限制</h4>
                <div class="condition-grid">
                  <div class="check-section">
                    <label class="check-label">面向学院</label>
                    <div class="check-group-bento">
                      <label v-for="college in collegeOptions" :key="college" class="bento-checkbox">
                        <input type="checkbox" :value="college" v-model="form.targetColleges" />
                        <span class="check-tile">{{ college }}</span>
                      </label>
                    </div>
                  </div>
                  <div class="check-section">
                    <label class="check-label">面向年级</label>
                    <div class="check-group-bento">
                      <label v-for="grade in gradeOptions" :key="grade" class="bento-checkbox">
                        <input type="checkbox" :value="grade" v-model="form.targetGrades" />
                        <span class="check-tile">{{ grade }}</span>
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <div class="bento-item span-2">
                <h4 class="bento-title">内容与媒体</h4>
                <div class="media-flex">
                  <div class="media-left">
                    <label class="inner-label">封面图片</label>
                    <div class="cover-uploader" @click="$refs.coverInput.click()">
                      <img v-if="coverImagePreview" :src="coverImagePreview" />
                      <div v-else class="upload-hint">
                        <span class="hint-icon">🖼️</span>
                        <p>点击上传</p>
                      </div>
                    </div>
                    <input type="file" ref="coverInput" hidden accept="image/*" @change="handleCoverUpload" />
                    <button v-if="coverImagePreview" type="button" class="btn-remove-lite" @click.stop="removeCoverImage">移除封面</button>
                    
                    <div class="attachment-box mt-20">
                      <label class="inner-label">附件上传</label>
                      <div class="file-upload-container">
                        <input type="file" multiple ref="attachmentInput" hidden @change="handleAttachmentUpload" />
                        <button type="button" class="btn-upload-trigger" @click="$refs.attachmentInput.click()">
                          <span class="icon">📎</span>
                          <span>选择相关附件...</span>
                        </button>
                        <div class="file-count-tip" v-if="form.attachments.length">
                          <span class="check-icon">✅</span> 已成功选择 {{ form.attachments.length }} 个文件
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="rich-desc">
                    <label class="inner-label">详细描述</label>
                    <textarea v-model="form.detailRichText" placeholder="支持填写详细的活动流程、规则等内容..."></textarea>
                  </div>
                </div>
              </div>

              <div class="bento-item span-2 status-notice-card">
                <h4 class="bento-title">流程说明</h4>
                <div class="status-steps">
                  <div class="step-item"><span>1</span> 提交审核：状态变更为「待审核」</div>
                  <div class="step-item"><span>2</span> 管理员通过：状态变为「已发布」并开放报名</div>
                  <div class="step-item"><span>3</span> 动态调整：编辑内容后需重新提交审核</div>
                </div>
              </div>
            </div>
          </form>
        </div>

        <div v-if="currentView === 'review'" class="view-container">
          <header class="view-header">
            <div class="header-text">
              <h2>审核中心</h2>
              <p>及时处理报名申请，提升活动参与体验</p>
            </div>
              <button class="btn-refresh" @click="loadActivities">刷新数据</button>
          </header>

          <div class="activity-radar-grid">
            <div v-for="act in myActivities" :key="act.id" class="mini-activity-card">
              <div class="card-thumb">
                <img :src="buildImageUrl(act.coverUrl)" />
                <span class="status-pill">{{ formatStatus(act.status) }}</span>
              </div>
              <div class="card-body">
                <div class="card-main">
                  <h4>{{ act.title }}</h4>
                  <p>📍 {{ act.location || '待定' }}</p>
                </div>
                <div class="card-stats-row">
                  <div class="stat-unit">
                    <span class="s-label">待审</span>
                    <span class="s-val">{{ act.pendingApplications }}</span>
                  </div>
                  <div class="stat-unit">
                    <span class="s-label">已过</span>
                    <span class="s-val highlight">{{ act.approvedApplications }}</span>
                  </div>
                </div>
                <button class="btn-manage-mini" @click="openReviewPanel(act)">管理名单 ↗</button>
              </div>
            </div>
          </div>

          <div v-if="myActivities.length === 0" class="empty-state-bento">
             <div class="empty-icon">📭</div>
             <p>暂无活动，快去发布一个吧！</p>
          </div>
        </div>

        <div v-if="currentView === 'rewards'" class="view-container rewards-panel">
          <header class="view-header">
            <div class="header-text">
              <h2>积分与礼品</h2>
              <p>管理礼品上架、制定积分规则，并查看活动激励数据</p>
            </div>
            <button class="btn-refresh" @click="refreshOrganizerRewards">刷新数据</button>
          </header>

          <div v-if="loadingOrganizerAnalytics" class="reward-loading">加载积分概览...</div>
          <div v-else class="reward-summary">
            <div class="summary-card">
              <p>累计发放</p>
              <strong>{{ organizerAnalytics.totalPointsIssued }}</strong>
              <small>本组织活动产生的积分</small>
            </div>
            <div class="summary-card">
              <p>待审核礼品</p>
              <strong>{{ organizerAnalytics.pendingGifts }}</strong>
              <small>等待管理员审批</small>
            </div>
            <div class="summary-card">
              <p>热门兑换</p>
              <strong>{{ organizerAnalytics.giftHeat.length }}</strong>
              <small>近期开启兑换的礼品</small>
            </div>
          </div>

          <section class="organizer-reward-grid">
            <article class="reward-card">
              <h3>{{ giftForm.id ? '编辑礼品' : '申请上架新礼品' }}</h3>
              <p class="card-tip">提交后需管理员审核，审核通过即会上架</p>
              <form class="reward-form" @submit.prevent="submitGiftForm">
                <label>礼品名称 <span>*</span>
                  <input v-model.trim="giftForm.title" type="text" placeholder="如 校园限定帆布包" required />
                </label>
                <label>礼品描述
                  <textarea v-model.trim="giftForm.description" rows="2" placeholder="简单介绍礼品亮点"></textarea>
                </label>
                <div class="two-cols">
                  <label>所需积分 <span>*</span>
                    <input v-model.number="giftForm.pointsCost" type="number" min="1" required />
                  </label>
                  <label>库存数量 <span>*</span>
                    <input v-model.number="giftForm.stock" type="number" min="1" required />
                  </label>
                </div>
                <label>交付方式
                  <select v-model="giftForm.deliveryType">
                    <option value="offline">线下领取</option>
                    <option value="online">线上发放</option>
                    <option value="both">线上/线下皆可</option>
                  </select>
                </label>
                <label class="gift-cover-field">封面图片
                  <input
                    ref="giftCoverInput"
                    type="file"
                    accept="image/*"
                    @change="handleGiftCoverChange"
                  />
                  <small>支持 JPG/PNG，大小不超过 5MB</small>
                  <div
                    v-if="giftCoverPreview || giftForm.coverImage"
                    class="gift-cover-preview"
                  >
                    <img
                      :src="giftCoverPreview || giftForm.coverImage"
                      alt="gift-cover"
                    />
                    <button type="button" class="btn-remove-lite" @click="clearGiftCover">
                      移除图片
                    </button>
                  </div>
                </label>
                <div class="form-actions">
                  <button type="button" class="btn-secondary" v-if="giftForm.id" @click="resetGiftForm">取消编辑</button>
                  <button type="submit" class="btn-primary-vibe" :disabled="savingGift">
                    {{ savingGift ? '提交中...' : (giftForm.id ? '保存修改' : '提交审核') }}
                  </button>
                </div>
              </form>
            </article>

            <article class="reward-card">
              <h3>我的礼品</h3>
              <div class="card-tip">查看状态，快速上下架或编辑库存</div>
              <div v-if="loadingGiftList" class="reward-loading">加载礼品中...</div>
              <template v-else>
                <ul v-if="rewardGifts.length" class="gift-list">
                  <li v-for="gift in rewardGifts" :key="gift.id">
                    <div class="gift-info">
                      <img :src="gift.coverImage" alt="gift" />
                      <div>
                        <h4>{{ gift.title }}</h4>
                        <p>{{ gift.pointsCost }} 分 · 库存 {{ gift.stock }}</p>
                        <small>{{ formatGiftStatus(gift.status) }} · {{ mapDeliveryLabel(gift.deliveryType) }}</small>
                      </div>
                    </div>
                    <div class="gift-actions">
                      <button class="btn-mini" @click="editGift(gift)">编辑</button>
                      <button
                        class="btn-mini ghost"
                        v-if="gift.status === 'active'"
                        @click="toggleGiftStatus(gift, 'inactive')"
                      >下架</button>
                      <button
                        class="btn-mini ghost"
                        v-else-if="gift.status === 'inactive'"
                        @click="toggleGiftStatus(gift, 'active')"
                      >上架</button>
                      <span class="status-tag" :class="gift.status">{{ gift.status }}</span>
                    </div>
                  </li>
                </ul>
                <p v-else class="empty">暂无礼品记录，提交一个吧</p>
              </template>
            </article>
          </section>

          <section class="reward-card span-2">
            <div class="rule-header">
              <div>
                <h3>积分规则</h3>
                <p class="card-tip">为活动设置奖励动作，学生完成后自动计分</p>
              </div>
              <button class="btn-refresh ghost" @click="loadOrganizerRules">刷新</button>
            </div>
            <form class="rule-form" @submit.prevent="submitRuleForm">
              <div class="two-cols">
                <label>关联活动
                  <select v-model="ruleForm.activityId" required>
                    <option value="" disabled>请选择活动</option>
                    <option v-for="act in myActivities" :value="act.id" :key="act.id">
                      {{ act.title }}
                    </option>
                  </select>
                </label>
                <label>奖励名称
                  <input v-model.trim="ruleForm.actionLabel" type="text" placeholder="如：签到" required />
                </label>
              </div>
              <div class="two-cols">
                <label>积分值
                  <input v-model.number="ruleForm.pointsValue" type="number" min="1" required />
                </label>
                <label>启用
                  <select v-model="ruleForm.isActive">
                    <option :value="true">启用</option>
                    <option :value="false">暂停</option>
                  </select>
                </label>
              </div>
              <label>说明
                <textarea v-model.trim="ruleForm.description" rows="2" placeholder="规则说明、触发条件等"></textarea>
              </label>
              <div class="form-actions">
                <button type="submit" class="btn-primary-vibe" :disabled="savingRule">
                  {{ savingRule ? '保存中...' : '保存规则' }}
                </button>
              </div>
            </form>

            <div v-if="loadingRules" class="reward-loading">加载规则中...</div>
            <div v-else>
              <div class="rule-list" v-if="organizerRules.length">
                <h4>最近规则</h4>
                <ul>
                  <li v-for="rule in organizerRules" :key="rule.id" @click="editRule(rule)">
                    <div>
                      <strong>{{ rule.actionLabel }}</strong>
                      <p>活动 {{ rule.activityId }} · {{ rule.pointsValue }} 分</p>
                    </div>
                    <span class="status-tag" :class="rule.isActive ? 'active' : 'inactive'">
                      {{ rule.isActive ? '启用' : '停用' }}
                    </span>
                  </li>
                </ul>
              </div>
              <p v-else class="empty">暂无已保存的积分规则</p>
            </div>
          </section>

          <section class="reward-card span-2">
            <h3>礼品兑换热度</h3>
            <div class="card-tip">按兑换数量 TOP5</div>
            <ul class="heat-list" v-if="organizerAnalytics.giftHeat.length">
              <li v-for="gift in organizerAnalytics.giftHeat" :key="gift.id">
                <span>{{ gift.title }}</span>
                <strong>{{ gift.redeemed }}</strong>
              </li>
            </ul>
            <p v-else class="empty">暂无兑换数据</p>
          </section>
        </div>

        <div v-if="['statistics', 'checkin'].includes(currentView)" class="view-container">
          <div class="empty-state-bento">
            <div class="loader-vibe"></div>
            <h3>正在打磨功能...</h3>
          </div>
        </div>
      </main>
    </div>

    <div v-if="selectedActivity" class="bento-modal-overlay" @click.self="closeReviewPanel">
      <div class="bento-modal">
        <div class="modal-header">
          <h3>报名名单 - {{ selectedActivity.title }}</h3>
          <button class="btn-close-circle" @click="closeReviewPanel">×</button>
        </div>
        <div class="modal-body custom-scrollbar">
          <div v-for="app in currentApplications" :key="app.id" class="applicant-item">
            <div class="app-avatar">{{ app.userName.charAt(0) }}</div>
            <div class="app-info">
              <span class="app-name">{{ app.userName }}</span>
              <span class="app-date">{{ formatDateTime(app.applyTime) }}</span>
            </div>
            <div :class="['app-status-tag', app.status]">{{ getStatusText(app.status) }}</div>
            <div class="app-actions" v-if="app.status === 'pending'">
              <button class="btn-app-approve" @click="handleApprove(app)" :disabled="isUpdating(app.id)">通过</button>
              <button class="btn-app-reject" @click="handleReject(app)" :disabled="isUpdating(app.id)">拒绝</button>
            </div>
          </div>
          <div v-if="currentApplications.length === 0" class="empty-mini">暂无报名记录</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, watch } from 'vue'
import NavBar from '@/components/NavBar.vue'
import { createEvent } from '@/api/event'
import {
  fetchMyActivities as fetchOrganizerActivities,
  fetchActivityApplications,
  updateApplicationStatus
} from '@/api/organizer'
import {
  fetchManagedGifts,
  createGift as createRewardGift,
  updateGift,
  updateGiftStatus,
  fetchPointRules,
  savePointRule,
  fetchOrganizerRewardStats
} from '@/api/reward'

const getDefaultForm = () => ({
  title: '',
  subtitle: '',
  activityType: '',
  belongCollege: '',
  description: '',
  detailRichText: '',
  location: '',
  startTime: '',
  endTime: '',
  registrationDeadline: '',
  maxParticipants: 0,
  enableWaitlist: false,
  waitlistLimit: 0,
  needApproval: false,
  targetColleges: [],
  targetGrades: [],
  coverImage: '',
  attachments: []
})
const form = reactive(getDefaultForm())
const coverImageFile = ref(null)
const coverImagePreview = ref(null)
const DRAFT_KEY = 'organizer_publish_draft'
// AI 推荐相关状态
const aiSuggestedType = ref('')        // AI 推荐的类型
const isAiLoading = ref(false)         // 是否正在请求 AI
const useAiSuggestion = ref(false)     // 是否已采纳 AI 建议



// AI 推荐接口（调用你刚加的分词器/NLP服务）
const suggestActivityType = async (title, description = '', detail = '') => {
  const response = await fetch('/api/events/suggest-type', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ title, description, detail })
  })
  if (!response.ok) throw new Error('AI 推荐服务暂时不可用')
  
   const result = await response.json()
  return result.data // ✅ 返回 { suggestedType: "学术讲座" }
}

// 防抖函数
function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

// 用户点击“修改类型”按钮
const editActivityType = () => {
  showManualTypeSelect.value = true
  aiSuggestedType.value = null
}

// 触发 AI 推荐（带防抖）
// 防抖触发 AI 推荐
const triggerAiSuggestion = debounce(async () => {
  if (!form.title.trim()) {
    aiSuggestedType.value = null
    form.activityType = '' // 清空类型
    return
  }

  try {
    const res = await suggestActivityType(
      form.title,
      form.description || '',
      form.detailRichText || ''
    )
    const type = res.suggestedType

    // 只要 AI 返回了类型，就直接使用（即使不在列表中也可考虑放宽）
    if (type) {
      aiSuggestedType.value = type
      form.activityType = type // ✅ 自动填入
    } else {
      // AI 无法识别，设为“其他活动”或留空（根据业务）
      aiSuggestedType.value = '其他活动'
      form.activityType = '其他活动'
    }
  } catch (err) {
    console.warn('AI 推荐失败:', err)
    aiSuggestedType.value = '其他活动'
    form.activityType = '其他活动'
  }
}, 800)

// 监听标题/描述变化
watch(
  () => `${form.title} ${form.description} ${form.detailRichText}`,
  triggerAiSuggestion
)


// 示例：加载组织者活动（按你实际需要保留）
onMounted(() => {
  // 例如加载礼品、积分规则等
})


// --- 【核心修改：显式导入本地资产图片】 ---
import imgCup from '@/assets/校园定制水杯.jpg'
import imgPack from '@/assets/活动加油礼包.jpg'
import imgMusic from '@/assets/线上音乐会门票.jpg'
import imgBag from '@/assets/珞狮校园帆布包.jpg'
import imgBadge from '@/assets/余区纪念微章套装.jpg'
import imgBoat from '@/assets/龙舟体验券.jpg'
import imgHand from '@/assets/夜游科普手账.jpg'
import imgVip from '@/assets/材料实验室VIP参观券.jpg'
import imgCoffee from '@/assets/校园咖啡券.jpg'

// --- API 基础处理 ---
const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')
const DEFAULT_COVER = `${API_ORIGIN}/uploads/3b72bdb5a6ca17d85131e816c9fdd0b1.jpg`

// 建立规范化的资产映射表
const normalizeAssetKey = (value = '') =>
  value
    .toString()
    .trim()
    .replace(/\.[^/.]+$/, '') // 移除后缀
    .replace(/[\s·\-()（）]/g, '') // 移除空格和特殊字符
    .toLowerCase()

const giftAssetMap = {
  [normalizeAssetKey('校园定制水杯')]: imgCup,
  [normalizeAssetKey('活动加油礼包')]: imgPack,
  [normalizeAssetKey('线上音乐会门票')]: imgMusic,
  [normalizeAssetKey('珞狮校园帆布包')]: imgBag,
  [normalizeAssetKey('余区纪念徽章套装')]: imgBadge,
  [normalizeAssetKey('余区纪念微章套装')]: imgBadge, // 处理错别字
  [normalizeAssetKey('龙舟体验券')]: imgBoat,
  [normalizeAssetKey('夜游科普手账')]: imgHand,
  [normalizeAssetKey('材料实验室VIP参观券')]: imgVip,
  [normalizeAssetKey('材料实验室 VIP 参观券')]: imgVip,
  [normalizeAssetKey('校园咖啡券')]: imgCoffee
}

const sanitizeGiftCoverPath = (value) => {
  if (!value) return ''
  const normalized = value.toString().trim()
  return normalized && normalized !== 'null' ? normalized : ''
}

const resolveAssetCover = (gift) => {
  const coverPath = sanitizeGiftCoverPath(gift.coverImage || gift.cover_image)
  // 1. 优先通过标题匹配映射表
  const fromTitle = giftAssetMap[normalizeAssetKey(gift.title || '')]
  if (fromTitle) return fromTitle
  // 2. 尝试通过文件名匹配（防止数据库只存了文件名）
  const fileName = coverPath.split('/').pop() || ''
  return giftAssetMap[normalizeAssetKey(fileName)] || null
}

const buildImageUrl = (url) => {
  if (!url || url === '' || url === 'null') return DEFAULT_COVER
  if (url.startsWith('http')) return url
  return API_ORIGIN + (url.startsWith('/') ? '' : '/') + url.replace(/\\/g, '/')
}

// --- 数据定义 ---
const currentView = ref('publish')
const selectedActivity = ref(null)
const currentApplications = ref([])
const myActivities = ref([])
const updatingApplicationId = ref(null)

const rewardViewInitialized = ref(false)
const organizerAnalytics = ref({
  totalPointsIssued: 0,
  pendingGifts: 0,
  giftHeat: []
})
const loadingOrganizerAnalytics = ref(false)
const rewardGifts = ref([])
const loadingGiftList = ref(false)
const savingGift = ref(false)
const organizerRules = ref([])
const loadingRules = ref(false)
const savingRule = ref(false)

const giftForm = reactive({
  id: null,
  title: '',
  description: '',
  pointsCost: 100,
  stock: 20,
  deliveryType: 'offline',
  coverImage: ''
})
const giftCoverFile = ref(null)
const giftCoverPreview = ref('')
const giftCoverInput = ref(null)

const ruleForm = reactive({
  activityId: '',
  actionLabel: '',
  pointsValue: '',
  description: '',
  isActive: true
})

const activityTypes = ['学术讲座', '文体活动', '志愿服务', '竞赛比赛', '社团活动']
const collegeOptions = ['计算机学院', '软件学院', '管理学院', '艺术设计学院', '经济学院']
const gradeOptions = ['大一', '大二', '大三', '大四', '研究生']



// --- 业务方法 ---
onMounted(() => {
  loadActivities()
  const stored = localStorage.getItem(DRAFT_KEY)
  if (stored) {
    const parsed = JSON.parse(stored)
    Object.assign(form, parsed)
  }
})

const loadActivities = async () => {
  try {
    const list = await fetchOrganizerActivities()
    myActivities.value = Array.isArray(list) ? list.map(item => ({
      id: item.id,
      title: item.title,
      location: item.location,
      status: item.status || 'published',
      coverUrl: item.cover_url,
      pendingApplications: Number(item.pending_applications) || 0,
      approvedApplications: Number(item.approved_applications) || 0
    })) : []
  } catch (err) { console.error(err) }
}

const ensureRewardsReady = () => {
  if (!rewardViewInitialized.value) {
    rewardViewInitialized.value = true
    refreshOrganizerRewards()
  }
}

const openRewardsView = () => {
  currentView.value = 'rewards'
  ensureRewardsReady()
}

const refreshOrganizerRewards = () => {
  loadOrganizerAnalytics()
  loadOrganizerGifts()
  loadOrganizerRules()
}

const revokeGiftCoverPreview = () => {
  if (giftCoverPreview.value && giftCoverPreview.value.startsWith('blob:')) {
    URL.revokeObjectURL(giftCoverPreview.value)
  }
}

const setGiftCoverPreview = (src = '') => {
  revokeGiftCoverPreview()
  giftCoverPreview.value = src
}

const resetGiftCover = () => {
  setGiftCoverPreview('')
  giftCoverFile.value = null
  if (giftCoverInput.value) {
    giftCoverInput.value.value = ''
  }
}

const handleGiftCoverChange = (event) => {
  const file = event.target.files && event.target.files[0]
  if (!file) return
  if (!file.type.startsWith('image/')) {
    alert('请上传图片文件')
    event.target.value = ''
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    alert('图片大小需小于 5MB')
    event.target.value = ''
    return
  }
  giftCoverFile.value = file
  setGiftCoverPreview(URL.createObjectURL(file))
}

const clearGiftCover = () => {
  resetGiftCover()
  giftForm.coverImage = ''
}

const loadOrganizerAnalytics = async () => {
  loadingOrganizerAnalytics.value = true
  try {
    const data = await fetchOrganizerRewardStats()
    organizerAnalytics.value = {
      totalPointsIssued: data?.totalPointsIssued || 0,
      pendingGifts: data?.pendingGifts || 0,
      giftHeat: data?.giftHeat || []
    }
  } catch (err) {
    console.error('加载组织者积分概览失败', err)
  } finally {
    loadingOrganizerAnalytics.value = false
  }
}

const normalizeGift = (gift) => {
  const coverPath = sanitizeGiftCoverPath(gift.coverImage || gift.cover_image)
  const assetCover = resolveAssetCover(gift)
  const coverImageUrl = assetCover
    ? assetCover
    : (coverPath ? buildImageUrl(coverPath) : DEFAULT_COVER)
  
  return {
    id: gift.id,
    title: gift.title,
    description: gift.description,
    pointsCost: gift.pointsCost ?? gift.points_cost ?? 0,
    stock: gift.stock ?? 0,
    status: gift.status,
    deliveryType: gift.deliveryType || gift.delivery_type || 'offline',
    coverImage: coverImageUrl,
    rawCover: coverPath
  }
}

const loadOrganizerGifts = async () => {
  loadingGiftList.value = true
  try {
    const list = await fetchManagedGifts()
    rewardGifts.value = Array.isArray(list) ? list.map(normalizeGift) : []
  } catch (err) {
    console.error('加载礼品失败', err)
    rewardGifts.value = []
  } finally {
    loadingGiftList.value = false
  }
}

const resetGiftForm = () => {
  giftForm.id = null
  giftForm.title = ''
  giftForm.description = ''
  giftForm.pointsCost = 100
  giftForm.stock = 20
  giftForm.deliveryType = 'offline'
  giftForm.coverImage = ''
  resetGiftCover()
}

const editGift = (gift) => {
  giftForm.id = gift.id
  giftForm.title = gift.title
  giftForm.description = gift.description || ''
  giftForm.pointsCost = gift.pointsCost
  giftForm.stock = gift.stock
  giftForm.deliveryType = gift.deliveryType
  giftForm.coverImage = gift.rawCover || ''
  giftCoverFile.value = null
  setGiftCoverPreview(gift.coverImage || '')
  if (giftCoverInput.value) {
    giftCoverInput.value.value = ''
  }
}

const submitGiftForm = async () => {
  if (!giftForm.title || !giftForm.pointsCost || !giftForm.stock) {
    alert('请填写完整的礼品信息')
    return
  }

  if (!giftForm.id && !giftCoverFile.value) {
    alert('请上传礼品封面图片')
    return
  }

  const buildPayload = () => {
    const base = {
      title: giftForm.title.trim(),
      description: giftForm.description,
      pointsCost: Number(giftForm.pointsCost),
      stock: Number(giftForm.stock),
      deliveryType: giftForm.deliveryType
    }

    if (giftCoverFile.value) {
      const formData = new FormData()
      Object.entries(base).forEach(([key, value]) => {
        formData.append(key, value)
      })
      formData.append('coverImage', giftCoverFile.value)
      return formData
    }

    return {
      ...base,
      coverImage: giftForm.coverImage
    }
  }

  const payload = buildPayload()
  savingGift.value = true

  try {
    if (giftForm.id) {
      await updateGift(giftForm.id, payload)
      alert('礼品信息已更新')
    } else {
      await createRewardGift(payload)
      alert('礼品申请已提交，等待管理员审核')
    }
    resetGiftForm()
    refreshOrganizerRewards()
  } catch (err) {
    console.error('提交礼品失败', err)
    alert(err?.response?.data?.message || '礼品保存失败')
  } finally {
    savingGift.value = false
  }
}

const toggleGiftStatus = async (gift, status) => {
  if (!confirm(`确认将「${gift.title}」${status === 'active' ? '重新上架' : '下架'}？`)) return
  try {
    await updateGiftStatus(gift.id, { status, reviewNote: '组织者调整' })
    refreshOrganizerRewards()
  } catch (err) {
    console.error('更新礼品状态失败', err)
    alert('更新礼品状态失败，请稍后再试')
  }
}

const mapDeliveryLabel = (type) => {
  if (type === 'online') return '线上'
  if (type === 'both') return '线上/线下'
  return '线下'
}

const formatGiftStatus = (status) => {
  const dict = {
    pending: '待审核',
    active: '已上架',
    inactive: '已下架',
    rejected: '已驳回'
  }
  return dict[status] || status
}

const loadOrganizerRules = async () => {
  loadingRules.value = true
  try {
    const list = await fetchPointRules()
    organizerRules.value = Array.isArray(list) ? list : []
  } catch (err) {
    console.error('加载积分规则失败', err)
    organizerRules.value = []
  } finally {
    loadingRules.value = false
  }
}

const submitRuleForm = async () => {
  if (!ruleForm.activityId || !ruleForm.actionLabel || !ruleForm.pointsValue) {
    alert('请完善规则信息')
    return
  }
  savingRule.value = true
  try {
    await savePointRule({
      activityId: ruleForm.activityId,
      actionLabel: ruleForm.actionLabel.trim(),
      pointsValue: Number(ruleForm.pointsValue),
      description: ruleForm.description,
      isActive: ruleForm.isActive
    })
    alert('积分规则已保存')
    loadOrganizerRules()
  } catch (err) {
    console.error('保存积分规则失败', err)
    alert(err?.response?.data?.message || '保存失败')
  } finally {
    savingRule.value = false
  }
}

const editRule = (rule) => {
  ruleForm.activityId = rule.activityId
  ruleForm.actionLabel = rule.actionLabel
  ruleForm.pointsValue = rule.pointsValue
  ruleForm.description = rule.description || ''
  ruleForm.isActive = !!rule.isActive
}

const handleCoverUpload = (e) => {
  const file = e.target.files[0]
  if (file) {
    coverImageFile.value = file
    coverImagePreview.value = URL.createObjectURL(file)
    form.coverImage = file.name
  }
}

const removeCoverImage = () => {
  if (coverImagePreview.value) URL.revokeObjectURL(coverImagePreview.value)
  coverImagePreview.value = null
  coverImageFile.value = null
  form.coverImage = ''
}

const handleAttachmentUpload = (e) => {
  const files = Array.from(e.target.files || [])
  form.attachments = files.map(file => file.name)
}

const handleSubmit = async () => {
  if (!form.title || !form.activityType || !form.startTime || !form.endTime) {
    alert('请填写标有*号的必填项')
    return
  }
  try {
    const formData = new FormData()
    Object.keys(form).forEach(key => {
      if (Array.isArray(form[key])) {
        formData.append(key, JSON.stringify(form[key]))
      } else {
        formData.append(key, form[key])
      }
    })
    if (coverImageFile.value) formData.append('coverImage', coverImageFile.value)

    await createEvent(formData)
    alert('发布成功！活动已进入审核队列')
    loadActivities()
    currentView.value = 'review'
    localStorage.removeItem(DRAFT_KEY)
    Object.assign(form, getDefaultForm())
    coverImagePreview.value = null
  } catch (err) { alert(err.message || '提交失败') }
}

const handleSaveDraft = () => {
  localStorage.setItem(DRAFT_KEY, JSON.stringify(form))
  alert('草稿已保存至本地')
}

const openReviewPanel = async (act) => {
  selectedActivity.value = act
  try {
    const list = await fetchActivityApplications(act.id)
    currentApplications.value = list.map(i => ({
      id: i.id, userName: i.user_name || '未知学号', applyTime: i.apply_time, status: i.status
    }))
  } catch (err) { alert('加载名单失败') }
}

const handleApprove = async (app) => {
  updatingApplicationId.value = app.id
  try {
    await updateApplicationStatus(app.id, 'approved')
    app.status = 'approved'
    loadActivities()
  } finally { updatingApplicationId.value = null }
}

const handleReject = async (app) => {
  if(!confirm('拒绝该学生的申请？')) return
  updatingApplicationId.value = app.id
  try {
    await updateApplicationStatus(app.id, 'rejected')
    app.status = 'rejected'
    loadActivities()
  } finally { updatingApplicationId.value = null }
}

const isUpdating = (id) => updatingApplicationId.value === id
const closeReviewPanel = () => { selectedActivity.value = null }
const formatStatus = (s) => ({ published:'进行中', draft:'草稿' }[s] || '审核中')
const getStatusText = (s) => ({ pending:'待审核', approved:'已通过', rejected:'已拒绝' }[s])
const formatDateTime = (d) => d ? new Date(d).toLocaleString() : '未知'

watch(currentView, (view) => {
  if (view === 'rewards') {
    ensureRewardsReady()
  }
})

watch(myActivities, (list) => {
  if (!ruleForm.activityId && Array.isArray(list) && list.length) {
    ruleForm.activityId = list[0].id
  }
})

onBeforeUnmount(() => {
  revokeGiftCoverPreview()
})
</script>

<style scoped>
/* 样式部分完全保留，不作改动 */
.premium-manage-page {
  --accent: #2dd4bf;
  --primary: #6366f1;
  --bg-main: #f8fafc;
  --text-dark: #0f172a;
  --text-light: #64748b;
  --bento-bg: #ffffff;
  --bento-border: rgba(0, 0, 0, 0.05);
  min-height: 100vh;
  background-color: var(--bg-main);
  padding-top: 60px;
}

.manage-wrapper {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  gap: 20px;
  padding: 24px;
}

.bento-sidebar {
  width: 220px;
  background: var(--bento-bg);
  border-radius: 24px;
  border: 1px solid var(--bento-border);
  padding: 24px 12px;
  height: fit-content;
  position: sticky;
  top: 84px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.02);
  display: flex;
  flex-direction: column;
}
.sidebar-header { display: flex; align-items: center; gap: 8px; padding: 0 12px 24px; }
.brand-icon { font-size: 20px; }
.sidebar-header h3 { font-size: 15px; font-weight: 800; margin: 0; }
.sidebar-nav { display: flex; flex-direction: column; gap: 4px; }
.nav-item {
  display: flex; align-items: center; gap: 10px; padding: 12px 16px;
  border-radius: 12px; color: var(--text-light); font-weight: 600;
  cursor: pointer; transition: 0.2s; font-size: 13px;
}
.nav-item:hover, .nav-item.active { background: #f1f5f9; color: var(--primary); }

.sidebar-footer { 
  margin-top: 40px; 
  padding: 0 16px 12px; 
}
.sidebar-footer p {
  font-size: 11px;
  color: #94a3b8;
  font-weight: 500;
  letter-spacing: 0.5px;
  margin: 0;
}

.manage-content { flex: 1; min-width: 0; }
.view-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.header-text h2 { font-size: 22px; font-weight: 800; margin: 0; }

.form-layout { display: grid; grid-template-columns: 1.6fr 1fr; gap: 16px; }
.span-2 { grid-column: span 2; }
.bento-item {
  background: var(--bento-bg); border-radius: 20px;
  border: 1px solid var(--bento-border); padding: 20px;
}
.bento-title { font-size: 14px; font-weight: 800; margin: 0 0 18px 0; color: #1e293b; border-left: 3px solid var(--accent); padding-left: 10px; }

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-row-2 { display: flex; gap: 16px; }
.input-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 12px; flex: 1; }
.input-group label, .inner-label { font-size: 12px; font-weight: 700; color: var(--text-light); }
.input-group label span { color: #f43f5e; }
.input-group input, .input-group select, .input-group textarea {
  border: 1px solid #f1f5f9; background: #f8fafc; border-radius: 10px;
  padding: 10px; font-size: 13px; transition: 0.2s;
}
.input-group input:focus { outline: none; border-color: var(--accent); background: white; }

.toggle-group { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.toggle-card {
  display: flex; gap: 10px; padding: 12px; background: #f8fafc; border-radius: 12px; cursor: pointer; border: 1px solid transparent;
}
.toggle-card:has(input:checked) { border-color: var(--accent); background: white; }
.t-title { display: block; font-weight: 700; font-size: 13px; }
.t-desc { font-size: 10px; color: var(--text-light); }

.condition-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.check-label { font-size: 12px; font-weight: 700; color: var(--text-light); margin-bottom: 10px; display: block; }
.check-group-bento { display: flex; flex-wrap: wrap; gap: 8px; }
.bento-checkbox input { display: none; }
.check-tile {
  padding: 6px 12px; border-radius: 8px; background: #f1f5f9; font-size: 11px;
  font-weight: 600; cursor: pointer; transition: 0.2s;
}
.bento-checkbox input:checked + .check-tile { background: var(--accent); color: white; }

.media-flex { display: flex; gap: 24px; }
.media-left { width: 220px; }
.cover-uploader {
  width: 100%; height: 130px; background: #f8fafc; border: 2px dashed #e2e8f0;
  border-radius: 16px; display: flex; align-items: center; justify-content: center;
  cursor: pointer; overflow: hidden; margin-top: 6px;
}
.cover-uploader img { width: 100%; height: 100%; object-fit: cover; }
.upload-hint { text-align: center; color: #94a3b8; font-size: 12px; }
.hint-icon { font-size: 24px; display: block; margin-bottom: 4px; }
.rich-desc { flex: 1; display: flex; flex-direction: column; }
.rich-desc textarea { flex: 1; margin-top: 6px; border: 1px solid #f1f5f9; border-radius: 12px; padding: 12px; background: #f8fafc; min-height: 180px; }

.btn-upload-trigger {
  display: flex; align-items: center; gap: 8px; padding: 10px 16px;
  background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px;
  color: var(--text-light); font-size: 13px; font-weight: 600;
  cursor: pointer; transition: all 0.2s; width: fit-content;
  margin-top: 6px;
}
.btn-upload-trigger:hover {
  background: white; border-color: var(--accent); color: var(--accent);
  box-shadow: 0 4px 12px rgba(45, 212, 191, 0.1);
}
.file-count-tip {
  margin-top: 8px; font-size: 12px; color: var(--accent); font-weight: 600;
  display: flex; align-items: center;
}
.check-icon { margin-right: 4px; }

.btn-primary-vibe {
  background: linear-gradient(135deg, var(--accent), var(--primary));
  color: white; border: none; padding: 10px 24px; border-radius: 100px;
  font-weight: 800; cursor: pointer; transition: 0.2s;
}
.btn-secondary { background: white; border: 1px solid #e2e8f0; padding: 10px 24px; border-radius: 100px; font-weight: 600; cursor: pointer; }
.btn-remove-lite { background: none; border: none; color: #ef4444; font-size: 11px; margin-top: 6px; cursor: pointer; }

.status-steps { display: flex; justify-content: space-between; gap: 20px; }
.step-item { flex: 1; font-size: 12px; color: var(--text-light); display: flex; align-items: center; gap: 8px; }
.step-item span { width: 18px; height: 18px; background: #e2e8f0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800; color: #1e293b; }

.activity-radar-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; }
.mini-activity-card {
  background: white; border-radius: 20px; border: 1px solid var(--bento-border);
  padding: 12px; display: flex; gap: 12px; transition: 0.2s;
}
.card-thumb { width: 80px; height: 80px; border-radius: 12px; overflow: hidden; position: relative; flex-shrink: 0; }
.card-thumb img { width: 100%; height: 100%; object-fit: cover; }
.status-pill { position: absolute; bottom: 4px; left: 4px; background: rgba(0,0,0,0.6); color: white; font-size: 9px; padding: 2px 6px; border-radius: 5px; }
.card-body { flex: 1; display: flex; flex-direction: column; justify-content: space-between; }
.card-main h4 { margin: 0; font-size: 14px; font-weight: 800; }
.card-stats-row { display: flex; gap: 12px; margin-bottom: 4px; }
.stat-unit { display: flex; align-items: center; gap: 4px; }
.s-label { font-size: 10px; color: #94a3b8; }
.s-val { font-size: 12px; font-weight: 800; }
.btn-manage-mini { background: #f1f5f9; border: none; padding: 5px 10px; border-radius: 7px; font-size: 11px; font-weight: 700; cursor: pointer; }
.btn-refresh { background: #f1f5f9; border: none; padding: 8px 16px; border-radius: 999px; font-weight: 600; cursor: pointer; }
.btn-refresh.ghost { background: transparent; border: 1px dashed #c7d2fe; color: var(--primary); }

.bento-modal { width: 500px; background: white; border-radius: 24px; max-height: 80vh; overflow: hidden; }
.applicant-item { display: flex; align-items: center; gap: 12px; padding: 12px; background: #f8fafc; border-radius: 12px; margin-bottom: 8px; }
.app-avatar { width: 36px; height: 36px; background: var(--primary); color: white; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 800; }
.empty-state-bento { text-align: center; padding: 40px; color: #cbd5e1; }

.mt-15 { margin-top: 15px; }
.mt-20 { margin-top: 20px; }

.custom-scrollbar::-webkit-scrollbar { width: 5px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }

.rewards-panel { display: flex; flex-direction: column; gap: 20px; }
.reward-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
.summary-card { background: #fff; border-radius: 18px; padding: 18px; border: 1px solid var(--bento-border); box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08); }
.summary-card p { margin: 0; color: var(--text-light); font-size: 12px; }
.summary-card strong { display: block; font-size: 28px; margin: 8px 0; color: var(--text-dark); }
.summary-card small { color: #94a3b8; font-size: 11px; }
.organizer-reward-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
.reward-card { background: #fff; border-radius: 20px; border: 1px solid var(--bento-border); padding: 20px; box-shadow: 0 12px 32px rgba(15, 23, 42, 0.06); }
.reward-card.span-2 { grid-column: span 2; }
.reward-form { display: flex; flex-direction: column; gap: 12px; }
.reward-form label { display: flex; flex-direction: column; gap: 6px; font-size: 12px; color: var(--text-light); }
.reward-form input,
.reward-form textarea,
.reward-form select { border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px 12px; font-size: 13px; background: #f8fafc; }
.reward-form textarea { min-height: 80px; }
.gift-cover-field small { display: block; margin-top: 4px; color: #94a3b8; }
.gift-cover-field input[type="file"] { margin-top: 6px; font-size: 12px; }
.gift-cover-preview { margin-top: 10px; display: flex; align-items: center; gap: 12px; }
.gift-cover-preview img { width: 64px; height: 64px; border-radius: 12px; object-fit: cover; border: 1px solid #e2e8f0; }
.form-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 6px; }
.two-cols { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; }
.card-tip { font-size: 12px; color: #94a3b8; margin-bottom: 12px; }
.reward-loading { padding: 16px 0; text-align: center; color: #94a3b8; font-size: 13px; }
.gift-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 12px; }
.gift-list li { display: flex; justify-content: space-between; gap: 12px; padding: 12px; border-radius: 14px; background: #f8fafc; border: 1px solid #eef2ff; align-items: center; }
.gift-info { display: flex; gap: 10px; align-items: center; }
.gift-info img { width: 48px; height: 48px; object-fit: cover; border-radius: 12px; }
.gift-info h4 { margin: 0; font-size: 14px; }
.gift-info p { margin: 2px 0; font-size: 12px; }
.gift-info small { color: #94a3b8; font-size: 11px; }
.gift-actions { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.btn-mini { border: none; border-radius: 999px; padding: 6px 12px; font-size: 12px; font-weight: 600; cursor: pointer; background: #e2e8f0; color: #0f172a; }
.btn-mini.ghost { background: rgba(99, 102, 241, 0.12); color: var(--primary); }
.status-tag { padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 600; text-transform: capitalize; background: #e2e8f0; color: #475569; }
.status-tag.active { background: rgba(34, 197, 94, 0.2); color: #15803d; }
.status-tag.inactive { background: rgba(248, 113, 113, 0.2); color: #b91c1c; }
.heat-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
.heat-list li { display: flex; justify-content: space-between; padding: 10px 12px; border-radius: 12px; background: #f8fafc; }
.rule-form { display: flex; flex-direction: column; gap: 12px; margin: 16px 0; }
.rule-form label { display: flex; flex-direction: column; gap: 6px; font-size: 12px; color: var(--text-light); }
.rule-form input,
.rule-form select,
.rule-form textarea { border: 1px solid #e2e8f0; border-radius: 12px; padding: 10px 12px; font-size: 13px; background: #f8fafc; }
.rule-form textarea { min-height: 70px; }
.rule-list ul { list-style: none; margin: 10px 0 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }
.rule-list li { display: flex; justify-content: space-between; align-items: center; padding: 10px 12px; border-radius: 12px; background: #f8fafc; cursor: pointer; }
.rule-list strong { display: block; font-size: 13px; }
.empty { text-align: center; color: #94a3b8; font-size: 13px; padding: 12px 0; }

@media (max-width: 1024px) {
  .manage-wrapper { flex-direction: column; }
  .bento-sidebar { width: 100%; position: static; }
  .form-layout { grid-template-columns: 1fr; }
  .condition-grid { grid-template-columns: 1fr; }
}
/* ============== AI 智能推荐活动类型 - 新增样式 ============== */

.ai-suggestion-box {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f0fdfa;
  border: 1px solid #a7f3d0;
  border-radius: 14px;
  font-weight: 600;
  color: #065f46;
  margin-bottom: 8px;
}

.ai-badge {
  background: #dcfce7;
  color: #16a34a;
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 999px;
  font-weight: bold;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.btn-edit-type {
  background: none;
  border: 1px solid #cbd5e1;
  border-radius: 10px;
  padding: 6px 12px;
  font-size: 12px;
  color: var(--text-light);
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 600;
}

.btn-edit-type:hover {
  background: #f1f5f9;
  border-color: var(--accent);
  color: var(--accent);
}

.ai-explain-text {
  font-size: 11px;
  color: #64748b;
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 4px;
  line-height: 1.4;
}

.ai-loading-hint {
  font-size: 13px;
  color: #94a3b8;
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.spinner {
  width: 14px;
  height: 14px;
  border: 2px solid #e2e8f0;
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.manual-type-select {
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 10px;
  background: white;
  font-size: 13px;
  width: 100%;
}
</style>