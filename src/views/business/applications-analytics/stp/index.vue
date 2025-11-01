<template>
  <div class="stp-analytics-page">
    <div class="page-title-section">
      <h1 class="page-title">АНАЛИТИКА ПРИНЯТЫХ ЗАЯВОК ПО МАСТЕРАМ</h1>
    </div>

    <div class="kpi-section">
      <div class="kpi-block kpi-blue">
        <div class="kpi-value">{{ totals.total }}</div>
        <div class="kpi-label">Заявки на подключение</div>
      </div>
      <div class="kpi-block kpi-green">
        <div class="kpi-value">{{ totals.done }}</div>
        <div class="kpi-label">Выполнено</div>
      </div>
      <div class="kpi-block kpi-orange">
        <div class="kpi-value">{{ totals.in_progress }}</div>
        <div class="kpi-label">В процессе</div>
      </div>
      <div class="kpi-block kpi-red">
        <div class="kpi-value">{{ totals.cancelled }}</div>
        <div class="kpi-label">Отменено</div>
      </div>
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

    <div class="content-section">
      <div class="table-wrapper">
        <div class="table-header">
          <h3 class="table-title">Данные по мастерам</h3>
          <div class="table-actions">
            <el-button size="small" @click="exportTableData">Экспорт</el-button>
          </div>
        </div>
        <div class="table-container">
          <HorizontalScrollButtons>
            <el-table
              :data="filteredRows"
              stripe
              border
              class="stp-table"
              :default-sort="{ prop: 'fio', order: 'ascending' }"
              style="width: 100%"
            >
              <el-table-column prop="fio" label="ФИО создателя" min-width="200" align="left" />
              <el-table-column
                prop="total"
                label="Заявки на подключение"
                min-width="150"
                align="center"
              />
              <el-table-column prop="cancelled" label="Отменено" min-width="100" align="center">
                <template #default="{ row }">
                  <div class="cell-value">{{ row.cancelled }}</div>
                </template>
              </el-table-column>
              <el-table-column prop="done" label="Выполнено" min-width="100" align="center">
                <template #default="{ row }">
                  <div class="cell-value">{{ row.done }}</div>
                </template>
              </el-table-column>
              <el-table-column prop="in_progress" label="В процессе" min-width="110" align="center">
                <template #default="{ row }">
                  <div class="cell-value">{{ row.in_progress }}</div>
                </template>
              </el-table-column>
            </el-table>
          </HorizontalScrollButtons>
        </div>
      </div>

      <div class="chart-wrapper">
        <div class="chart-header">
          <h3 class="chart-title">Удельный вес в %</h3>
        </div>
        <div class="chart-container">
          <div class="chart-legend">
            <div class="legend-item">
              <span class="dot done"></span>
              <span class="legend-text">Выполнено {{ totals.done }} ({{ percentTotalDone }}%)</span>
            </div>
            <div class="legend-item">
              <span class="dot cancelled"></span>
              <span class="legend-text"
                >Отменено {{ totals.cancelled }} ({{ percentTotalCancelled }}%)</span
              >
            </div>
            <div class="legend-item">
              <span class="dot inprog"></span>
              <span class="legend-text"
                >В процессе {{ totals.in_progress }} ({{ percentTotalInProgress }}%)</span
              >
            </div>
          </div>
          <div ref="chartRef" class="pie-chart" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, watch, nextTick } from 'vue'
  import * as echarts from 'echarts'
  import { mockCenterRows } from '@/mock/center-service'
  import HorizontalScrollButtons from '../../../../components/custom/HorizontalScrollButtons.vue'

  interface Row {
    fio: string
    dept: string
    total: number
    cancelled: number
    in_progress: number
    done: number
  }

  interface DatePreset {
    name: string
    label: string
    getRange: () => [Date, Date]
  }

  const rows = ref<Row[]>(mockCenterRows)
  const dateRange = ref<[Date, Date] | null>(null)
  const daysRange = ref<[number, number]>([1, 31])

  const defaultDateRange: [Date, Date] = [new Date(2025, 7, 1), new Date(2025, 7, 31)]

  const datePresets: DatePreset[] = [
    {
      name: 'month',
      label: 'Месяц',
      getRange: () => [new Date(2025, 7, 1), new Date(2025, 7, 31)]
    },
    {
      name: 'first',
      label: '1-15',
      getRange: () => [new Date(2025, 7, 1), new Date(2025, 7, 15)]
    },
    {
      name: 'second',
      label: '16-31',
      getRange: () => [new Date(2025, 7, 16), new Date(2025, 7, 31)]
    },
    {
      name: 'week',
      label: 'Неделя',
      getRange: () => {
        const end = new Date(2025, 7, 31)
        const start = new Date(end)
        start.setDate(start.getDate() - 6)
        return [start, end]
      }
    }
  ]

  const filteredRows = computed(() => {
    return rows.value.filter((row) => {
      if (!row) return false
      return true
    })
  })

  const totals = computed(() => {
    const filtered = filteredRows.value
    const total = filtered.reduce((s, r) => s + r.total, 0)
    const cancelled = filtered.reduce((s, r) => s + r.cancelled, 0)
    const done = filtered.reduce((s, r) => s + r.done, 0)
    const in_progress = filtered.reduce((s, r) => s + r.in_progress, 0)
    return { total, cancelled, done, in_progress }
  })

  const percentTotalDone = computed(() =>
    Math.round((totals.value.done / Math.max(1, totals.value.total)) * 100)
  )
  const percentTotalCancelled = computed(() =>
    Math.round((totals.value.cancelled / Math.max(1, totals.value.total)) * 100)
  )
  const percentTotalInProgress = computed(() =>
    Math.round((totals.value.in_progress / Math.max(1, totals.value.total)) * 100)
  )

  const chartRef = ref<HTMLDivElement | null>(null)
  let chart: echarts.ECharts | null = null

  function renderChart() {
    if (!chartRef.value) return

    chart = echarts.init(chartRef.value as HTMLDivElement)

    const option = {
      tooltip: { trigger: 'item', formatter: '{b} {c} ({d}%)' },
      series: [
        {
          name: 'Статус',
          type: 'pie',
          radius: ['35%', '65%'],
          avoidLabelOverlap: false,
          label: { show: true, formatter: '{b}\n{d}%', position: 'outside' },
          emphasis: { label: { show: true, fontSize: '14', fontWeight: 'bold' } },
          labelLine: { length: 15, length2: 8 },
          data: [
            {
              value: totals.value.done,
              name: `Выполнено ${totals.value.done}`,
              itemStyle: { color: '#16a34a' }
            },
            {
              value: totals.value.cancelled,
              name: `Отменено ${totals.value.cancelled}`,
              itemStyle: { color: '#dc2626' }
            },
            {
              value: totals.value.in_progress,
              name: `В процессе ${totals.value.in_progress}`,
              itemStyle: { color: '#f97316' }
            }
          ]
        }
      ]
    }

    chart.setOption(option)
  }

  function percentRow(row: Row) {
    const total = row.total || 1
    return Math.round((row.done / total) * 100)
  }

  function getPercentageClass(row: Row) {
    const p = percentRow(row)
    if (p >= 80) return 'high'
    if (p >= 50) return 'medium'
    return 'low'
  }

  function getStatusType(row: Row) {
    const p = percentRow(row)
    if (p >= 80) return 'success'
    if (p >= 50) return 'warning'
    return 'danger'
  }

  function getStatusText(row: Row) {
    const p = percentRow(row)
    if (p >= 80) return 'Хорошо'
    if (p >= 50) return 'Нормально'
    return 'Низко'
  }

  function formatDate(date: Date | null | undefined): string {
    if (!date) return ''
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  function validateDaysRange() {
    if (daysRange.value[0] > daysRange.value[1]) {
      const temp = daysRange.value[0]
      daysRange.value[0] = daysRange.value[1]
      daysRange.value[1] = temp
    }
  }

  function exportTableData() {
    console.log('Export table data')
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

  onMounted(() => {
    if (!dateRange.value) {
      dateRange.value = [...defaultDateRange]
    }
    nextTick(() => renderChart())
    window.addEventListener('resize', () => {
      if (chart) chart.resize()
    })
  })

  watch(totals, () => {
    renderChart()
  })
</script>

<style scoped lang="scss">
  .stp-analytics-page {
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    color: var(--text-color, #0f172a);
    padding: 24px;
    width: 100%;
    max-width: 100vw;
    margin: 0 auto;
    background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
    min-height: 100vh;
    box-sizing: border-box;

    .page-title-section {
      text-align: center;
      margin-bottom: 32px;
      
      .page-title {
        font-size: 32px;
        font-weight: 800;
        color: #1e40af;
        margin: 0;
        padding: 0;
        text-shadow: 0 2px 4px rgba(30, 64, 175, 0.1);
        letter-spacing: 0.5px;
      }
    }

    .kpi-section {
      display: flex;
      gap: 16px;
      margin-bottom: 24px;
      justify-content: center;
      align-items: center;
      flex-wrap: wrap;

      .kpi-block {
        padding: 16px 20px;
        border-radius: 8px;
        text-align: center;
        flex: 1;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        transition: all 0.3s ease;

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }
      }
    }

      .kpi-value {
        font-size: 32px;
        font-weight: 700;
        line-height: 1;
        margin-bottom: 8px;
      }

      .kpi-label {
        font-size: 14px;
        font-weight: 600;
        line-height: 1.3;
      }

      .kpi-blue {
        background: linear-gradient(135deg, #dbeafe, #f0f9ff);
        color: #1e40af;
      }

      .kpi-red {
        background: linear-gradient(135deg, #fee2e2, #fef2f2);
        color: #991b1b;
      }

      .kpi-green {
        background: linear-gradient(135deg, #dcfce7, #f0fdf4);
        color: #15803d;
      }

      .kpi-orange {
        background: linear-gradient(135deg, #fed7aa, #fffbeb);
        color: #b45309;
      }

    .filters-section {
      margin-bottom: 20px;
    }

    .filter-bar-container {
      background: white;
      border-radius: 10px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
      border: 1px solid #e5e7eb;
      overflow: hidden;
    }

    .filter-bar {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 14px 18px;
      flex-wrap: wrap;
    }

    .filter-group {
      display: flex;
      align-items: center;
      gap: 8px;
      white-space: nowrap;
    }

    .filter-label {
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
      color: #374151;
      letter-spacing: 0.4px;
      margin: 0;
    }

    .date-picker-input {
      width: 200px;

      :deep(.el-input__inner) {
        font-size: 12px;
        border-color: #d1d5db;
        transition: all 0.2s ease;
        height: 32px;

        &:focus {
          border-color: #1e40af;
          box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.1);
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
      align-items: center;
      gap: 6px;

      :deep(.el-input-number) {
        width: 60px;

        .el-input__inner {
          text-align: center;
          font-size: 12px;
          font-weight: 600;
          height: 32px;
          border-color: #d1d5db;
          transition: all 0.2s ease;

          &:focus {
            border-color: #1e40af;
            box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.1);
          }
        }
      }
    }

    .days-separator {
      color: #d1d5db;
      font-weight: 600;
      font-size: 12px;
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
      font-size: 11px;
      font-weight: 600;
      min-width: 52px;
      padding: 5px 10px;
      height: 32px;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      transition: all 0.2s ease;

      &:hover {
        transform: translateY(-1px);
      }
    }

    .filter-actions {
      margin-left: auto;
      display: flex;
      gap: 8px;

      :deep(.el-button) {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
      }
    }

    .content-section {
      display: grid;
      grid-template-columns: 1fr 1.3fr;
      gap: 20px;
      min-height: 650px;
    }

    .table-wrapper {
      display: flex;
      flex-direction: column;
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      border: 1px solid #e5e7eb;
    }

    .table-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px;
      border-bottom: 2px solid #f0f4f8;
      background: linear-gradient(to right, #f8f9fb, #ffffff);
    }

    .table-title {
      margin: 0;
      font-size: 17px;
      font-weight: 700;
      color: #1e40af;
      letter-spacing: 0.3px;
    }

    .table-actions {
      display: flex;
      gap: 8px;
    }

    .table-container {
      flex: 1;
      overflow-x: auto;
      min-height: 400px;
      width: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 0 20px;
    }

    .stp-table {
      width: auto;
      min-width: 100%;
      margin: 0 auto;
      table-layout: fixed;
      display: table;

      :deep(.el-table) {
        width: 100%;
        margin: 0 auto;
        display: table;
        table-layout: fixed;
      }

      :deep(.el-table__header-wrapper) {
        width: 100%;
        display: table-header-group;
      }

      :deep(.el-table__body-wrapper) {
        width: 100%;
        display: table-row-group;
      }

      :deep(.el-table__header th) {
        background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);
        color: white;
        font-weight: 700;
        font-size: 12px;
        padding: 12px 0;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        text-align: center;
        white-space: nowrap;
      }

      :deep(.el-table__body td) {
        padding: 12px 0;
        font-size: 12px;
        text-align: center;
        white-space: nowrap;
      }

      :deep(.el-table__row:hover > td) {
        background-color: #f3f4f6;
      }
    }

    .cell-value {
      font-weight: 600;
      color: #1f2937;
    }

    .percentage-badge {
      padding: 6px 12px;
      border-radius: 6px;
      font-weight: 600;
      font-size: 11px;

      &.high {
        background-color: rgba(22, 163, 74, 0.12);
        color: #15803d;
      }

      &.medium {
        background-color: rgba(249, 115, 22, 0.12);
        color: #92400e;
      }

      &.low {
        background-color: rgba(220, 38, 38, 0.12);
        color: #991b1b;
      }
    }

    .chart-wrapper {
      display: flex;
      flex-direction: column;
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      border: 1px solid #e5e7eb;
    }

    .chart-header {
      padding: 20px;
      border-bottom: 2px solid #f0f4f8;
      background: linear-gradient(to right, #f8f9fb, #ffffff);
    }

    .chart-title {
      margin: 0;
      font-size: 17px;
      font-weight: 700;
      color: #1e40af;
      letter-spacing: 0.3px;
    }

    .chart-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      padding: 24px 20px;
      min-height: 480px;
      width: 100%;
      justify-content: center;
      align-items: center;
    }

    .chart-legend {
      display: flex;
      flex-direction: column;
      gap: 14px;
      margin-bottom: 24px;
      padding: 16px;
      background: #f0f9ff;
      border-radius: 8px;
      border-left: 4px solid #1e40af;
      width: 100%;
      max-width: 400px;
    }

    .legend-item {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 13px;
      font-weight: 600;
      line-height: 1.4;
    }

    .dot {
      width: 14px;
      height: 14px;
      border-radius: 50%;
      flex-shrink: 0;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .dot.done {
      background: #16a34a;
    }

    .dot.cancelled {
      background: #dc2626;
    }

    .dot.inprog {
      background: #f97316;
    }

    .legend-text {
      color: #1f2937;
      font-weight: 600;
    }

    .pie-chart {
      flex: 1;
      min-height: 380px;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      max-width: 500px;
    }

    @media (max-width: 1400px) {
      .stp-analytics-page {
        padding: 20px;
        width: 100%;
        max-width: 100vw;
      }

      .content-section {
        grid-template-columns: 1fr;
        min-height: auto;
      }
    }

    @media (max-width: 1200px) {
      .stp-analytics-page {
        padding: 16px;
        width: 100%;
        max-width: 100vw;

        .kpi-section {
          gap: 12px;

          .kpi-block {
            padding: 12px 16px;
            flex: 1;
          }

          .kpi-value {
            font-size: 28px;
          }

          .kpi-label {
            font-size: 13px;
          }
        }

        .filter-bar {
          gap: 12px;
          padding: 12px 16px;
        }

        .content-section {
          gap: 16px;
        }
      }
    }

    @media (max-width: 992px) {
      .stp-analytics-page {
        padding: 14px;
        width: 100%;
        max-width: 100vw;

        .page-title-section .page-title {
          font-size: 26px;
        }

        .kpi-section {
          gap: 10px;

          .kpi-block {
            padding: 14px 12px;
            flex: 1;
          }

          .kpi-value {
            font-size: 26px;
          }

          .kpi-label {
            font-size: 12px;
          }
        }

        .filter-bar {
          flex-direction: column;
          gap: 12px;
          padding: 16px;

          .filter-group {
            justify-content: center;
          }

          .filter-presets {
            justify-content: center;
            flex-wrap: wrap;
          }

          .filter-actions {
            margin-left: 0;
            justify-content: center;
          }
        }

        .table-header,
        .chart-header {
          padding: 16px;
        }

        .table-title,
        .chart-title {
          font-size: 15px;
        }

        .table-container {
          padding: 0 16px;
          display: flex;
          justify-content: center;
          align-items: center;

          .stp-table {
            min-width: 600px;
            width: auto;
            margin: 0 auto;
            display: table;
            table-layout: fixed;

            :deep(.el-table) {
              width: 100%;
              margin: 0 auto;
              display: table;
              table-layout: fixed;
            }

            :deep(.el-table__header th) {
              font-size: 11px;
              padding: 10px 0;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 10px 0;
              font-size: 11px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }

        .chart-container {
          padding: 20px 16px;
          min-height: 400px;

          .chart-legend {
            max-width: 350px;
            padding: 14px;
            margin-bottom: 20px;

            .legend-item {
              font-size: 12px;
              gap: 8px;
            }

            .dot {
              width: 12px;
              height: 12px;
            }
          }

          .pie-chart {
            min-height: 320px;
            max-width: 400px;
          }
        }
      }
    }

    @media (max-width: 768px) {
      .stp-analytics-page {
        padding: 12px;
        width: 100%;
        max-width: 100vw;

        .page-title-section .page-title {
          font-size: 22px;
          line-height: 1.2;
        }

        .kpi-section {
          flex-direction: row;
          gap: 8px;
          margin-bottom: 20px;

          .kpi-block {
            padding: 12px 8px;
            flex: 1;
          }

          .kpi-value {
            font-size: 20px;
          }

          .kpi-label {
            font-size: 11px;
            line-height: 1.2;
          }
        }

        .filter-bar {
          flex-direction: column;
          gap: 10px;
          padding: 14px;

          .filter-group {
            justify-content: center;
          }

          .filter-presets {
            justify-content: center;
            flex-wrap: wrap;
            gap: 8px;
          }

          .filter-actions {
            margin-left: 0;
            justify-content: center;
          }
        }

        .content-section {
          gap: 16px;
          min-height: auto;
        }

        .table-wrapper,
        .chart-wrapper {
          min-height: 400px;
        }

        .table-header,
        .chart-header {
          padding: 14px;
          flex-direction: column;
          gap: 10px;
          align-items: stretch;

          .table-title,
          .chart-title {
            font-size: 16px;
            justify-content: center;
          }
        }

        .table-container {
          padding: 0 14px;
          display: flex;
          justify-content: center;
          align-items: center;

          .stp-table {
            min-width: 500px;
            width: auto;
            margin: 0 auto;
            display: table;
            table-layout: fixed;

            :deep(.el-table) {
              width: 100%;
              margin: 0 auto;
              display: table;
              table-layout: fixed;
            }

            :deep(.el-table__header th) {
              font-size: 10px;
              padding: 8px 0;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 8px 0;
              font-size: 10px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }

        .chart-container {
          padding: 16px 14px;
          min-height: 350px;

          .chart-legend {
            max-width: 300px;
            padding: 12px;
            margin-bottom: 16px;

            .legend-item {
              font-size: 11px;
              gap: 6px;
            }

            .dot {
              width: 10px;
              height: 10px;
            }
          }

          .pie-chart {
            min-height: 280px;
            max-width: 350px;
          }
        }
      }
    }

    @media (max-width: 480px) {
      .stp-analytics-page {
        padding: 8px;
        width: 100%;
        max-width: 100vw;

        .page-title-section .page-title {
          font-size: 18px;
          line-height: 1.1;
        }

        .kpi-section {
          flex-direction: column;
          gap: 8px;
          margin-bottom: 16px;

          .kpi-block {
            padding: 12px;
            flex: 1;
          }

          .kpi-value {
            font-size: 18px;
            margin-bottom: 4px;
          }

          .kpi-label {
            font-size: 10px;
            line-height: 1.1;
          }
        }

        .filter-bar {
          padding: 12px;

          .filter-group {
            .filter-label {
              font-size: 10px;
            }
          }

          .preset-button {
            font-size: 10px;
            padding: 4px 8px;
            height: 28px;
            min-width: 45px;
          }

          .filter-actions {
            .el-button {
              font-size: 10px;
              padding: 6px 10px;
            }
          }
        }

        .table-container {
          padding: 0 12px;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 300px;

          .stp-table {
            min-width: 400px;
            width: auto;
            margin: 0 auto;
            display: table;
            table-layout: fixed;

            :deep(.el-table) {
              width: 100%;
              margin: 0 auto;
              display: table;
              table-layout: fixed;
            }

            :deep(.el-table__header th) {
              font-size: 9px;
              padding: 6px 0;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 6px 0;
              font-size: 9px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }

        .chart-container {
          padding: 12px;
          min-height: 300px;

          .chart-legend {
            max-width: 280px;
            padding: 10px;
            margin-bottom: 12px;

            .legend-item {
              font-size: 10px;
              gap: 5px;
            }

            .dot {
              width: 8px;
              height: 8px;
            }
          }

          .pie-chart {
            min-height: 250px;
            max-width: 300px;
          }
        }

        .table-header,
        .chart-header {
          padding: 12px;

          .table-title,
          .chart-title {
            font-size: 14px;
          }
        }

        .stp-table {
          :deep(.el-table__header th) {
            font-size: 9px;
            padding: 8px 2px;
          }

          :deep(.el-table__body td) {
            padding: 8px 2px;
            font-size: 9px;
          }
        }
      }
    }

    @media (max-width: 360px) {
      .stp-analytics-page {
        padding: 6px;
        width: 100%;
        max-width: 100vw;

        .page-title-section .page-title {
          font-size: 16px;
        }

        .kpi-section {
          gap: 6px;

          .kpi-block {
            padding: 10px;
            flex: 1;
          }

          .kpi-value {
            font-size: 16px;
          }

          .kpi-label {
            font-size: 9px;
          }
        }

        .filter-bar {
          padding: 10px;

          .filter-group {
            .filter-label {
              font-size: 9px;
            }
          }

          .preset-button {
            font-size: 9px;
            padding: 3px 6px;
            height: 26px;
            min-width: 40px;
          }

          .filter-actions {
            .el-button {
              font-size: 9px;
              padding: 5px 8px;
            }
          }
        }

        .table-header,
        .chart-header {
          padding: 10px;

          .table-title,
          .chart-title {
            font-size: 13px;
          }
        }

        .stp-table {
          :deep(.el-table__header th) {
            font-size: 8px;
            padding: 6px 1px;
          }

          :deep(.el-table__body td) {
            padding: 6px 1px;
            font-size: 8px;
          }
        }

        .chart-container {
          padding: 10px;

          .chart-legend {
            padding: 8px;
            margin-bottom: 10px;

            .legend-item {
              font-size: 10px;
              gap: 5px;
            }

            .dot {
              width: 8px;
              height: 8px;
            }
          }

          .pie-chart {
            min-height: 200px;
          }
        }
      }
    }
  }
</style>
