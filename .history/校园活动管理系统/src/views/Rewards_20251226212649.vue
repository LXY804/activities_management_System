<template>
  <div class="premium-rewards-page">
    <NavBar />

    <main class="dashboard-container">
      <section class="hero-summary glass-card" v-if="summaryLoaded">
        <div class="summary-left">
          <div class="badge">🔥 热门激励中</div>
          <div class="points-display">
            <span class="label">我的可用积分</span>
            <h1 class="count">{{ summaryData.totalPoints }} <small>分</small></h1>
          </div>
        </div>

        <div class="metrics-row">
          <div class="metric-item hover-lift">
            <div class="icon-wrap red">📦</div>
            <div class="val">
              <strong>{{ recentOrders.length }}</strong>
              <p>本周兑换</p>
            </div>
          </div>
          <div class="metric-item hover-lift">
            <div class="icon-wrap green">🎁</div>
            <div class="val">
              <strong>{{ allGifts.length }}</strong>
              <p>活跃礼品</p>
            </div>
          </div>
          <div class="actions-wrap">
            <button class="modern-refresh-btn" @click="refreshAll" title="刷新数据">
              <span class="refresh-icon">🔄</span>
              <span>刷新数据</span>
            </button>
            <button class="modern-ranking-btn" @click="showRankingModal = true" title="查看积分排行榜">
              <span class="ranking-icon">🏆</span>
              <span>积分排行榜</span>
            </button>
            <p v-if="loginRequired" class="login-hint">需登录查看</p>
          </div>
        </div>
      </section>

      <div class="bento-grid">
        <section class="gift-section glass-card">
          <header class="section-header">
            <div class="header-main">
              <h2>礼品库 <span class="subtitle">今日甄选</span></h2>
            </div>
            <button class="shuffle-btn" @click="refreshGifts">
              <i class="shuffle-icon">↻</i>
              刷新
            </button>
          </header>

          <div class="scroll-area custom-scrollbar">
            <div v-if="loadingGifts" class="loading-state">
              <div class="shimmer"></div>
            </div>
            <div v-else-if="!displayedGifts.length" class="empty-state">
               <span class="empty-icon">❀</span>
               <p>目前还没有上架礼品哦</p>
            </div>
            <div v-else class="compact-gift-grid">
              <article v-for="gift in displayedGifts" :key="gift.id" class="mini-gift-card">
                <div class="card-image">
                  <img :src="gift.coverImage" :alt="gift.title" />
                  <div class="points-tag">{{ gift.pointsCost }} P</div>
                </div>
                <div class="card-info">
                  <h3>{{ gift.title }}</h3>
                  <div class="card-footer">
                    <span class="stock">剩 {{ gift.stock }}</span>
                    <button class="redeem-btn-modern" :disabled="gift.stock === 0" @click="openRedeem(gift)">
                      兑换
                    </button>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </section>

        <div class="insight-column">
          <section class="mini-panel glass-card">
            <h3>最近兑换</h3>
            <div class="list-container custom-scrollbar">
              <ul class="mini-order-list" v-if="recentOrders.length">
                <li v-for="order in recentOrders" :key="order.id" class="hover-item">
                  <span class="order-dot" :class="order.status"></span>
                  <p class="name">{{ order.giftTitle }}</p>
                  <span class="status-label">{{ mapStatus(order.status) }}</span>
                </li>
              </ul>
              <p v-else class="empty-sub">暂无兑换记录</p>
            </div>
          </section>

          <section class="mini-panel glass-card">
            <h3>积分动态</h3>
            <div class="list-container custom-scrollbar">
              <ul class="compact-timeline" v-if="recentTransactions.length">
                <li v-for="tx in recentTransactions" :key="tx.id" class="hover-item">
                  <div class="tx-info">
                    <p>{{ tx.remark || '积分变动' }}</p>
                    <small>{{ formatTime(tx.createdAt) }}</small>
                  </div>
                  <span class="tx-val" :class="{ plus: tx.changeAmount > 0 }">
                    {{ tx.changeAmount > 0 ? '+' : '' }}{{ tx.changeAmount }}
                  </span>
                </li>
              </ul>
              <p v-else class="empty-sub">暂无积分流水</p>
            </div>
          </section>
        </div>
      </div>
    </main>

    <div v-if="redeemState.open" class="redeem-overlay" @click.self="closeRedeem">
      <div class="redeem-sheet glass-panel animate-pop">
        <div class="sheet-header">
          <div class="sheet-icon-wrap">🎁</div>
          <h2>确认兑换</h2>
          <p class="gift-name-display">{{ redeemState.gift?.title }}</p>
        </div>

        <form @submit.prevent="submitRedeem" class="modern-form">
          <div class="form-grid">
            <div class="input-group">
              <label>兑换数量</label>
              <div class="number-input-wrap">
                <input type="number" min="1" v-model.number="redeemState.quantity" />
              </div>
            </div>
            <div class="input-group">
              <label>领取方式</label>
              <select v-model="redeemState.deliveryMethod">
                <option value="offline">线下领取</option>
                <option value="online">线上发放</option>
              </select>
            </div>
          </div>

          <div class="input-group">
            <label>联系人姓名</label>
            <input type="text" v-model.trim="redeemState.contactName" placeholder="请填写姓名，用于通知领取" />
          </div>

          <div class="input-group">
            <label>联系电话</label>
            <input type="text" v-model.trim="redeemState.contactPhone" placeholder="请填写常用手机号" />
          </div>

          <div class="sheet-actions">
            <button type="button" class="cancel-btn-modern" @click="closeRedeem">下次再说</button>
            <button type="submit" class="submit-btn-modern" :disabled="submittingRedeem">
              <span v-if="!submittingRedeem">确认消耗 <strong>{{ redeemCost }}</strong> 积分</span>
              <span v-else>正在处理中...</span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- 积分排行榜弹窗 -->
    <PointsRankingModal :visible="showRankingModal" @close="showRankingModal = false" />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import NavBar from '../components/NavBar.vue'
