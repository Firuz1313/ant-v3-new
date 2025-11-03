# ✅ Builder.io - Финальная настройка

## ✅ Что уже настроено:

1. ✅ `@builder.io/sdk-vue` добавлен в `package.json`
2. ✅ `BuilderComponent.vue` создан в `src/components/builder/`
3. ✅ `vite.config.ts` настроен с CORS заголовками
4. ✅ Зависимости установлены через `pnpm install`
5. ✅ Dev сервер запущен и работает на порту 3006

## 📋 Настройки для Builder.io Cloud:

### 1. Environment Variables (Переменные окружения)

**Скопируйте и вставьте в Builder.io:**

```
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

**Важно:** Замените `your-builder-api-key-here` на ваш реальный API ключ из Builder.io

### 2. Setup Command

```
pnpm install
```

### 3. Dev Command

```
pnpm dev
```

### 4. Package Manager

```
pnpm
```

### 5. Port

```
3006
```

## 🔧 Создание файла .env

### Вариант 1: Автоматически (Windows)

Запустите:

```bash
create-env.bat
```

### Вариант 2: Вручную

Создайте файл `.env` в корне проекта:

```env
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

Замените `your-builder-api-key-here` на ваш API ключ.

## ✅ Проверка работы

Сервер должен запуститься на:

```
http://localhost:3006
```

Статус: ✅ **Сервер работает!** (проверено)

## 📝 Использование BuilderComponent

```vue
<template>
  <BuilderComponent model="page" entry="your-entry-id" />
</template>

<script setup lang="ts">
  import BuilderComponent from '@/components/builder/BuilderComponent.vue'
</script>
```

## 🎯 Готово!

Проект полностью настроен для работы с Builder.io!
