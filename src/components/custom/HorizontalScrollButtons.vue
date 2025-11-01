<template>
  <div class="scroll-container" ref="containerRef">
    <button 
      class="scroll-button left" 
      :class="{ hidden: !showLeftButton }"
      @click="scrollLeft"
      aria-label="Scroll left"
    >
      ←
    </button>
    
    <div class="scroll-content" ref="contentRef" @scroll="onScroll">
      <slot></slot>
    </div>
    
    <button 
      class="scroll-button right" 
      :class="{ hidden: !showRightButton }"
      @click="scrollRight"
      aria-label="Scroll right"
    >
      →
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'

const containerRef = ref<HTMLElement | null>(null)
const contentRef = ref<HTMLElement | null>(null)
const showLeftButton = ref(false)
const showRightButton = ref(false)

const scrollLeft = () => {
  if (contentRef.value) {
    contentRef.value.scrollBy({ left: -200, behavior: 'smooth' })
  }
}

const scrollRight = () => {
  if (contentRef.value) {
    contentRef.value.scrollBy({ left: 200, behavior: 'smooth' })
  }
}

const onScroll = () => {
  updateButtonVisibility()
}

const updateButtonVisibility = () => {
  if (!contentRef.value) return
  
  const { scrollLeft, scrollWidth, clientWidth } = contentRef.value
  showLeftButton.value = scrollLeft > 0
  showRightButton.value = scrollLeft + clientWidth < scrollWidth
}

const checkOverflow = () => {
  if (!contentRef.value) return
  
  const { scrollWidth, clientWidth } = contentRef.value
  const hasOverflow = scrollWidth > clientWidth
  
  showLeftButton.value = hasOverflow && contentRef.value.scrollLeft > 0
  showRightButton.value = hasOverflow && contentRef.value.scrollLeft + clientWidth < scrollWidth
}

onMounted(() => {
  nextTick(() => {
    checkOverflow()
    updateButtonVisibility()
  })
  
  window.addEventListener('resize', checkOverflow)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkOverflow)
})

defineExpose({
  updateButtonVisibility,
  checkOverflow
})
</script>

<style scoped lang="scss">
.scroll-container {
  position: relative;
  display: flex;
  align-items: center;
  width: 100%;
}

.scroll-content {
  display: flex;
  overflow-x: auto;
  overflow-y: hidden;
  scrollbar-width: none;
  -ms-overflow-style: none;
  flex: 1;
  
  &::-webkit-scrollbar {
    display: none;
  }
}

.scroll-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid #d1d5db;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: bold;
  color: #374151;
  z-index: 10;
  transition: all 0.2s ease;
  
  &.left {
    left: 8px;
  }
  
  &.right {
    right: 8px;
  }
  
  &:hover {
    background: rgba(255, 255, 255, 1);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    color: #1e40af;
  }
  
  &:active {
    transform: translateY(-50%) scale(0.95);
  }
  
  &.hidden {
    opacity: 0;
    pointer-events: none;
    visibility: hidden;
  }
}
</style>
