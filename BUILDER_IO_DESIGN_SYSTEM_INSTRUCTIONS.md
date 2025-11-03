# 🎨 Builder.io Design System Instructions

## Как AI должен использовать дизайн-систему проекта

### 📁 Расположение компонентов

**Основные компоненты:**

- Дизайн-система компонентов находится в `src/components/core/`
- Кастомные компоненты находятся в `src/components/custom/`
- Builder.io компоненты находятся в `src/components/builder/`

**Структура компонентов:**

```
src/components/
├── core/                    # Основные компоненты дизайн-системы
│   ├── banners/            # Баннеры (art-basic-banner, art-card-banner)
│   ├── base/               # Базовые компоненты (art-back-to-top, art-icon-selector, art-logo)
│   ├── cards/              # Карточки (art-stats-card, art-bar-chart-card, art-line-chart-card)
│   ├── charts/             # Графики и диаграммы (art-bar-chart, art-line-chart, art-pie-chart)
│   ├── forms/              # Формы (art-form, art-search-bar, art-wang-editor)
│   ├── layouts/            # Макеты (art-header-bar, art-sidebar-menu, art-breadcrumb)
│   ├── media/              # Медиа (art-cutter-img, art-video-player)
│   ├── tables/             # Таблицы (art-table, art-table-header)
│   ├── text-effect/        # Текстовые эффекты (art-count-to, art-text-scroll)
│   └── views/              # Представления (ArtException, ArtResultPage)
├── custom/                 # Кастомные компоненты
│   ├── comment-widget/
│   ├── HorizontalScrollButtons.vue
│   └── PagePlaceholder.vue
└── builder/                # Builder.io компоненты
    └── BuilderComponent.vue
```

### 🔧 Паттерны использования компонентов

#### 1. Vue 3 Composition API

**Все компоненты используют Composition API с `<script setup>`:**

```vue
<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'

  defineOptions({ name: 'ComponentName' })

  interface Props {
    /** Описание пропса */
    propName?: string
  }

  const props = withDefaults(defineProps<Props>(), {
    propName: 'default-value'
  })
</script>
```

#### 2. Именование компонентов

**Префикс компонентов: `art-*`**

Примеры:

- `ArtStatsCard` (компонент: `src/components/core/cards/art-stats-card/index.vue`)
- `ArtBarChart` (компонент: `src/components/core/charts/art-bar-chart/index.vue`)
- `ArtForm` (компонент: `src/components/core/forms/art-form/index.vue`)
- `ArtTable` (компонент: `src/components/core/tables/art-table/index.vue`)

#### 3. TypeScript типизация

**Все props должны быть типизированы через интерфейсы:**

Пример из `src/components/core/cards/art-stats-card/index.vue`:

```typescript
interface StatsCardProps {
  /** 图标 */
  icon?: string
  /** 标题 */
  title?: string
  /** 数值 */
  count?: number
  /** 小数位 */
  decimals?: number
  /** 分隔符 */
  separator?: string
  /** 背景颜色 */
  backgroundColor?: string
  /** 文本颜色 */
  textColor?: string
  /** 显示箭头 */
  showArrow?: boolean
}
```

#### 4. Стилизация

**Используется SCSS с scoped стилями:**

```vue
<style scoped lang="scss">
  .component-name {
    // Стили компонента
  }
</style>
```

**Глобальные стили:**

- `src/assets/styles/app.scss` - основные стили приложения
- `src/assets/styles/variables.scss` - переменные SCSS
- `src/assets/styles/mixin.scss` - миксины SCSS

### 📦 Использование Element Plus

**Проект использует Element Plus 2.11.2 как базовый UI фреймворк:**

**Доступные компоненты Element Plus:**

- `ElButton` - кнопки
- `ElInput` - поля ввода
- `ElForm` - формы
- `ElTable` - таблицы
- `ElCard` - карточки
- `ElDialog` - диалоги
- `ElSelect` - селекторы
- И другие компоненты из Element Plus

**Пример использования:**

```vue
<template>
  <el-button type="primary">Click me</el-button>
</template>
```

### 🎯 Рекомендации по использованию компонентов

#### Карточки (Cards)

**Компоненты: `src/components/core/cards/`**

Примеры:

- `ArtStatsCard` - карточка со статистикой
- `ArtBarChartCard` - карточка с барным графиком
- `ArtLineChartCard` - карточка с линейным графиком
- `ArtDonutChartCard` - карточка с круговым графиком
- `ArtProgressCard` - карточка с прогресс-баром

**Использование:**

```vue
<ArtStatsCard :title="'Total Users'" :count="1234" icon="&#xe601;" :show-arrow="true" />
```

#### Графики (Charts)

**Компоненты: `src/components/core/charts/`**

Примеры:

- `ArtBarChart` - барный график
- `ArtLineChart` - линейный график
- `ArtRingChart` - кольцевой график
- `ArtMapChart` - карта
- `ArtRadarChart` - радарный график

**Использование:**

