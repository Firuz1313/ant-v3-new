@echo off
chcp 65001 >nul
cls

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║              🚀 АНТ АНАЛИТИКА - ЗАПУСК                   ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

echo [INFO] Добавление Node.js в PATH...
set "PATH=C:\Program Files\nodejs;%PATH%"

echo [INFO] Проверка Node.js...
"C:\Program Files\nodejs\node.exe" --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Node.js не найден!
    echo [INFO] Установите Node.js с https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [OK] Node.js найден
echo.
echo [INFO] Запуск сервера разработки...
echo.
echo ═══════════════════════════════════════════════════════════
echo.
echo   После запуска браузер откроет страницу входа:
echo   📍 http://localhost:3006/#/auth/login
echo.
echo   Для входа используйте:
echo   👤 Логин: super
echo   🔑 Пароль: super123
echo.
echo   Для остановки нажмите: Ctrl+C
echo.
echo ═══════════════════════════════════════════════════════════
echo.

"C:\Program Files\nodejs\node.exe" "C:\Program Files\nodejs\node_modules\npm\bin\npm-cli.js" run dev

pause
