<template>
  <div class="system-page">
    <div class="empty-placeholder">
      <el-empty description="Страница в разработке">
        <template #image>
          <svg class="empty-icon" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M512 64C264.6 64 64 264.6 64 512s200.6 448 448 448 448-200.6 448-448S759.4 64 512 64zm0 820c-205.4 0-372-166.6-372-372s166.6-372 372-372 372 166.6 372 372-166.6 372-372 372z"
              fill="currentColor"
            />
            <path
              d="M512 140c-205.4 0-372 166.6-372 372s166.6 372 372 372 372-166.6 372-372-166.6-372-372-372zm184.4 277.7l-244 199c-4.4 3.6-10.8 0.4-10.8-5.4V412.7c0-5.8 6.5-9 10.8-5.4l244 199c3.9 3.2 3.9 9.4 0 12.8z"
              fill="currentColor"
              opacity="0.3"
            />
          </svg>
        </template>
        <template #description>
          <div class="description-content">
            <h3>Управление ролями</h3>
            <p>Эта страница готова для добавления функционала</p>
          </div>
        </template>
        <el-button type="primary">Начать разработку</el-button>
      </el-empty>
    </div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'SystemRole' })
</script>

<style lang="scss" scoped>
  .system-page {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: calc(100vh - 200px);
    padding: 40px 20px;

    .empty-placeholder {
      width: 100%;
      max-width: 600px;

      .empty-icon {
        width: 120px;
        height: 120px;
        color: var(--el-color-primary);
        opacity: 0.6;
      }

      .description-content {
        h3 {
          font-size: 20px;
          font-weight: 600;
          color: var(--art-text-gray-800);
          margin-bottom: 8px;
        }

        p {
          font-size: 14px;
          color: var(--art-text-gray-600);
        }
      }
    }
  }
</style>
