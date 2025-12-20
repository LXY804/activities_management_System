<template>
  <div class="premium-forum-container">
    <NavBar />
    <div class="forum-body-wrapper">
      <main class="forum-canvas-container" :style="{ backgroundImage: `url(${mapImage})` }">
        <div class="fixed-portal-ui" v-if="activeCategoryId === null">
          <div class="text-manifesto">
            <h1>论坛交流 Space</h1>
            <p class="desc">
              点击地图上的图标进入对应板块。<br />
              分享闲置、寻求帮助、记录校园趣闻。
            </p>
          </div>
          <div class="identity-panel">
            <div class="mode-pill" :class="currentUser.role">
              <span class="breathing-dot"></span>
              <span class="label">{{ currentUser.role === 'admin' ? '管理员 (监管)' : '普通校友' }}</span>
            </div>
          </div>
        </div>
        <section v-if="activeCategoryId === null" class="map-interactive-layer animate-fade">
          <button class="raw-map-anchor" style="left: 50%; top: 12%;" @click="goBoard(0)">
            <div class="icon-img-host">
              <img src="@/assets/人员信息.svg" class="raw-icon" />
            </div>
            <div class="anchor-label">全部动态</div>
          </button>
          <button
            v-for="item in forumCategories"
            :key="item.id"
            class="raw-map-anchor"
            :style="item.position"
            @click="goBoard(item.id)"
          >
            <div class="icon-img-host">
              <img :src="item.icon" class="raw-icon" />
            </div>
            <div class="anchor-label">{{ item.name }}</div>
          </button>
        </section>
        <transition name="panel-slide">
          <section v-if="activeCategoryId !== null" class="board-panel-overlay">
            <div class="board-glass-box glass-blur">
              <header class="panel-navbar">
                <div class="panel-navbar-top">
                  <div class="panel-nav-left">
                    <button class="back-btn-vibe" @click="goPortal">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/></svg>
                    </button>
                    <div class="panel-title-group">
                      <h2>{{ currentBoardName }}</h2>
                      <p>WHUT · 校园共创空间 / {{ currentBoardName }}</p>
                    </div>
                  </div>
                  <div class="panel-nav-center">
                    <div class="glass-search-input">
                      <span class="s-icon">🔍</span>
                      <input v-model.trim="keyword" type="text" placeholder="搜索标题或内容中的关键词..." />
                    </div>
                  </div>
                </div>
                <div class="panel-navbar-bottom">
                  <div class="panel-nav-right">
                    <div class="tab-pill-container custom-scrollbar">
                      <button
                        v-for="btn in [{id:0, name:'全部'}, ...forumCategories]"
                        :key="btn.id"
                        :class="['nav-pill-btn', { active: activeCategoryId === btn.id }]"
                        @click="goBoard(btn.id)"
                      >
                        {{ btn.name }}
                      </button>
                    </div>
                  </div>
                </div>
              </header>
              <section class="board-hero" v-if="currentCategoryMeta">
                <div class="hero-info">
                  <span class="hero-icon" aria-hidden="true">{{ currentCategoryMeta.emoji }}</span>
                  <div>
                    <p class="hero-label">{{ currentCategoryMeta.label }}</p>
                    <h3>{{ currentCategoryMeta.desc }}</h3>
                    <small>{{ currentCategoryMeta.tip }}</small>
                  </div>
                </div>
                <div class="hero-stats">
                  <div class="hero-stat">
                    <strong>{{ activeCategoryPostCount }}</strong>
                    <span>板块帖子</span>
                  </div>
                  <div class="hero-stat">
                    <strong>{{ mockPosts.length }}</strong>
                    <span>全站累计</span>
                  </div>
                </div>
              </section>
              <div class="panel-main-grid">
                <aside class="panel-side-bento">
                  <div class="white-bento-card publish-card">
                    <div class="bento-card-head">
                      <div class="compose-icon" aria-hidden="true">✍️</div>
                      <div>
                        <p>发布新讨论</p>
                        <small>{{ currentCategoryMeta.tip }}</small>
                      </div>
                    </div>
                    <div class="bento-form-scroll custom-scrollbar">
                      <form @submit.prevent="publishPost" class="bento-form">
                        <input v-model.trim="publishForm.title" type="text" placeholder="标题 (吸引大家点击...)" required />
                        <textarea v-model.trim="publishForm.content" rows="6" placeholder="分享今天的见闻、求助信息或出物详情..." required></textarea>
                        <div class="bento-upload-area">
                          <p>附件图片（最多3张）</p>
                          <div class="upload-drop-zone" @click.prevent="triggerImagePicker">
                            <div class="upload-cta">
                              <span class="upload-icon" aria-hidden="true">📁</span>
                              <div>
                                <strong>选择图片文件夹</strong>
                                <small>点击此区域或拖拽图片，自动上限 3 张</small>
                              </div>
                            </div>
                            <input ref="imagePicker" class="hidden-file-input" type="file" accept="image/*" multiple @change="handleImageSelect" />
                          </div>
                          <div class="upload-preview-row" v-if="imagePreviewList.length">
                            <div class="upload-chip" v-for="(img, idx) in imagePreviewList" :key="img + idx">
                              <img :src="img" alt="preview" />
                              <span>图片 {{ idx + 1 }}</span>
                            </div>
                          </div>
                        </div>
                        <div class="bento-footer">
                          <label v-if="currentUser.role === 'admin'" class="sticky-check-wrap">
                            <input type="checkbox" v-model="publishForm.isSticky" />
                            <span>置顶</span>
                          </label>
                          <div class="bento-action-btns">
                            <button type="button" class="btn-cancel" @click="resetForm">取消</button>
                            <button type="submit" class="btn-send-grad">确认发布</button>
                          </div>
                        </div>
                      </form>
                    </div>
                  </div>
                  <div class="white-bento-card mt-20 stats-infographic">
                    <div class="info-row">
                      <div class="info-cell">
                        <span class="val">{{ mockPosts.length }}</span>
                        <span class="lab">累计动态</span>
                      </div>
                      <div class="info-cell">
                        <span class="val">{{ activeCategoryPostCount }}</span>
                        <span class="lab">本版块</span>
                      </div>
                    </div>
                  </div>
                </aside>
                <main class="panel-feed-container custom-scrollbar">
                  <transition-group name="post-anim">
                    <article
                      v-for="post in filteredPosts"
                      :key="post.id"
                      class="post-premium-card"
                      :class="{ 'sticky-active': post.isSticky, 'solved-state': post.status === 'solved' }"
                    >
                      <div class="p-card-header">
                        <div class="p-author">
                          <div class="p-avatar" :style="{ background: generateColor(post.userName) }">
                            {{ post.userName.charAt(0) }}
                          </div>
                          <div class="p-meta">
                            <span class="p-name">{{ post.userName }}</span>
                            <span class="p-time">{{ formatTime(post.createdAt) }}</span>
                          </div>
                        </div>
                        <div class="p-label-group">
                          <span v-if="post.isSticky" class="p-tag-vibe sticky">置顶公告</span>
                          <span v-if="post.status === 'solved'" class="p-tag-vibe solved">已结帖</span>
                          <span class="p-tag-vibe cat">{{ getCatName(post.categoryId) }}</span>
                        </div>
                      </div>
                      <div class="p-card-body">
                        <h3>{{ post.title }}</h3>
                        <p class="content-text">{{ post.content }}</p>
                        <div v-if="post.images.length" class="p-image-matrix" :class="'grid-' + post.images.length">
                          <img v-for="img in post.images" :key="img" :src="img" alt="attachment" />
                        </div>
                      </div>
                      <footer class="p-card-footer">
                        <div class="comment-stream-box" v-if="post.comments.length">
                          <div v-for="c in post.comments" :key="c.id" class="c-item-row">
                            <strong>{{ c.userName }}:</strong> {{ c.content }}
                          </div>
                        </div>
                        <div class="interaction-control">
                          <form @submit.prevent="addComment(post)" class="reply-form-vibe">
                            <input v-model.trim="commentDrafts[post.id]" placeholder="回帖交流..." />
                          </form>
                          <div class="op-btns-group">
                            <button v-if="currentUser.role === 'admin'" class="btn-text-op" @click="toggleSticky(post)">
                              {{ post.isSticky ? '取消置顶' : '置顶' }}
                            </button>
                            <button v-if="isMyPost(post)" class="btn-text-op" @click="handleStatusToggle(post)">
                              {{ post.status === 'active' ? '标记解决' : '重新开启' }}
                            </button>
                            <button v-if="canDelete(post)" class="btn-text-op danger" @click="handleDelete(post.id)">删除</button>
                          </div>
                        </div>
                      </footer>
                    </article>
                  </transition-group>
                  <div v-if="filteredPosts.length === 0" class="empty-vibe">
                    <p>🍃 暂无匹配动态，换个分类看看吧</p>
                  </div>
                </main>
              </div>
            </div>
          </section>
        </transition>
      </main>
    </div>
    <div class="decoration-blobs">
      <div class="blob b1"></div>
      <div class="blob b2"></div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted, onBeforeUnmount } from 'vue'
