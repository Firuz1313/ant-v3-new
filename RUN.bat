@echo off
chcp 65001 >nul
cls

echo.
echo ══════════════════════════════════════════════════════
echo              ЗАПУСК АНТ АНАЛИТИКА
echo ══════════════════════════════════════════════════════
echo.

cd /d "%~dp0"

echo Запуск сервера разработки...
echo.
echo После запуска откроется браузер на странице входа
echo URL: http://localhost:3006/#/auth/login
echo.
echo Для остановки нажмите Ctrl+C
echo.
echo ══════════════════════════════════════════════════════
echo.

set "PATH=C:\Program Files\nodejs;%PATH%"

"C:\Program Files\nodejs\node.exe" "C:\Program Files\nodejs\node_modules\npm\bin\npm-cli.js" run dev

if errorlevel 1 (
    echo.
    echo ══════════════════════════════════════════════════════
    echo ОШИБКА ЗАПУСКА!
    echo ══════════════════════════════════════════════════════
    echo.
    echo Попробуйте:
    echo 1. Закройте это окно
    echo 2. Дважды кликните на файл dev.bat
    echo 3. Или выполните: npm install и повторите запуск
    echo.
    pause
    exit /b 1
)

pause
