<template>
  <div class="iframe-container">
    <div v-if="loading" class="iframe-loading">
      <el-icon class="is-loading">
        <Loading />
      </el-icon>
      <span>Загрузка...</span>
    </div>
    <iframe
      v-show="!loading"
      ref="iframeRef"
      :src="iframeSrc"
      class="iframe-content"
      frameborder="0"
      @load="handleLoad"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute } from 'vue-router'
  import { Loading } from '@element-plus/icons-vue'

  defineOptions({ name: 'Iframe' })

  const route = useRoute()
  const iframeRef = ref<HTMLIFrameElement>()
  const loading = ref(true)

  const iframeSrc = computed(() => {
    return (route.meta?.link as string) || ''
  })

  const handleLoad = () => {
    loading.value = false
  }

  onMounted(() => {
    if (!iframeSrc.value) {
      loading.value = false
    }
  })
</script>

<style lang="scss" scoped>
  .iframe-container {
    position: relative;
    width: 100%;
    height: calc(100vh - 120px);
    background-color: var(--art-bg-color);

    .iframe-loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100%;
      color: var(--art-text-gray-600);

      .el-icon {
        font-size: 32px;
        margin-bottom: 10px;
      }

      span {
        font-size: 14px;
      }
    }

    .iframe-content {
      width: 100%;
      height: 100%;
      border: none;
      background-color: #fff;
    }
  }
</style>