import NavBar from '@/components/NavBar.vue'
import mapImage from '@/assets/论坛背景图.jpg'
import iconResale from '@/assets/论坛-二手闲置.png'
import iconHelp from '@/assets/论坛-打听求助.png'
import iconLove from '@/assets/论坛-恋爱交友.png'
import iconFun from '@/assets/论坛-校园趣事.png'
import iconJob from '@/assets/论坛-兼职招聘.png'

const forumCategories = [
  { id: 1, name: '二手闲置', position: { left: '20%', top: '88%' }, icon: iconResale },
  { id: 2, name: '打听求助', position: { left: '66%', top: '24%' }, icon: iconHelp },
  { id: 3, name: '恋爱交友', position: { left: '85%', top: '67%' }, icon: iconLove },
  { id: 4, name: '校园趣事', position: { left: '42%', top: '50%' }, icon: iconFun },
  { id: 5, name: '兼职招聘', position: { left: '74%', top: '76%' }, icon: iconJob }
]

const categoryMetaMap = {
  0: { label: '理大广场', emoji: '🌿', desc: '随手记录你的校园瞬间', tip: '发布任何灵感或即时想法' },
  1: { label: '二手闲置', emoji: '🧺', desc: '交换闲置好物，拒绝浪费', tip: '别忘了写明价格与取货点' },
  2: { label: '打听求助', emoji: '🧠', desc: '提问、求助，校园智囊团在线', tip: '描述清楚遇到的问题' },
  3: { label: '恋爱交友', emoji: '💌', desc: '用真诚邂逅好朋友', tip: '礼貌表达，尊重彼此边界' },
  4: { label: '校园趣事', emoji: '📸', desc: '分享有趣瞬间与灵感', tip: '可配图记录高光时刻' },
  5: { label: '兼职招聘', emoji: '💼', desc: '寻找靠谱兼职与合作', tip: '说明薪酬与时间范围' }
}

