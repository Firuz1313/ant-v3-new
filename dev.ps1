# Установка кодировки UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║           🚀 Запуск Ант Аналитика (Dev Mode)                  ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Переход в директорию скрипта
Set-Location $PSScriptRoot

# Проверка Node.js
Write-Host "[1/5] Проверка Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = & node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Node.js установлен: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js не найден"
    }
} catch {
    Write-Host "❌ Node.js не найден!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Попытка использовать стандартный путь..." -ForegroundColor Yellow

    $nodePath = "C:\Program Files\nodejs"
    if (Test-Path "$nodePath\node.exe") {
        $env:Path = "$nodePath;$env:Path"
        $nodeVersion = & node --version 2>&1
        Write-Host "✓ Node.js найден: $nodeVersion" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Node.js не установлен!" -ForegroundColor Red
        Write-Host "Установите Node.js с https://nodejs.org/" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
}

# Проверка npm
Write-Host ""
Write-Host "[2/5] Проверка npm..." -ForegroundColor Yellow
try {
    $npmVersion = & npm --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ npm установлен: $npmVersion" -ForegroundColor Green
    } else {
        throw "npm не найден"
    }
} catch {
    Write-Host "❌ npm не найден!" -ForegroundColor Red
    $env:Path = "C:\Program Files\nodejs;$env:Path"
    $npmVersion = & npm --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ npm найден: $npmVersion" -ForegroundColor Green
    } else {
        Write-Host ""
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
}

# Проверка node_modules
Write-Host ""
Write-Host "[3/5] Проверка зависимостей..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠ Зависимости не установлены" -ForegroundColor Yellow
    Write-Host "Установка зависимостей..." -ForegroundColor Cyan

    & npm install

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Ошибка установки зависимостей" -ForegroundColor Red
        Write-Host ""
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
    Write-Host "✓ Зависимости установлены" -ForegroundColor Green
} else {
    Write-Host "✓ Зависимости найдены" -ForegroundColor Green
}

# Очистка кэша Vite
Write-Host ""
Write-Host "[4/5] Очистка кэша Vite..." -ForegroundColor Yellow
if (Test-Path "node_modules\.vite") {
    Remove-Item -Recurse -Force "node_modules\.vite" -ErrorAction SilentlyContinue
    Write-Host "✓ Кэш Vite очищен" -ForegroundColor Green
} else {
    Write-Host "✓ Кэш уже чист" -ForegroundColor Green
}

# Проверка переменных окружения
Write-Host ""
Write-Host "[5/5] Проверка конфигурации..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ Файл .env найден" -ForegroundColor Green
} else {
    Write-Host "⚠ Файл .env не найден" -ForegroundColor Yellow
}

# Запуск проекта
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Запуск сервера разработки..." -ForegroundColor Green
Write-Host ""
Write-Host "📍 Проект откроется автоматически в браузере" -ForegroundColor White
Write-Host "🌐 URL: " -NoNewline -ForegroundColor White
Write-Host "http://localhost:3006/#/auth/login" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Для остановки нажмите Ctrl+C" -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Запуск npm run dev
try {
    & npm run dev
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "❌ Ошибка запуска сервера!" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Попробуйте:" -ForegroundColor Yellow
    Write-Host "1. Закрыть все процессы node.exe" -ForegroundColor White
    Write-Host "2. Удалить папку node_modules" -ForegroundColor White
    Write-Host "3. Выполнить: npm install" -ForegroundColor White
    Write-Host "4. Запустить снова" -ForegroundColor White
    Write-Host ""
    Write-Host "Ошибка: $_" -ForegroundColor Red
    Write-Host ""
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

# Если скрипт завершился нормально
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "❌ Сервер остановлен с ошибкой" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Read-Host "Нажмите Enter для выхода"
    exit 1
}
