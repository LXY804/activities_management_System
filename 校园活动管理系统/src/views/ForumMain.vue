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
        <section v-if="activeCategoryId === null && viewMode === 'all'" class="map-interactive-layer animate-fade">
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
          <section v-if="activeCategoryId !== null || viewMode === 'myPosts' || viewMode === 'myComments'" class="board-panel-overlay">
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
                    <p class="hero-label">{{ viewModeLabel }}</p>
                    <h3>{{ viewModeDesc }}</h3>
                    <small>{{ currentCategoryMeta.tip }}</small>
                  </div>
                </div>
                <div class="hero-actions">
                  <button v-if="viewMode !== 'all'" class="btn-back" @click="showAllPosts">
                    <span>← 返回全部</span>
                  </button>
                  <button class="btn-publish" @click="showPublishModal = true">
                    <span class="publish-icon">✍️</span>
                    <span>发布帖子</span>
                  </button>
                  <div class="hero-stats">
                    <div 
                      class="hero-stat" 
                      :class="{ 'active': viewMode === 'myPosts' }" 
                      @click.stop.prevent="showMyPosts"
                      @mousedown.stop
                    >
                      <strong>{{ myPostsCount }}</strong>
                      <span>我的帖子</span>
                    </div>
                    <div 
                      class="hero-stat" 
                      :class="{ 'active': viewMode === 'myComments' }" 
                      @click.stop.prevent="showMyComments"
                      @mousedown.stop
                    >
                      <strong>{{ myCommentsCount }}</strong>
                      <span>我的消息</span>
                    </div>
                  </div>
                </div>
              </section>
              <!-- 发布帖子弹窗 -->
              <Teleport to="body">
                <div v-if="showPublishModal" class="publish-modal-overlay" @click.self="closePublishModal">
                  <div class="publish-modal-content">
                    <div class="publish-modal-header">
                      <h2>发布新帖子</h2>
                      <button class="modal-close-btn" @click="closePublishModal">×</button>
                      </div>
                    <div class="publish-modal-body">
                      <form @submit.prevent="publishPost" class="bento-form">
                        <div class="form-group">
                          <label>选择类别</label>
                          <select v-model.number="publishForm.categoryId" class="category-select" required>
                            <option :value="0">全部 / 未分类</option>
                            <option v-for="cat in forumCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                          </select>
                        </div>
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
                            <button type="button" class="btn-cancel" @click="closePublishModal">取消</button>
                            <button type="submit" class="btn-send-grad">确认发布</button>
                          </div>
                        </div>
                      </form>
                    </div>
                  </div>
                      </div>
              </Teleport>
              <div class="panel-main-grid">
                <main class="panel-feed-container custom-scrollbar">
                  <div v-if="loading" class="loading-state">
                    <p>正在加载帖子...</p>
                  </div>
                  <div v-else-if="errorMsg" class="error-state">
                    <p>{{ errorMsg }}</p>
                  </div>
                  <transition-group v-else name="post-anim">
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
                          <form @submit.prevent="addCommentToPost(post)" class="reply-form-vibe">
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
                  <div v-if="!loading && !errorMsg && filteredPosts.length === 0" class="empty-vibe">
                    <p v-if="viewMode === 'myPosts'">📝 您还没有发布过帖子</p>
                    <p v-else-if="viewMode === 'myComments'">💬 您还没有评论过任何帖子</p>
                    <p v-else>🍃 暂无匹配动态，换个分类看看吧</p>
                  </div>
                  <!-- 调试：显示当前状态 -->
                  <div v-if="false" style="position: fixed; top: 10px; right: 10px; background: rgba(0,0,0,0.8); color: white; padding: 10px; z-index: 9999; font-size: 12px;">
                    <p>loading: {{ loading }}</p>
                    <p>errorMsg: {{ errorMsg || '无' }}</p>
                    <p>posts: {{ posts.length }}</p>
                    <p>filtered: {{ filteredPosts.length }}</p>
                    <p>viewMode: {{ viewMode }}</p>
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
import { reactive, ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import NavBar from '@/components/NavBar.vue'
import { fetchPosts, createPost, addComment, deletePost, fetchPostComments, fetchMyStats, fetchMyPosts, fetchMyCommentedPosts } from '@/api/forum'
import mapImage from '@/assets/论坛背景图.jpg'
import iconResale from '@/assets/论坛-二手闲置.png'
import iconHelp from '@/assets/论坛-打听求助.png'
import iconLove from '@/assets/论坛-恋爱交友.png'
import iconFun from '@/assets/论坛-校园趣事.png'
import iconJob from '@/assets/论坛-兼职招聘.png'

const router = useRouter()
const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api').replace(/\/api\/?$/, '')

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
const publishForm = reactive({ title: '', content: '', imageInputs: ['', '', ''], isSticky: false, categoryId: 0 })
const showPublishModal = ref(false)
const imagePicker = ref(null)
const tempImageUrls = ref([])
const viewMode = ref('all') // 'all' | 'myPosts' | 'myComments'

const currentCategoryMeta = computed(() => {
  const target = activeCategoryId.value ?? 0
  return categoryMetaMap[target] || categoryMetaMap[0]
})

const viewModeLabel = computed(() => {
  if (viewMode.value === 'myPosts') return '我的帖子'
  if (viewMode.value === 'myComments') return '我的消息'
  return currentCategoryMeta.value.label
})

const viewModeDesc = computed(() => {
  if (viewMode.value === 'myPosts') return '查看我发布的所有帖子'
  if (viewMode.value === 'myComments') return '查看我评论过的帖子'
  return currentCategoryMeta.value.desc
})
const imagePreviewList = computed(() => publishForm.imageInputs.filter(src => src))

const posts = ref([])
const loading = ref(false)
const errorMsg = ref('')
const myPostsCount = ref(0)
const myCommentsCount = ref(0)

const currentBoardName = computed(() => {
  if (activeCategoryId.value === 0) return '理大广场 · 全部动态'
  return forumCategories.find(c => c.id === activeCategoryId.value)?.name || ''
})

const filteredPosts = computed(() => {
  if (!posts.value || !Array.isArray(posts.value)) {
    return []
  }
  let list = [...posts.value]
  
  // 如果是"我的帖子"或"我的消息"视图，不进行类别和关键词筛选，直接显示所有结果
  if (viewMode.value === 'myPosts' || viewMode.value === 'myComments') {
    return list.sort((a, b) => {
      const dateA = a.createdAt ? new Date(a.createdAt) : new Date(0)
      const dateB = b.createdAt ? new Date(b.createdAt) : new Date(0)
      return dateB - dateA
    })
  }
  
  // 按类别筛选（仅在全部视图模式下）
  if (activeCategoryId.value !== null && activeCategoryId.value !== 0) {
    list = list.filter(p => p.categoryId === activeCategoryId.value)
  }
  
  // 按关键词筛选
  if (keyword.value) {
    const k = keyword.value.toLowerCase()
    list = list.filter(p => 
      (p.title && p.title.toLowerCase().includes(k)) || 
      (p.content && p.content.toLowerCase().includes(k))
    )
  }
  
  return list.sort((a, b) => {
    const dateA = a.createdAt ? new Date(a.createdAt) : new Date(0)
    const dateB = b.createdAt ? new Date(b.createdAt) : new Date(0)
    return dateB - dateA
  })
})

const loadMyStats = async () => {
  // 检查是否登录
  if (!localStorage.getItem('token')) {
    myPostsCount.value = 0
    myCommentsCount.value = 0
    return
  }

  try {
    const stats = await fetchMyStats()
    myPostsCount.value = stats?.myPostsCount || 0
    myCommentsCount.value = stats?.myCommentsCount || 0
  } catch (err) {
    console.error('加载我的统计失败:', err)
    // 如果未登录或其他错误，不显示错误，只显示0
    myPostsCount.value = 0
    myCommentsCount.value = 0
  }
}

const loadPosts = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    let fetchedPosts = []
    
    if (viewMode.value === 'myPosts') {
      if (!localStorage.getItem('token')) {
        errorMsg.value = '请先登录'
        posts.value = []
        loading.value = false
        return
      }
      const data = await fetchMyPosts({ page: 1, pageSize: 100 })
      fetchedPosts = data?.list || []
    } else if (viewMode.value === 'myComments') {
      if (!localStorage.getItem('token')) {
        errorMsg.value = '请先登录'
        posts.value = []
        loading.value = false
        return
      }
      const data = await fetchMyCommentedPosts({ page: 1, pageSize: 100 })
      fetchedPosts = data?.list || []
    } else {
      const params = {}
      if (keyword.value) {
        params.keyword = keyword.value
      }
      const data = await fetchPosts({ page: 1, pageSize: 100, ...params })
      fetchedPosts = data?.list || []
    }
    
    // 从数据库获取数据并转换格式
    posts.value = fetchedPosts.map(post => {
      let comments = []
      if (post.comments) {
        if (typeof post.comments === 'string') {
          try {
            comments = JSON.parse(post.comments)
          } catch (e) {
            comments = []
          }
        } else if (Array.isArray(post.comments)) {
          comments = post.comments
        }
      }
      
      return {
        id: post.id,
        categoryId: post.category_id || 0,
        userId: post.author_id || post.user_id,
        userName: post.author || post.username,
        title: post.title,
        content: post.content,
        status: (post.status === 1 || post.status === '1') ? 'active' : 'solved',
        isSticky: false,
        createdAt: post.created_at,
        images: post.image_url ? [API_ORIGIN + post.image_url] : [],
        comments: comments || []
      }
    })
  } catch (err) {
    errorMsg.value = '加载失败: ' + (err.message || '请稍后重试')
    posts.value = []
    if (err.message && (err.message.includes('401') || err.message.includes('认证'))) {
      errorMsg.value = '请先登录'
    }
  } finally {
    loading.value = false
  }
}

