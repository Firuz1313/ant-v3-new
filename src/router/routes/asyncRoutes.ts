import { AppRouteRecord } from '@/types/router'
import { RoutesAlias } from '../routesAlias'

/**
 * Асинхронные маршруты: только новые разделы из ТЗ
 */
export const asyncRoutes: AppRouteRecord[] = [
  {
    name: 'ApplicationsAnalytics',
    path: '/applications-analytics',
    component: RoutesAlias.Layout,
    meta: {
      title: 'АНАЛИТИКА ПРИНЯТЫХ ЗАЯВОК',
      icon: '&#xe73a;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'ApplicationsAnalyticsIndex',
        component: () => import('@views/business/applications-analytics/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'service-center',
        name: 'ApplicationsAnalyticsServiceCenter',
        component: () => import('@views/business/applications-analytics/service-center/index.vue'),
        meta: { title: 'ЦЕНТР ОБСЛУЖИВАНИЯ', keepAlive: true, icon: '&#xe6af;' }
      },
      {
        path: 'stp',
        name: 'ApplicationsAnalyticsSTP',
        component: () => import('@views/business/applications-analytics/stp/index.vue'),
        meta: { title: 'СТП', keepAlive: true, icon: '&#xe722;' }
      },
      {
        path: 'contact-center',
        name: 'ApplicationsAnalyticsContactCenter',
        component: () => import('@views/business/applications-analytics/contact-center/index.vue'),
        meta: { title: 'Контакт центр', keepAlive: true, icon: '&#xe734;' }
      },
      {
        path: 'f2f',
        name: 'ApplicationsAnalyticsF2F',
        component: () => import('@views/business/applications-analytics/f2f/index.vue'),
        meta: { title: 'F2F', keepAlive: true, icon: '&#xe75f;' }
      }
    ]
  },
  {
    name: 'MastersDept',
    path: '/masters-dept',
    component: RoutesAlias.Layout,
    meta: {
      title: 'Отдел-мастеров: план/факт выполнения заявок',
      icon: '&#xe722;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'MastersDeptIndex',
        component: () => import('@views/business/masters-dept/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'cancelled',
        name: 'MastersDeptCancelled',
        component: () => import('@views/business/masters-dept/cancelled/index.vue'),
        meta: { title: 'Отмененные заявки', keepAlive: true, icon: '&#xe6af;' }
      },
      {
        path: 'repair-days',
        name: 'MastersDeptRepairDays',
        component: () => import('@views/business/masters-dept/repair-days/index.vue'),
        meta: { title: 'Дни обработки на ремонт', keepAlive: true, icon: '&#xe734;' }
      },
      {
        path: 'connection-days',
        name: 'MastersDeptConnectionDays',
        component: () => import('@views/business/masters-dept/connection-days/index.vue'),
        meta: { title: 'Дни обработки подключений', keepAlive: true, icon: '&#xe75f;' }
      },
      {
        path: 'percent-completed',
        name: 'MastersDeptPercentCompleted',
        component: () => import('@views/business/masters-dept/percent-completed/index.vue'),
        meta: { title: '% Выполнено', keepAlive: true, icon: '&#xe73a;' }
      },
      {
        path: 'avg-days',
        name: 'MastersDeptAvgDays',
        component: () => import('@views/business/masters-dept/avg-days/index.vue'),
        meta: { title: 'Среднее количество дней', keepAlive: true, icon: '&#xe722;' }
      },
      {
        path: 'forecasts',
        name: 'MastersDeptForecasts',
        component: () => import('@views/business/masters-dept/forecasts/index.vue'),
        meta: { title: 'Прогнозы', keepAlive: true, icon: '&#xe6af;' }
      },
      {
        path: 'source',
        name: 'MastersDeptSource',
        component: () => import('@views/business/masters-dept/source/index.vue'),
        meta: { title: 'Источник заявок', keepAlive: true, icon: '&#xe734;' }
      }
    ]
  },
  {
    name: 'CallCenterStats',
    path: '/call-center',
    component: RoutesAlias.Layout,
    meta: {
      title: 'Контакт-центр: статистика звонков',
      icon: '&#xe6af;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'CallCenterIndex',
        component: () => import('@views/business/call-center/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'call-purpose-repeat',
        name: 'CallCenterPurposeRepeat',
        component: () => import('@views/business/call-center/call-purpose-repeat/index.vue'),
        meta: { title: 'Цель звонка и повторные', keepAlive: true, icon: '&#xe73a;' }
      },
      {
        path: 'by-periods',
        name: 'CallCenterByPeriods',
        component: () => import('@views/business/call-center/by-periods/index.vue'),
        meta: { title: 'По дням, месяцам, годам', keepAlive: true, icon: '&#xe734;' }
      },
      {
        path: 'by-daytime',
        name: 'CallCenterByDaytime',
        component: () => import('@views/business/call-center/by-daytime/index.vue'),
        meta: { title: 'По времени суток', keepAlive: true, icon: '&#xe75f;' }
      },
      {
        path: 'resolved-remotely',
        name: 'CallCenterResolvedRemotely',
        component: () => import('@views/business/call-center/resolved-remotely/index.vue'),
        meta: { title: 'Решенные удаленно', keepAlive: true, icon: '&#xe722;' }
      }
    ]
  },
  {
    name: 'DiscountProgram',
    path: '/discount-program',
    component: RoutesAlias.Layout,
    meta: {
      title: 'Участники дисконтной программы',
      icon: '&#xe75f;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'DiscountProgramIndex',
        component: () => import('@views/business/discount-program/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'by-connection',
        name: 'DiscountProgramByConnection',
        component: () => import('@views/business/discount-program/by-connection/index.vue'),
        meta: { title: 'По подключению', keepAlive: true, icon: '&#xe6af;' }
      },
      {
        path: 'by-years',
        name: 'DiscountProgramByYears',
        component: () => import('@views/business/discount-program/by-years/index.vue'),
        meta: { title: 'По годам', keepAlive: true, icon: '&#xe734;' }
      },
      {
        path: 'package-share',
        name: 'DiscountProgramPackageShare',
        component: () => import('@views/business/discount-program/package-share/index.vue'),
        meta: { title: 'Удельный вес по пакетам', keepAlive: true, icon: '&#xe73a;' }
      }
    ]
  },
  {
    name: 'BackofficeDelay',
    path: '/backoffice-delay',
    component: RoutesAlias.Layout,
    meta: {
      title: 'Опоздание Backoffice',
      icon: '&#xe734;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'BackofficeDelayIndex',
        component: () => import('@views/business/backoffice-delay/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'salary-penalty',
        name: 'BackofficeSalaryPenalty',
        component: () => import('@views/business/backoffice-delay/salary-penalty/index.vue'),
        meta: { title: 'Штраф от ЗП', keepAlive: true, icon: '&#xe6af;' }
      }
    ]
  },
  {
    name: 'Clients',
    path: '/clients',
    component: RoutesAlias.Layout,
    meta: {
      title: 'Клиенты',
      icon: '&#xe6af;',
      roles: ['R_SUPER', 'R_ADMIN', 'R_USER']
    },
    children: [
      {
        path: 'index',
        name: 'ClientsIndex',
        component: () => import('@views/business/clients/index.vue'),
        meta: { title: 'Общая сводка', keepAlive: true, icon: '&#xe721;' }
      },
      {
        path: 'inactive',
        name: 'ClientsInactive',
        component: () => import('@views/business/clients/inactive/index.vue'),
        meta: { title: 'Неактивные', keepAlive: true, icon: '&#xe73a;' }
      },
      {
        path: 'by-region',
        name: 'ClientsByRegion',
        component: () => import('@views/business/clients/by-region/index.vue'),
        meta: { title: 'По регионам', keepAlive: true, icon: '&#xe734;' }
      },
      {
        path: 'empty-names',
        name: 'ClientsEmptyNames',
        component: () => import('@views/business/clients/empty-names/index.vue'),
        meta: { title: 'С пустыми ФИО', keepAlive: true, icon: '&#xe75f;' }
      }
    ]
  }
]
