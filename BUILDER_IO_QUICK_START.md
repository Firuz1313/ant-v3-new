# 🚀 Builder.io - Быстрый старт

## Автоматическая настройка (Windows)

Просто запустите:

```bash
create-env.bat
```

Это создаст файл `.env` со всеми необходимыми переменными.

## Ручная настройка

### 1. Создайте файл `.env`

Создайте файл `.env` в корне проекта с содержимым:

```env
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

### 2. Установите зависимости

```bash
pnpm install
```

### 3. Добавьте API ключ Builder.io

1. Зарегистрируйтесь на [builder.io](https://builder.io)
2. Создайте проект
3. Скопируйте API ключ
4. Вставьте в `.env` вместо `your-api-key-here`

### 4. Запустите проект

```bash
pnpm dev
```

Сервер запустится на `http://localhost:3006`

## Настройки для Builder.io Cloud

При настройке проекта в Builder.io используйте:

**Environment Variables:**

```
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

**Setup Command:**

```
pnpm install
```

**Dev Command:**

```
pnpm dev
```

**Package Manager:**

```
pnpm
```

## Готово! ✅

Проект настроен и готов к работе с Builder.io!
