# ✅ Builder.io - Полная настройка завершена

## ✅ Что уже сделано:

1. ✅ Добавлен `@builder.io/sdk-vue@4.2.4` в `package.json`
2. ✅ Создан компонент `BuilderComponent.vue` в `src/components/builder/`
3. ✅ Настроен `vite.config.ts` с CORS заголовками для Builder.io
4. ✅ Установлены зависимости через `pnpm install`
5. ✅ Dev сервер запущен и работает на порту 3006

## 📋 Настройки для Builder.io Cloud:

### Environment Variables (Скопируйте в Builder.io)

```
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

**⚠️ Важно:** Замените `your-builder-api-key-here` на ваш реальный API ключ!

### Setup Command

```
pnpm install
```

### Dev Command

```
pnpm dev
```

### Package Manager

```
pnpm
```

## 🔧 Создание .env файла

### Автоматически (Windows)

Запустите скрипт:

```bash
create-env.bat
```

### Вручную

Создайте файл `.env` в корне проекта со следующим содержимым:

```env
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

## 📝 Как получить API ключ Builder.io

1. Зайдите на [builder.io](https://builder.io)
2. Создайте аккаунт или войдите
3. Создайте новый проект
4. Перейдите в **Settings** → **API Keys**
5. Скопируйте **Public API Key**
6. Вставьте в `.env` вместо `your-builder-api-key-here`

## ✅ Проверка работы

После настройки:

1. Убедитесь, что `.env` файл создан
2. Добавьте ваш API ключ в `.env`
3. Запустите: `pnpm dev`
4. Сервер запустится на `http://localhost:3006`
5. Проверьте в браузере: `http://localhost:3006`

## 📦 Использование BuilderComponent

```vue
<template>
  <div>
    <BuilderComponent model="page" entry="your-entry-id" />
  </div>
</template>

<script setup lang="ts">
  import BuilderComponent from '@/components/builder/BuilderComponent.vue'
</script>
```

## 🎯 Готово!

Проект полностью настроен и готов к работе с Builder.io!

**Текущий статус:**

- ✅ Зависимости установлены
- ✅ Компоненты созданы
- ✅ Конфигурация готова
- ✅ Dev сервер работает на порту 3006
- ⚠️ Осталось только добавить API ключ в `.env`