```vue
<ArtBarChart
  :data="[10, 20, 30, 40, 50]"
  :x-axis-data="['Mon', 'Tue', 'Wed', 'Thu', 'Fri']"
  height="300px"
/>
```

#### Формы (Forms)

**Компоненты: `src/components/core/forms/`**

Примеры:

- `ArtForm` - динамическая форма
- `ArtSearchBar` - поисковая строка
- `ArtWangEditor` - текстовый редактор

**Использование ArtForm:**

```vue
<ArtForm :items="formItems" :span="6" @submit="handleSubmit" @reset="handleReset" />
```

#### Макеты (Layouts)

**Компоненты: `src/components/core/layouts/`**

Примеры:

- `ArtHeaderBar` - шапка страницы
- `ArtSidebarMenu` - боковое меню
- `ArtBreadcrumb` - хлебные крошки
- `ArtPageContent` - контент страницы

### 📚 Composables и утилиты

**Composables: `src/composables/`**

Доступные composables:

- `useChart` - работа с графиками
- `useTable` - работа с таблицами
- `useAuth` - аутентификация
- `useTheme` - темы
- И другие в `src/composables/`

**Пример:**

```typescript
import { useChartOps } from '@/composables/useChart'

const { chartHeight, colors } = useChartOps()
```

### 🎨 Типы компонентов

**Типы: `src/types/component/`**

Примеры:

- `src/types/component/chart.ts` - типы для графиков
- `src/types/component/index.ts` - общие типы компонентов

**Использование:**

```typescript
import type { BarChartProps } from '@/types/component/chart'
```

### 📝 Специфические рекомендации

#### 1. Импорт компонентов

**Всегда используйте полные пути для импорта:**

```typescript
// Правильно ✅
import ArtStatsCard from '@/components/core/cards/art-stats-card/index.vue'
import ArtBarChart from '@/components/core/charts/art-bar-chart/index.vue'

// Неправильно ❌
import ArtStatsCard from './components/art-stats-card'
```

#### 2. Использование иконок

**Иконки системы: `src/assets/icons/system/iconfont.css`**

```vue
<i class="iconfont-sys">&#xe601;</i>
```

#### 3. Использование цветов

**Используйте CSS переменные из темы:**

```typescript
import { getCssVar } from '@/utils/ui'

const primaryColor = getCssVar('el-color-primary')
```

#### 4. Адаптивность

**Используйте composable для определения мобильного устройства:**

```typescript
import { useWindowSize } from '@vueuse/core'

const { width } = useWindowSize()
const isMobile = computed(() => width.value < 500)
```

### 🚀 Примеры использования компонентов

#### Пример 1: Карточка со статистикой

```vue
<template>
  <ArtStatsCard
    title="Total Users"
    :count="1234"
    icon="&#xe601;"
    :show-arrow="true"
    background-color="#f0f9ff"
    text-color="#1e40af"
  />
</template>

<script setup lang="ts">
  import ArtStatsCard from '@/components/core/cards/art-stats-card/index.vue'
</script>
```

#### Пример 2: Барный график

```vue
<template>
  <ArtBarChart
    :data="[10, 20, 30, 40, 50]"
    :x-axis-data="['Mon', 'Tue', 'Wed', 'Thu', 'Fri']"
    height="300px"
    :colors="['#3b82f6', '#10b981']"
    :show-tooltip="true"
  />
</template>

<script setup lang="ts">
  import ArtBarChart from '@/components/core/charts/art-bar-chart/index.vue'
</script>
```

#### Пример 3: Форма с полями

```vue
<template>
  <ArtForm
    :items="formItems"
    :span="6"
    label-position="right"
    :show-submit="true"
    :show-reset="true"
    @submit="handleSubmit"
  />
</template>

<script setup lang="ts">
  import ArtForm from '@/components/core/forms/art-form/index.vue'
  import type { FormItem } from '@/components/core/forms/art-form/index.vue'

  const formItems: FormItem[] = [
    {
      key: 'name',
      label: 'Name',
      type: 'input',
      placeholder: 'Enter your name'
    },
    {
      key: 'email',
      label: 'Email',
      type: 'input',
      placeholder: 'Enter your email'
    }
  ]

  const handleSubmit = () => {
    // Handle form submit
  }
</script>
```

### ⚠️ Важные замечания

1. **Всегда используйте TypeScript** для типизации props и данных
2. **Используйте Composition API** с `<script setup>`
3. **Применяйте scoped стили** для изоляции CSS
4. **Используйте полные пути импорта** с алиасом `@/`
5. **Следуйте паттерну именования** `art-*` для компонентов
6. **Используйте Element Plus компоненты** как базовые UI элементы
7. **Обращайтесь к типам** из `src/types/component/` для типизации

### 📖 Дополнительные ресурсы

- **Элементы дизайн-системы:** `src/components/core/`
- **Типы компонентов:** `src/types/component/`
- **Composables:** `src/composables/`
- **Утилиты:** `src/utils/`
- **Стили:** `src/assets/styles/`

---

## Готово! ✅

AI теперь знает, как использовать дизайн-систему проекта для создания компонентов в Builder.io.
