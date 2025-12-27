<template>
    <div>
      <!-- 悬浮按钮 -->
      <div
        class="chat-float-button"
        :style="{ left: buttonPosition.x + 'px', top: buttonPosition.y + 'px' }"
        @mousedown.prevent="startButtonDrag"
        @click="handleButtonClick"
      >
        <!-- 自定义图标：使用项目中的 header-logo.png，你可以换成自己的图片路径 -->
        <img src="@/assets/AI_bot.jpg" alt="智能助手" class="chat-float-icon" />
      </div>
  
      <!-- 悬浮聊天窗口 -->
    <div
      v-if="open"
      class="chat-float-window"
      :style="{ left: position.x + 'px', top: position.y + 'px' }"
    >
      <div class="chat-header" @mousedown.prevent="startDrag">
        <span>智能助手</span>
        <button class="close-btn" @click="toggleOpen">×</button>
      </div>
  
        <div class="chat-body" @click="handleMsgButtonClick">
          <div
            v-for="(msg, index) in messages"
            :key="index"
            :class="['msg', msg.from]"
          >
            <div v-if="msg.from === 'bot'" v-html="formatMessage(msg.text)"></div>
            <div v-else>{{ msg.text }}</div>
          </div>
        </div>
  
        <div class="chat-input">
          <input
            v-model="inputText"
            @keyup.enter="sendMessage"
            placeholder="和机器人聊点什么..."
          />
          <button @click="sendMessage" :disabled="loading">
            {{ loading ? '发送中...' : '发送' }}
          </button>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
    import { ref, onMounted, onBeforeUnmount } from 'vue'
    import request from '@/api/request'
    
    const open = ref(false)
    const inputText = ref('')
    const messages = ref([])
    const loading = ref(false)
    
    // 悬浮按钮位置（左上角坐标）
    const buttonPosition = ref({ x: 0, y: 0 })
    const buttonDragging = ref(false)
    const buttonDragStart = { x: 0, y: 0, startX: 0, startY: 0 }
    
    // 悬浮窗口当前位置（左上角坐标）
    const position = ref({ x: 0, y: 0 })
    const dragging = ref(false)
    const dragOffset = { x: 0, y: 0 }
    
    // 获取用户ID，用于个性化推荐
    const getUserId = () => {
      // 方法1：从localStorage直接获取
      let userId = localStorage.getItem('userId')
      if (userId) {
        return Number(userId)
      }
      
      // 方法2：从JWT token中解析userId（备用方案）
      const token = localStorage.getItem('token')
      if (token) {
        try {
          // JWT token格式：header.payload.signature
          const payload = token.split('.')[1]
          if (payload) {
            const decoded = JSON.parse(atob(payload))
            if (decoded.userId) {
              // 同时保存到localStorage，下次直接使用
              localStorage.setItem('userId', String(decoded.userId))
              return Number(decoded.userId)
            }
          }
        } catch (e) {
          console.warn('解析JWT token失败:', e)
        }
      }
      
      return null
    }
    
    // 生成sessionId：基于用户ID，如果未登录则使用默认会话
    const getSessionId = () => {
      const userId = getUserId()
      if (userId) {
        return `user-${userId}-session`
      }
      return 'guest-session'
    }
    
    const sessionId = getSessionId()
    
    function toggleOpen() {
      open.value = !open.value
    }
    
    // 初始化位置：按钮和窗口默认在右下角附近
    onMounted(() => {
      if (typeof window !== 'undefined') {
        const buttonSize = 56  // 按钮大小
        buttonPosition.value.x = window.innerWidth - buttonSize - 24
        buttonPosition.value.y = window.innerHeight - buttonSize - 24
        
        const width = 450   // 和 .chat-float-window 的宽度对应
        const height = 600  // 和 .chat-float-window 的高度对应
        position.value.x = window.innerWidth - width - 24
        position.value.y = window.innerHeight - height - 90
      }
    })
    
    // 按钮拖拽开始
    function startButtonDrag(event) {
      buttonDragging.value = true
      buttonDragStart.startX = event.clientX
      buttonDragStart.startY = event.clientY
      buttonDragStart.x = buttonPosition.value.x
      buttonDragStart.y = buttonPosition.value.y
      window.addEventListener('mousemove', onButtonDrag)
      window.addEventListener('mouseup', stopButtonDrag)
    }
    
    // 按钮拖拽中
    function onButtonDrag(event) {
      if (!buttonDragging.value) return
      const deltaX = event.clientX - buttonDragStart.startX
      const deltaY = event.clientY - buttonDragStart.startY
      buttonPosition.value.x = buttonDragStart.x + deltaX
      buttonPosition.value.y = buttonDragStart.y + deltaY
      
      // 限制在屏幕内
      const buttonSize = 56
      const maxX = window.innerWidth - buttonSize
      const maxY = window.innerHeight - buttonSize
      buttonPosition.value.x = Math.max(0, Math.min(buttonPosition.value.x, maxX))
      buttonPosition.value.y = Math.max(0, Math.min(buttonPosition.value.y, maxY))
    }
    
    // 按钮拖拽结束
    function stopButtonDrag(event) {
      const deltaX = Math.abs(event.clientX - buttonDragStart.startX)
      const deltaY = Math.abs(event.clientY - buttonDragStart.startY)
      const moved = deltaX > 5 || deltaY > 5  // 移动超过5px才算拖拽
      
      buttonDragging.value = false
      window.removeEventListener('mousemove', onButtonDrag)
      window.removeEventListener('mouseup', stopButtonDrag)
      
      // 如果没有明显移动，认为是点击，打开窗口
      if (!moved) {
        toggleOpen()
      }
    }
    
    // 处理按钮点击（如果拖拽逻辑没触发）
    function handleButtonClick(event) {
      // 如果已经通过拖拽结束处理了点击，这里就不重复处理
      // 这个函数主要是为了确保点击事件能正常工作
    }
    
    // 窗口拖拽开始
    function startDrag(event) {
      dragging.value = true
      dragOffset.x = event.clientX - position.value.x
      dragOffset.y = event.clientY - position.value.y
      window.addEventListener('mousemove', onDrag)
      window.addEventListener('mouseup', stopDrag)
    }
    
    // 窗口拖拽中
    function onDrag(event) {
      if (!dragging.value) return
      position.value.x = event.clientX - dragOffset.x
      position.value.y = event.clientY - dragOffset.y
      
      // 限制在屏幕内
      const width = 450
      const height = 600
      const maxX = window.innerWidth - width
      const maxY = window.innerHeight - height
      position.value.x = Math.max(0, Math.min(position.value.x, maxX))
      position.value.y = Math.max(0, Math.min(position.value.y, maxY))
    }
    
    // 窗口拖拽结束
    function stopDrag() {
      dragging.value = false
      window.removeEventListener('mousemove', onDrag)
      window.removeEventListener('mouseup', stopDrag)
    }
    
    // 格式化消息，将按钮文本转换为可点击的按钮
    function formatMessage(text) {
      if (!text) return ''
      
      // 转义 HTML 特殊字符
      let formatted = text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;')
      
      // 匹配按钮文本模式（如"推荐活动"、"智能推荐活动"等）
      const buttonPatterns = [
        /推荐活动/g,
        /智能推荐活动/g,
        /给我推荐/g,
        /热门活动/g,
        /查询热门活动/g,
        /我报名的活动/g,
        /已报名活动/g
      ]
      
      buttonPatterns.forEach(pattern => {
        formatted = formatted.replace(pattern, (match) => {
          return `<button class="msg-button" data-action="${match}">${match}</button>`
        })
      })
      
      // 将换行符转换为 <br>
      formatted = formatted.replace(/\n/g, '<br>')
      
      return formatted
    }
    
    // 处理消息中的按钮点击
    function handleMsgButtonClick(event) {
      if (event.target.classList.contains('msg-button')) {
        const action = event.target.getAttribute('data-action')
        if (action) {
          inputText.value = action
          sendMessage()
        }
      }
    }
    
    // 发送消息逻辑
    async function sendMessage(customText = null) {
      const text = customText || inputText.value.trim()
      if (!text || loading.value) return
    
      messages.value.push({ from: 'user', text })
      inputText.value = ''
      loading.value = true
    
      try {
        const userId = getUserId()
        console.log('[前端] 发送消息，userId:', userId, 'text:', text)
        const data = await request.post('/chat/ask', {
          sessionId: getSessionId(),
          userMessage: text,
          userId: userId, // 传递用户ID，用于个性化推荐
        })
        const reply = data?.reply || '机器人没有返回内容'
        console.log('[前端] 收到回复，长度:', reply?.length || 0)
        messages.value.push({ from: 'bot', text: reply })
      } catch (e) {
        console.error('[前端] 请求错误:', e)
        console.error('[前端] 错误详情:', e.response?.data || e.message)
        // 显示更友好的错误提示
        let errorMsg = '出错了，请稍后再试。'
        if (e.message && e.message.includes('网络')) {
          errorMsg = '网络连接失败，请检查网络后重试。'
        } else if (e.message && e.message.includes('401')) {
          errorMsg = '登录已过期，请重新登录。'
        }
        messages.value.push({ from: 'bot', text: errorMsg })
      } finally {
        loading.value = false
      }
    }
    
    onBeforeUnmount(() => {
      window.removeEventListener('mousemove', onDrag)
      window.removeEventListener('mouseup', stopDrag)
      window.removeEventListener('mousemove', onButtonDrag)
      window.removeEventListener('mouseup', stopButtonDrag)
    })
    </script>
  
  <style scoped>
  .chat-float-button {
    position: fixed;
    /* 不再使用 right/bottom，改用 left/top 通过 JS 控制 */
    width: 56px;
    height: 56px;
    background-color: #b6b9bc;
    color: #fff;
    border-radius: 50%;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: move;  /* 改为 move 光标，提示可以拖动 */
    z-index: 9999;
    user-select: none;  /* 防止拖动时选中文本 */
  }

  /* 悬浮按钮中的图标图片，铺满圆形按钮 */
  .chat-float-icon {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
    pointer-events: none; /* 避免阻塞拖拽事件 */
  }
  
  /* 悬浮窗口 */
  .chat-float-window {
    position: fixed;
    width: 450px;
    height: 600px;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.2);
    display: flex;
    flex-direction: column;
    z-index: 9999;
    overflow: hidden;
  }
  
  .chat-header {
    height: 40px;
    background: #b498a4;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 12px;
    font-size: 14px;
  }
  
  .close-btn {
    border: none;
    background: transparent;
    color: #fff;
    font-size: 18px;
    cursor: pointer;
  }
  
  .chat-body {
    flex: 1;
    padding: 8px;
    overflow-y: auto;
    background: #f5f5f5;
  }
  
  .msg {
    max-width: 80%;
    margin: 4px 0;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 13px;
    line-height: 1.4;
    word-break: break-word;
  }
  
  .msg.user {
    margin-left: auto;
    background: #9a7377;
    color: #fff;
  }
  
  .msg.bot {
    margin-right: auto;
    background: #fff;
    border: 1px solid #e0e0e0;
  }
  
  .chat-input {
    display: flex;
    padding: 6px;
    border-top: 1px solid #eee;
    background: #fafafa;
  }
  
  .chat-input input {
    flex: 1;
    padding: 4px 8px;
    font-size: 13px;
    border-radius: 4px;
    border: 1px solid #ddd;
    outline: none;
  }
  
  .chat-input button {
    margin-left: 6px;
    padding: 4px 10px;
    font-size: 13px;
    border-radius: 4px;
    border: none;
    background: #9a7377;
    color: #fff;
    cursor: pointer;
  }
  .chat-input button:disabled {
    opacity: 0.6;
    cursor: default;
  }
  
  .msg-button {
    display: inline-block;
    margin: 4px 8px 4px 0;
    padding: 6px 12px;
    background: #b498a4;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    transition: background 0.2s;
  }
  
  .msg-button:hover {
    background: #9a7377;
  }
  
  .msg-button:active {
    background: #7d5d61;
  }
  </style>