const showMyPosts = async (e) => {
  if (e) {
    e.preventDefault()
    e.stopPropagation()
  }
  
  if (!localStorage.getItem('token')) {
    if (confirm('此操作需要登录，是否前往登录？')) {
      router.push('/login')
    }
    return
  }
  
  // 设置一个特殊值来显示帖子列表，而不是地图
  activeCategoryId.value = -1  // 使用-1表示"我的帖子"视图
  viewMode.value = 'myPosts'
  keyword.value = ''
  await loadPosts()
}

const showMyComments = async (e) => {
  if (e) {
    e.preventDefault()
    e.stopPropagation()
  }
  
  if (!localStorage.getItem('token')) {
    if (confirm('此操作需要登录，是否前往登录？')) {
      router.push('/login')
    }
    return
  }
  
  // 设置一个特殊值来显示帖子列表，而不是地图
  activeCategoryId.value = -2  // 使用-2表示"我的消息"视图
  viewMode.value = 'myComments'
  keyword.value = ''
  await loadPosts()
}

const showAllPosts = async () => {
  viewMode.value = 'all'
  activeCategoryId.value = null
  keyword.value = ''
  await loadPosts()
}

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
const goBoard = (id) => goBoardWithLoad(id)
const goPortal = () => { activeCategoryId.value = null }
const getCatName = (id) => forumCategories.find(c => c.id === id)?.name || '未分类'
const isMyPost = (post) => post.userId === currentUser.id
const canDelete = (post) => currentUser.role === 'admin' || post.userId === currentUser.id

