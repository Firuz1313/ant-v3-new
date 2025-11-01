/**
 * Алиасы маршрутов для быстрого доступа и навигации
 */

/** Алиасы маршрутов */
export enum RoutesAlias {
  Layout = '/index/index', // Контейнер макета
  Login = '/auth/login', // Вход
  Register = '/auth/register', // Регистрация
  ForgetPassword = '/auth/forget-password', // Забыли пароль
  Exception403 = '/exception/403', // 403
  Exception404 = '/exception/404', // 404
  Exception500 = '/exception/500', // 500
  Dashboard = '/dashboard/console', // Главная панель
  
  // Аналитика
  AnalyticsOverview = '/analytics/overview',
  AnalyticsRealtime = '/analytics/realtime',
  AnalyticsTrends = '/analytics/trends',
  AnalyticsComparison = '/analytics/comparison',
  
  // Отчёты
  ReportsSales = '/reports/sales',
  ReportsFinancial = '/reports/financial',
  ReportsMarketing = '/reports/marketing',
  ReportsCustom = '/reports/custom',
  
  // Данные
  DataSources = '/data/sources',
  DataIntegration = '/data/integration',
  DataWarehouse = '/data/warehouse',
  DataQuality = '/data/quality',
  
  // Визуализация
  VisualizationCharts = '/visualization/charts',
  VisualizationTables = '/visualization/tables',
  VisualizationMaps = '/visualization/maps',
  VisualizationWidgets = '/visualization/widgets',
  
  // Система
  User = '/system/user', // Управление пользователями
  Role = '/system/role', // Управление ролями
  UserCenter = '/system/user-center', // Личный кабинет
  Menu = '/system/menu' // Управление меню
}
