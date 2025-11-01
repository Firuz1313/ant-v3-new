@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║           🚀 Запуск Ант Аналитика (Dev Mode)                  ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: Проверка Node.js
echo [1/5] Проверка Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js не найден в PATH
    echo.
    echo Попытка использовать стандартный путь...
    set "NODE_PATH=C:\Program Files\nodejs"
    if exist "!NODE_PATH!\node.exe" (
        set "PATH=!NODE_PATH!;!PATH!"
        echo ✓ Node.js найден: !NODE_PATH!
    ) else (
        echo.
        echo ❌ Node.js не установлен!
        echo Установите Node.js с https://nodejs.org/
        echo.
        pause
        exit /b 1
    )
) else (
    for /f "tokens=*" %%i in ('node --version 2^>^&1') do set NODE_VERSION=%%i
    echo ✓ Node.js установлен: !NODE_VERSION!
)

:: Проверка npm
echo.
echo [2/5] Проверка npm...
where npm >nul 2>&1
if errorlevel 1 (
    echo ❌ npm не найден в PATH
    set "PATH=C:\Program Files\nodejs;!PATH!"
)

for /f "tokens=*" %%i in ('npm --version 2^>^&1') do set NPM_VERSION=%%i
echo ✓ npm установлен: !NPM_VERSION!

:: Проверка node_modules
echo.
echo [3/5] Проверка зависимостей...
if not exist "node_modules" (
    echo ⚠ Зависимости не установлены
    echo Установка зависимостей...
    call npm install
    if errorlevel 1 (
        echo.
        echo ❌ Ошибка установки зависимостей
        pause
        exit /b 1
    )
    echo ✓ Зависимости установлены
) else (
    echo ✓ Зависимости найдены
)

:: Очистка кэша Vite
echo.
echo [4/5] Очистка кэша Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite" 2>nul
    echo ✓ Кэш Vite очищен
) else (
    echo ✓ Кэш уже чист
)

:: Проверка переменных окружения
echo.
echo [5/5] Проверка конфигурации...
if exist ".env" (
    echo ✓ Файл .env найден
) else (
    echo ⚠ Файл .env не найден
)

:: Запуск проекта
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo ✨ Запуск сервера разработки...
echo.
echo 📍 Проект откроется автоматически в браузере
echo 🌐 URL: http://localhost:3006/#/auth/login
echo.
echo 💡 Для остановки нажмите Ctrl+C
echo.
echo ════════════════════════════════════════════════════════════════
echo.

:: Запуск npm run dev
call npm run dev

:: Если произошла ошибка
if errorlevel 1 (
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo ❌ Ошибка запуска сервера!
    echo ════════════════════════════════════════════════════════════════
    echo.
    echo Попробуйте:
    echo 1. Закрыть все процессы node.exe
    echo 2. Удалить папку node_modules
    echo 3. Выполнить: npm install
    echo 4. Запустить снова
    echo.
    pause
    exit /b 1
)

pause
