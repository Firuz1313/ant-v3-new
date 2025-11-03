# Настройка переменных окружения для Builder.io

## Создайте файл .env в корне проекта

Создайте файл `.env` со следующим содержимым:

```env
# Server Configuration
VITE_PORT=3006
VITE_VERSION=2.5.8
VITE_BASE_URL=/

# API Configuration
VITE_API_URL=/api/mock
# VITE_API_PROXY_URL=https://your-api-url.com

# Builder.io Configuration
# Замените 'your-builder-api-key-here' на ваш реальный API ключ из Builder.io
VITE_BUILDER_API_KEY=your-builder-api-key-here
# Preview URL для Builder.io редактора
VITE_BUILDER_PREVIEW_URL=http://localhost:3006

# Optional: Development Mode
NODE_ENV=development
```

## Как получить API ключ Builder.io

1. Зайдите на [builder.io](https://builder.io)
2. Создайте аккаунт или войдите
3. Создайте новый проект
4. Перейдите в Settings → API Keys
5. Скопируйте ваш Public API Key
6. Вставьте его в `.env` вместо `your-builder-api-key-here`

## Важные примечания

- Файл `.env` должен находиться в корне проекта
- После изменения `.env` перезапустите dev сервер
- `VITE_BUILDER_PREVIEW_URL` должен указывать на URL вашего dev сервера
- Для Builder.io Cloud используйте URL вашего продакшен домена
