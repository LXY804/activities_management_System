<template>
  <div 
    ref="wrapperRef"
    class="optimized-image-wrapper" 
    :style="wrapperStyle"
    :data-src="lazy ? src : null"
  >
    <!-- 占位符骨架屏 -->
    <div v-if="!loaded && !error" class="image-placeholder">
      <div class="skeleton-loader"></div>
    </div>
    
    <!-- 错误占位符 -->
    <div v-if="error" class="image-error">
      <span class="error-icon">🖼️</span>
      <span class="error-text">图片加载失败</span>
    </div>
    
    <!-- 实际图片 -->
    <img
      v-show="loaded && !error"
      :src="shouldLoad ? displaySrc : ''"
      :alt="alt"
      :class="['optimized-image', { 'image-loaded': loaded }]"
      @load="onLoad"
      @error="onError"
      :loading="lazy ? 'lazy' : 'eager'"
      decoding="async"
      :fetchpriority="priority"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onBeforeUnmount } from 'vue'

const props = defineProps({
  src: {
    type: String,
    required: true
  },
  alt: {
    type: String,
    default: ''
  },
  width: {
    type: [Number, String],
    default: null
  },
  height: {
    type: [Number, String],
    default: null
  },
  lazy: {
    type: Boolean,
    default: true
  },
  priority: {
    type: String,
    default: 'auto', // 'high' | 'low' | 'auto'
    validator: (value) => ['high', 'low', 'auto'].includes(value)
  }
})

const loaded = ref(false)
const error = ref(false)
const useFallback = ref(false)
const shouldLoad = ref(!props.lazy) // 懒加载时初始为false
const wrapperRef = ref(null)
let observer = null

// 显示用的图片 URL
const displaySrc = computed(() => {
  if (!props.src) return ''
  
  // 如果原图加载失败，尝试使用备用路径
  if (useFallback.value) {
    return props.src
  }
  
  return props.src
})

// 容器样式
const wrapperStyle = computed(() => {
  const style = {}
  if (props.width) {
    style.width = typeof props.width === 'number' ? `${props.width}px` : props.width
  }
  if (props.height) {
    style.height = typeof props.height === 'number' ? `${props.height}px` : props.height
  }
  return style
})

const onLoad = () => {
  loaded.value = true
  error.value = false
}

const onError = () => {
  if (!useFallback.value) {
    // 第一次失败，尝试使用原路径
    useFallback.value = true
    error.value = false
  } else {
    // 备用路径也失败，显示错误
    error.value = true
    loaded.value = false
  }
}

// 监听 src 变化，重置状态
watch(() => props.src, () => {
  loaded.value = false
  error.value = false
  useFallback.value = false
})

onMounted(() => {
  // 如果使用懒加载，使用 Intersection Observer
  if (props.lazy && 'IntersectionObserver' in window && wrapperRef.value) {
    observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            // 图片进入视口，开始加载
            shouldLoad.value = true
            if (observer) {
              observer.unobserve(entry.target)
              observer.disconnect()
              observer = null
            }
          }
        })
      },
      {
        rootMargin: '100px' // 提前 100px 开始加载（优化：提前更多）
      }
    )
    
    // 观察图片容器
    observer.observe(wrapperRef.value)
  } else if (!props.lazy) {
    // 不使用懒加载，立即加载
    shouldLoad.value = true
  }
})

onBeforeUnmount(() => {
  if (observer) {
    observer.disconnect()
    observer = null
  }
})
</script>

<style scoped>
.optimized-image-wrapper {
  position: relative;
  overflow: hidden;
  background: #f0f0f0;
  display: inline-block;
  width: 100%;
}

.optimized-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0;
  transition: opacity 0.3s ease;
  display: block;
}

.optimized-image.image-loaded {
  opacity: 1;
}

.image-placeholder {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

.skeleton-loader {
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

.image-error {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
  color: #999;
  z-index: 2;
}

.error-icon {
  font-size: 32px;
  margin-bottom: 8px;
  opacity: 0.6;
}

.error-text {
  font-size: 12px;
  font-weight: 500;
}
</style>