const resetForm = () => {
  publishForm.title = ''
  publishForm.content = ''
  publishForm.imageInputs = ['', '', '']
  publishForm.categoryId = activeCategoryId.value || 0 // 根据当前板块设置默认类别
  releaseTempImageUrls()
  if (imagePicker.value) imagePicker.value.value = ''
}

const closePublishModal = () => {
  showPublishModal.value = false
  resetForm()
}

const publishPost = async () => {
  if (!publishForm.title || !publishForm.content) {
    alert('请填写标题和内容')
    return
  }
  
  try {
    // 处理图片上传（如果有）
    const imageFile = publishForm.imageInputs.find(img => img && typeof img !== 'string')
    
    await createPost({
    title: publishForm.title,
    content: publishForm.content,
      categoryId: publishForm.categoryId || 0,
      image: imageFile
    })
    
    alert('帖子已提交，等待管理员审核通过后即可显示！')
    closePublishModal()
    // 重新加载帖子列表和统计
    await loadPosts()
    await loadMyStats()
  } catch (err) {
    console.error('发帖错误:', err)
    alert('发帖失败: ' + (err.message || '未知错误'))
  }
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

const addCommentToPost = async (post) => {
  if (!requireLogin()) return
  
  const text = commentDrafts[post.id]
  if (!text || !text.trim()) {
    alert('请输入评论内容')
    return
  }
  
  const postIndex = posts.value.findIndex(p => p.id === post.id)
  if (postIndex === -1) return
  
  // 获取当前用户信息
  const currentUsername = localStorage.getItem('username') || currentUser.name || '我'
  const currentUserId = Number(localStorage.getItem('userId')) || currentUser.id
  
  // 创建临时评论对象（乐观更新）
  const tempComment = {
    id: Date.now(), // 临时ID，后端会返回真实ID
    userName: currentUsername,
    content: text.trim(),
    created_at: new Date().toISOString()
  }
  
  // 立即添加到本地状态（实时显示）
  if (!posts.value[postIndex].comments) {
    posts.value[postIndex].comments = []
  }
  posts.value[postIndex].comments.push(tempComment)
  
  // 清空输入框
  const commentText = text.trim()
  commentDrafts[post.id] = ''
  
  try {
    // 提交到后端
    const result = await addComment(post.id, commentText)
    
    // 如果后端返回了评论ID，更新临时评论的ID
    if (result?.commentId && posts.value[postIndex].comments) {
      const tempIndex = posts.value[postIndex].comments.findIndex(c => c.id === tempComment.id)
      if (tempIndex !== -1) {
        posts.value[postIndex].comments[tempIndex].id = result.commentId
      }
    }
    
    // 更新我的消息统计
    loadMyStats()
    
    // 可选：在后台重新获取评论列表以确保数据完全同步（不阻塞UI）
    fetchPostComments(post.id).then(comments => {
      if (comments && Array.isArray(comments) && posts.value[postIndex]) {
        posts.value[postIndex].comments = comments
      }
    }).catch(err => {
      console.warn('后台同步评论失败:', err)
      // 失败不影响已显示的评论
    })
  } catch (err) {
    console.error('评论失败:', err)
    
    // 如果提交失败，移除刚才添加的临时评论
    if (posts.value[postIndex].comments) {
      const tempIndex = posts.value[postIndex].comments.findIndex(c => c.id === tempComment.id)
      if (tempIndex !== -1) {
        posts.value[postIndex].comments.splice(tempIndex, 1)
      }
    }
    
    // 恢复输入框内容
    commentDrafts[post.id] = commentText
    
    alert('评论失败: ' + (err.message || '未知错误，请稍后重试'))
  }
}

const handleStatusToggle = (p) => {
  // 状态切换功能需要后端支持，暂时保留前端逻辑
  p.status = p.status === 'active' ? 'solved' : 'active'
}

const toggleSticky = (p) => {
  // 置顶功能需要后端支持，暂时保留前端逻辑
  p.isSticky = !p.isSticky
}

const handleDelete = async (id) => {
  if(!confirm('确定删除吗？')) return
  
  try {
    await deletePost(id)
    await loadPosts() // 重新加载帖子列表
  } catch (err) {
    alert('删除失败: ' + (err.message || '未知错误'))
  }
}
const formatTime = (v) => {
  const d = new Date(v)
  return `${d.getMonth()+1}/${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
}
const generateColor = (name) => {
  const colors = ['#6366f1', '#10b981', '#f59e0b', '#3b82f6', '#ef4444', '#0db18c']
  return colors[name.length % colors.length]
}

const goBoardWithLoad = (id) => {
  viewMode.value = 'all' // 切换到分类视图时，重置为全部模式
  activeCategoryId.value = id
  keyword.value = ''
  // 根据当前板块设置默认类别
  if (id && id !== 0) {
    publishForm.categoryId = id
  }
  loadPosts()
}

watch(keyword, () => {
  loadPosts()
})

onMounted(() => {
  const role = localStorage.getItem('userRole')
  const userId = localStorage.getItem('userId')
  const username = localStorage.getItem('username')
  if (role) currentUser.role = role
  if (userId) currentUser.id = Number(userId)
  if (username) currentUser.name = username
  // 确保 posts 初始化为空数组
  if (!posts.value) {
    posts.value = []
  }
  // 从数据库加载数据
  loadPosts()
  loadMyStats()
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
.hero-actions {
  display: flex;
  align-items: center;
  gap: 24px;
}
.btn-publish {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 28px;
  background: linear-gradient(135deg, var(--mint), #0db18c);
  color: white;
  border: none;
  border-radius: 16px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(13, 177, 140, 0.3);
}
.btn-publish:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(13, 177, 140, 0.4);
}
.btn-publish:active {
  transform: translateY(0);
}
.publish-icon {
  font-size: 18px;
}
.btn-back {
  padding: 14px 24px;
  background: #f1f5f9;
  color: #64748b;
  border: none;
  border-radius: 16px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
}
.btn-back:hover {
  background: #e2e8f0;
  color: #0f172a;
}
.hero-stat {
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
  z-index: 10;
  pointer-events: auto;
  user-select: none;
}
.hero-stat:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  background: rgba(13, 177, 140, 0.05);
}
.hero-stat.active {
  background: rgba(13, 177, 140, 0.15);
  border: 2px solid var(--mint);
}
.hero-stat:active {
  transform: translateY(0);
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
.hero-stats { display: flex; gap: 22px; flex-wrap: wrap; }
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
.panel-main-grid { flex: 1; display: grid; grid-template-columns: 1fr; gap: 36px; padding: 30px 40px 40px; overflow: hidden; }

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
.form-group {
  display: flex; flex-direction: column; gap: 8px;
}
.form-group label {
  font-size: 13px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px;
}
.category-select {
  border: 1px solid #f1f5f9; padding: 18px; border-radius: 20px; background: #f8fafc; outline: none; font-size: 15px;
  cursor: pointer; transition: 0.3s;
}
.category-select:focus {
  border-color: var(--mint); background: white;
}

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
  background: white; border-radius: 28px; padding: 24px; margin-bottom: 20px;
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
  margin-bottom: 16px;
}
.p-author {
  display: flex;
  align-items: center;
  gap: 12px;
}
.p-avatar {
  width: 44px; 
  height: 44px; 
  border-radius: 16px; 
  color: white;
  display: flex; 
  align-items: center; 
  justify-content: center; 
  font-weight: 900; 
  font-size: 20px;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}
.p-meta {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.p-name { 
  font-weight: 900; 
  font-size: 15px; 
  color: var(--bg-dark); 
  line-height: 1.2;
}
.p-time { 
  font-size: 11px; 
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
  font-size: 10px; 
  font-weight: 900; 
  padding: 4px 12px; 
  border-radius: 8px; 
  margin-left: 0 !important; /* 清除旧的间距逻辑 */
  white-space: nowrap;
}
/* --- 布局优化结束 --- */

.p-tag-vibe.sticky { background: var(--mint); color: white; }
.p-tag-vibe.cat { background: #f1f5f9; color: #64748b; }
.p-card-body h3 { font-size: 20px; font-weight: 900; margin: 12px 0; color: var(--bg-dark); }
.p-card-body p { font-size: 14px; line-height: 1.7; color: #4b5563; margin-bottom: 16px; }
.p-image-matrix { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 16px; }
.p-image-matrix img { width: 100%; height: 160px; object-fit: cover; border-radius: 20px; transition: 0.3s; cursor: pointer; }
.comment-stream-box { margin-bottom: 16px; border-top: 1px dashed #f1f5f9; padding-top: 16px; }
.c-item-row { font-size: 13px; padding: 8px 0; border-bottom: 1px solid rgba(0,0,0,0.03); }
.interaction-control { display: flex; align-items: center; gap: 16px; }
.reply-form-vibe { flex: 1; }
.reply-form-vibe input {
  width: 100%; background: #f8fafc; border: 1px solid #f1f5f9; padding: 10px 18px;
  border-radius: 100px; font-size: 13px; outline: none; transition: 0.3s;
}
.btn-text-op {
  border: none; background: #f1f5f9; padding: 8px 16px; border-radius: 10px;
  font-size: 12px; font-weight: 900; color: #64748b; cursor: pointer; transition: 0.2s;
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

/* 发布帖子弹窗样式 */
.publish-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 1000;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

.publish-modal-content {
  background: white;
  border-radius: 32px;
  width: 100%;
  max-width: 700px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.3s ease;
  overflow: hidden;
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

.publish-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 32px;
  border-bottom: 1px solid #f1f5f9;
}

.publish-modal-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
}

.modal-close-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: #f1f5f9;
  border-radius: 12px;
  font-size: 24px;
  color: #64748b;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.modal-close-btn:hover {
  background: #e2e8f0;
  color: #0f172a;
}

.publish-modal-body {
  padding: 32px;
  overflow-y: auto;
  flex: 1;
}

.publish-modal-body .bento-form {
  gap: 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .board-hero {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }
  
  .hero-actions {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }
  
  .btn-publish {
    width: 100%;
    justify-content: center;
  }
  
  .hero-stats {
    width: 100%;
    justify-content: space-between;
  }
  
  .publish-modal-content {
    max-width: 100%;
    border-radius: 24px 24px 0 0;
    max-height: 95vh;
  }
  
  .publish-modal-header,
  .publish-modal-body {
    padding: 20px;
  }
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

.custom-scrollbar::-webkit-scrollbar { width: 10px; height: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #94a3b8; border-radius: 10px; border: 2px solid #fff; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #64748b; }
.custom-scrollbar::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 10px; }

.mt-20 { margin-top: 20px; }
.empty-vibe { text-align: center; padding: 150px 0; font-size: 1.5rem; color: #94a3b8; font-weight: 800; }
.loading-state, .error-state { text-align: center; padding: 100px 0; font-size: 1.2rem; color: #64748b; }
.loading-state { color: #0db18c; }
.error-state { color: #ef4444; }
@media (max-width: 1350px) {
  .panel-main-grid { grid-template-columns: 1fr; }
}
</style>