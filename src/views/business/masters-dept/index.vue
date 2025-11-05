<template>
  <div class="masters-overview">
    <div class="page-title-section">
      <h1 class="page-title">ОТДЕЛ МАСТЕРОВ — ОБЩАЯ СВОДКА</h1>
    </div>

    <div class="filters-section">
      <div class="filter-bar-container">
        <div class="filter-bar">
          <div class="filter-group">
            <label class="filter-label">Период:</label>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="—"
              start-placeholder="От"
              end-placeholder="До"
              format="DD.MM.YYYY"
              size="small"
              class="date-picker-input"
              @change="onFilterChange"
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

          <div class="filter-presets">
            <el-button
              v-for="preset in datePresets"
              :key="preset.name"
              :type="isPresetActive(preset) ? 'primary' : 'default'"
              size="small"
              @click="applyPreset(preset)"
              class="preset-button"
            >
              {{ preset.label }}
            </el-button>
          </div>

          <div class="filter-actions">
            <el-button @click="resetFilters" size="small" plain type="info"> Очистить </el-button>
          </div>
        </div>
      </div>
    </div>

    <div class="layout-container">
      <!-- Left Panel: Table -->
      <div class="left-panel">
        <div class="table-header">
          <h2 class="table-title">ПЛАН/ФАКТ ПО ПОДКЛЮЧЕНИЯМ - ВЫПОЛНЕНИЯ</h2>
        </div>
        <div class="table-wrapper">
          <el-table
            :data="tableData"
            stripe
            border
            class="main-table"
            :row-class-name="getRowClassName"
          >
            <el-table-column prop="date" label="Дата" min-width="140" align="left">
              <template #default="{ row }">
                <span class="date-cell">{{ row.date }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="plan" label="План" min-width="100" align="center">
              <template #default="{ row }">
                <span class="plan-cell">{{ formatNumber(row.plan) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="fact" label="Факт" min-width="100" align="center">
              <template #default="{ row }">
                <span class="fact-cell">{{ row.fact }}</span>
              </template>
            </el-table-column>
            <el-table-column label="Выполнения в %" min-width="150" align="center">
              <template #default="{ row }">
                <div :class="['percent-cell', getPercentClass(row.percent)]">
                  <i :class="['arrow-icon', getArrowIcon(row.percent)]"></i>
                  <span>{{ row.percent }}%</span>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="table-summary">
          <span class="summary-label">Всего</span>
          <span class="summary-value">{{ formatNumber(totals.plan) }}</span>
          <span class="summary-value">{{ totals.fact }}</span>
          <div :class="['summary-percent', getPercentClass(overallPercent)]">
            <i :class="['arrow-icon', getArrowIcon(overallPercent)]"></i>
            <span>{{ overallPercent }}%</span>
          </div>
        </div>
      </div>

      <!-- Right Panel: KPIs and Gauge in one block -->
      <div class="right-panel">
        <div class="right-panel-content">
          <!-- Top Row KPIs -->
          <div class="kpi-row top">
            <div class="kpi-card blue">
              <div class="kpi-value">{{ animatedMonthDays }}</div>
              <div class="kpi-label">Дней в месяце</div>
            </div>
            <div class="kpi-card blue">
              <div class="kpi-value">{{ animatedDaysPassed }}</div>
              <div class="kpi-label">Дней прошло</div>
            </div>
            <div class="kpi-card orange">
              <div class="kpi-value">{{ animatedDaysLeft }}</div>
              <div class="kpi-label">Дней осталось</div>
            </div>
          </div>

          <!-- Middle Section KPIs -->
          <div class="kpi-section">
            <div class="kpi-card big blue">
              <div class="kpi-value">{{ animatedApplications }}</div>
              <div class="kpi-label">Заявки на подключение</div>
            </div>
            <div class="kpi-card blue">
              <div class="kpi-value">{{ formatNumber(animatedPlan) }}</div>
              <div class="kpi-label">План на подключение</div>
            </div>
            <div class="kpi-card red wide">
              <div class="kpi-value">{{ formatNumber(animatedRemaining) }}</div>
              <div class="kpi-label">Осталось для выполнения плана</div>
            </div>
          </div>

          <!-- Bottom Section KPIs -->
          <div class="kpi-section">
            <div class="kpi-card red">
              <div class="kpi-value">{{ formatNumber(animatedCancelled) }}</div>
              <div class="kpi-label">Отменено</div>
            </div>
            <div class="kpi-card green">
              <div class="kpi-value">{{ formatNumber(animatedFact) }}</div>
              <div class="kpi-label">Выполнено</div>
            </div>
            <div class="kpi-card orange">
              <div class="kpi-value">{{ formatNumber(animatedInProgress) }}</div>
              <div class="kpi-label">В процессе</div>
            </div>
          </div>

          <!-- Gauge Chart -->
          <div class="gauge-container">
            <div ref="gaugeRef" class="gauge-chart"></div>
            <div class="gauge-info">
              <div class="gauge-text"
                >Ежедневно нужно выполнить для достижения плановых подключений</div
              >
              <div class="gauge-target">
                <div class="target-value">190.24</div>
                <div class="target-label">Цель для достижения плана</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
  import * as echarts from 'echarts'

  interface TableRow {
    date: string
    plan: number
    fact: number
    percent: number
  }

  interface DatePreset {
    name: string
    label: string
    getRange: () => [Date, Date]
  }

  // Mock data based on photo
  const allTableData = ref<TableRow[]>([
    { date: '1 января 2025 г.', plan: 51.29, fact: 22, percent: 42.89 },
    { date: '2 января 2025 г.', plan: 51.29, fact: 24, percent: 46.79 },
    { date: '3 января 2025 г.', plan: 51.29, fact: 116, percent: 226.16 },
    { date: '4 января 2025 г.', plan: 51.29, fact: 66, percent: 128.68 },
    { date: '5 января 2025 г.', plan: 51.29, fact: 48, percent: 93.58 },
    { date: '6 января 2025 г.', plan: 51.29, fact: 50, percent: 97.48 },
    { date: '7 января 2025 г.', plan: 51.29, fact: 45, percent: 87.74 },
    { date: '8 января 2025 г.', plan: 51.29, fact: 46, percent: 89.69 },
    { date: '9 января 2025 г.', plan: 51.29, fact: 47, percent: 91.64 },
    { date: '10 января 2025 г.', plan: 51.29, fact: 59, percent: 115.03 },
    { date: '11 января 2025 г.', plan: 51.29, fact: 62, percent: 120.88 },
    { date: '12 января 2025 г.', plan: 51.29, fact: 67, percent: 130.63 },
    { date: '13 января 2025 г.', plan: 51.29, fact: 35, percent: 68.26 },
    { date: '14 января 2025 г.', plan: 51.29, fact: 33, percent: 64.34 },
    { date: '15 января 2025 г.', plan: 51.29, fact: 36, percent: 70.19 },
    { date: '16 января 2025 г.', plan: 51.29, fact: 32, percent: 62.4 },
    { date: '17 января 2025 г.', plan: 51.29, fact: 30, percent: 58.49 },
    { date: '18 января 2025 г.', plan: 51.29, fact: 23, percent: 44.84 },
    { date: '19 января 2025 г.', plan: 51.29, fact: 22, percent: 42.89 },
    { date: '20 января 2025 г.', plan: 51.29, fact: 24, percent: 46.79 }
  ])

  // Filter state
  const dateRange = ref<[Date, Date] | null>(null)
  const daysRange = ref<[number, number]>([1, 31])
  const defaultDateRange: [Date, Date] = [new Date(2025, 0, 1), new Date(2025, 0, 31)]

  const datePresets: DatePreset[] = [
    {
      name: 'month',
      label: 'Месяц',
      getRange: () => [new Date(2025, 0, 1), new Date(2025, 0, 31)]
    },
    {
      name: 'first',
      label: '1-15',
      getRange: () => [new Date(2025, 0, 1), new Date(2025, 0, 15)]
    },
    {
      name: 'second',
      label: '16-31',
      getRange: () => [new Date(2025, 0, 16), new Date(2025, 0, 31)]
    },
    {
      name: 'week',
      label: 'Неделя',
      getRange: () => {
        const end = new Date(2025, 0, 31)
        const start = new Date(end)
        start.setDate(start.getDate() - 6)
        return [start, end]
      }
    }
  ]

  // Filtered table data
  const tableData = computed(() => {
    let filtered = [...allTableData.value]

    // Filter by days range
    if (daysRange.value[0] && daysRange.value[1]) {
      filtered = filtered.filter((row) => {
        const dayMatch = row.date.match(/(\d+)\s+января/)
        if (dayMatch) {
          const day = parseInt(dayMatch[1])
          return day >= daysRange.value[0] && day <= daysRange.value[1]
        }
        return true
      })
    }

    return filtered
  })

  // Calculate totals from filtered data
  const totals = computed(() => {
    const filtered = tableData.value
    const plan = filtered.reduce((sum, row) => sum + row.plan, 0)
    const fact = filtered.reduce((sum, row) => sum + row.fact, 0)
    return { plan, fact }
  })

  const overallPercent = computed(() => {
    if (!totals.value.plan) return 0
    return Math.round((totals.value.fact / totals.value.plan) * 100)
  })

  const cancelled = computed(() => 4522)
  const inProgress = computed(() => 534)
  const remainingForPlan = computed(() => totals.value.plan - totals.value.fact)

  // Animated values
  const animatedMonthDays = ref(0)
  const animatedDaysPassed = ref(0)
  const animatedDaysLeft = ref(0)
  const animatedApplications = ref('0')
  const animatedPlan = ref(0)
  const animatedRemaining = ref(0)
  const animatedCancelled = ref(0)
  const animatedFact = ref(0)
  const animatedInProgress = ref(0)

  // Animation function
  function animateValue(
    start: number,
    end: number,
    duration: number,
    callback: (value: number) => void
  ) {
    const startTime = performance.now()
    const difference = end - start

    function step(currentTime: number) {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Easing function (ease-out)
      const easeOut = 1 - Math.pow(1 - progress, 3)
      const current = start + difference * easeOut

      callback(Math.round(current))

      if (progress < 1) {
        requestAnimationFrame(step)
      }
    }

    requestAnimationFrame(step)
  }

  // Animate special text value
  function animateTextValue(
    start: string,
    end: string,
    duration: number,
    callback: (value: string) => void
  ) {
    const startTime = performance.now()
    const numStart = parseInt(start) || 0
    const numEnd = parseInt(end.replace(/\s/g, '')) || 0
    const hasText = end.includes('ТЫС.')

    function step(currentTime: number) {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      const easeOut = 1 - Math.pow(1 - progress, 3)
      const current = numStart + (numEnd - numStart) * easeOut

      if (hasText) {
        callback(`${Math.round(current)} ТЫС.`)
      } else {
        callback(Math.round(current).toString())
      }

      if (progress < 1) {
        requestAnimationFrame(step)
      }
    }

    requestAnimationFrame(step)
  }

  const handleResize = () => {
    if (gaugeChart) {
      gaugeChart.resize()
    }
  }

  // Start animations on mount
  onMounted(() => {
    if (!dateRange.value) {
      dateRange.value = [...defaultDateRange]
    }
    renderGauge(0) // Initialize gauge at 0
    window.addEventListener('resize', handleResize)

    // Delay to ensure page is rendered
    setTimeout(() => {
      // Days
      animateValue(0, 30, 1500, (val) => {
        animatedMonthDays.value = val
      })
      animateValue(0, 1, 1500, (val) => {
        animatedDaysPassed.value = val
      })
      animateValue(0, 29, 1500, (val) => {
        animatedDaysLeft.value = val
      })

      // Applications
      animateTextValue('0', '13 ТЫС.', 2000, (val) => {
        animatedApplications.value = val
      })

      // Numbers
      animateValue(0, totals.value.plan, 2000, (val) => {
        animatedPlan.value = val
      })
      animateValue(0, remainingForPlan.value, 2000, (val) => {
        animatedRemaining.value = val
      })
      animateValue(0, cancelled.value, 2000, (val) => {
        animatedCancelled.value = val
      })
      animateValue(0, totals.value.fact, 2000, (val) => {
        animatedFact.value = val
      })
      animateValue(0, inProgress.value, 2000, (val) => {
        animatedInProgress.value = val
      })

      // Gauge animation
      animateGauge()
    }, 300)
  })

  // Formatting
  function formatNumber(num: number, decimals: number = 0): string {
    if (decimals > 0) {
      return num.toFixed(decimals).replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
    }
    return Math.round(num)
      .toString()
      .replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  }

  function getPercentClass(percent: number): string {
    if (percent >= 100) return 'high'
    if (percent >= 80) return 'medium'
    return 'low'
  }

  function getArrowIcon(percent: number): string {
    if (percent >= 100) return 'up'
    if (percent >= 80) return 'neutral'
    return 'down'
  }

  function getRowClassName({ rowIndex }: { rowIndex: number }): string {
    return rowIndex % 2 === 0 ? 'row-even' : 'row-odd'
  }

  // Gauge Chart
  const gaugeRef = ref<HTMLDivElement | null>(null)
  let gaugeChart: echarts.ECharts | null = null

  function renderGauge(animatedValue: number = 0) {
    if (!gaugeRef.value) return
    if (!gaugeChart) {
      gaugeChart = echarts.init(gaugeRef.value)
    }

    const maxValue = 13880
    const currentValue = animatedValue || totals.value.fact

    const option = {
      animation: true,
      animationDuration: 2000,
      series: [
        {
          type: 'gauge',
          startAngle: 180,
          endAngle: 0,
          min: 0,
          max: maxValue,
          splitNumber: 5,
          radius: '95%',
          center: ['50%', '70%'],
          pointer: {
            show: false
          },
          progress: {
            show: true,
            overlap: false,
            roundCap: true,
            clip: false,
            itemStyle: {
              color: '#16a34a'
            },
            width: 24
          },
          axisLine: {
            lineStyle: {
              width: 24,
              color: [[1, '#e5e7eb']]
            }
          },
          axisTick: {
            show: false
          },
          splitLine: {
            show: false
          },
          axisLabel: {
            show: false
          },
          detail: {
            valueAnimation: true,
            formatter: (value: number) => formatNumber(value),
            fontSize: 42,
            fontWeight: 'bold',
            color: '#1e40af',
            offsetCenter: [0, '0%']
          },
          data: [
            {
              value: currentValue
            }
          ]
        }
      ]
    }

    gaugeChart.setOption(option)
  }

  // Animate gauge from 0
  function animateGauge() {
    const duration = 2000
    const startTime = performance.now()
    const endValue = totals.value.fact

    function step(currentTime: number) {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      const easeOut = 1 - Math.pow(1 - progress, 3)
      const current = 0 + (endValue - 0) * easeOut

      renderGauge(Math.round(current))

      if (progress < 1) {
        requestAnimationFrame(step)
      }
    }

    requestAnimationFrame(step)
  }

  // Filter functions
  function validateDaysRange() {
    if (daysRange.value[0] > daysRange.value[1]) {
      const temp = daysRange.value[0]
      daysRange.value[0] = daysRange.value[1]
      daysRange.value[1] = temp
    }
  }

  function onFilterChange() {
    // Reactive update happens automatically via computed property
  }

  function resetFilters() {
    dateRange.value = [...defaultDateRange]
    daysRange.value = [1, 31]
  }

  function isPresetActive(preset: DatePreset): boolean {
    const range = dateRange.value || defaultDateRange
    if (!range || range.length !== 2) return false

    const [presetStart, presetEnd] = preset.getRange()
    const [currentStart, currentEnd] = range

    return (
      currentStart.getTime() === presetStart.getTime() &&
      currentEnd.getTime() === presetEnd.getTime()
    )
  }

  function applyPreset(preset: DatePreset) {
    dateRange.value = preset.getRange()
  }

  onBeforeUnmount(() => {
    window.removeEventListener('resize', handleResize)
    if (gaugeChart) {
      gaugeChart.dispose()
      gaugeChart = null
    }
  })
</script>

<style scoped lang="scss">
  .masters-overview {
    box-sizing: border-box;
    width: 100%;
    max-width: 100vw;
    min-height: 100vh;
    padding: 24px;
    margin: 0 auto;
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
  }

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
    margin-bottom: 20px;
  }

  .filter-bar-container {
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

  .filter-presets {
    display: flex;
    gap: 6px;
  }

  .preset-button {
    min-width: 52px;
    height: 32px;
    padding: 5px 10px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    transition: all 0.2s ease;

    &:hover {
      transform: translateY(-1px);
    }
  }

  .filter-actions {
    display: flex;
    gap: 8px;
    margin-left: auto;

    :deep(.el-button) {
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
  }

  .layout-container {
    display: grid;
    grid-template-columns: 1.5fr 1fr;
    gap: 20px;
    max-width: 1600px;
    margin: 0 auto;
  }

  /* Left Panel - Table */
  .left-panel {
    overflow: hidden;
    background: #fff;
    border: 1px solid rgb(30 64 175 / 10%);
    border-radius: 16px;
    box-shadow: 0 4px 20px rgb(0 0 0 / 8%);
  }

  .table-header {
    padding: 24px;
    background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
    border-bottom: 2px solid #f0f4f8;
  }

  .table-title {
    margin: 0;
    font-size: 20px;
    font-weight: 800;
    color: #1e40af;
    letter-spacing: 0.3px;
  }

  .table-wrapper {
    padding: 0;
    overflow-x: auto;
  }

  .main-table {
    width: 100%;

    :deep(.el-table__header-wrapper) {
      .el-table__header {
        th {
          padding: 16px 8px;
          font-size: 13px;
          font-weight: 700;
          color: white;
          text-align: center;
          background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);
          border-color: #cbd5e1;
        }
      }
    }

    :deep(.el-table__body-wrapper) {
      .el-table__body {
        .row-even {
          background-color: #f0f9ff;

          td {
            background-color: #f0f9ff;
          }
        }

        .row-odd {
          background-color: #fff;

          td {
            background-color: #fff;
          }
        }

        td {
          padding: 16px 8px;
          font-size: 13px;
          border-color: #e5e7eb;
        }
      }

      :deep(.el-table__row:hover > td) {
        background-color: #f3f4f6;
      }
    }
  }

  .date-cell {
    font-weight: 500;
    color: #1f2937;
  }

  .plan-cell {
    font-weight: 600;
    color: #1f2937;
  }

  .fact-cell {
    font-weight: 600;
    color: #1f2937;
  }

  .percent-cell {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    padding: 4px 10px;
    font-size: 12px;
    font-weight: 700;
    border-radius: 4px;

    &.high {
      color: #15803d;
      background: rgb(34 197 94 / 15%);
    }

    &.medium {
      color: #a16207;
      background: rgb(234 179 8 / 15%);
    }

    &.low {
      color: #b91c1c;
      background: rgb(239 68 68 / 15%);
    }

    .arrow-icon {
      font-size: 10px;

      &.up::after {
        content: '▲';
      }

      &.neutral::after {
        content: '▶';
      }

      &.down::after {
        content: '▼';
      }
    }
  }

  .table-summary {
    display: grid;
    grid-template-columns: auto repeat(3, 1fr);
    gap: 12px;
    align-items: center;
    padding: 20px 24px;
    background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
    border-top: 2px solid #f0f4f8;
  }

  .summary-label {
    font-size: 14px;
    font-weight: 800;
    color: #1f2937;
  }

  .summary-value {
    font-size: 14px;
    font-weight: 700;
    color: #1f2937;
    text-align: center;
  }

  .summary-percent {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    justify-content: center;
    padding: 4px 10px;
    margin: 0 auto;
    font-size: 13px;
    font-weight: 700;
    border-radius: 4px;

    &.high {
      color: #15803d;
      background: rgb(34 197 94 / 15%);
    }

    &.medium {
      color: #a16207;
      background: rgb(234 179 8 / 15%);
    }

    &.low {
      color: #b91c1c;
      background: rgb(239 68 68 / 15%);
    }

    .arrow-icon {
      font-size: 10px;

      &.up::after {
        content: '▲';
      }

      &.neutral::after {
        content: '▶';
      }

      &.down::after {
        content: '▼';
      }
    }
  }

  /* Right Panel - KPIs and Gauge */
  .right-panel {
    display: flex;
    flex-direction: column;
  }

  .right-panel-content {
    display: flex;
    flex-direction: column;
    gap: 16px;
    padding: 20px;
    background: #fff;
    border: 1px solid rgb(30 64 175 / 10%);
    border-radius: 16px;
    box-shadow: 0 4px 20px rgb(0 0 0 / 8%);
  }

  .kpi-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;

    &.top {
      margin-bottom: 0;
    }
  }

  .kpi-section {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }

  .kpi-card {
    padding: 16px 20px;
    text-align: center;
    background: transparent;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgb(0 0 0 / 8%);
    transition: all 0.3s ease;

    &:hover {
      box-shadow: 0 4px 12px rgb(0 0 0 / 12%);
      transform: translateY(-2px);
    }

    &.big {
      grid-column: 1 / -1;
    }

    &.wide {
      grid-column: span 2;
    }

    .kpi-value {
      margin-bottom: 8px;
      font-size: 32px;
      font-weight: 700;
      line-height: 1;
    }

    .kpi-label {
      font-size: 14px;
      font-weight: 600;
      line-height: 1.3;
      color: #6b7280;
    }

    &.blue {
      color: #1e40af;
      background: linear-gradient(135deg, #dbeafe, #f0f9ff);

      .kpi-value {
        color: #1e40af;
      }
    }

    &.green {
      color: #15803d;
      background: linear-gradient(135deg, #dcfce7, #f0fdf4);

      .kpi-value {
        color: #15803d;
      }
    }

    &.red {
      color: #991b1b;
      background: linear-gradient(135deg, #fee2e2, #fef2f2);

      .kpi-value {
        color: #991b1b;
      }
    }

    &.orange {
      color: #b45309;
      background: linear-gradient(135deg, #fed7aa, #fffbeb);

      .kpi-value {
        color: #b45309;
      }
    }
  }

  /* Gauge Chart */
  .gauge-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20px 0;
    background: transparent;
    border: none;
    border-radius: 8px;
  }

  .gauge-chart {
    width: 100%;
    height: 320px;
    margin-bottom: 16px;
  }

  .gauge-info {
    width: 100%;
    text-align: center;
  }

  .gauge-text {
    margin-bottom: 12px;
    font-size: 12px;
    font-weight: 600;
    line-height: 1.4;
    color: #6b7280;
  }

  .gauge-target {
    .target-value {
      margin-bottom: 4px;
      font-size: 28px;
      font-weight: 800;
      color: #16a34a;
    }

    .target-label {
      font-size: 14px;
      font-weight: 600;
      color: #6b7280;
    }
  }

  /* Responsive */
  @media (width <= 1400px) {
    .layout-container {
      grid-template-columns: 1.4fr 1fr;
      gap: 16px;
    }
  }

  @media (width <= 1200px) {
    .layout-container {
      grid-template-columns: 1fr;
      gap: 16px;
    }

    .right-panel {
      order: 2;
    }

    .left-panel {
      order: 1;
    }
  }

  @media (width <= 992px) {
    .masters-overview {
      padding: 16px;
    }

    .kpi-row,
    .kpi-section {
      grid-template-columns: repeat(2, 1fr);
    }

    .kpi-card.big {
      grid-column: 1 / -1;
    }

    .kpi-card.wide {
      grid-column: 1 / -1;
    }

    .gauge-chart {
      height: 280px;
    }
  }

  @media (width <= 768px) {
    .masters-overview {
      padding: 12px;
    }

    .kpi-row,
    .kpi-section {
      grid-template-columns: 1fr;
    }

    .kpi-card.wide {
      grid-column: 1 / -1;
    }

    .table-wrapper {
      overflow-x: auto;
    }

    .main-table {
      min-width: 600px;
    }

    .gauge-chart {
      height: 240px;
    }
  }

  @media (width <= 480px) {
    .table-title {
      font-size: 16px;
    }

    .kpi-card .kpi-value {
      font-size: 24px;
    }

    .gauge-chart {
      height: 200px;
    }

    .target-value {
      font-size: 24px;
    }
  }
</style>