import PointsRankingModal from '../components/PointsRankingModal.vue'
import {
  fetchRewardsSummary,
  fetchGiftLibrary,
  redeemGift,
  fetchRewardOrders
} from '@/api/reward'

// --- 导入本地图片资产 ---
import img1 from '@/assets/校园定制水杯.jpg'
import img2 from '@/assets/活动加油礼包.jpg'
import img3 from '@/assets/线上音乐会门票.jpg'
import img4 from '@/assets/珞狮校园帆布包.jpg'
import img5 from '@/assets/余区纪念微章套装.jpg'
import img6 from '@/assets/龙舟体验券.jpg'
import img7 from '@/assets/夜游科普手账.jpg'
import img8 from '@/assets/材料实验室VIP参观券.jpg'
import img9 from '@/assets/校园咖啡券.jpg'
const assetImages = [img1, img2, img3, img4, img5, img6, img7, img8, img9]

// --- 逻辑与接口 ---
const summaryData = ref({ totalPoints: 0 })
const summaryLoaded = ref(false)
const loginRequired = ref(false)
const recentTransactions = ref([])
const submittingRedeem = ref(false)
const recentOrders = ref([])

const allGifts = ref([])         
const displayedGifts = ref([])   
const loadingGifts = ref(false)
const showRankingModal = ref(false)

const redeemState = reactive({
  open: false,
  gift: null,
  quantity: 1,
  contactName: '',
  contactPhone: '',
  deliveryMethod: 'offline',
  pickupLocation: ''
})

const redeemCost = computed(() => (redeemState.gift?.pointsCost || 0) * (redeemState.quantity || 1))

// API 基础路径
const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')

// 构建图片URL
const buildImageUrl = (imageUrl) => {
  if (!imageUrl) return assetImages[0] // 如果没有图片，使用默认图片
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl
  }
  let normalized = imageUrl.replace(/\\/g, '/')
  if (!normalized.startsWith('/')) {
    normalized = '/' + normalized
  }
  return API_ORIGIN + normalized
}

const formatGift = (gift, index) => ({
  ...gift,
  deliveryType: gift.deliveryType || gift.delivery_type || 'offline',
  // 优先使用数据库中的图片，如果没有则使用静态图片作为默认值
  coverImage: gift.coverImage ? buildImageUrl(gift.coverImage) : assetImages[index % assetImages.length]
})

const shuffleGifts = () => {
  if (allGifts.value.length === 0) return
  const shuffled = [...allGifts.value].sort(() => 0.5 - Math.random())
  displayedGifts.value = shuffled.slice(0, 6)
}

// 刷新礼品库（从服务器重新加载）
const refreshGiftLibrary = async () => {
  await refreshGifts()
}

const refreshGifts = async () => {
  loadingGifts.value = true
  try {
    const data = await fetchGiftLibrary()
    allGifts.value = data.map((gift, index) => formatGift(gift, index))
    shuffleGifts()
  } catch (err) {
    console.error("加载礼品库失败", err)
  } finally {
    loadingGifts.value = false
  }
}

const mapStatus = (s) => ({ pending: '待处理', processing: '进行中', shipped: '已完成' }[s] || s)
const formatTime = (v) => v ? new Date(v).toLocaleDateString() : '—'

