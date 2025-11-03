# 📋 Builder.io Settings - Быстрое копирование

## Быстрая настройка (Copy & Paste)

### Основные настройки:

```
Project Name: ant-v3-new
Framework Preset: Vue 3
Main Branch Name: main
Memory Limit: 4096 MB
Fusion Execution Environment: Use space settings
Commit Mode: Automatic
Default Branch Type: Feature Branch
Node.js Version: 20.x
Docker Image Path: (пусто)
Require Desktop App: Disabled
```

### Error Ignore Patterns:

```
^ResizeObserver loop limit exceeded$
^Non-Error promise rejection captured$
^ChunkLoadError.*
```

### Include Patterns:

```
src/**/*
public/**/*
*.json
*.md
vite.config.ts
tsconfig.json
```

### Preview URL Template:

```
http://localhost:3006$PATHNAME
```

### Design Mode Selector:

```
#app
```

**Примечание:** В `index.html` и `main.ts` приложение монтируется в `#app`, поэтому этот селектор будет работать корректно.

### Git Branch Naming:

```
feature/{{name}}
```

---

## 📝 Подробное описание каждого поля

См. `BUILDER_IO_PROJECT_SETUP.md` для подробной информации о каждом поле и рекомендациях.
