<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title">ПЛАН/ФАКТ ПО ПРИЁМУ ЗАЯВОК НА ПОДКЛЮЧЕНИЕ</h1>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-section">
      <div class="kpi-block kpi-blue">
        <div class="kpi-value">{{ filteredTotalCount }}</div>
        <div class="kpi-label">Всего заявок</div>
      </div>
      <div class="kpi-block kpi-green">
        <div class="kpi-value">{{ filteredDoneCount }}</div>
        <div class="kpi-label">Выполнено</div>
      </div>
      <div class="kpi-block kpi-orange">
        <div class="kpi-value">{{ filteredInProgressCount }}</div>
        <div class="kpi-label">В работе</div>
      </div>
      <div class="kpi-block kpi-red">
        <div class="kpi-value">{{ filteredOverdueCount }}</div>
        <div class="kpi-label">Просрочено</div>
      </div>
    </div>

    <!-- Enhanced Filter Section -->
    <div class="filter-section">
      <div class="filter-container">
        <div class="filter-header">
          <h3 class="filter-title">
            <i class="el-icon-filter"></i>
            Фильтры и поиск
          </h3>
          <el-button 
            @click="showFilter = !showFilter" 
            :type="showFilter ? 'primary' : 'default'"
            size="small"
            class="filter-toggle"
          >
            <i :class="showFilter ? 'el-icon-arrow-up' : 'el-icon-arrow-down'"></i>
            {{ showFilter ? 'Скрыть' : 'Показать' }}
          </el-button>
        </div>
        
        <transition name="filter-slide">
          <div v-show="showFilter" class="filter-content">
            <div class="filter-grid">
              <div class="filter-group">
                <label class="filter-label">Период</label>
                <el-date-picker
                  v-model="dateRange"
                  type="daterange"
                  range-separator="—"
                  start-placeholder="Дата от"
                  end-placeholder="Дата до"
                  value-format="yyyy-MM-dd"
                  class="filter-input"
                  @change="applyFilters"
                />
              </div>

              <div class="filter-group">
                <label class="filter-label">Статус</label>
                <el-select
                  v-model="status"
                  placeholder="Выберите статус"
                  class="filter-input"
                  clearable
                  @change="applyFilters"
                >
                  <el-option label="Все статусы" value="all" />
                  <el-option label="Выполнено" value="done" />
                  <el-option label="В работе" value="in_progress" />
                  <el-option label="Просрочено" value="overdue" />
                </el-select>
              </div>

              <div class="filter-group">
                <label class="filter-label">Поиск</label>
                <el-input
                  v-model="search"
                  placeholder="Поиск по данным..."
                  clearable
                  class="filter-input"
                  @input="applyFilters"
                >
                  <template #prefix>
                    <i class="el-icon-search"></i>
                  </template>
                </el-input>
              </div>

              <div class="filter-actions">
                <el-button @click="resetFilters" size="small" type="info" plain>
                  <i class="el-icon-refresh"></i>
                  Сбросить
                </el-button>
                <el-button @click="exportData" size="small" type="success" plain>
                  <i class="el-icon-download"></i>
                  Экспорт
                </el-button>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </div>

    <!-- Main Content -->
    <div class="content-container">
      <div class="table-wrapper">
        <div class="table-header">
          <h3 class="table-title">
            <i class="el-icon-s-data"></i>
            План/Факт по приёму заявок
          </h3>
          <div class="table-info">
            <span class="table-count">Показано: {{ filteredData.length }} записей</span>
          </div>
        </div>

        <div class="table-container">
          <el-table 
            :data="sortedData" 
            stripe 
            border 
            class="modern-table" 
            style="width: 100%"
            :default-sort="{ prop: 'date', order: 'descending' }"
          >
            <el-table-column prop="date" label="Дата" min-width="80" align="center" sortable />
            <el-table-column prop="days_nd" label="Дни нд" min-width="70" align="center" sortable />
            
            <el-table-column prop="kc_plan" label="КЦ План" min-width="80" align="center" sortable />
            <el-table-column prop="kc_done" label="КЦ Выполнено" min-width="100" align="center" sortable>
              <template #default="{ row }">
                <div class="cell-combo">
                  <div class="value">{{ row.kc_done }}</div>
                  <div :class="['delta', deltaClass(row.kc_plan, row.kc_done)]">
                    <i :class="['arrow', arrowIcon(row.kc_plan, row.kc_done)]" :title="arrowTitle(row.kc_plan, row.kc_done)"></i>
                    <span class="pct">{{ percent(row.kc_plan, row.kc_done) }}%</span>
                  </div>
                </div>
              </template>
            </el-table-column>

            <el-table-column prop="co_plan" label="ЦО План" min-width="80" align="center" sortable />
            <el-table-column prop="co_fact" label="ЦО Факт" min-width="80" align="center" sortable />
            <el-table-column prop="co_done" label="ЦО Выполнено" min-width="100" align="center" sortable>
              <template #default="{ row }">
                <div class="cell-combo">
                  <div class="value">{{ row.co_done }}</div>
                  <div :class="['delta', deltaClass(row.co_plan, row.co_done)]">
                    <i :class="['arrow', arrowIcon(row.co_plan, row.co_done)]" :title="arrowTitle(row.co_plan, row.co_done)"></i>
                    <span class="pct">{{ percent(row.co_plan, row.co_done) }}%</span>
                  </div>
                </div>
              </template>
            </el-table-column>

            <el-table-column prop="stp_plan" label="СТП План" min-width="80" align="center" sortable />
            <el-table-column prop="stp_fact" label="СТП Факт" min-width="80" align="center" sortable />
            <el-table-column prop="stp_done" label="СТП Выполнено" min-width="100" align="center" sortable>
              <template #default="{ row }">
                <div class="cell-combo">
                  <div class="value">{{ row.stp_done }}</div>
                  <div :class="['delta', deltaClass(row.stp_plan, row.stp_done)]">
                    <i :class="['arrow', arrowIcon(row.stp_plan, row.stp_done)]" :title="arrowTitle(row.stp_plan, row.stp_done)"></i>
                    <span class="pct">{{ percent(row.stp_plan, row.stp_done) }}%</span>
                  </div>
                </div>
              </template>
            </el-table-column>

            <el-table-column prop="f2f_plan" label="F2F План" min-width="80" align="center" sortable />
            <el-table-column prop="f2f_fact" label="F2F Факт" min-width="80" align="center" sortable />
            <el-table-column prop="f2f_done" label="F2F Выполнено" min-width="100" align="center" sortable>
              <template #default="{ row }">
                <div class="cell-combo">
                  <div class="value">{{ row.f2f_done }}</div>
                  <div :class="['delta', deltaClass(row.f2f_plan, row.f2f_done)]">
                    <i :class="['arrow', arrowIcon(row.f2f_plan, row.f2f_done)]" :title="arrowTitle(row.f2f_plan, row.f2f_done)"></i>
                    <span class="pct">{{ percent(row.f2f_plan, row.f2f_done) }}%</span>
                  </div>
                </div>
              </template>
            </el-table-column>

            <el-table-column prop="total_plan" label="ИТОГ План" min-width="90" align="center" sortable />
            <el-table-column prop="total_fact" label="ИТОГ Факт" min-width="90" align="center" sortable />
            <el-table-column prop="total_done" label="ИТОГ Выполнено" min-width="110" align="center" sortable>
              <template #default="{ row }">
                <div class="cell-combo">
                  <div class="value">{{ row.total_done }}</div>
                  <div :class="['delta', deltaClass(row.total_plan, row.total_done)]">
                    <i :class="['arrow', arrowIcon(row.total_plan, row.total_done)]" :title="arrowTitle(row.total_plan, row.total_done)"></i>
                    <span class="pct">{{ percent(row.total_plan, row.total_done) }}%</span>
                  </div>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>

      <!-- Summary Section -->
      <div class="summary-section">
        <div class="summary-header">
          <h3 class="summary-title">
            <i class="el-icon-data-analysis"></i>
            Дополнительно
          </h3>
        </div>
        
        <div class="summary-grid">
          <div class="summary-card">
            <div class="summary-card-header">
              <i class="el-icon-calendar"></i>
              <span>Дни нд</span>
            </div>
            <div class="summary-card-value">{{ summaryData[1] }}</div>
          </div>

          <div class="summary-card">
            <div class="summary-card-header">
              <i class="el-icon-office-building"></i>
              <span>КЦ (Клиентский центр)</span>
            </div>
            <div class="summary-card-content">
              <div class="summary-metric">
                <span class="metric-label">План</span>
                <span class="metric-value">{{ summaryData[2] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Выполнено</span>
                <span class="metric-value">{{ summaryData[3] }}</span>
              </div>
            </div>
          </div>

          <div class="summary-card">
            <div class="summary-card-header">
              <i class="el-icon-service"></i>
              <span>ЦО (Центр обслуживания)</span>
            </div>
            <div class="summary-card-content">
              <div class="summary-metric">
                <span class="metric-label">План</span>
                <span class="metric-value">{{ summaryData[4] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Факт</span>
                <span class="metric-value">{{ summaryData[5] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Выполнено</span>
                <span class="metric-value">{{ summaryData[6] }}</span>
              </div>
            </div>
          </div>

          <div class="summary-card">
            <div class="summary-card-header">
              <i class="el-icon-headset"></i>
              <span>СТП (Служба технической поддержки)</span>
            </div>
            <div class="summary-card-content">
              <div class="summary-metric">
                <span class="metric-label">План</span>
                <span class="metric-value">{{ summaryData[7] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Факт</span>
                <span class="metric-value">{{ summaryData[8] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Выполнено</span>
                <span class="metric-value">{{ summaryData[9] }}</span>
              </div>
            </div>
          </div>

          <div class="summary-card">
            <div class="summary-card-header">
              <i class="el-icon-user"></i>
              <span>F2F (Face to Face)</span>
            </div>
            <div class="summary-card-content">
              <div class="summary-metric">
                <span class="metric-label">План</span>
                <span class="metric-value">{{ summaryData[10] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Факт</span>
                <span class="metric-value">{{ summaryData[11] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Выполнено</span>
                <span class="metric-value">{{ summaryData[12] }}</span>
              </div>
            </div>
          </div>

          <div class="summary-card summary-total">
            <div class="summary-card-header">
              <i class="el-icon-s-data"></i>
              <span>Итого</span>
            </div>
            <div class="summary-card-content">
              <div class="summary-metric">
                <span class="metric-label">План</span>
                <span class="metric-value total-value">{{ summaryData[13] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Факт</span>
                <span class="metric-value total-value">{{ summaryData[14] }}</span>
              </div>
              <div class="summary-metric">
                <span class="metric-label">Выполнено</span>
                <span class="metric-value total-value">{{ summaryData[15] }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'

  interface Row {
    id: number
    date: string
    days_nd: number
    kc_plan: number
    kc_done: number
    co_plan: number
    co_fact: number
    co_done: number
    stp_plan: number
    stp_fact: number
    stp_done: number
    f2f_plan: number
    f2f_fact: number
    f2f_done: number
    total_plan: number
    total_fact: number
    total_done: number
    status: 'done' | 'in_progress' | 'overdue' | 'other'
  }

  const showFilter = ref(true)
  const dateRange = ref<[string, string] | null>(null)
  const status = ref<string>('all')
  const search = ref<string>('')

  const sortBy = ref<string>('date')
  const sortOrder = ref<'ascending' | 'descending'>('descending')

  const rows = ref<Row[]>(generateMockRows())

  function randInt(min: number, max: number) {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }

  function generateMockRows(): Row[] {
    const base: Row[] = []
    // Create 24 done rows and 4 in_progress rows to match requested totals
    for (let i = 1; i <= 28; i++) {
      const kc_plan = randInt(10, 60)
      const co_plan = randInt(5, 40)
      const stp_plan = randInt(3, 30)
      const f2f_plan = randInt(0, 10)
      const total_plan = kc_plan + co_plan + stp_plan + f2f_plan

      let kc_done = kc_plan
      let co_fact = co_plan
      let co_done = co_plan
      let stp_fact = stp_plan
      let stp_done = stp_plan
      let f2f_fact = f2f_plan
      let f2f_done = f2f_plan

      // For last 4 rows make them in_progress
      const isInProgress = i > 24
      if (isInProgress) {
        // lower completions
        kc_done = Math.max(0, Math.round(kc_plan * 0.6))
        co_fact = Math.max(0, Math.round(co_plan * 0.7))
        co_done = Math.max(0, Math.round(co_fact * 0.7))
        stp_fact = Math.max(0, Math.round(stp_plan * 0.6))
        stp_done = Math.max(0, Math.round(stp_fact * 0.6))
        f2f_fact = Math.max(0, Math.round(f2f_plan * 0.5))
        f2f_done = Math.max(0, Math.round(f2f_fact * 0.5))
      }

      const total_fact = Math.max(0, kc_done + co_fact + stp_fact + f2f_fact)
      const total_done = Math.max(0, kc_done + co_done + stp_done + f2f_done)

      const date = new Date()
      date.setDate(date.getDate() - (28 - i))

      const statusVal: Row['status'] = i <= 24 ? 'done' : 'in_progress'

      base.push({
        id: i,
        date: date.toISOString().slice(0, 10),
        days_nd: randInt(0, 3),
        kc_plan,
        kc_done,
        co_plan,
        co_fact,
        co_done,
        stp_plan,
        stp_fact,
        stp_done,
        f2f_plan,
        f2f_fact,
        f2f_done,
        total_plan,
        total_fact,
        total_done,
        status: statusVal
      })
    }
    return base
  }

  const filteredData = computed(() => {
    let data = rows.value.slice()
    if (dateRange.value && dateRange.value.length === 2) {
      const [from, to] = dateRange.value
      data = data.filter((r) => r.date >= from && r.date <= to)
    }
    if (status.value && status.value !== 'all') {
      data = data.filter((r) => r.status === status.value)
    }
    if (search.value && search.value.trim().length > 0) {
      const q = search.value.trim().toLowerCase()
      data = data.filter(
        (r) =>
          String(r.id).includes(q) ||
          String(r.kc_plan).includes(q) ||
          String(r.kc_done).includes(q) ||
          String(r.co_plan).includes(q) ||
          String(r.co_fact).includes(q) ||
          String(r.co_done).includes(q) ||
          String(r.total_done).includes(q)
      )
    }
    return data
  })

  const sortedData = computed(() => {
    const data = filteredData.value.slice()
    const sBy = sortBy.value
    const order = sortOrder.value === 'ascending' ? 1 : -1
    data.sort((a: any, b: any) => {
      const va = a[sBy]
      const vb = b[sBy]
      if (typeof va === 'number' && typeof vb === 'number') return (va - vb) * order
      return String(va).localeCompare(String(vb)) * order
    })
    return data
  })

  function applyFilters() {
    // Reactive update happens automatically via computed property
  }

  function resetFilters() {
    dateRange.value = null
    status.value = 'all'
    search.value = ''
  }

  function exportData() {
    console.log('Export data')
  }

  function percent(plan: number, done: number) {
    if (!plan || plan === 0) return 0
    return Math.round((done / plan) * 100)
  }

  function deltaClass(plan: number, done: number) {
    const p = percent(plan, done)
    // Color thresholds: red <50, yellow 50-79, green >=80
    if (p >= 80) return 'good'
    if (p >= 50) return 'warning'
    return 'poor'
  }

  function arrowIcon(plan: number, done: number) {
    // Arrow based on percent thresholds: <50 down, 50-79 right, >=80 up
    const p = percent(plan, done)
    if (!plan) return 'right'
    if (p >= 80) return 'up'
    if (p >= 50) return 'right'
    return 'down'
  }

  function arrowTitle(plan: number, done: number) {
    if (!plan) return 'План отсутствует'
    const p = percent(plan, done)
    if (p >= 80) return `Показатель отличный (${p}%)`
    if (p >= 50) return `Показатель в норме (${p}%)`
    return `Низкий показатель (${p}%)`
  }

  const summaryData = computed(() => {
    const data = filteredData.value
    const sum = (key: string) =>
      data.reduce((acc, cur) => acc + (Number((cur as any)[key]) || 0), 0)
    return [
      'Итого',
      sum('days_nd'),
      sum('kc_plan'),
      sum('kc_done'),
      sum('co_plan'),
      sum('co_fact'),
      sum('co_done'),
      sum('stp_plan'),
      sum('stp_fact'),
      sum('stp_done'),
      sum('f2f_plan'),
      sum('f2f_fact'),
      sum('f2f_done'),
      sum('total_plan'),
      sum('total_fact'),
      sum('total_done')
    ]
  })

  const filteredTotalCount = computed(() => filteredData.value.length)
  const filteredDoneCount = computed(
    () => filteredData.value.filter((r) => r.status === 'done').length
  )
  const filteredInProgressCount = computed(
    () => filteredData.value.filter((r) => r.status === 'in_progress').length
  )
  const filteredOverdueCount = computed(
    () => filteredData.value.filter((r) => r.status === 'overdue').length
  )

  watch([filteredData, sortBy, sortOrder], () => {
    // Reactive updates
  })
</script>

<style scoped lang="scss">
  .analytics-page {
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    color: var(--text-color, #0f172a);
    padding: 24px;
    width: 100%;
    max-width: 100vw;
    margin: 0 auto;
    background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
    min-height: 100vh;
    box-sizing: border-box;

    .page-header {
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
    }

    .filter-section {
      margin-bottom: 32px;

      .filter-container {
        background: white;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        border: 1px solid rgba(30, 64, 175, 0.1);
        overflow: hidden;

        .filter-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 20px 24px;
          background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
          border-bottom: 1px solid #e5e7eb;

          .filter-title {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
            color: #1e40af;
            display: flex;
            align-items: center;
            gap: 8px;

            i {
              font-size: 20px;
            }
          }

          .filter-toggle {
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 600;
          }
        }

        .filter-content {
          padding: 24px;

          .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            align-items: end;

            .filter-group {
              display: flex;
              flex-direction: column;
              gap: 8px;

              .filter-label {
                font-size: 12px;
                font-weight: 700;
                text-transform: uppercase;
                color: #6b7280;
                letter-spacing: 0.5px;
              }

              .filter-input {
                width: 100%;
              }
            }

            .filter-actions {
              display: flex;
              gap: 12px;
              align-items: center;

              .el-button {
                display: flex;
                align-items: center;
                gap: 6px;
                font-weight: 600;
              }
            }
          }
        }
      }
    }

    .content-container {
      .table-wrapper {
        background: white;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        border: 1px solid rgba(30, 64, 175, 0.1);
        overflow: hidden;

        .table-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 24px;
          background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
          border-bottom: 2px solid #e5e7eb;

          .table-title {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #1e40af;
            display: flex;
            align-items: center;
            gap: 8px;

            i {
              font-size: 22px;
            }
          }

          .table-info {
            .table-count {
              font-size: 14px;
              color: #6b7280;
              font-weight: 600;
            }
          }
        }

        .table-container {
          overflow-x: auto;
          min-height: 400px;
          width: 100%;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 0 20px;

          .modern-table {
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
              font-size: 13px;
              padding: 16px 8px;
              text-transform: uppercase;
              letter-spacing: 0.5px;
              border: none;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 16px 8px;
              font-size: 13px;
              border-color: #f1f5f9;
              transition: all 0.2s ease;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__row:hover > td) {
              background-color: #f8fafc;
            }

            :deep(.el-table__row:nth-child(even) > td) {
              background-color: #fafbfc;
            }

            :deep(.el-table__row:nth-child(even):hover > td) {
              background-color: #f1f5f9;
            }
          }
        }
      }
    }

    .cell-combo {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 4px;
      flex-wrap: wrap;

      .value {
        font-weight: 700;
        font-size: 14px;
        color: #1f2937;
        flex-shrink: 0;
      }

      .delta {
        display: inline-flex;
        align-items: center;
        gap: 2px;
        padding: 3px 6px;
        border-radius: 4px;
        font-size: 10px;
        font-weight: 600;
        flex-shrink: 0;
      }

      .arrow.up::after {
        content: '▲';
        color: #16a34a;
        font-weight: 700;
        margin-right: 1px;
        font-size: 9px;
      }

      .arrow.down::after {
        content: '▼';
        color: #dc2626;
        font-weight: 700;
        margin-right: 1px;
        font-size: 9px;
      }

      .arrow.right::after {
        content: '▶';
        color: #f59e0b;
        font-weight: 700;
        margin-right: 1px;
        font-size: 9px;
      }

      .delta.good {
        background: rgba(22, 163, 74, 0.12);
        color: #15803d;
      }

      .delta.warning {
        background: rgba(249, 115, 22, 0.12);
        color: #92400e;
      }

      .delta.poor {
        background: rgba(220, 38, 38, 0.12);
        color: #991b1b;
      }
    }

    // Адаптивные стили для стрелочек
    @media (max-width: 768px) {
      .cell-combo {
        gap: 2px;
        flex-direction: column;

        .value {
          font-size: 12px;
        }

        .delta {
          padding: 2px 4px;
          font-size: 9px;
        }

        .arrow.up::after,
        .arrow.down::after,
        .arrow.right::after {
          font-size: 8px;
        }
      }
    }

    @media (max-width: 480px) {
      .cell-combo {
        .value {
          font-size: 10px;
        }

        .delta {
          padding: 1px 3px;
          font-size: 8px;
        }

        .arrow.up::after,
        .arrow.down::after,
        .arrow.right::after {
          font-size: 7px;
        }
      }
    }

    .summary-section {
      margin-top: 24px;
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      border: 1px solid rgba(30, 64, 175, 0.1);
      overflow: hidden;

      .summary-header {
        padding: 20px 24px;
        background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
        border-bottom: 2px solid #e5e7eb;

        .summary-title {
          margin: 0;
          font-size: 18px;
          font-weight: 700;
          color: #1e40af;
          display: flex;
          align-items: center;
          gap: 8px;

          i {
            font-size: 20px;
          }
        }
      }

      .summary-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        padding: 24px;

        .summary-card {
          background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
          border-radius: 12px;
          padding: 20px;
          border: 1px solid #e5e7eb;
          transition: all 0.3s ease;

          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
          }

          &.summary-total {
            background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 100%);
            border-color: #10b981;

            .summary-card-header {
              color: #059669;

              i {
                color: #10b981;
              }
            }

            .total-value {
              color: #059669;
              font-weight: 800;
            }
          }

          .summary-card-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 16px;
            font-size: 14px;
            font-weight: 700;
            color: #1e40af;
            text-transform: uppercase;
            letter-spacing: 0.5px;

            i {
              font-size: 16px;
              color: #3b82f6;
            }
          }

          .summary-card-value {
            font-size: 32px;
            font-weight: 800;
            color: #1e40af;
            text-align: center;
            margin-top: 8px;
          }

          .summary-card-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(80px, 1fr));
            gap: 12px;

            .summary-metric {
              display: flex;
              flex-direction: column;
              align-items: center;
              padding: 12px 8px;
              background: white;
              border-radius: 8px;
              border: 1px solid #e5e7eb;
              transition: all 0.2s ease;

              &:hover {
                background: #f8fafc;
                border-color: #3b82f6;
              }

              .metric-label {
                font-size: 11px;
                font-weight: 600;
                text-transform: uppercase;
                color: #6b7280;
                letter-spacing: 0.3px;
                margin-bottom: 6px;
              }

              .metric-value {
                font-weight: 700;
                color: #1e40af;
                font-size: 18px;
                line-height: 1;
              }
            }
          }
        }
      }
    }
  }

  .filter-slide-enter-active,
  .filter-slide-leave-active {
    transition: all 0.3s ease;
  }

  .filter-slide-enter-from,
  .filter-slide-leave-to {
    opacity: 0;
    transform: translateY(-10px);
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }

  @media (max-width: 1400px) {
    .analytics-page {
      padding: 20px;
      width: 100%;
      max-width: 100vw;
    }
  }

  @media (max-width: 1200px) {
    .analytics-page {
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

      .filter-section .filter-container .filter-content .filter-grid {
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
      }

      .summary-section .summary-grid {
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 16px;
      }
    }
  }

  @media (max-width: 992px) {
    .analytics-page {
      padding: 14px;
      width: 100%;
      max-width: 100vw;

      .page-header .page-title {
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

      .filter-section .filter-container {
        .filter-header {
          padding: 18px;
        }

        .filter-content {
          padding: 20px;

          .filter-grid {
            grid-template-columns: 1fr;
            gap: 14px;
          }
        }
      }

      .content-container .table-wrapper {
        .table-header {
          padding: 18px;
        }

        .table-container .modern-table {
          :deep(.el-table__header th) {
            font-size: 12px;
            padding: 14px 6px;
          }

          :deep(.el-table__body td) {
            padding: 14px 6px;
            font-size: 12px;
          }
        }
      }

      .summary-section {
        .summary-header {
          padding: 18px;
        }

        .summary-grid {
          grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
          gap: 14px;
          padding: 20px;
        }
      }
    }
  }

  @media (max-width: 768px) {
    .analytics-page {
      padding: 12px;
      width: 100%;
      max-width: 100vw;

      .page-header .page-title {
        font-size: 22px;
        line-height: 1.2;
      }

      .kpi-section {
        flex-direction: row;
        gap: 8px;
        margin-bottom: 20px;

        .kpi-block {
          padding: 12px 8px;
          min-width: 0;
          flex: 1;
          max-width: none;
        }

        .kpi-value {
          font-size: 20px;
        }

        .kpi-label {
          font-size: 11px;
          line-height: 1.2;
        }
      }

      .filter-section .filter-container {
        .filter-header {
          padding: 14px;
          flex-direction: column;
          gap: 10px;
          align-items: stretch;

          .filter-title {
            font-size: 15px;
            justify-content: center;
          }

          .filter-toggle {
            align-self: center;
          }
        }

        .filter-content {
          padding: 14px;

          .filter-grid {
            gap: 12px;

            .filter-group {
              .filter-label {
                font-size: 11px;
              }
            }

            .filter-actions {
              justify-content: center;
              flex-wrap: wrap;
              gap: 8px;

              .el-button {
                font-size: 12px;
                padding: 8px 12px;
              }
            }
          }
        }
      }

      .content-container .table-wrapper {
        .table-header {
          padding: 14px;
          flex-direction: column;
          gap: 10px;
          align-items: stretch;

          .table-title {
            font-size: 16px;
            justify-content: center;
          }

          .table-info {
            text-align: center;
            font-size: 12px;
          }
        }

        .table-container {
          overflow-x: auto;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 0 16px;
          
          .modern-table {
            min-width: 800px;
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
              padding: 12px 6px;
              white-space: nowrap;
              text-align: center;
            }

            :deep(.el-table__body td) {
              padding: 12px 6px;
              font-size: 11px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }
      }

      .summary-section {
        .summary-header {
          padding: 14px;

          .summary-title {
            font-size: 15px;
            justify-content: center;
          }
        }

        .summary-grid {
          grid-template-columns: 1fr;
          gap: 12px;
          padding: 14px;

          .summary-card {
            padding: 14px;

            .summary-card-header {
              font-size: 12px;
              margin-bottom: 10px;
            }

            .summary-card-value {
              font-size: 24px;
            }

            .summary-card-content {
              grid-template-columns: repeat(auto-fit, minmax(60px, 1fr));
              gap: 6px;

              .summary-metric {
                padding: 8px 4px;

                .metric-label {
                  font-size: 9px;
                  margin-bottom: 3px;
                }

                .metric-value {
                  font-size: 14px;
                }
              }
            }
          }
        }
      }
    }
  }

  @media (max-width: 480px) {
    .analytics-page {
      padding: 8px;
      width: 100%;
      max-width: 100vw;

      .page-header .page-title {
        font-size: 18px;
        line-height: 1.1;
      }

      .kpi-section {
        flex-direction: column;
        gap: 8px;
        margin-bottom: 16px;

        .kpi-block {
          padding: 12px;
          min-width: 0;
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

      .filter-section .filter-container {
        .filter-header {
          padding: 12px;

          .filter-title {
            font-size: 14px;
          }
        }

        .filter-content {
          padding: 12px;

          .filter-grid {
            gap: 10px;

            .filter-group {
              .filter-label {
                font-size: 10px;
              }
            }

            .filter-actions {
              .el-button {
                font-size: 11px;
                padding: 6px 10px;
              }
            }
          }
        }
      }

      .content-container .table-wrapper {
        .table-header {
          padding: 12px;

          .table-title {
            font-size: 14px;
          }

          .table-info {
            font-size: 11px;
          }
        }

        .table-container {
          padding: 0 12px;
          display: flex;
          justify-content: center;
          align-items: center;
          
          .modern-table {
            min-width: 700px;
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
              padding: 10px 4px;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 10px 4px;
              font-size: 10px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }
      }

      .summary-section {
        .summary-header {
          padding: 12px;

          .summary-title {
            font-size: 14px;
          }
        }

        .summary-grid {
          gap: 10px;
          padding: 12px;

          .summary-card {
            padding: 12px;

            .summary-card-header {
              font-size: 11px;
              margin-bottom: 8px;
            }

            .summary-card-value {
              font-size: 20px;
            }

            .summary-card-content {
              grid-template-columns: repeat(auto-fit, minmax(50px, 1fr));
              gap: 4px;

              .summary-metric {
                padding: 6px 3px;

                .metric-label {
                  font-size: 8px;
                  margin-bottom: 2px;
                }

                .metric-value {
                  font-size: 12px;
                }
              }
            }
          }
        }
      }
    }
  }

  @media (max-width: 360px) {
    .analytics-page {
      padding: 6px;
      width: 100%;
      max-width: 100vw;

      .page-header .page-title {
        font-size: 16px;
      }

      .kpi-section {
        gap: 6px;

        .kpi-block {
          padding: 10px;
        }

        .kpi-value {
          font-size: 16px;
        }

        .kpi-label {
          font-size: 9px;
        }
      }

      .filter-section .filter-container {
        .filter-header {
          padding: 10px;
        }

        .filter-content {
          padding: 10px;
        }
      }

      .content-container .table-wrapper {
        .table-header {
          padding: 10px;
        }

        .table-container {
          display: flex;
          justify-content: center;
          align-items: center;
          
          .modern-table {
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
              font-size: 9px;
              padding: 8px 3px;
              text-align: center;
              white-space: nowrap;
            }

            :deep(.el-table__body td) {
              padding: 8px 3px;
              font-size: 9px;
              text-align: center;
              white-space: nowrap;
            }
          }
        }
      }

      .summary-section {
        .summary-header {
          padding: 10px;
        }

        .summary-grid {
          padding: 10px;

          .summary-card {
            padding: 10px;

            .summary-card-header {
              font-size: 10px;
            }

            .summary-card-value {
              font-size: 18px;
            }

            .summary-card-content {
              grid-template-columns: repeat(auto-fit, minmax(45px, 1fr));

              .summary-metric {
                padding: 5px 2px;

                .metric-label {
                  font-size: 7px;
                }

                .metric-value {
                  font-size: 11px;
                }
              }
            }
          }
        }
      }
    }
  }
</style>