const refreshSummary = async () => {
  try {
    const data = await fetchRewardsSummary()
    summaryData.value = data
    recentTransactions.value = data.recentTransactions || []
    summaryLoaded.value = true
  } catch (err) {
    summaryLoaded.value = true
    if (err?.response?.status === 401) loginRequired.value = true
  }
}

const refreshOrders = async () => {
  try {
    const orders = await fetchRewardOrders()
    recentOrders.value = orders.slice(0, 8)
  } catch (err) { console.error(err) }
}

const refreshAll = async () => Promise.all([refreshSummary(), refreshGifts(), refreshOrders()])
const openRedeem = (gift) => { redeemState.gift = gift; redeemState.open = true }
const closeRedeem = () => { redeemState.open = false; redeemState.gift = null }
const submitRedeem = async () => {
  submittingRedeem.value = true
  try {
    await redeemGift(redeemState.gift.id, { ...redeemState })
    closeRedeem(); refreshAll(); window.alert('兑换成功！')
  } catch (err) { window.alert(err?.response?.data?.message || '兑换失败') }
  finally { submittingRedeem.value = false }
}

onMounted(refreshAll)
</script>

<style scoped>
/* 核心布局与基础样式 */
.premium-rewards-page {
  --primary: #2dd4bf;
  --primary-hover: #14b8a6;
  --accent: #6366f1;
  --bg-gradient: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  --glass: rgba(255, 255, 255, 0.85);
  height: 100vh;
  background: var(--bg-gradient);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  color: #1e293b;
}

.dashboard-container {
  flex: 1;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 85px 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow: hidden; 
}

.glass-card {
  background: var(--glass);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 24px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
}