const currentUser = reactive({
  id: Number(localStorage.getItem('userId')) || 777,
  role: localStorage.getItem('userRole') || 'admin',
  name: localStorage.getItem('nickname') || '理大小青'
})

const activeCategoryId = ref(null)
const keyword = ref('')
const commentDrafts = reactive({})
const publishForm = reactive({ title: '', content: '', imageInputs: ['', '', ''], isSticky: false })
const imagePicker = ref(null)
const tempImageUrls = ref([])

const currentCategoryMeta = computed(() => {
  const target = activeCategoryId.value ?? 0
  return categoryMetaMap[target] || categoryMetaMap[0]
})
const imagePreviewList = computed(() => publishForm.imageInputs.filter(src => src))

const mockPosts = reactive([
  { id: 1, categoryId: 1, userId: 101, userName: '南湖余文乐', title: '【急出】南湖西院出Giant公路车，碟刹24速', content: '由于毕业无法带走，极品成色。原价2800购入，现价1100。南湖校区自提，车况非常好，送车锁。', status: 'active', isSticky: true, createdAt: '2025-05-18T10:00:00Z', images: ['https://img.alicdn.com/imgextra/i4/1596671518/O1CN01pBikeC1d2v8b3MtMz_!!0-item_pic.jpg'], comments: [{ id: 1, userName: '鉴湖车神', content: '鉴主教学楼这边能骑过来看看吗？' }] },
  { id: 2, categoryId: 2, userId: 202, userName: '鉴湖钉子户', title: '求助：博学楼302有没有捡到一个蓝色钥匙包？', content: '昨晚在那自习，里面有升升公寓的门禁卡和两把宿舍钥匙，真的很急，今天还要回寝室。', status: 'active', isSticky: false, createdAt: '2025-05-19T08:30:00Z', images: [], comments: [{ id: 2, userName: '理大暖男', content: '我刚才去302看了一眼，去一楼保安亭问问？' }] },
  { id: 3, categoryId: 4, userId: 303, userName: '南湖大橘粉', title: '南湖图书馆后门的猫猫又胖了，大家真的别喂火腿肠了！', content: '宿管阿姨说它最近已经跳不上窗台了，建议大家换成健康的冻干或者猫粮。', status: 'active', isSticky: false, createdAt: '2025-05-20T14:20:00Z', images: ['https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500'], comments: [{ id: 3, userName: '喵星人', content: '它是真的心宽体胖。' }] },
  { id: 4, categoryId: 5, userId: 404, userName: '校团委兼职组', title: '【官方招募】校园文创市集执行志愿者，有补贴', content: '本周五下午校门口。协助布展。表现优异送理大限定帆布包。', status: 'active', isSticky: true, createdAt: '2025-05-14T09:00:00Z', images: [], comments: [] },
  { id: 5, categoryId: 3, userId: 505, userName: '鉴湖晚风', title: '寻找每天在鉴湖边晨读的那个戴蓝色耳机的女孩', content: '你经常在早上7点左右出现，读的是托尔斯泰，感觉很有气质，想交个朋友。', status: 'active', isSticky: false, createdAt: '2025-05-20T19:00:00Z', images: [], comments: [] },
  { id: 6, categoryId: 1, userId: 606, userName: '考研退坑小张', title: '出全套考研数学资料（武忠祥+李永乐）', content: '全是新的，还没翻就保研了，南湖图书馆面交。', status: 'active', isSticky: false, createdAt: '2025-05-18T16:00:00Z', images: ['https://img.alicdn.com/imgextra/i3/2208035252538/O1CN01Z7z6hJ1Q2Y8N0V7Yp_!!2208035252538.jpg'], comments: [] },
  { id: 7, categoryId: 2, userId: 707, userName: '小白本白', title: '救命！鉴主402的插座怎么没电了？', content: '电脑快关机了，有没有同学知道那边的电表开关在哪？', status: 'solved', isSticky: false, createdAt: '2025-05-19T10:00:00Z', images: [], comments: [] },
  { id: 8, categoryId: 4, userId: 808, userName: '理大摄影师', title: '今日份鉴湖夕阳，理大yyds！', content: '理大的夏天虽然热，但夕阳真的从不让人失望！毕业快乐！', status: 'active', isSticky: false, createdAt: '2025-05-20T19:30:00Z', images: ['https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500'], comments: [] },
  { id: 9, categoryId: 5, userId: 909, userName: '研会公关部', title: '急招：晚会短视频剪辑助手', content: '熟悉PR/剪映即可，酬劳面议，管饭！', status: 'active', isSticky: false, createdAt: '2025-05-20T11:00:00Z', images: [], comments: [] },
  { id: 11, categoryId: 1, userId: 111, userName: '转专业的小苏', title: '低价出大一计算机专业课教材，九成新', content: 'C语言、数据结构、计算机组成原理。南湖校区面交。', status: 'active', isSticky: false, createdAt: '2025-05-17T09:00:00Z', images: [], comments: [] },
  { id: 12, categoryId: 2, userId: 222, userName: '赶论文的人', title: '求助：南湖校区哪家打印店现在还开门？', content: '要在12点前打出初稿，西院后街的都关了。', status: 'active', isSticky: false, createdAt: '2025-05-20T22:30:00Z', images: [], comments: [] },
  { id: 13, categoryId: 3, userId: 333, userName: '吃瓜群众', title: '今天的鉴湖边有大动作！', content: '看到有人在布置玫瑰花阵，难道是哪个学院的求婚吗？', status: 'active', isSticky: false, createdAt: '2025-05-19T17:00:00Z', images: [], comments: [] },
  { id: 14, categoryId: 4, userId: 444, userName: '升升原住民', title: '升升二食堂的麻辣烫涨价了...', content: '心碎，以前10块钱吃到撑，现在要15了。', status: 'active', isSticky: false, createdAt: '2025-05-18T12:00:00Z', images: [], comments: [] },
  { id: 15, categoryId: 2, userId: 555, userName: '求职老鸟', title: '有没有推荐的刷题网站？', content: '除了力扣和牛客，还有没有比较适合理大计算机考研/找工作的。', status: 'active', isSticky: false, createdAt: '2025-05-15T14:00:00Z', images: [], comments: [] },
  { id: 16, categoryId: 1, userId: 666, userName: '电赛退坑', title: '出一堆电赛元器件，还有电烙铁', content: '包含各种传感器、STM32核心板，通通白菜价处理。', status: 'active', isSticky: false, createdAt: '2025-05-20T08:00:00Z', images: [], comments: [] }
])

