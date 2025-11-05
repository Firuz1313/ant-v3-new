<template>
  <div class="cancelled-applications-page">
    <div class="page-title-section">
      <h1 class="page-title">ОТМЕНЕННЫЕ ЗАЯВКИ НА ПОДКЛЮЧЕНИЕ</h1>
    </div>

    <!-- Filters Section -->
    <div class="filters-section">
      <div class="filter-bar-container">
        <div class="filter-bar">
          <div class="filter-group">
            <label class="filter-label">Период:</label>
            <el-date-picker
              v-model="dateRangePicker"
              type="daterange"
              range-separator="—"
              start-placeholder="От"
              end-placeholder="До"
              format="DD.MM.YYYY"
              size="small"
              class="date-picker-input"
              @change="handleDateRangeChange"
            />
          </div>

          <div class="filter-divider"></div>

          <div class="filter-group days-group">
            <label class="filter-label">Дни:</label>
            <div class="days-input-group">
              <el-input-number
                v-model="daysRange[0]"
                :min="1"
                :max="31"
                size="small"
                controls-position="right"
                @change="validateDaysRange"
              />
              <span class="days-separator">—</span>
              <el-input-number
                v-model="daysRange[1]"
                :min="1"
                :max="31"
                size="small"
                controls-position="right"
                @change="validateDaysRange"
              />
              <span class="days-count">({{ daysRange[1] - daysRange[0] + 1 }} дн.)</span>
            </div>
          </div>

          <div class="filter-divider"></div>

          <!-- Date Range Slider inline -->
          <div class="filter-group slider-group">
            <label class="slider-label">Задать период</label>
            <div class="date-slider-wrapper">
              <div class="date-slider-track" ref="sliderTrackRef" @mousedown="handleTrackMouseDown">
                <div class="date-slider-rail"></div>
                <div
                  class="date-slider-range"
                  :style="{
                    left: `${startPercent}%`,
                    width: `${endPercent - startPercent}%`
                  }"
                ></div>
                <div
                  class="date-slider-handle start-handle"
                  :style="{ left: `${startPercent}%` }"
                  @mousedown.stop="handleStartMouseDown"
                >
                  <div class="handle-inner"></div>
                </div>
                <div
                  class="date-slider-handle end-handle"
                  :style="{ left: `${endPercent}%` }"
                  @mousedown.stop="handleEndMouseDown"
                >
                  <div class="handle-inner"></div>
                </div>
              </div>
              <div class="date-labels">
                <span class="date-label start-date">{{ formatDate(startDate) }}</span>
                <span class="date-label end-date">{{ formatDate(endDate) }}</span>
              </div>
            </div>
          </div>

          <div class="filter-divider"></div>

          <div class="filter-actions">
            <el-button @click="resetFilters" size="small" plain type="info"> Очистить </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-section">
      <div class="kpi-card kpi-blue">
        <div class="kpi-value">{{ formatNumber(totalCancelled) }}</div>
        <div class="kpi-label">Отмененные заявки на подключения</div>
      </div>
      <div class="kpi-card kpi-red">
        <div class="kpi-value">{{ cancelledPercent }}%</div>
        <div class="kpi-label">% отмененные заявок на подключения от выполненных</div>
      </div>
    </div>

    <!-- Main Content: Three Panels -->
    <div class="content-section">
      <!-- Left Panel: Creator FIO Table -->
      <div class="left-panel">
        <div class="table-wrapper">
          <div class="table-header">
            <h2 class="table-title">ОТМЕНЕННЫЕ ЗАЯВКИ НА ПОДКЛЮЧЕНИЕ</h2>
          </div>
          <div class="table-container">
            <el-table
              :data="groupedCreatorTable"
              stripe
              border
              class="creator-table"
              :default-sort="{ prop: 'cancelled', order: 'descending' }"
            >
              <el-table-column prop="creatorFio" label="ФИО создателя" min-width="200" align="left">
                <template #default="{ row }">
                  <span class="fio-cell">{{ row.creatorFio }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="masterFio" label="Мастер ФИО" min-width="200" align="left">
                <template #default="{ row }">
                  <span class="fio-cell">{{ row.masterFio }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="cancelled" label="Отменено" min-width="120" align="center">
                <template #default="{ row }">
                  <span class="number-cell">{{ formatNumber(row.cancelled) }}</span>
                </template>
              </el-table-column>
            </el-table>
          </div>
          <div class="table-summary">
            <span class="summary-label">Всего</span>
            <span class="summary-value">{{ formatNumber(totalCancelled) }}</span>
          </div>
        </div>
      </div>

      <!-- Middle Panel: Comment Table -->
      <div class="middle-panel">
        <div class="table-wrapper">
          <div class="table-header">
            <h2 class="table-title">Комментарий ответственного</h2>
            <h3 class="table-subtitle">Количества отмененных заявок на подключение</h3>
          </div>
          <div class="table-container">
            <el-table
              :data="filteredCommentTable"
              stripe
              border
              class="comment-table"
              :default-sort="{ prop: 'count', order: 'descending' }"
            >
              <el-table-column
                prop="comment"
                label="Комментарий"
                min-width="200"
                align="left"
                show-overflow-tooltip
              >
                <template #default="{ row }">
                  <div class="comment-cell">{{ row.comment }}</div>
                </template>
              </el-table-column>
              <el-table-column prop="count" label="Количество" min-width="100" align="center">
                <template #default="{ row }">
                  <span class="number-cell">{{ formatNumber(row.count) }}</span>
                </template>
              </el-table-column>
            </el-table>
          </div>
          <div class="table-summary">
            <span class="summary-label">Всего</span>
            <span class="summary-value">{{ formatNumber(totalCancelled) }}</span>
          </div>
        </div>
      </div>

      <!-- Creator Filter Panel -->
      <div class="creator-filter-panel">
        <div class="filter-wrapper">
          <h3 class="filter-title">ФИО создателя</h3>
          <div class="filter-checkboxes">
            <el-checkbox
              v-model="selectAllCreator"
              :indeterminate="isIndeterminateCreator"
              @change="handleSelectAllCreator"
              class="select-all-checkbox"
            >
              Выбрать все
            </el-checkbox>
            <el-checkbox-group v-model="selectedCreatorFios" @change="handleCreatorFilterChange">
              <div v-for="creator in uniqueCreatorFios" :key="creator" class="checkbox-item">
                <el-checkbox :label="creator">{{ creator }}</el-checkbox>
              </div>
            </el-checkbox-group>
          </div>
        </div>
      </div>

      <!-- Master Filter Panel -->
      <div class="master-filter-panel">
        <div class="filter-wrapper">
          <h3 class="filter-title">Мастер ФИО</h3>
          <div class="filter-checkboxes">
            <el-checkbox
              v-model="selectAllMaster"
              :indeterminate="isIndeterminateMaster"
              @change="handleSelectAllMaster"
              class="select-all-checkbox"
            >
              Выбрать все
            </el-checkbox>
            <el-checkbox-group v-model="selectedMasterFios" @change="handleMasterFilterChange">
              <div v-for="master in uniqueMasterFios" :key="master" class="checkbox-item">
                <el-checkbox :label="master">{{ master }}</el-checkbox>
              </div>
            </el-checkbox-group>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

  interface CreatorRow {
    creatorFio: string
    masterFio: string
    cancelled: number
    date: Date
  }

  interface CommentRow {
    comment: string
    count: number
    creatorFio?: string
    masterFio?: string
  }

  // Mock data based on image description
  // Генерируем данные с датами для фильтрации (с апреля 2024 по декабрь 2025)
  const generateMockData = (): CreatorRow[] => {
    const baseData = [
      { creatorFio: 'Курбонова Сурайё', masterFio: 'Нозимов Мухаммадчон', cancelled: 196 },
      { creatorFio: 'Сафаров Мухаммадулло', masterFio: 'Абдухоликов Илхомчон', cancelled: 159 },
      { creatorFio: 'Сидикова Мадина', masterFio: 'Хамдамов Азамат', cancelled: 137 },
      { creatorFio: 'Абдуазизова Умида', masterFio: 'Ибрагимов Улугбек', cancelled: 115 },
      { creatorFio: 'Администратор', masterFio: 'Администратор', cancelled: 100 },
      { creatorFio: 'Абдувахобова Зарринахон', masterFio: 'Абдулатипов Ёдгор', cancelled: 95 },
      { creatorFio: 'Абдуллоева Шахноза', masterFio: 'Абдунабиев Аминчон', cancelled: 88 },
      { creatorFio: 'Ахмедова Дильноза', masterFio: 'Абдурахмонов Самад', cancelled: 82 },
      { creatorFio: 'Бобоева Фарзона', masterFio: 'Абдухоликов Илхомчон', cancelled: 75 },
      { creatorFio: 'Вахидова Муниса', masterFio: 'Администратор', cancelled: 68 }
    ]

    // Генерируем данные для разных месяцев и дней
    // С апреля 2024 по декабрь 2025
    const result: CreatorRow[] = []
    const startYear = 2024
    const startMonth = 3 // апрель (0-indexed)
    const endYear = 2025
    const endMonth = 11 // декабрь (0-indexed)

    for (let year = startYear; year <= endYear; year++) {
      const startM = year === startYear ? startMonth : 0
      const endM = year === endYear ? endMonth : 11

      for (let month = startM; month <= endM; month++) {
        // Определяем количество дней в месяце
        const daysInMonth = new Date(year, month + 1, 0).getDate()

        // Генерируем данные для каждого дня месяца (для тестирования фильтров)
        for (let day = 1; day <= daysInMonth; day++) {
          baseData.forEach((item) => {
            // Генерируем данные для большинства дней (80% вероятность)
            if (Math.random() > 0.2) {
              const date = new Date(year, month, day)
              // Создаем случайное значение отмененных заявок для каждого дня
              const baseCancelled = item.cancelled
              const cancelled = Math.max(
                1,
                Math.floor((baseCancelled * (0.3 + Math.random() * 0.5)) / 20)
              )
              result.push({
                ...item,
                date,
                cancelled
              })
            }
          })
        }
      }
    }

    return result
  }

  const allCreatorData = ref<CreatorRow[]>(generateMockData())

  // Comment data - будет пересчитываться на основе отфильтрованных данных
  const allCommentData = ref<CommentRow[]>([
    { comment: 'Отменена абонентом, через МП/ЛК', count: 8034 },
    { comment: 'у абонента все оборудование есть', count: 55 },
    { comment: 'муштари душанбенда будиян кай биён худашон занг мезадиян', count: 2 },
    { comment: 'Другая причина', count: 1 }
  ])

  // Filter state
  const dateRangePicker = ref<[Date, Date] | null>(null)
  const daysRange = ref<[number, number]>([1, 31])
  const defaultDateRange: [Date, Date] = [new Date(2025, 0, 1), new Date(2025, 0, 31)]

  // Date range slider state
  const minDate = new Date(2024, 3, 1) // 01.04.2024
  const maxDate = new Date(2025, 11, 31) // 31.12.2025
  const startDate = ref(new Date(2025, 0, 1))
  const endDate = ref(new Date(2025, 0, 31))

  const sliderTrackRef = ref<HTMLDivElement | null>(null)
  const isDragging = ref<'start' | 'end' | null>(null)

  // Calculate percentages
  const totalDays = computed(() => {
    return Math.ceil((maxDate.getTime() - minDate.getTime()) / (1000 * 60 * 60 * 24))
  })

  const startDays = computed(() => {
    return Math.ceil((startDate.value.getTime() - minDate.getTime()) / (1000 * 60 * 60 * 24))
  })

  const endDays = computed(() => {
    return Math.ceil((endDate.value.getTime() - minDate.getTime()) / (1000 * 60 * 60 * 24))
  })

  const startPercent = computed(() => {
    return (startDays.value / totalDays.value) * 100
  })

  const endPercent = computed(() => {
    return (endDays.value / totalDays.value) * 100
  })

  // Mouse event handlers
  function handleStartMouseDown(e: MouseEvent) {
    isDragging.value = 'start'
    e.preventDefault()
    document.addEventListener('mousemove', handleMouseMove)
    document.addEventListener('mouseup', handleMouseUp)
  }

  function handleEndMouseDown(e: MouseEvent) {
    isDragging.value = 'end'
    e.preventDefault()
    document.addEventListener('mousemove', handleMouseMove)
    document.addEventListener('mouseup', handleMouseUp)
  }

  function handleTrackMouseDown(e: MouseEvent) {
    if (!sliderTrackRef.value) return
    const rect = sliderTrackRef.value.getBoundingClientRect()
    const percent = ((e.clientX - rect.left) / rect.width) * 100
    const clickedDate = getDateFromPercent(percent)

    // Determine which handle to move based on which is closer
    const startDist = Math.abs(percent - startPercent.value)
    const endDist = Math.abs(percent - endPercent.value)

    if (startDist < endDist) {
      isDragging.value = 'start'
      startDate.value = clickedDate
    } else {
      isDragging.value = 'end'
      endDate.value = clickedDate
    }

    e.preventDefault()
    document.addEventListener('mousemove', handleMouseMove)
    document.addEventListener('mouseup', handleMouseUp)
  }

  function handleMouseMove(e: MouseEvent) {
    if (!isDragging.value || !sliderTrackRef.value) return

    const rect = sliderTrackRef.value.getBoundingClientRect()
    let percent = ((e.clientX - rect.left) / rect.width) * 100
    percent = Math.max(0, Math.min(100, percent))

    const clickedDate = getDateFromPercent(percent)

    if (isDragging.value === 'start') {
      if (clickedDate <= endDate.value) {
        startDate.value = clickedDate
      }
    } else if (isDragging.value === 'end') {
      if (clickedDate >= startDate.value) {
        endDate.value = clickedDate
      }
    }
  }

  function handleMouseUp() {
    isDragging.value = null
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
    // Sync slider with date picker
    dateRangePicker.value = [startDate.value, endDate.value]

    // Синхронизируем daysRange
    const startDay = startDate.value.getDate()
    const endDay = endDate.value.getDate()
    if (
      startDate.value.getMonth() === endDate.value.getMonth() &&
      startDate.value.getFullYear() === endDate.value.getFullYear()
    ) {
      daysRange.value = [startDay, endDay]
    }

    onFilterChange()
  }

  function handleDateRangeChange() {
    if (dateRangePicker.value && dateRangePicker.value.length === 2) {
      startDate.value = dateRangePicker.value[0]
      endDate.value = dateRangePicker.value[1]

      // Синхронизируем daysRange с датами
      const startDay = startDate.value.getDate()
      const endDay = endDate.value.getDate()
      if (
        startDate.value.getMonth() === endDate.value.getMonth() &&
        startDate.value.getFullYear() === endDate.value.getFullYear()
      ) {
        daysRange.value = [startDay, endDay]
      }
    }
    onFilterChange()
  }

  function validateDaysRange() {
    if (daysRange.value[0] > daysRange.value[1]) {
      const temp = daysRange.value[0]
      daysRange.value[0] = daysRange.value[1]
      daysRange.value[1] = temp
    }

    // Синхронизируем даты с daysRange
    if (startDate.value && endDate.value) {
      const year = startDate.value.getFullYear()
      const month = startDate.value.getMonth()
      const newStartDate = new Date(year, month, daysRange.value[0])
      const newEndDate = new Date(year, month, daysRange.value[1])

      if (
        newStartDate.getTime() !== startDate.value.getTime() ||
        newEndDate.getTime() !== endDate.value.getTime()
      ) {
        startDate.value = newStartDate
        endDate.value = newEndDate
        dateRangePicker.value = [newStartDate, newEndDate]
      }
    }
    onFilterChange()
  }

  function getDateFromPercent(percent: number): Date {
    const days = Math.round((percent / 100) * totalDays.value)
    const date = new Date(minDate)
    date.setDate(date.getDate() + days)
    return date
  }

  function formatDate(date: Date): string {
    const day = String(date.getDate()).padStart(2, '0')
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const year = date.getFullYear()
    return `${day}.${month}.${year}`
  }

  // Filter checkboxes
  const selectedCreatorFios = ref<string[]>([])
  const selectedMasterFios = ref<string[]>([])
  const selectAllCreator = ref(false)
  const selectAllMaster = ref(false)

  // Unique FIOs for filters - берем из всех данных, но можно фильтровать по датам
  const uniqueCreatorFios = computed(() => {
    // Фильтруем по датам для отображения только релевантных ФИО
    let filtered = [...allCreatorData.value]

    if (startDate.value && endDate.value) {
      filtered = filtered.filter((row) => {
        const rowDate = new Date(row.date)
        rowDate.setHours(0, 0, 0, 0)
        const start = new Date(startDate.value)
        start.setHours(0, 0, 0, 0)
        const end = new Date(endDate.value)
        end.setHours(23, 59, 59, 999)
        return rowDate >= start && rowDate <= end
      })
    }

    const fios = new Set(filtered.map((row) => row.creatorFio))
    return Array.from(fios).sort()
  })

  const uniqueMasterFios = computed(() => {
    // Фильтруем по датам для отображения только релевантных ФИО
    let filtered = [...allCreatorData.value]

    if (startDate.value && endDate.value) {
      filtered = filtered.filter((row) => {
        const rowDate = new Date(row.date)
        rowDate.setHours(0, 0, 0, 0)
        const start = new Date(startDate.value)
        start.setHours(0, 0, 0, 0)
        const end = new Date(endDate.value)
        end.setHours(23, 59, 59, 999)
        return rowDate >= start && rowDate <= end
      })
    }

    const fios = new Set(filtered.map((row) => row.masterFio))
    return Array.from(fios).sort()
  })

  // Filtered tables
  const filteredCreatorTable = computed(() => {
    let filtered = [...allCreatorData.value]

    // Фильтр по датам (из бегунка или date picker) - ОБЯЗАТЕЛЬНЫЙ
    if (startDate.value && endDate.value) {
      filtered = filtered.filter((row) => {
        const rowDate = new Date(row.date)
        rowDate.setHours(0, 0, 0, 0)
        const start = new Date(startDate.value)
        start.setHours(0, 0, 0, 0)
        const end = new Date(endDate.value)
        end.setHours(23, 59, 59, 999)
        return rowDate >= start && rowDate <= end
      })
    }

    // Фильтр по дням месяца - применяется только если даты в одном месяце
    if (daysRange.value[0] && daysRange.value[1] && startDate.value && endDate.value) {
      const startMonth = startDate.value.getMonth()
      const startYear = startDate.value.getFullYear()
      const endMonth = endDate.value.getMonth()
      const endYear = endDate.value.getFullYear()

      // Применяем фильтр по дням только если выбранный диапазон в одном месяце
      if (startMonth === endMonth && startYear === endYear) {
        filtered = filtered.filter((row) => {
          const day = row.date.getDate()
          const rowMonth = row.date.getMonth()
          const rowYear = row.date.getFullYear()
          // Проверяем, что день в том же месяце и году
          if (rowMonth === startMonth && rowYear === startYear) {
            return day >= daysRange.value[0] && day <= daysRange.value[1]
          }
          return false
        })
      }
    }

    // Фильтр по ФИО создателя
    if (selectedCreatorFios.value.length > 0) {
      const shouldIncludeAll =
        selectedCreatorFios.value.length === uniqueCreatorFios.value.length &&
        selectAllCreator.value
      if (!shouldIncludeAll) {
        filtered = filtered.filter((row) => selectedCreatorFios.value.includes(row.creatorFio))
      }
    }

    // Фильтр по ФИО мастера
    if (selectedMasterFios.value.length > 0) {
      const shouldIncludeAll =
        selectedMasterFios.value.length === uniqueMasterFios.value.length && selectAllMaster.value
      if (!shouldIncludeAll) {
        filtered = filtered.filter((row) => selectedMasterFios.value.includes(row.masterFio))
      }
    }

    return filtered
  })

  // Группировка отфильтрованных данных для таблицы Creator
  const groupedCreatorTable = computed(() => {
    const grouped = new Map<string, { creatorFio: string; masterFio: string; cancelled: number }>()

    filteredCreatorTable.value.forEach((row) => {
      const key = `${row.creatorFio}|${row.masterFio}`
      if (grouped.has(key)) {
        const existing = grouped.get(key)!
        existing.cancelled += row.cancelled
      } else {
        grouped.set(key, {
          creatorFio: row.creatorFio,
          masterFio: row.masterFio,
          cancelled: row.cancelled
        })
      }
    })

    return Array.from(grouped.values()).sort((a, b) => b.cancelled - a.cancelled)
  })

  const filteredCommentTable = computed(() => {
    // Для комментариев используем базовые данные, но можно пересчитать на основе отфильтрованных
    // В реальном приложении здесь была бы связь между комментариями и заявками
    return [...allCommentData.value]
  })

  // Totals
  const totalCancelled = computed(() => {
    return groupedCreatorTable.value.reduce((sum, row) => sum + row.cancelled, 0)
  })

  const totalCompleted = computed(() => 27900) // Mock value for percentage calculation
  const cancelledPercent = computed(() => {
    if (!totalCompleted.value) return 0
    return Math.round((totalCancelled.value / totalCompleted.value) * 100)
  })

  // Checkbox states
  const isIndeterminateCreator = computed(() => {
    return (
      selectedCreatorFios.value.length > 0 &&
      selectedCreatorFios.value.length < uniqueCreatorFios.value.length
    )
  })

  const isIndeterminateMaster = computed(() => {
    return (
      selectedMasterFios.value.length > 0 &&
      selectedMasterFios.value.length < uniqueMasterFios.value.length
    )
  })

  // Filter functions
  function onFilterChange() {
    // Reactive update happens automatically via computed property
  }

  function resetFilters() {
    dateRangePicker.value = [...defaultDateRange]
    startDate.value = defaultDateRange[0]
    endDate.value = defaultDateRange[1]
    daysRange.value = [1, 31]

    // Обновляем списки после сброса дат
    setTimeout(() => {
      selectedCreatorFios.value = [...uniqueCreatorFios.value]
      selectedMasterFios.value = [...uniqueMasterFios.value]
      selectAllCreator.value = true
      selectAllMaster.value = true
    }, 0)
  }

  function handleSelectAllCreator(val: boolean | string | number) {
    const isSelected = Boolean(val)
    selectedCreatorFios.value = isSelected ? [...uniqueCreatorFios.value] : []
  }

  function handleSelectAllMaster(val: boolean | string | number) {
    const isSelected = Boolean(val)
    selectedMasterFios.value = isSelected ? [...uniqueMasterFios.value] : []
  }

  function handleCreatorFilterChange() {
    selectAllCreator.value = selectedCreatorFios.value.length === uniqueCreatorFios.value.length
  }

  function handleMasterFilterChange() {
    selectAllMaster.value = selectedMasterFios.value.length === uniqueMasterFios.value.length
  }

  // Formatting
  function formatNumber(num: number): string {
    return Math.round(num)
      .toString()
      .replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  }

  onMounted(() => {
    // Initialize date range
    dateRangePicker.value = [...defaultDateRange]
    startDate.value = defaultDateRange[0]
    endDate.value = defaultDateRange[1]

    // Initialize with all selected - используем watch для обновления
    setTimeout(() => {
      selectedCreatorFios.value = [...uniqueCreatorFios.value]
      selectedMasterFios.value = [...uniqueMasterFios.value]
      selectAllCreator.value = true
      selectAllMaster.value = true
    }, 0)
  })

  onBeforeUnmount(() => {
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  })
</script>

<style scoped lang="scss">
  .cancelled-applications-page {
    box-sizing: border-box;
    width: 100%;
    max-width: 1600px;
    min-height: 100vh;
    padding: 24px;
    margin: 0 auto;
    overflow-x: hidden;
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);

    .page-title-section {
      margin-bottom: 32px;
      text-align: center;

      .page-title {
        padding: 0;
        margin: 0;
        font-size: 32px;
        font-weight: 800;
        color: #1e40af;
        text-shadow: 0 2px 4px rgb(30 64 175 / 10%);
        letter-spacing: 0.5px;
      }
    }

    .filters-section {
      margin-bottom: 24px;
    }

    .filter-bar-container {
      box-sizing: border-box;
      width: 100%;
      max-width: 100%;
      overflow: hidden;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      box-shadow: 0 2px 8px rgb(0 0 0 / 8%);
    }

    .filter-bar {
      display: flex;
      flex-wrap: wrap;
      gap: 14px;
      align-items: center;
      padding: 14px 18px;
    }

    .filter-group {
      display: flex;
      gap: 8px;
      align-items: center;
      white-space: nowrap;
    }

    .filter-label {
      margin: 0;
      font-size: 12px;
      font-weight: 700;
      color: #374151;
      text-transform: uppercase;
      letter-spacing: 0.4px;
    }

    .date-picker-input {
      width: 200px;

      :deep(.el-input__inner) {
        height: 32px;
        font-size: 12px;
        border-color: #d1d5db;
        transition: all 0.2s ease;

        &:focus {
          border-color: #1e40af;
          box-shadow: 0 0 0 2px rgb(30 64 175 / 10%);
        }
      }
    }

    .filter-divider {
      width: 1px;
      height: 24px;
      background: #e5e7eb;
    }

    .days-group {
      gap: 10px;
    }

    .days-input-group {
      display: flex;
      gap: 6px;
      align-items: center;

      :deep(.el-input-number) {
        width: 60px;

        .el-input__inner {
          height: 32px;
          font-size: 12px;
          font-weight: 600;
          text-align: center;
          border-color: #d1d5db;
          transition: all 0.2s ease;

          &:focus {
            border-color: #1e40af;
            box-shadow: 0 0 0 2px rgb(30 64 175 / 10%);
          }
        }
      }
    }

    .days-separator {
      font-size: 12px;
      font-weight: 600;
      color: #d1d5db;
    }

    .days-count {
      font-size: 11px;
      font-weight: 700;
      color: #6b7280;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      white-space: nowrap;
    }

    .filter-actions {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-left: auto;

      :deep(.el-button) {
        height: 32px;
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
      }
    }

    .slider-group {
      display: flex;
      flex: 1;
      flex-direction: column;
      gap: 8px;
      align-items: center;
      align-self: center;
      justify-content: flex-start;
      min-width: 320px;
      max-width: 500px;
      margin: 0 auto;
    }

    .slider-label {
      width: 100%;
      margin: 0;
      font-size: 12px;
      font-weight: 700;
      color: #374151;
      text-align: center;
      text-transform: uppercase;
      letter-spacing: 0.4px;
      white-space: nowrap;
    }

    .date-slider-wrapper {
      position: relative;
      display: flex;
      flex-direction: column;
      gap: 0;
      align-items: center;
      justify-content: flex-start;
      width: 100%;
      padding: 0 12px;
      margin-top: 0;
    }

    .date-labels {
      position: relative;
      z-index: 1;
      display: flex;
      align-items: center;
      justify-content: space-between;
      width: 100%;
      padding: 0 4px;
      margin-top: 18px;
      pointer-events: none;

      .date-label {
        padding: 3px 8px;
        font-size: 10px;
        font-weight: 700;
        color: #1e40af;
        white-space: nowrap;
        background: linear-gradient(135deg, #f0f9ff 0%, #fff 100%);
        border: 1.5px solid #1e40af;
        border-radius: 5px;
        box-shadow: 0 1px 3px rgb(30 64 175 / 20%);
      }
    }

    .date-slider-track {
      position: relative;
      display: flex;
      flex-direction: column;
      justify-content: center;
      width: 100%;
      max-width: 100%;
      height: 28px;
      margin-top: 0;
      touch-action: none;
      cursor: pointer;
    }

    .date-slider-rail {
      position: absolute;
      top: 50%;
      right: 0;
      left: 0;
      height: 7px;
      background: linear-gradient(90deg, #dbeafe 0%, #e0e7ff 100%);
      border-radius: 4px;
      box-shadow: inset 0 1px 3px rgb(0 0 0 / 10%);
      transform: translateY(-50%);
    }

    .date-slider-range {
      position: absolute;
      top: 50%;
      height: 7px;
      background: linear-gradient(90deg, #1e40af 0%, #2563eb 100%);
      border-radius: 4px;
      box-shadow: 0 2px 4px rgb(30 64 175 / 30%);
      transition:
        left 0.15s ease,
        width 0.15s ease;
      transform: translateY(-50%);
    }

    .date-slider-handle {
      position: absolute;
      top: 50%;
      z-index: 2;
      width: 20px;
      height: 20px;
      cursor: grab;
      background: white;
      border: 3px solid #1e40af;
      border-radius: 50%;
      box-shadow:
        0 2px 8px rgb(0 0 0 / 20%),
        0 0 0 1px rgb(255 255 255 / 80%);
      transition:
        transform 0.15s ease,
        box-shadow 0.15s ease,
        border-color 0.15s ease;
      transform: translate(-50%, -50%);

      &:hover {
        border-color: #2563eb;
        box-shadow:
          0 3px 10px rgb(0 0 0 / 25%),
          0 0 0 2px rgb(30 64 175 / 10%);
        transform: translate(-50%, -50%) scale(1.12);
      }

      &:active {
        cursor: grabbing;
        box-shadow:
          0 4px 12px rgb(0 0 0 / 30%),
          0 0 0 3px rgb(30 64 175 / 15%);
        transform: translate(-50%, -50%) scale(1.18);
      }

      .handle-inner {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 7px;
        height: 7px;
        background: #1e40af;
        border-radius: 50%;
        transition: background 0.15s ease;
        transform: translate(-50%, -50%);
      }

      &:hover .handle-inner {
        background: #2563eb;
      }
    }

    @media (width <= 1200px) {
      .filter-bar {
        gap: 12px;
        padding: 12px 16px;
      }

      .date-picker-input {
        width: 180px;
      }

      .slider-group {
        min-width: 280px;
        max-width: 450px;
      }
    }

    @media (width <= 992px) {
      .filter-bar {
        flex-direction: column;
        gap: 12px;
        align-items: stretch;
        padding: 16px;
      }

      .filter-group {
        justify-content: space-between;
        width: 100%;
      }

      .filter-divider {
        display: none;
      }

      .date-picker-input {
        width: 100%;
        max-width: 300px;
      }

      .days-input-group {
        flex-wrap: wrap;
        gap: 8px;
      }

      .filter-actions {
        justify-content: center;
        width: 100%;
        margin-left: 0;
      }

      .slider-group {
        order: 10;
        width: 100%;
        min-width: auto;
        max-width: 100%;
        margin-top: 12px;
      }

      .date-slider-wrapper {
        gap: 0;
        padding: 0 10px;
        margin-top: 0;
      }

      .date-labels {
        padding: 0 3px;
        margin-top: 16px;

        .date-label {
          padding: 2px 6px;
          font-size: 9px;
        }
      }

      .date-slider-track {
        height: 26px;
      }

      .date-slider-handle {
        width: 18px;
        height: 18px;
        border-width: 2.5px;
      }
    }

    @media (width <= 768px) {
      .filter-bar {
        gap: 10px;
        padding: 14px;
      }

      .filter-label {
        font-size: 11px;
      }

      .date-picker-input {
        max-width: 100%;

        :deep(.el-input__inner) {
          height: 36px;
          font-size: 13px;
        }
      }

      .days-input-group {
        :deep(.el-input-number) {
          width: 70px;

          .el-input__inner {
            height: 36px;
            font-size: 13px;
          }
        }
      }

      .days-count {
        font-size: 10px;
      }

      .filter-actions {
        :deep(.el-button) {
          height: 36px;
          padding: 8px 16px;
          font-size: 12px;
        }
      }

      .slider-group {
        margin-top: 10px;
      }

      .slider-label {
        font-size: 11px;
      }

      .date-slider-wrapper {
        gap: 0;
        padding: 0 8px;
        margin-top: 0;
      }

      .date-labels {
        padding: 0 2px;
        margin-top: 14px;

        .date-label {
          padding: 2px 4px;
          font-size: 8px;
        }
      }

      .date-slider-track {
        height: 24px;
      }

      .date-slider-handle {
        width: 16px;
        height: 16px;
        border-width: 2px;
      }
    }

    .kpi-section {
      display: flex;
      flex-wrap: nowrap;
      gap: 16px;
      align-items: stretch;
      justify-content: stretch;
      width: 100%;
      max-width: 100%;
      margin-bottom: 24px;

      .kpi-card {
        flex: 1;
        width: 100%;
        min-width: 0;
        max-width: none;
        padding: 24px 32px;
        text-align: center;
        border: 1px solid rgb(30 64 175 / 10%);
        border-radius: 16px;
        box-shadow: 0 4px 20px rgb(0 0 0 / 8%);
        transition: all 0.3s ease;

        &:hover {
          box-shadow: 0 6px 24px rgb(0 0 0 / 12%);
          transform: translateY(-2px);
        }

        .kpi-value {
          margin-bottom: 12px;
          font-size: 48px;
          font-weight: 800;
          line-height: 1;
        }

        .kpi-label {
          font-size: 14px;
          font-weight: 600;
          line-height: 1.4;
          color: #6b7280;
        }
      }

      .kpi-blue {
        color: #1e40af;
        background: linear-gradient(135deg, #dbeafe, #f0f9ff);

        .kpi-value {
          color: #1e40af;
        }
      }

      .kpi-red {
        color: #991b1b;
        background: linear-gradient(135deg, #fee2e2, #fef2f2);

        .kpi-value {
          color: #dc2626;
        }
      }
    }

    .content-section {
      box-sizing: border-box;
      display: grid;
      grid-template-columns: 1.5fr 1fr 280px 280px;
      gap: 20px;
      align-items: start;
      width: 100%;
      max-width: 100%;
    }

    .left-panel,
    .middle-panel {
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      width: 100%;
      max-width: 100%;
      height: 100%;
      overflow: hidden;

      .table-wrapper {
        box-sizing: border-box;
        display: flex;
        flex-direction: column;
        width: 100%;
        max-width: 100%;
        height: 100%;
        min-height: 600px;
        overflow: hidden;
        background: white;
        border: 1px solid rgb(30 64 175 / 10%);
        border-radius: 16px;
        box-shadow: 0 4px 20px rgb(0 0 0 / 8%);
        transition: all 0.3s ease;

        &:hover {
          box-shadow: 0 6px 24px rgb(0 0 0 / 12%);
        }
      }

      .table-header {
        flex-shrink: 0;
        padding: 20px 24px;
        background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
        border-bottom: 2px solid #f0f4f8;

        .table-title {
          margin: 0 0 6px;
          font-size: 17px;
          font-weight: 800;
          line-height: 1.3;
          color: #1e40af;
          letter-spacing: 0.3px;
        }

        .table-subtitle {
          margin: 0;
          font-size: 13px;
          font-weight: 600;
          line-height: 1.4;
          color: #6b7280;
          letter-spacing: 0.2px;
        }
      }

      .table-container {
        box-sizing: border-box;
        flex: 1;
        width: 100%;
        max-width: 100%;
        min-height: 0;
        padding: 0;
        overflow: auto;
      }

      .creator-table,
      .comment-table {
        width: 100%;
        max-width: 100%;
        table-layout: auto;

        :deep(.el-table) {
          width: 100%;
          max-width: 100%;
        }

        :deep(.el-table__header-wrapper) {
          overflow-x: hidden;

          .el-table__header {
            width: 100%;

            th {
              padding: 12px 8px;
              font-size: 13px;
              font-weight: 700;
              line-height: 1.4;
              color: white;
              text-align: center;
              word-wrap: break-word;
              overflow-wrap: break-word;
              white-space: normal;
              background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);
              border-color: #cbd5e1;
            }
          }
        }

        :deep(.el-table__body-wrapper) {
          overflow-x: hidden;

          .el-table__body {
            width: 100%;

            td {
              padding: 12px 8px;
              font-size: 13px;
              word-wrap: break-word;
              overflow-wrap: break-word;
              vertical-align: top;
              border-color: #e5e7eb;

              &.el-table__cell {
                padding: 12px 8px;
              }
            }

            :deep(.el-table__row:hover > td) {
              background-color: #f3f4f6;
            }
          }
        }
      }

      .fio-cell {
        font-weight: 500;
        color: #1f2937;
      }

      .comment-cell {
        display: -webkit-box;
        max-height: 2.8em;
        overflow: hidden;
        font-weight: 500;
        line-height: 1.4;
        color: #1f2937;
        text-overflow: ellipsis;
        word-wrap: break-word;
        overflow-wrap: break-word;
        white-space: normal;
        -webkit-line-clamp: 2;
        line-clamp: 2;
        -webkit-box-orient: vertical;
      }

      .number-cell {
        font-weight: 700;
        color: #1f2937;
      }

      .table-summary {
        display: flex;
        flex-shrink: 0;
        align-items: center;
        justify-content: space-between;
        padding: 16px 24px;
        background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
        border-top: 2px solid #f0f4f8;

        .summary-label {
          font-size: 14px;
          font-weight: 800;
          color: #1f2937;
        }

        .summary-value {
          font-size: 18px;
          font-weight: 700;
          color: #1e40af;
        }
      }
    }

    .creator-filter-panel,
    .master-filter-panel {
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      width: 100%;
      max-width: 100%;
      height: 100%;
      overflow: hidden;

      .filter-wrapper {
        box-sizing: border-box;
        display: flex;
        flex-direction: column;
        gap: 14px;
        width: 100%;
        max-width: 100%;
        height: 100%;
        min-height: 600px;
        padding: 20px;
        overflow: hidden auto;
        background: white;
        border: 1px solid rgb(30 64 175 / 10%);
        border-radius: 16px;
        box-shadow: 0 4px 20px rgb(0 0 0 / 8%);
        transition: all 0.3s ease;

        &:hover {
          box-shadow: 0 6px 24px rgb(0 0 0 / 12%);
        }

        .filter-title {
          flex-shrink: 0;
          padding-bottom: 10px;
          margin: 0;
          font-size: 14px;
          font-weight: 700;
          color: #1e40af;
          text-transform: uppercase;
          letter-spacing: 0.3px;
          border-bottom: 2px solid #f0f4f8;
        }

        .filter-checkboxes {
          display: flex;
          flex: 1;
          flex-direction: column;
          gap: 10px;
          min-height: 0;
          padding-right: 6px;
          overflow-y: auto;

          &::-webkit-scrollbar {
            width: 6px;
          }

          &::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 3px;
          }

          &::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;

            &:hover {
              background: #94a3b8;
            }
          }
        }

        .select-all-checkbox {
          padding-bottom: 8px;
          margin-bottom: 8px;
          border-bottom: 1px solid #e5e7eb;

          :deep(.el-checkbox__label) {
            font-weight: 700;
            color: #1e40af;
          }
        }

        .checkbox-item {
          :deep(.el-checkbox) {
            width: 100%;

            .el-checkbox__label {
              font-size: 13px;
              font-weight: 500;
              color: #374151;
            }
          }
        }
      }
    }

    @media (width <= 1600px) {
      .content-section {
        grid-template-columns: 1.5fr 1fr 240px 240px;
        gap: 18px;
        width: 100%;
        max-width: 100%;
      }
    }

    @media (width <= 1400px) {
      .cancelled-applications-page {
        width: 100%;
        max-width: 100vw;
        padding: 20px;
      }

      .content-section {
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        width: 100%;
        max-width: 100%;

        .creator-filter-panel {
          grid-column: 1;
          order: 3;
        }

        .master-filter-panel {
          grid-column: 2;
          order: 4;
        }

        .left-panel {
          order: 1;
        }

        .middle-panel {
          order: 2;
        }
      }

      .left-panel,
      .middle-panel {
        .table-wrapper {
          min-height: 550px;
        }
      }

      .creator-filter-panel,
      .master-filter-panel {
        .filter-wrapper {
          min-height: 400px;
          max-height: 500px;
        }
      }
    }

    @media (width <= 1200px) {
      .cancelled-applications-page {
        width: 100%;
        max-width: 100vw;
        padding: 20px;
      }

      .kpi-section {
        gap: 12px;
        width: 100%;
        max-width: 100%;

        .kpi-card {
          flex: 1;
          min-width: 0;
          max-width: none;
          padding: 20px 24px;

          .kpi-value {
            font-size: 40px;
          }

          .kpi-label {
            font-size: 13px;
          }
        }
      }

      .content-section {
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        width: 100%;
        max-width: 100%;

        .creator-filter-panel {
          grid-column: 1;
          order: 3;
        }

        .master-filter-panel {
          grid-column: 2;
          order: 4;
        }
      }

      .left-panel,
      .middle-panel {
        .table-wrapper {
          min-height: 500px;
        }
      }

      .creator-filter-panel,
      .master-filter-panel {
        .filter-wrapper {
          min-height: 350px;
          max-height: 450px;
        }
      }
    }

    @media (width <= 992px) {
      .cancelled-applications-page {
        width: 100%;
        max-width: 100vw;
        padding: 16px;
      }

      .page-title-section {
        margin-bottom: 24px;

        .page-title {
          font-size: 26px;
        }
      }

      .kpi-section {
        gap: 12px;
        width: 100%;
        max-width: 100%;
        margin-bottom: 20px;

        .kpi-card {
          flex: 1;
          min-width: 0;
          max-width: none;
          padding: 20px 24px;

          .kpi-value {
            font-size: 36px;
          }

          .kpi-label {
            font-size: 13px;
          }
        }
      }

      .content-section {
        box-sizing: border-box;
        grid-template-columns: 1fr;
        gap: 16px;
        width: 100%;
        max-width: 100%;

        .creator-filter-panel {
          order: 3;
        }

        .master-filter-panel {
          order: 4;
        }
      }

      .left-panel,
      .middle-panel {
        .table-wrapper {
          min-height: 450px;
        }

        .table-header {
          padding: 18px 20px;

          .table-title {
            font-size: 16px;
          }

          .table-subtitle {
            font-size: 12px;
          }
        }

        .table-container {
          width: 100%;
          max-width: 100%;
          overflow: hidden auto;

          .creator-table,
          .comment-table {
            width: 100%;
            min-width: 0;
            max-width: 100%;

            :deep(.el-table) {
              width: 100%;
              max-width: 100%;
            }

            :deep(.el-table__header th) {
              padding: 10px 6px;
              font-size: 12px;
              line-height: 1.4;
              word-wrap: break-word;
              overflow-wrap: break-word;
              white-space: normal;
            }

            :deep(.el-table__body td) {
              padding: 10px 6px;
              font-size: 12px;
              word-wrap: break-word;
              overflow-wrap: break-word;
              vertical-align: top;
            }
          }
        }
      }

      .creator-filter-panel,
      .master-filter-panel {
        .filter-wrapper {
          min-height: 300px;
          max-height: 400px;
        }
      }
    }

    @media (width <= 768px) {
      .cancelled-applications-page {
        width: 100%;
        max-width: 100vw;
        padding: 12px;
      }

      .page-title-section {
        margin-bottom: 24px;

        .page-title {
          font-size: 24px;
        }
      }

      .kpi-section {
        flex-direction: row;
        gap: 12px;
        width: 100%;
        max-width: 100%;
        margin-bottom: 16px;

        .kpi-card {
          flex: 1;
          width: 100%;
          min-width: 0;
          max-width: none;
          padding: 18px 20px;

          .kpi-value {
            font-size: 32px;
          }

          .kpi-label {
            font-size: 12px;
          }
        }
      }

      .content-section {
        box-sizing: border-box;
        grid-template-columns: 1fr;
        gap: 12px;
        width: 100%;
        max-width: 100%;

        .creator-filter-panel {
          order: 3;
        }

        .master-filter-panel {
          order: 4;
        }
      }

      .left-panel,
      .middle-panel {
        .table-wrapper {
          width: 100%;
          max-width: 100%;
          min-height: 400px;
          border-radius: 12px;
        }

        .table-header {
          padding: 16px 20px;

          .table-title {
            font-size: 15px;
          }

          .table-subtitle {
            font-size: 12px;
          }
        }

        .table-container {
          width: 100%;
          max-width: 100%;
          max-height: 350px;
          overflow: hidden auto;

          .creator-table,
          .comment-table {
            width: 100%;
            min-width: 0;
            max-width: 100%;
            table-layout: auto;

            :deep(.el-table) {
              width: 100%;
              max-width: 100%;
            }

            :deep(.el-table__header th) {
              padding: 10px 6px;
              font-size: 11px;
              line-height: 1.3;
              word-wrap: break-word;
              overflow-wrap: break-word;
              white-space: normal;
            }

            :deep(.el-table__body td) {
              padding: 10px 6px;
              font-size: 11px;
              word-wrap: break-word;
              overflow-wrap: break-word;
              vertical-align: top;
            }
          }
        }

        .table-summary {
          padding: 14px 20px;

          .summary-label {
            font-size: 13px;
          }

          .summary-value {
            font-size: 16px;
          }
        }
      }

      .creator-filter-panel,
      .master-filter-panel {
        width: 100%;
        max-width: 100%;

        .filter-wrapper {
          width: 100%;
          max-width: 100%;
          min-height: 250px;
          max-height: 300px;
          padding: 16px;
          border-radius: 12px;
        }
      }
    }

    @media (width <= 480px) {
      .cancelled-applications-page {
        width: 100%;
        max-width: 100vw;
        padding: 8px;
      }

      .page-title-section {
        margin-bottom: 16px;

        .page-title {
          font-size: 18px;
          line-height: 1.2;
        }
      }

      .filters-section {
        margin-bottom: 16px;
      }

      .filter-bar-container {
        width: 100%;
        max-width: 100%;
        border-radius: 8px;
      }

      .filter-bar {
        box-sizing: border-box;
        gap: 8px;
        width: 100%;
        max-width: 100%;
        padding: 12px;
      }

      .filter-group {
        flex-direction: column;
        gap: 6px;
        align-items: flex-start;
        width: 100%;
      }

      .filter-label {
        font-size: 10px;
      }

      .date-picker-input {
        width: 100%;
        max-width: 100%;

        :deep(.el-input__inner) {
          height: 38px;
          font-size: 12px;
        }
      }

      .days-input-group {
        justify-content: space-between;
        width: 100%;

        :deep(.el-input-number) {
          width: 80px;

          .el-input__inner {
            height: 38px;
            font-size: 12px;
          }
        }
      }

      .days-count {
        font-size: 9px;
      }

      .filter-actions {
        width: 100%;
        margin-top: 4px;

        :deep(.el-button) {
          width: 100%;
          height: 38px;
          font-size: 11px;
        }
      }

      .slider-group {
        width: 100%;
        margin-top: 8px;
      }

      .slider-label {
        font-size: 10px;
      }

      .date-slider-wrapper {
        padding: 0 6px;
      }

      .date-labels {
        margin-top: 12px;

        .date-label {
          padding: 1px 3px;
          font-size: 7px;
        }
      }

      .date-slider-track {
        height: 22px;
      }

      .date-slider-handle {
        width: 14px;
        height: 14px;
        border-width: 2px;
      }

      .kpi-section {
        flex-direction: column;
        gap: 8px;
        width: 100%;
        max-width: 100%;
        margin-bottom: 16px;

        .kpi-card {
          width: 100%;
          min-width: 0;
          max-width: 100%;
          padding: 16px;

          .kpi-value {
            margin-bottom: 8px;
            font-size: 28px;
          }

          .kpi-label {
            font-size: 11px;
            line-height: 1.3;
          }
        }
      }

      .content-section {
        grid-template-columns: 1fr;
        gap: 12px;

        .creator-filter-panel {
          order: 3;
        }

        .master-filter-panel {
          order: 4;
        }
      }

      .left-panel,
      .middle-panel {
        .table-wrapper {
          min-height: 350px;
          border-radius: 8px;
        }

        .table-header {
          padding: 12px 16px;

          .table-title {
            font-size: 14px;
            line-height: 1.2;
          }

          .table-subtitle {
            font-size: 11px;
          }
        }

        .table-container {
          width: 100%;
          max-width: 100%;
          max-height: 300px;
          overflow: hidden auto;

          .creator-table,
          .comment-table {
            width: 100%;
            min-width: 0;
            max-width: 100%;
            table-layout: auto;

            :deep(.el-table) {
              width: 100%;
              max-width: 100%;
            }

            :deep(.el-table__header th) {
              padding: 8px 4px;
              font-size: 10px;
              line-height: 1.3;
              word-wrap: break-word;
              overflow-wrap: break-word;
              white-space: normal;
            }

            :deep(.el-table__body td) {
              padding: 8px 4px;
              font-size: 10px;
              word-wrap: break-word;
              overflow-wrap: break-word;
              vertical-align: top;
            }
          }
        }

        .table-summary {
          padding: 12px 16px;

          .summary-label {
            font-size: 12px;
          }

          .summary-value {
            font-size: 16px;
          }
        }
      }

      .creator-filter-panel,
      .master-filter-panel {
        width: 100%;
        max-width: 100%;

        .filter-wrapper {
          box-sizing: border-box;
          width: 100%;
          max-width: 100%;
          min-height: 200px;
          max-height: 280px;
          padding: 12px;
          border-radius: 8px;

          .filter-title {
            padding-bottom: 6px;
            font-size: 12px;
          }

          .filter-checkboxes {
            gap: 6px;

            .checkbox-item {
              :deep(.el-checkbox__label) {
                font-size: 12px;
              }
            }
          }
        }
      }
    }
  }
</style>