.hero-summary {
  padding: 24px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.points-display .count { font-size: 36px; font-weight: 800; color: #0f172a; margin: 0; }
.points-display .label { font-size: 13px; color: #64748b; font-weight: 600; }

.metrics-row { display: flex; gap: 30px; align-items: center; }
.metric-item { display: flex; align-items: center; gap: 12px; transition: 0.3s; }
.hover-lift:hover { transform: translateY(-3px); }

.icon-wrap {
  width: 44px; height: 44px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center; font-size: 18px;
}
.icon-wrap.red { background: #fee2e2; }
.icon-wrap.green { background: #dcfce7; }

.modern-refresh-btn {
  display: flex; align-items: center; gap: 8px;
  border: none; background: #f1f5f9; padding: 10px 18px;
  border-radius: 12px; cursor: pointer; transition: 0.3s;
  font-weight: 700; color: #64748b;
}
.modern-refresh-btn:hover { background: #e2e8f0; color: var(--accent); }
.modern-refresh-btn:active .refresh-icon { transform: rotate(180deg); }
.refresh-icon { transition: 0.5s; display: inline-block; }

.modern-ranking-btn {
  display: flex; align-items: center; gap: 8px;
  border: none; background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  padding: 10px 18px; border-radius: 12px; cursor: pointer; transition: 0.3s;
  font-weight: 700; color: white;
}
.modern-ranking-btn:hover { 
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(251, 191, 36, 0.3);
}
.modern-ranking-btn:active { transform: translateY(0); }
.ranking-icon { display: inline-block; }

.bento-grid { 
  flex: 1; 
  display: grid; 
  grid-template-columns: 1fr 340px; 
  gap: 20px; 
  overflow: hidden; 
}

.gift-section { 
  padding: 24px; 
  display: flex; 
  flex-direction: column; 
  overflow: hidden; 
}
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-shrink: 0; }

.shuffle-btn {
  display: flex; align-items: center; gap: 6px;
  background: white; border: 1px solid #e2e8f0;
  padding: 8px 16px; border-radius: 100px;
  font-size: 13px; font-weight: 700; color: var(--primary);
  cursor: pointer; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.shuffle-btn:hover {
  background: var(--primary); color: white;
  border-color: var(--primary); transform: translateY(-1px);
}
.shuffle-icon { font-style: normal; font-size: 16px; transition: 0.6s; }

.scroll-area { 
  flex: 1; 
  overflow-y: auto; 
  padding-right: 12px; 
  margin-right: -4px;
}

.compact-gift-grid { 
  display: grid; 
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); 
  gap: 16px; 
  padding-bottom: 20px; 
}

.custom-scrollbar::-webkit-scrollbar { 
  width: 6px; 
}
.custom-scrollbar::-webkit-scrollbar-thumb { 
  background: #cbd5e1; 
  border-radius: 10px; 
}

.mini-gift-card {
  background: white; border-radius: 20px; overflow: hidden;
  border: 1px solid #f1f5f9; transition: all 0.4s ease;
}
.mini-gift-card:hover { transform: translateY(-6px); box-shadow: 0 12px 24px rgba(0, 0, 0, 0.06); border-color: var(--primary); }

.card-image { height: 150px; position: relative; }
.card-image img { width: 100%; height: 100%; object-fit: cover; }
.points-tag {
  position: absolute; top: 10px; left: 10px; background: rgba(15, 23, 42, 0.8);
  color: white; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 8px; backdrop-filter: blur(4px);
}

.card-info { padding: 14px; }
.card-info h3 { font-size: 15px; margin: 0 0 12px; color: #334155; }
.card-footer { display: flex; justify-content: space-between; align-items: center; }
.stock { font-size: 11px; color: #94a3b8; }

.redeem-btn-modern {
  background: var(--primary); color: white; border: none;
  padding: 8px 16px; border-radius: 10px; font-size: 12px;
  font-weight: 800; cursor: pointer; transition: 0.3s;
}

.insight-column { display: flex; flex-direction: column; gap: 20px; overflow: hidden; }
.mini-panel { padding: 20px; display: flex; flex-direction: column; flex: 1; overflow: hidden; }
.list-container { flex: 1; overflow-y: auto; }

.hover-item {
  display: flex; align-items: center; gap: 12px; padding: 12px;
  border-radius: 14px; transition: 0.2s; border-bottom: 1px solid #f8fafc;
}
.order-dot { width: 8px; height: 8px; border-radius: 50%; background: #cbd5e1; }
.order-dot.shipped { background: var(--primary); }
.status-label { font-size: 11px; color: #64748b; background: #f1f5f9; padding: 2px 8px; border-radius: 6px; }
.tx-val { font-weight: 800; font-size: 14px; color: #ef4444; }
.tx-val.plus { color: var(--primary); }

/* --- 重点：弹窗美化样式 --- */

.redeem-overlay {
  position: fixed; inset: 0; background: rgba(15, 23, 42, 0.5);
  backdrop-filter: blur(10px); z-index: 2000; display: flex; align-items: center; justify-content: center;
  padding: 20px;
}

.redeem-sheet { 
  width: 100%;
  max-width: 460px; 
  padding: 40px; 
  background: rgba(255, 255, 255, 0.9);
  border-radius: 32px; 
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.sheet-header { text-align: center; margin-bottom: 30px; }
.sheet-icon-wrap { 
  font-size: 40px; margin-bottom: 15px; 
  background: #f0fdfa; width: 80px; height: 80px; 
  display: flex; align-items: center; justify-content: center;
  border-radius: 24px; margin: 0 auto 15px;
}
.sheet-header h2 { font-size: 24px; font-weight: 800; color: #0f172a; margin-bottom: 8px; }
.gift-name-display { font-size: 16px; color: var(--primary); font-weight: 700; }

.modern-form { display: flex; flex-direction: column; gap: 20px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

.input-group { display: flex; flex-direction: column; gap: 8px; }
.input-group label { font-size: 13px; font-weight: 700; color: #64748b; margin-left: 4px; }

/* 输入框统一风格 */
.modern-form input, .modern-form select {
  padding: 12px 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  font-size: 14px;
  color: #334155;
  transition: all 0.2s ease;
  outline: none;
}

.modern-form input:focus, .modern-form select:focus {
  background: white;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(45, 212, 191, 0.1);
}

.sheet-actions { 
  display: grid; grid-template-columns: 100px 1fr; gap: 12px; margin-top: 15px; 
}

.cancel-btn-modern {
  background: #f1f5f9; color: #94a3b8; border: none;
  border-radius: 14px; font-weight: 700; font-size: 14px;
  cursor: pointer; transition: 0.2s;
}
.cancel-btn-modern:hover { background: #e2e8f0; color: #64748b; }

.submit-btn-modern {
  background: linear-gradient(135deg, var(--primary) 0%, #0d9488 100%);
  color: white; border: none; padding: 16px;
  border-radius: 14px; font-weight: 700; font-size: 15px;
  cursor: pointer; transition: 0.3s;
  box-shadow: 0 4px 12px rgba(45, 212, 191, 0.3);
}
.submit-btn-modern:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(45, 212, 191, 0.4); filter: brightness(1.05); }
.submit-btn-modern strong { font-size: 18px; }

.animate-pop { animation: pop 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
@keyframes pop { from { opacity: 0; transform: scale(0.9) translateY(20px); } to { opacity: 1; transform: scale(1) translateY(0); } }

@media (max-width: 1024px) {
  .dashboard-container { height: auto; overflow: visible; padding-top: 80px; }
  .bento-grid { grid-template-columns: 1fr; }
  .premium-rewards-page { overflow-y: auto; }
  .scroll-area { max-height: 500px; }
}
</style>