const currentBoardName = computed(() => {
  if (activeCategoryId.value === 0) return '理大广场 · 全部动态'
  return forumCategories.find(c => c.id === activeCategoryId.value)?.name || ''
})
const activeCategoryPostCount = computed(() => {
  if (activeCategoryId.value === 0) return mockPosts.length
  return mockPosts.filter(p => p.categoryId === activeCategoryId.value).length
})
const filteredPosts = computed(() => {
  let list = [...mockPosts]
  if (activeCategoryId.value !== 0 && activeCategoryId.value !== null) {
    list = list.filter(p => p.categoryId === activeCategoryId.value)
  }
  if (keyword.value) {
    const k = keyword.value.toLowerCase()
    list = list.filter(p => p.title.toLowerCase().includes(k) || p.content.toLowerCase().includes(k))
  }
  return list.sort((a, b) => b.isSticky - a.isSticky || new Date(b.createdAt) - new Date(a.createdAt))
})

const releaseTempImageUrls = () => {
  tempImageUrls.value.forEach(url => URL.revokeObjectURL(url))
  tempImageUrls.value = []
}
const handleImageSelect = (event) => {
  const files = Array.from(event.target?.files || []).slice(0, 3)
  releaseTempImageUrls()
  const urls = files.map(file => URL.createObjectURL(file))
  tempImageUrls.value = urls
  publishForm.imageInputs = ['', '', '']
  urls.forEach((url, idx) => { publishForm.imageInputs[idx] = url })
  event.target.value = ''
}
const triggerImagePicker = () => { imagePicker.value?.click() }
const goBoard = (id) => { activeCategoryId.value = id; keyword.value = '' }
const goPortal = () => { activeCategoryId.value = null }
const getCatName = (id) => forumCategories.find(c => c.id === id)?.name || '未分类'
const isMyPost = (post) => post.userId === currentUser.id
const canDelete = (post) => currentUser.role === 'admin' || post.userId === currentUser.id

