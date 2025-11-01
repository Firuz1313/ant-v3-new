<template>
  <div class="page-container">
    <el-card class="page-card">
      <template #header>
        <div class="card-header">
          <h2>{{ icon }} {{ $t(titleKey) }}</h2>
        </div>
      </template>
      
      <div class="content">
        <el-result
          icon="info"
          :title="$t(titleKey)"
          sub-title="Эта страница находится в разработке"
        >
          <template #extra>
            <el-button type="primary" @click="goHome">На главную</el-button>
          </template>
        </el-result>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

defineProps<{
  titleKey: string
  icon?: string
}>()

const router = useRouter()

const goHome = () => {
  router.push('/dashboard/console')
}
</script>

<style lang="scss" scoped>
.page-container {
  padding: 16px;
}

.page-card {
  min-height: 500px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  
  h2 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
  }
}

.content {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}
</style>
