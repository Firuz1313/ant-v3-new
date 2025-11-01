import { AxiosInstance, AxiosResponse, InternalAxiosRequestConfig } from 'axios'

/**
 * Mock API Adapter
 * Перехватывает все API запросы и возвращает локальные данные
 * Никаких внешних запросов не делается - всё работает локально
 */

interface MockResponse {
  code: number
  msg: string
  data: any
}

// Mock данные пользователя
const mockUser = {
  id: '1',
  username: 'admin',
  nickname: 'Администратор',
  email: 'admin@ant-bi.com',
  avatar: '',
  role: 'admin',
  roles: ['R_SUPER', 'R_ADMIN', 'R_USER'], // Важно: роли для фильтрации меню
  buttons: ['add', 'edit', 'delete', 'view', 'export', 'import'], // Кнопки для прав доступа
  permissions: ['*:*:*']
}

// Mock токен
const mockToken = 'mock-token-local-only-' + Date.now()

/**
 * Создаёт успешный ответ
 */
function createSuccessResponse<T>(data: T, msg = 'Success'): MockResponse {
  return {
    code: 200,
    msg,
    data
  }
}

/**
 * Создаёт mock ответ для Axios
 */
function createAxiosResponse(
  config: InternalAxiosRequestConfig,
  data: MockResponse
): AxiosResponse {
  return {
    data,
    status: 200,
    statusText: 'OK',
    headers: { 'content-type': 'application/json' },
    config: config as any,
    request: {}
  }
}

/**
 * Обрабатывает mock запросы
 */
function handleMockRequest(config: InternalAxiosRequestConfig): MockResponse | null {
  const url = config.url || ''
  const method = (config.method || 'get').toUpperCase()

  console.log(`[MOCK API] ${method} ${url}`)

  // Авторизация
  if (url.includes('/auth/login') && method === 'POST') {
    return createSuccessResponse(
      {
        token: mockToken,
        refreshToken: mockToken + '-refresh',
        user: mockUser
      },
      'Вход выполнен успешно'
    )
  }

  // Получение информации о пользователе
  if (url.includes('/user/info') && method === 'GET') {
    return createSuccessResponse(mockUser)
  }

  // Список пользователей
  if (url.includes('/user/list') && method === 'GET') {
    return createSuccessResponse({
      list: [mockUser],
      total: 1,
      page: 1,
      pageSize: 10
    })
  }

  // Список ролей
  if (url.includes('/role/list') && method === 'GET') {
    return createSuccessResponse({
      list: [
        {
          id: '1',
          name: 'admin',
          label: 'Администратор',
          permissions: ['*:*:*']
        }
      ],
      total: 1,
      page: 1,
      pageSize: 10
    })
  }

  // Любые другие запросы - возвращаем пустой успешный ответ
  console.log(`[MOCK API] Неизвестный endpoint: ${url}, возвращаем пустой ответ`)
  return createSuccessResponse(null, 'OK')
}

/**
 * Устанавливает mock adapter для axios instance
 */
export function setupMockAdapter(axiosInstance: AxiosInstance) {
  // Перехватываем запросы ДО отправки
  axiosInstance.interceptors.request.use(
    async (config: InternalAxiosRequestConfig) => {
      // Проверяем, нужно ли перехватить этот запрос
      const mockResponse = handleMockRequest(config)

      if (mockResponse) {
        // Создаём promise который сразу resolve с mock данными
        const response = createAxiosResponse(config, mockResponse)

        // Используем трюк: кидаем специальную ошибку с response
        // которая будет поймана в response interceptor
        const error: any = new Error('MockResponse')
        error.isMockResponse = true
        error.mockResponse = response
        throw error
      }

      return config
    },
    (error) => {
      return Promise.reject(error)
    }
  )

  // Перехватываем ответы - обрабатываем наши mock ответы
  const originalResponseInterceptor = axiosInstance.interceptors.response.use.bind(
    axiosInstance.interceptors.response
  )

  // Переопределяем response interceptor
  axiosInstance.interceptors.response.use = function (onFulfilled: any, onRejected: any) {
    // Оборачиваем onRejected
    const wrappedOnRejected = async (error: any) => {
      // Если это наш mock response - возвращаем его
      if (error?.isMockResponse && error?.mockResponse) {
        return Promise.resolve(error.mockResponse)
      }
      // Иначе передаём в оригинальный обработчик
      return onRejected ? onRejected(error) : Promise.reject(error)
    }

    // Вызываем оригинальный interceptor
    return originalResponseInterceptor(onFulfilled, wrappedOnRejected)
  } as any

  console.log('[MOCK API] Mock adapter установлен - все API запросы работают локально')
}
