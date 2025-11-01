import type { App } from 'vue'

function safeToString(input: unknown): string {
  try {
    if (input === null) return 'null'
    if (input === undefined) return 'undefined'
    if (typeof input === 'string') return input
    if (typeof input === 'number' || typeof input === 'boolean') return String(input)
    if (typeof input === 'bigint') return input.toString()
    if (typeof input === 'symbol') return input.toString()

    if (input instanceof Error) {
      const name = input.name || 'Error'
      const msg = input.message || ''
      const stack = input.stack ? `\n${input.stack}` : ''
      return `${name}: ${msg}${stack}`
    }

    const maybeComp = input as any
    if (
      maybeComp &&
      (maybeComp.$?.type?.name || maybeComp.type?.name || maybeComp.$options?.name)
    ) {
      const name = maybeComp.$?.type?.name || maybeComp.type?.name || maybeComp.$options?.name
      return `[Component ${String(name)}]`
    }

    const seen = new WeakSet<object>()
    const json = JSON.stringify(input as any, (key, value) => {
      if (typeof value === 'bigint') return value.toString()
      if (typeof value === 'symbol') return value.toString()
      if (typeof value === 'function') return `[Function ${value.name || 'anonymous'}]`
      if (typeof value === 'object' && value !== null) {
        if (seen.has(value)) return '[Circular]'
        seen.add(value)
      }
      return value
    })
    if (json !== undefined) return json

    return Object.prototype.toString.call(input)
  } catch {
    try {
      return Object.prototype.toString.call(input)
    } catch {
      return '[Unserializable]'
    }
  }
}

/**
 * Vue 运行时错误处理
 */
export function vueErrorHandler(err: unknown, instance: any, info: string) {
  const parts: string[] = ['[VueError]', safeToString(err)]
  if (info) parts.push(`info=${safeToString(info)}`)
  if (instance) parts.push(`component=${safeToString(instance)}`)
  console.error(parts.join(' | '))
  // 这里可以上报到服务端，比如：
  // reportError({ type: 'vue', err, info })
}

/**
 * 全局脚本错误处理
 */
export function scriptErrorHandler(
  message: Event | string,
  source?: string,
  lineno?: number,
  colno?: number,
  error?: Error
): boolean {
  const msg = `message=${safeToString(message)} | source=${safeToString(source)} | line=${String(
    lineno ?? ''
  )} | col=${String(colno ?? '')}${error ? ' | ' + safeToString(error) : ''}`
  console.error(`[ScriptError] ${msg}`)
  // reportError({ type: 'script', message, source, lineno, colno, error })
  return true // 阻止默认控制台报错，可根据需求改
}

/**
 * Promise 未捕获错误处理
 */
export function registerPromiseErrorHandler() {
  window.addEventListener('unhandledrejection', (event) => {
    console.error(`[PromiseError] ${safeToString(event.reason)}`)
    // reportError({ type: 'promise', reason: event.reason })
  })
}

/**
 * 资源加载错误处理 (img, script, css...)
 */
export function registerResourceErrorHandler() {
  window.addEventListener(
    'error',
    (event: Event) => {
      const target = event.target as HTMLElement
      if (
        target &&
        (target.tagName === 'IMG' || target.tagName === 'SCRIPT' || target.tagName === 'LINK')
      ) {
        const src =
          (target as HTMLImageElement).src ||
          (target as HTMLScriptElement).src ||
          (target as HTMLLinkElement).href
        console.error(`[ResourceError] tag=${target.tagName} | src=${safeToString(src)}`)
        // reportError({ type: 'resource', target })
      }
    },
    true // 捕获阶段才能监听到资源错误
  )
}

/**
 * 安装统一错误处理
 */
export function setupErrorHandle(app: App) {
  app.config.errorHandler = vueErrorHandler
  window.onerror = scriptErrorHandler
  registerPromiseErrorHandler()
  registerResourceErrorHandler()
}
