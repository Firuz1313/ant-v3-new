<template>
  <div class="builder-component">
    <RenderContent v-if="content" :model="model" :content="content" :api-key="apiKey" />
    <div v-else-if="loading" class="loading"> Загрузка контента... </div>
    <div v-else class="error"> Контент не найден </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { builder, RenderContent } from '@builder.io/sdk-vue'

  interface Props {
    model?: string
    entry?: string
    apiKey?: string
  }

  const props = withDefaults(defineProps<Props>(), {
    model: 'page',
    apiKey: import.meta.env.VITE_BUILDER_API_KEY || ''
  })

  // Инициализация Builder.io с API ключом
  if (props.apiKey) {
    builder.init(props.apiKey)
  }

  const content = ref<any>(null)
  const loading = ref(true)

  onMounted(async () => {
    if (!props.apiKey) {
      console.warn('Builder.io API ключ не настроен. Установите VITE_BUILDER_API_KEY в .env файле')
      loading.value = false
      return
    }

    try {
      const result = await builder
        .get(props.entry || props.model, {
          userAttributes: {
            urlPath: window.location.pathname
          }
        })
        .promise()

      if (result) {
        content.value = result
      }
    } catch (error) {
      console.error('Ошибка загрузки контента Builder.io:', error)
    } finally {
      loading.value = false
    }
  })
</script>

<style scoped lang="scss">
  .builder-component {
    width: 100%;
    min-height: 200px;

    .loading {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px;
      color: #666;
    }

    .error {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px;
      color: #dc2626;
    }
  }
</style>
