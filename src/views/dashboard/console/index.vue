<template>
  <div class="console">
    <div class="empty-state">
      <h2>Добро пожаловать в Ант Аналитика</h2>
      <p>Панель управления готова к настройке</p>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useCommon } from '@/composables/useCommon'

  defineOptions({ name: 'Console' })

  useCommon().scrollToTop()
</script>

<style lang="scss" scoped>
  .console {
    padding: 20px;

    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 400px;
      text-align: center;

      h2 {
        font-size: 24px;
        margin-bottom: 10px;
        color: var(--art-text-gray-800);
      }

      p {
        font-size: 16px;
        color: var(--art-text-gray-600);
      }
    }
  }
</style>
