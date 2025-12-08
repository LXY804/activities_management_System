<template>
  <div class="page exchange-page" :style="bgStyle">
    <!-- 半透明遮罩，提升文字可读性 -->
    <div class="bg-overlay"></div>

    <div class="content">
      <NavBar />

      <div class="container">
        <h2 class="page-title">积分礼品兑换</h2>
      
        <!-- 礼品列表 -->
        <div class="gifts-grid">
          <div v-for="gift in gifts" :key="gift.id" class="gift-card">
            <div class="gift-image">
              <img :src="gift.image" :alt="gift.name" />
              </div>
            <div class="gift-info">
              <h3 class="gift-name">{{ gift.name }}</h3>
              <p class="gift-description">{{ gift.description }}</p>
              <div class="gift-footer">
                <span class="gift-points">{{ gift.points }} 积分</span>
                <span class="gift-stock">库存：{{ gift.stock }}</span>
              </div>
              <button 
                class="btn-exchange" 
                :disabled="userPoints < gift.points || gift.stock <= 0"
                @click="exchangeGift(gift)"
              >
                {{ userPoints < gift.points ? '积分不足' : (gift.stock <= 0 ? '已售罄' : '立即兑换') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
import { ref } from 'vue'
import libraryImg from '@/assets/图书馆.webp'

const bgStyle = {
  backgroundImage: `url(${libraryImg})`,
  backgroundSize: 'cover',
  backgroundPosition: 'center top',
  backgroundRepeat: 'no-repeat',
  backgroundAttachment: 'fixed',
  minHeight: '100vh'
}

// 用户积分（静态数据，后续可从 API 获取）
const userPoints = ref(1000)

// 礼品列表（静态数据，后续可从 API 获取）
const gifts = ref([
  {
    id: 1,
    name: '校园文创笔记本',
    description: '精美校园主题笔记本，记录你的校园生活',
    points: 200,
    stock: 50,
    image: 'https://via.placeholder.com/300x200?text=笔记本'
  },
  {
    id: 2,
    name: '定制帆布袋',
    description: '环保帆布袋，印有校园logo',
    points: 150,
    stock: 30,
    image: 'https://via.placeholder.com/300x200?text=帆布袋'
  },
  {
    id: 3,
    name: '校园咖啡券',
    description: '校内咖啡店优惠券，价值30元',
    points: 300,
    stock: 20,
    image: 'https://via.placeholder.com/300x200?text=咖啡券'
  },
  {
    id: 4,
    name: '图书借阅卡',
    description: '图书馆VIP借阅卡，延长借阅期限',
    points: 500,
    stock: 10,
    image: 'https://via.placeholder.com/300x200?text=借阅卡'
  },
  {
    id: 5,
    name: '校园纪念徽章',
    description: '限量版校园纪念徽章套装',
    points: 100,
    stock: 100,
    image: 'https://via.placeholder.com/300x200?text=徽章'
  },
  {
    id: 6,
    name: '运动装备券',
    description: '体育用品商店优惠券，价值50元',
    points: 400,
    stock: 15,
    image: 'https://via.placeholder.com/300x200?text=运动券'
  }
])

// 兑换礼品（静态交互，后续可接入 API）
const exchangeGift = (gift) => {
  if (userPoints.value < gift.points) {
    alert('积分不足，无法兑换')
    return
  }
  if (gift.stock <= 0) {
    alert('该礼品已售罄')
    return
  }
  
  if (confirm(`确定要用 ${gift.points} 积分兑换 ${gift.name} 吗？`)) {
    // 静态更新（后续改为 API 调用）
    userPoints.value -= gift.points
    gift.stock -= 1
    alert('兑换成功！请到指定地点领取礼品。')
    
    // TODO: 后续接入 API 时，改为：
    // try {
    //   await exchangeGiftAPI(gift.id)
    //   // 刷新数据
    // } catch (error) {
    //   alert('兑换失败：' + error.message)
    // }
  }
}
</script>

<style scoped>
.container {
  max-width: 1200px;
  margin: 18px auto;
  padding: 0 16px;
  background-color: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  padding-bottom: 24px;
}

.page-title {
  font-size: 24px;
  margin: 18px 0;
  font-weight: 700;
  color: #333;
  text-align: center;
}

/* 积分卡片 */
.points-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 20px;
  margin: 20px 0;
  color: #fff;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.points-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.points-label {
  font-size: 16px;
  opacity: 0.9;
}

.points-value {
  font-size: 32px;
  font-weight: 700;
}

/* 礼品网格 */
.gifts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.gift-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.gift-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.gift-image {
  width: 100%;
  height: 200px;
  overflow: hidden;
  background: #f5f5f5;
}

.gift-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.gift-info {
  padding: 16px;
}

.gift-name {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #333;
}

.gift-description {
  font-size: 14px;
  color: #666;
  margin: 0 0 12px 0;
  line-height: 1.5;
  min-height: 42px;
}

.gift-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.gift-points {
  font-size: 20px;
  font-weight: 700;
  color: #ff6b6b;
}

.gift-stock {
  font-size: 14px;
  color: #999;
}

.btn-exchange {
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 6px;
  background: #4caf50;
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-exchange:hover:not(:disabled) {
  background: #45a049;
}

.btn-exchange:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* 背景与遮罩 */
.page.exchange-page {
  position: relative;
}

.bg-overlay {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.6);
  pointer-events: none;
}

.content {
  position: relative;
  z-index: 2;
}

@media (max-width: 768px) {
  .gifts-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
  }
  
  .points-value {
    font-size: 24px;
  }
}
</style>
