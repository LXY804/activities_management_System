<template>
    <div>
      <!-- 悬浮按钮 -->
      <div
        class="chat-float-button"
        :style="{ left: buttonPosition.x + 'px', top: buttonPosition.y + 'px' }"
        @mousedown.prevent="startButtonDrag"
        @click="handleButtonClick"
      >
        💬
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
  
        <div class="chat-body">
          <div
            v-for="(msg, index) in messages"
            :key="index"
            :class="['msg', msg.from]"
          >
            {{ msg.text }}
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
    import axios from 'axios'
    
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
    
    // 简单用一个固定的 sessionId，实际可用用户ID + 时间戳
    const sessionId = 'demo-session-1'
    
    function toggleOpen() {
      open.value = !open.value
    }
    
    // 初始化位置：按钮和窗口默认在右下角附近
    onMounted(() => {
      if (typeof window !== 'undefined') {
        const buttonSize = 56  // 按钮大小
        buttonPosition.value.x = window.innerWidth - buttonSize - 24
        buttonPosition.value.y = window.innerHeight - buttonSize - 24
        
        const width = 320   // 和 .chat-float-window 的宽度对应
        const height = 420  // 和 .chat-float-window 的高度对应
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
      const width = 320
      const height = 420
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
    
    // 发送消息逻辑
    async function sendMessage() {
      const text = inputText.value.trim()
      if (!text || loading.value) return
    
      messages.value.push({ from: 'user', text })
      inputText.value = ''
      loading.value = true
    
      try {
    const { data } = await axios.post('http://localhost:3000/api/chat/ask', {
      sessionId,
      userMessage: text,
    })
    const reply = data?.data?.reply || data?.reply || '机器人没有返回内容'
    messages.value.push({ from: 'bot', text: reply })
      } catch (e) {
        console.error(e)
        messages.value.push({ from: 'bot', text: '出错了，请稍后再试。' })
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
    background-color: #409eff;
    color: #fff;
    border-radius: 50%;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: move;  /* 改为 move 光标，提示可以拖动 */
    z-index: 9999;
    font-size: 24px;
    user-select: none;  /* 防止拖动时选中文本 */
  }
  
  /* 悬浮窗口 */
  .chat-float-window {
    position: fixed;
    width: 320px;
    height: 420px;
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
    background: #409eff;
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
    background: #409eff;
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
    background: #409eff;
    color: #fff;
    cursor: pointer;
  }
  .chat-input button:disabled {
    opacity: 0.6;
    cursor: default;
  }
  </style>