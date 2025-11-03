# Builder.io Configuration Guide

## Настройка проекта в Builder.io

### 1. Environment Variables (Переменные окружения)

В Builder.io при настройке проекта используйте следующие переменные:

```env
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/
VITE_API_URL=/api/mock
VITE_BUILDER_API_KEY=your-builder-api-key-here
VITE_BUILDER_PREVIEW_URL=http://localhost:3006
NODE_ENV=development
```

**Важно:** Создайте файл `.env` в корне проекта с этими переменными.

### 2. Setup Command (Команда установки)

Используйте:

```bash
pnpm install
```

или

```bash
npm install
```

### 3. Dev Command (Команда разработки)

Используйте:

```bash
pnpm dev
```

или

```bash
npm run dev
```

**Package Manager:** `pnpm` (рекомендуется)

### 4. Port Configuration (Настройка порта)

- **Порт:** `3006` (настраивается через `VITE_PORT` в `.env`)
- Сервер должен быть доступен на `http://localhost:3006`
- Убедитесь, что порт свободен перед запуском

### 5. Troubleshooting (Решение проблем)

#### Dev server failed to start

1. Проверьте, что все зависимости установлены:

   ```bash
   pnpm install
   ```

2. Убедитесь, что файл `.env` существует в корне проекта

3. Проверьте, что порт 3006 свободен:

   ```bash
   netstat -ano | findstr :3006
   ```

4. Запустите сервер вручную для проверки:
   ```bash
   pnpm dev
   ```

#### CORS errors

CORS заголовки уже настроены в `vite.config.ts`. Если возникают проблемы:

- Убедитесь, что `host: true` установлен в конфигурации сервера
- Проверьте, что `cors: true` включен

#### API Key not found

- Убедитесь, что `.env` файл содержит `VITE_BUILDER_API_KEY`
- Перезапустите dev сервер после изменения `.env`
- Проверьте, что переменная начинается с `VITE_` (требование Vite)

### 6. Preview URL

В Builder.io Settings → Preview URL установите:

- **Development:** `http://localhost:3006`
- **Production:** ваш продакшен домен
