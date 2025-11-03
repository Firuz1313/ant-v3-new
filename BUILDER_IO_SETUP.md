# Настройка Builder.io

Этот проект настроен для работы с Builder.io - визуальным редактором контента.

## Быстрая настройка

### 1. Установка зависимостей

```bash
npm install
# или
pnpm install
```

### 2. Получение API ключа Builder.io

1. Зарегистрируйтесь на [builder.io](https://builder.io)
2. Создайте новый проект
3. Скопируйте ваш API ключ из настроек проекта

### 3. Настройка переменных окружения

Создайте файл `.env` в корне проекта на основе `.env.example`:

```bash
cp .env.example .env
```

Затем отредактируйте `.env` и добавьте ваш API ключ:

```env
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
```

### 4. Запуск проекта

```bash
npm run dev
# или
pnpm dev
```

Сервер запустится на `http://localhost:3006`

## Использование Builder.io компонента

### Базовое использование

```vue
<template>
  <BuilderComponent model="page" entry="your-entry-id" />
</template>

<script setup lang="ts">
  import BuilderComponent from '@/components/builder/BuilderComponent.vue'
</script>
```

### С кастомным API ключом

```vue
<template>
  <BuilderComponent model="page" :api-key="customApiKey" />
</template>
```

## Настройка в Builder.io

### Регистрация компонентов

В Builder.io зайдите в настройки проекта и зарегистрируйте ваши Vue компоненты:

1. Settings → Custom Components
2. Добавьте ваши компоненты из `src/components/`
3. Укажите props и варианты использования

### Настройка Preview URL

В Builder.io:

1. Settings → Preview URL
2. Установите: `http://localhost:3006` (для разработки)
3. Для продакшена: ваш домен

## Решение проблем

### Ошибка: API ключ не найден

- Проверьте, что файл `.env` существует
- Убедитесь, что переменная `VITE_BUILDER_API_KEY` установлена
- Перезапустите сервер разработки после изменения `.env`

### Контент не загружается

- Проверьте, что API ключ правильный
- Убедитесь, что в Builder.io создан контент с указанным `entry` или `model`
- Проверьте консоль браузера на наличие ошибок

### CORS ошибки

- Настройки CORS уже включены в `vite.config.ts`
- Для продакшена убедитесь, что ваш домен добавлен в Builder.io Settings → Allowed Hosts

### Dev server failed to start

- Убедитесь, что порт 3006 свободен
- Проверьте, что переменная `VITE_PORT` установлена в `.env`
- Запустите `pnpm install` для установки зависимостей