const resetForm = () => {
  publishForm.title = ''
  publishForm.content = ''
  publishForm.imageInputs = ['', '', '']
  releaseTempImageUrls()
  if (imagePicker.value) imagePicker.value.value = ''
}

const publishPost = () => {
  if (!publishForm.title || !publishForm.content) return
  mockPosts.unshift({
    id: Date.now(),
    categoryId: activeCategoryId.value === 0 ? 4 : activeCategoryId.value,
    userId: currentUser.id,
    userName: currentUser.name,
    title: publishForm.title,
    content: publishForm.content,
    status: 'active',
    isSticky: currentUser.role === 'admin' ? publishForm.isSticky : false,
    createdAt: new Date().toISOString(),
    images: publishForm.imageInputs.filter(v => v !== ''),
    comments: []
  })
  resetForm()
}

const addComment = (post) => {
  const text = commentDrafts[post.id]
  if (!text) return
  post.comments.push({ id: Date.now(), userName: currentUser.name, content: text })
  commentDrafts[post.id] = ''
}
const handleStatusToggle = (p) => p.status = p.status === 'active' ? 'solved' : 'active'
const toggleSticky = (p) => p.isSticky = !p.isSticky

const handleDelete = (id) => {
  if(!confirm('确定删除吗？')) return
  const idx = mockPosts.findIndex(p => p.id === id)
  if (idx !== -1) mockPosts.splice(idx, 1)
}
const formatTime = (v) => {
  const d = new Date(v)
  return `${d.getMonth()+1}/${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
}
const generateColor = (name) => {
  const colors = ['#6366f1', '#10b981', '#f59e0b', '#3b82f6', '#ef4444', '#0db18c']
  return colors[name.length % colors.length]
}

onMounted(() => {
  const role = localStorage.getItem('userRole')
  if (role) currentUser.role = role
})
onBeforeUnmount(() => {
  releaseTempImageUrls()
})
</script>

<style scoped>
.premium-forum-container {
  --sidebar-w: 220px;
  --topbar-h: 60px;
  --mint: #0db18c;
  --bg-dark: #0f172a;
  min-height: 100vh;
  width: 100%;
  overflow: hidden;
  position: relative;
  background: #f1f5f9;
}
.forum-body-wrapper {
  margin-top: 0;
  min-height: calc(100vh - var(--topbar-h));
  display: flex;
}
.forum-canvas-container {
  flex: 1;
  min-height: calc(100vh + 200px);
  width: 100%;
  padding-bottom: 200px;
  background-size: cover;
  background-position: center top;
  background-repeat: no-repeat;
  background-attachment: fixed;
  position: relative;
  overflow: visible;
}
.fixed-portal-ui {
  position: absolute;
  top: 40px;
  left: 40px;
  z-index: 10;
  pointer-events: none;
}
.text-manifesto h1 {
  font-size: 3.8rem;
  font-weight: 900;
  color: var(--bg-dark);
  margin: 0;
  letter-spacing: -4px;
}
.text-manifesto .desc {
  font-size: 1.25rem;
  color: #f0f7ff;
  margin: 15px 0 25px;
  line-height: 1.6;
}
.mode-pill {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.95);
  padding: 12px 28px;
  border-radius: 100px;
  font-weight: 800;
  font-size: 15px;
  box-shadow: 0 15px 35px rgba(0,0,0,0.08);
  pointer-events: auto;
}
.mode-pill.admin { color: #f43f5e; border: 1px solid #fecaca; }
.breathing-dot { width: 10px; height: 10px; border-radius: 50%; background: currentColor; animation: indicator-glow 2s infinite; }
.map-interactive-layer { width: 100%; height: 100%; position: relative; }
.raw-map-anchor {
  position: absolute;
  transform: translate(-50%, -50%);
  border: none;
  background: transparent;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  z-index: 5;
  padding: 12px;
}
.icon-img-host {
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.raw-icon {
  width: 100%; height: 100%; object-fit: contain;
  filter: drop-shadow(0 10px 15px rgba(0,0,0,0.3));
}
.anchor-label {
  margin-top: 15px;
  background: var(--bg-dark);
  color: white;
  padding: 8px 18px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 800;
  opacity: 0;
  transform: translateY(10px);
  transition: 0.3s;
}
.raw-map-anchor:hover .icon-img-host { transform: scale(1.3) translateY(-10px); }
.raw-map-anchor:hover .anchor-label { opacity: 1; transform: translateY(0); }
.board-panel-overlay {
  position: absolute;
  inset: 0;
  z-index: 100;
  background: rgba(241, 245, 249, 0.45);
  backdrop-filter: blur(8px);
  display: flex;
  justify-content: center;
  padding: 30px;
}
.board-glass-box {
  width: 100%;
  max-width: 1400px;
  height: 100%;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(40px);
  border-radius: 40px;
  border: 1px solid rgba(255,255,255,0.6);
  display: flex; flex-direction: column; overflow: hidden;
}
.panel-navbar {
  padding: 24px 40px;
  border-bottom: 1px solid rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.panel-navbar-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
}
.board-hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 24px 40px 0;
  padding: 28px 36px;
  border-radius: 32px;
  background: linear-gradient(120deg, rgba(255, 255, 255, 0.85), rgba(230, 245, 255, 0.9));
  border: 1px solid rgba(255,255,255,0.6);
  box-shadow: 0 20px 50px rgba(15, 29, 51, 0.08);
  gap: 30px;
}
.hero-info { display: flex; align-items: center; gap: 22px; }
.hero-icon {
  width: 72px; height: 72px;
  border-radius: 20px;
  background: rgba(13, 177, 140, 0.12);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;
}
.hero-label { margin: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 2px; color: #94a3b8; }
.board-hero h3 { margin: 4px 0; font-size: 24px; color: #0f172a; }
.hero-stats { display: flex; gap: 22px; }
.hero-stat { min-width: 120px; text-align: center; background: rgba(255,255,255,0.8); border-radius: 20px; padding: 12px 18px; }
.hero-stat strong { display: block; font-size: 26px; color: #0f172a; }
.hero-stat span { color: #94a3b8; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
.panel-nav-left { display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }
.panel-nav-center { flex: 1; min-width: 260px; display: flex; justify-content: flex-end; }
.back-btn-vibe {
  width: 50px; height: 50px; border-radius: 50%; border: none;
  background: var(--bg-dark); color: white; cursor: pointer; font-size: 20px;
  display: flex; align-items: center; justify-content: center; transition: 0.3s;
}
.back-btn-vibe:hover { transform: scale(1.1); background: var(--mint); }
.panel-title-group h2 { font-size: 28px; font-weight: 900; margin: 0; color: var(--bg-dark); }
.panel-title-group p { font-size: 11px; color: #94a3b8; font-weight: 800; text-transform: uppercase; margin-top: 3px; }
.glass-search-input {
  background: white; border-radius: 100px; padding: 0 24px;
  display: flex; align-items: center; width: 100%; max-width: 460px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);
}
.glass-search-input input { border: none; padding: 14px; width: 100%; outline: none; font-weight: 600; background: transparent; }
.panel-nav-right {
  width: 100%;
  background: #f8fafc;
  border-radius: 30px;
  padding: 20px 24px;
  border: 1px solid rgba(148, 163, 184, 0.4);
  box-shadow: 0 12px 35px rgba(15, 23, 42, 0.08);
  overflow-x: auto;
}
.tab-pill-container { display: flex; gap: 12px; flex-wrap: wrap; }
.nav-pill-btn {
  border: none; background: white; padding: 12px 28px; border-radius: 14px;
  font-weight: 800; color: #64748b; cursor: pointer; white-space: nowrap;
  transition: 0.3s;
}
.nav-pill-btn.active { background: var(--mint); color: white; box-shadow: 0 8px 20px rgba(13, 177, 140, 0.3); }
.panel-main-grid { flex: 1; display: grid; grid-template-columns: 360px 1fr; gap: 36px; padding: 30px 40px 40px; overflow: hidden; }

.publish-card { 
  display: flex; 
  flex-direction: column; 
  max-height: calc(100vh - 420px); 
  min-height: 500px;
}
.bento-card-head { flex-shrink: 0; display: flex; align-items: center; gap: 14px; margin-bottom: 20px; }
.bento-card-head p { margin: 0; font-weight: 900; font-size: 18px; color: #0f172a; }
.bento-card-head small { color: #94a3b8; }
.bento-form-scroll { 
  flex: 1; 
  overflow-y: auto !important; 
  padding-right: 8px; 
  padding-bottom: 40px; 
}

.white-bento-card { background: white; border-radius: 36px; padding: 35px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
.compose-icon {
  width: 54px; height: 54px;
  border-radius: 16px;
  background: rgba(15, 29, 51, 0.08);
  display: flex; align-items: center; justify-content: center;
  font-size: 24px;
}
.bento-form { display: flex; flex-direction: column; gap: 15px; }
.bento-form input, .bento-form textarea {
  border: 1px solid #f1f5f9; padding: 18px; border-radius: 20px; background: #f8fafc; outline: none; font-size: 15px;
}
.bento-form input:focus, .bento-form textarea:focus { border-color: var(--mint); background: white; }

.bento-footer { display: flex; flex-direction: column; gap: 18px; margin-top: 20px; }
.bento-action-btns { display: flex; gap: 12px; width: 100%; }
.btn-cancel {
  flex: 1; background: #f3f4f6; color: #6b7280; border: none; padding: 14px 0;
  border-radius: 100px; font-weight: 800; cursor: pointer; transition: all 0.3s;
}
.btn-cancel:hover { background: #e5e7eb; color: #111827; }
.btn-send-grad {
  flex: 2; background: var(--bg-dark); color: white; border: none; padding: 14px 0;
  border-radius: 100px; font-weight: 800; cursor: pointer; transition: all 0.3s;
}
.btn-send-grad:hover { transform: translateY(-3px); background: var(--mint); box-shadow: 0 10px 20px rgba(13, 177, 140, 0.2); }

.bento-upload-area { background: rgba(248, 250, 252, 0.7); border: 1px dashed rgba(148,163,184,0.6); border-radius: 26px; padding: 18px 22px; display: flex; flex-direction: column; gap: 14px; }
.bento-upload-area p { font-size: 12px; font-weight: 800; color: #94a3b8; margin: 0; letter-spacing: 0.5px; }
.upload-drop-zone { position: relative; border: 1px dashed rgba(99, 102, 241, 0.4); border-radius: 24px; padding: 18px 22px; background: white; cursor: pointer; transition: 0.3s ease; }
.upload-drop-zone:hover { border-color: var(--mint); box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08); }
.upload-cta { display: flex; align-items: center; gap: 16px; }
.upload-icon { width: 48px; height: 48px; border-radius: 16px; background: rgba(13, 177, 140, 0.12); display: flex; align-items: center; justify-content: center; font-size: 24px; }
.upload-cta strong { display: block; font-size: 15px; color: #0f172a; }
.hidden-file-input { position: absolute; inset: 0; opacity: 0; pointer-events: none; }
.upload-preview-row { display: flex; gap: 12px; flex-wrap: wrap; }
.upload-chip { display: flex; align-items: center; gap: 10px; padding: 10px 14px; border-radius: 16px; background: white; border: 1px solid rgba(226, 232, 240, 0.9); box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06); font-size: 12px; font-weight: 800; color: #475569; }
.upload-chip img { width: 36px; height: 36px; border-radius: 12px; object-fit: cover; }

.info-row { display: flex; gap: 20px; margin-top: 15px; }
.info-cell { flex: 1; text-align: center; background: #f8fafc; padding: 18px; border-radius: 24px; }
.info-cell .val { display: block; font-size: 28px; font-weight: 900; color: var(--bg-dark); }
.info-cell .lab { color: #94a3b8; font-weight: 800; font-size: 11px; text-transform: uppercase; }

.panel-feed-container { height: 100%; overflow-y: auto !important; padding-right: 15px; padding-bottom: 400px; scroll-padding-bottom: 100px; }

.post-premium-card {
  background: white; border-radius: 36px; padding: 40px; margin-bottom: 30px;
  border: 1px solid transparent; transition: 0.5s cubic-bezier(0.23, 1, 0.32, 1);
}
.post-premium-card:hover { border-color: var(--mint); transform: translateX(10px); }
.sticky-active { border-left: 8px solid var(--mint); background: #f0fdfa; }
.solved-state { opacity: 0.6; filter: grayscale(0.5); }

/* --- 优化头部排版布局 --- */
.p-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}
.p-author {
  display: flex;
  align-items: center;
  gap: 16px; /* 增加头像和名字的间距 */
}
.p-avatar {
  width: 56px; 
  height: 56px; 
  border-radius: 20px; 
  color: white;
  display: flex; 
  align-items: center; 
  justify-content: center; 
  font-weight: 900; 
  font-size: 26px;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}
.p-meta {
  display: flex;
  flex-direction: column; /* 纵向排列名字和时间 */
  gap: 4px;
}
.p-name { 
  font-weight: 900; 
  font-size: 18px; 
  color: var(--bg-dark); 
  line-height: 1.2;
}
.p-time { 
  font-size: 12px; 
  color: #94a3b8; 
  font-weight: 600; 
  letter-spacing: 0.3px;
}
.p-label-group {
  display: flex;
  gap: 8px; /* 标签之间的间距 */
  align-items: center;
  flex-wrap: wrap;
  justify-content: flex-end;
}
.p-tag-vibe { 
  font-size: 11px; 
  font-weight: 900; 
  padding: 6px 14px; 
  border-radius: 10px; 
  margin-left: 0 !important; /* 清除旧的间距逻辑 */
  white-space: nowrap;
}
/* --- 布局优化结束 --- */

.p-tag-vibe.sticky { background: var(--mint); color: white; }
.p-tag-vibe.cat { background: #f1f5f9; color: #64748b; }
.p-card-body h3 { font-size: 24px; font-weight: 900; margin: 18px 0; color: var(--bg-dark); }
.p-card-body p { font-size: 16px; line-height: 1.8; color: #4b5563; margin-bottom: 25px; }
.p-image-matrix { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-bottom: 20px; }
.p-image-matrix img { width: 100%; height: 200px; object-fit: cover; border-radius: 28px; transition: 0.3s; cursor: pointer; }
.comment-stream-box { margin-bottom: 25px; border-top: 1px dashed #f1f5f9; padding-top: 25px; }
.c-item-row { font-size: 14px; padding: 10px 0; border-bottom: 1px solid rgba(0,0,0,0.03); }
.interaction-control { display: flex; align-items: center; gap: 20px; }
.reply-form-vibe { flex: 1; }
.reply-form-vibe input {
  width: 100%; background: #f8fafc; border: 1px solid #f1f5f9; padding: 14px 24px;
  border-radius: 100px; font-size: 14px; outline: none; transition: 0.3s;
}
.btn-text-op {
  border: none; background: #f1f5f9; padding: 10px 20px; border-radius: 12px;
  font-size: 13px; font-weight: 900; color: #64748b; cursor: pointer; transition: 0.2s;
}
.btn-text-op.danger { color: #f43f5e; }

@keyframes indicator-glow { 0%, 100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 1; transform: scale(1.3); } }
.decoration-blobs { position: absolute; inset: 0; pointer-events: none; z-index: 0; }
.blob { position: absolute; border-radius: 50%; filter: blur(100px); opacity: 0.15; }
.b1 { width: 700px; height: 700px; background: var(--mint); top: -300px; right: -100px; }
.b2 { width: 600px; height: 600px; background: #6366f1; bottom: -300px; left: -100px; }
.panel-slide-enter-active, .panel-slide-leave-active { transition: all 0.6s cubic-bezier(0.23, 1, 0.32, 1); }
.panel-slide-enter-from, .panel-slide-leave-to { transform: translateY(100%); opacity: 0; }
.animate-fade { animation: fadeIn 1s ease; }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

.custom-scrollbar::-webkit-scrollbar { width: 10px; height: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #94a3b8; border-radius: 10px; border: 2px solid #fff; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #64748b; }
.custom-scrollbar::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 10px; }

.mt-20 { margin-top: 20px; }
.empty-vibe { text-align: center; padding: 150px 0; font-size: 1.5rem; color: #94a3b8; font-weight: 800; }
@media (max-width: 1350px) {
  .panel-main-grid { grid-template-columns: 1fr; }
  .panel-side-bento { display: none; }
}
</style>