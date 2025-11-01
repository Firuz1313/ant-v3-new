/**
 * Конфигурация быстрого входа
 * Включает: список приложений, быстрые ссылки и т.д.
 */
import { RoutesAlias } from '@/router/routesAlias'
import type { FastEnterConfig } from '@/types/config'

const fastEnterConfig: FastEnterConfig = {
  // Условие отображения (ширина экрана)
  minWidth: 1200,
  // Список приложений
  applications: [
    {
      name: 'Панель управления',
      description: 'Главная страница системы',
      icon: '&#xe721;',
      iconColor: '#377dff',
      path: RoutesAlias.Dashboard,
      enabled: true,
      order: 1
    },
    {
      name: 'Личный кабинет',
      description: 'Настройки профиля',
      icon: '&#xe7b9;',
      iconColor: '#13DEB9',
      path: RoutesAlias.UserCenter,
      enabled: true,
      order: 2
    }
  ],
  // Быстрые ссылки
  quickLinks: [
    {
      name: 'Вход',
      path: RoutesAlias.Login,
      enabled: true,
      order: 1
    },
    {
      name: 'Регистрация',
      path: RoutesAlias.Register,
      enabled: true,
      order: 2
    }
  ]
}

export default Object.freeze(fastEnterConfig)
