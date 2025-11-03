<template>
  <div class="center-analytics-page">
    <div class="page-title-section">
      <h1 class="page-title">АНАЛИТИКА ПРИНЯТЫХ ЗАЯВОК ЦЕНТР ОБСЛУЖИВАНИЕ</h1>
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
          <h3 class="table-title">Данные по сотрудникам</h3>
          <div class="table-actions">
            <el-button size="small" @click="exportTableData">Экспорт</el-button>
          </div>
        </div>
        <div class="table-container">
          <el-table
            :data="filteredRows"
            stripe
            border
            class="center-table"
            :default-sort="{ prop: 'fio', order: 'ascending' }"
            style="width: 100%"
          >
            <el-table-column prop="fio" label="ФИО" min-width="140" align="left" />
            <el-table-column prop="dept" label="Подразделение" min-width="120" align="center" />
            <el-table-column
              prop="total"
              label="Заявки на подключение"
              min-width="120"
              align="center"
            />
            <el-table-column prop="cancelled" label="Отменено" min-width="100" align="center">
              <template #default="{ row }">
                <div class="cell-value">{{ row.cancelled }}</div>
              </template>
            </el-table-column>
            <el-table-column prop="in_progress" label="В процессе" min-width="110" align="center">
              <template #default="{ row }">
                <div class="cell-value">{{ row.in_progress }}</div>
              </template>
            </el-table-column>
            <el-table-column prop="done" label="Выполнено" min-width="100" align="center">
              <template #default="{ row }">
                <div class="cell-value">{{ row.done }}</div>
              </template>
            </el-table-column>
            <el-table-column label="% выполнения" min-width="100" align="center">
              <template #default="{ row }">
                <div class="percentage-badge" :class="getPercentageClass(row)">
                  {{ percentRow(row) }}%
                </div>
              </template>
            </el-table-column>
            <el-table-column label="Статус" min-width="110" align="center">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row)">{{ getStatusText(row) }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
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
  .center-analytics-page {
    box-sizing: border-box;
    width: 100%;
    max-width: 100vw;
    min-height: 100vh;
    padding: 24px;
    margin: 0 auto;
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    color: var(--text-color, #0f172a);
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

    .kpi-section {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      align-items: center;
      justify-content: center;
      margin-bottom: 24px;

      .kpi-block {
        flex: 1;
        padding: 16px 20px;
        text-align: center;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgb(0 0 0 / 8%);
        transition: all 0.3s ease;

        &:hover {
          box-shadow: 0 4px 12px rgb(0 0 0 / 12%);
          transform: translateY(-2px);
        }
      }
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
    }

    .kpi-blue {
      color: #1e40af;
      background: linear-gradient(135deg, #dbeafe, #f0f9ff);
    }

    .kpi-red {
      color: #991b1b;
      background: linear-gradient(135deg, #fee2e2, #fef2f2);
    }

    .kpi-green {
      color: #15803d;
      background: linear-gradient(135deg, #dcfce7, #f0fdf4);
    }

    .kpi-orange {
      color: #b45309;
      background: linear-gradient(135deg, #fed7aa, #fffbeb);
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

    .content-section {
      display: grid;
      grid-template-columns: 1fr 1.3fr;
      gap: 20px;
      min-height: 650px;
    }

    .table-wrapper {
      display: flex;
      flex-direction: column;
      overflow: hidden;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgb(0 0 0 / 8%);
    }

    .table-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 20px;
      background: linear-gradient(to right, #f8f9fb, #fff);
      border-bottom: 2px solid #f0f4f8;
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
      display: flex;
      flex: 1;
      align-items: center;
      justify-content: center;
      width: 100%;
      min-height: 400px;
      padding: 0 20px;
      overflow-x: auto;
    }

    .center-table {
      display: table;
      width: auto;
      min-width: 100%;
      margin: 0 auto;
      table-layout: fixed;

      :deep(.el-table) {
        display: table;
        width: 100%;
        margin: 0 auto;
        table-layout: fixed;
      }

      :deep(.el-table__header-wrapper) {
        display: table-header-group;
        width: 100%;
      }

      :deep(.el-table__body-wrapper) {
        display: table-row-group;
        width: 100%;
      }

      :deep(.el-table__header th) {
        padding: 12px 0;
        font-size: 12px;
        font-weight: 700;
        color: white;
        text-align: center;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        white-space: nowrap;
        background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);
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
      font-size: 11px;
      font-weight: 600;
      border-radius: 6px;

      &.high {
        color: #15803d;
        background-color: rgb(22 163 74 / 12%);
      }

      &.medium {
        color: #92400e;
        background-color: rgb(249 115 22 / 12%);
      }

      &.low {
        color: #991b1b;
        background-color: rgb(220 38 38 / 12%);
      }
    }

    .chart-wrapper {
      display: flex;
      flex-direction: column;
      overflow: hidden;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgb(0 0 0 / 8%);
    }

    .chart-header {
      padding: 20px;
      background: linear-gradient(to right, #f8f9fb, #fff);
      border-bottom: 2px solid #f0f4f8;
    }

    .chart-title {
      margin: 0;
      font-size: 17px;
      font-weight: 700;
      color: #1e40af;
      letter-spacing: 0.3px;
    }

    .chart-container {
      display: flex;
      flex: 1;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 100%;
      min-height: 480px;
      padding: 24px 20px;
    }

    .chart-legend {
      display: flex;
      flex-direction: column;
      gap: 14px;
      width: 100%;
      max-width: 400px;
      padding: 16px;
      margin-bottom: 24px;
      background: #f0f9ff;
      border-left: 4px solid #1e40af;
      border-radius: 8px;
    }

    .legend-item {
      display: flex;
      gap: 10px;
      align-items: center;
      font-size: 13px;
      font-weight: 600;
      line-height: 1.4;
    }

    .dot {
      flex-shrink: 0;
      width: 14px;
      height: 14px;
      border-radius: 50%;
      box-shadow: 0 2px 4px rgb(0 0 0 / 10%);
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
      font-weight: 600;
      color: #1f2937;
    }

    .pie-chart {
      display: flex;
      flex: 1;
      align-items: center;
      justify-content: center;
      width: 100%;
      max-width: 500px;
      min-height: 380px;
    }

    @media (width <= 1400px) {
      .center-analytics-page {
        width: 100%;
        max-width: 100vw;
        padding: 20px;
      }
    }

    @media (width <= 1400px) {
      .content-section {
        grid-template-columns: 1fr;
        min-height: auto;
      }
    }

    @media (width <= 1200px) {
      .center-analytics-page {
        width: 100%;
        max-width: 100vw;
        padding: 16px;

        .kpi-section {
          gap: 12px;

          .kpi-block {
            flex: 1;
            padding: 12px 16px;
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

    @media (width <= 992px) {
      .center-analytics-page {
        width: 100%;
        max-width: 100vw;
        padding: 14px;

        .page-title-section .page-title {
          font-size: 26px;
        }

        .kpi-section {
          gap: 10px;

          .kpi-block {
            flex: 1;
            padding: 14px 12px;
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
            flex-wrap: wrap;
            justify-content: center;
          }

          .filter-actions {
            justify-content: center;
            margin-left: 0;
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
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 0 16px;

          .center-table {
            display: table;
            width: auto;
            min-width: 600px;
            margin: 0 auto;
            table-layout: fixed;

            :deep(.el-table) {
              display: table;
              width: 100%;
              margin: 0 auto;
              table-layout: fixed;
            }

            :deep(.el-table__header th) {
              padding: 10px 0;
              font-size: 11px;
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
          min-height: 400px;
          padding: 20px 16px;

          .chart-legend {
            max-width: 350px;
            padding: 14px;
            margin-bottom: 20px;

            .legend-item {
              gap: 8px;
              font-size: 12px;
            }

            .dot {
              width: 12px;
              height: 12px;
            }
          }

          .pie-chart {
            max-width: 400px;
            min-height: 320px;
          }
        }
      }
    }

    @media (width <= 768px) {
      .center-analytics-page {
        width: 100%;
        max-width: 100vw;
        padding: 12px;

        .page-title-section .page-title {
          font-size: 22px;
          line-height: 1.2;
        }

        .kpi-section {
          flex-direction: row;
          gap: 8px;
          margin-bottom: 20px;

          .kpi-block {
            flex: 1;
            padding: 12px 8px;
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
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
          }

          .filter-actions {
            justify-content: center;
            margin-left: 0;
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
          flex-direction: column;
          gap: 10px;
          align-items: stretch;
          padding: 14px;

          .table-title,
          .chart-title {
            justify-content: center;
            font-size: 16px;
          }
        }

        .table-container {
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 0 14px;

          .center-table {
            display: table;
            width: auto;
            min-width: 500px;
            margin: 0 auto;
            table-layout: fixed;

            :deep(.el-table) {
              display: table;
              width: 100%;
              margin: 0 auto;
              table-layout: fixed;
            }

            :deep(.el-table__header th) {
              padding: 8px 0;
              font-size: 10px;
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
          min-height: 350px;
          padding: 16px 14px;

          .chart-legend {
            max-width: 300px;
            padding: 12px;
            margin-bottom: 16px;

            .legend-item {
              gap: 6px;
              font-size: 11px;
            }

            .dot {
              width: 10px;
              height: 10px;
            }
          }

          .pie-chart {
            max-width: 350px;
            min-height: 280px;
          }
        }
      }
    }

    @media (width <= 768px) {
      .center-analytics-page {
        padding: 12px;

        .page-title {
          font-size: 22px;
        }

        .kpi-section {
          flex-direction: row;
          gap: 12px;
          margin-bottom: 16px;
        }

        .kpi-block {
          flex: 1;
          min-width: 0;
          max-width: none;
          padding: 12px 16px;
        }

        .kpi-value {
          font-size: 24px;
        }

        .kpi-label {
          font-size: 12px;
        }

        .filters-section {
          grid-template-columns: 1fr;
          gap: 16px;
          margin-bottom: 16px;
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
          padding: 16px;
        }

        .table-title,
        .chart-title {
          font-size: 15px;
        }

        .center-table {
          :deep(.el-table__header th) {
            padding: 8px 0;
            font-size: 11px;
          }

          :deep(.el-table__body td) {
            padding: 8px 0;
            font-size: 11px;
          }
        }
      }

      @media (width <= 480px) {
        .center-analytics-page {
          width: 100%;
          max-width: 100vw;
          padding: 8px;

          .page-title-section .page-title {
            font-size: 18px;
            line-height: 1.1;
          }

          .kpi-section {
            flex-direction: column;
            gap: 8px;
            margin-bottom: 16px;

            .kpi-block {
              flex: 1;
              padding: 12px;
            }

            .kpi-value {
              margin-bottom: 4px;
              font-size: 18px;
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
              min-width: 45px;
              height: 28px;
              padding: 4px 8px;
              font-size: 10px;
            }

            .filter-actions {
              .el-button {
                padding: 6px 10px;
                font-size: 10px;
              }
            }
          }

          .table-container {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 300px;
            padding: 0 12px;

            .center-table {
              display: table;
              width: auto;
              min-width: 400px;
              margin: 0 auto;
              table-layout: fixed;

              :deep(.el-table) {
                display: table;
                width: 100%;
                margin: 0 auto;
                table-layout: fixed;
              }

              :deep(.el-table__header th) {
                padding: 6px 0;
                font-size: 9px;
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
            min-height: 300px;
            padding: 12px;

            .chart-legend {
              max-width: 280px;
              padding: 10px;
              margin-bottom: 12px;

              .legend-item {
                gap: 5px;
                font-size: 10px;
              }

              .dot {
                width: 8px;
                height: 8px;
              }
            }

            .pie-chart {
              max-width: 300px;
              min-height: 250px;
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

          .center-table {
            :deep(.el-table__header th) {
              padding: 8px 2px;
              font-size: 9px;
            }

            :deep(.el-table__body td) {
              padding: 8px 2px;
              font-size: 9px;
            }
          }
        }
      }

      @media (width <= 360px) {
        .center-analytics-page {
          width: 100%;
          max-width: 100vw;
          padding: 6px;

          .page-title-section .page-title {
            font-size: 16px;
          }

          .kpi-section {
            gap: 6px;

            .kpi-block {
              flex: 1;
              padding: 10px;
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
              min-width: 40px;
              height: 26px;
              padding: 3px 6px;
              font-size: 9px;
            }

            .filter-actions {
              .el-button {
                padding: 5px 8px;
                font-size: 9px;
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

          .center-table {
            :deep(.el-table__header th) {
              padding: 6px 1px;
              font-size: 8px;
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
                gap: 5px;
                font-size: 10px;
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
  }
</style>
