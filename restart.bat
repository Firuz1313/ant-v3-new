@echo off
chcp 65001 >nul
echo ====================================
echo   Перезапуск проекта Ант Аналитика
echo ====================================
echo.

cd /d "%~dp0"

echo [1/4] Остановка процессов...
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/4] Очистка кэша Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo ✓ Кэш Vite очищен
) else (
    echo ✓ Кэш уже чист
)

echo [3/4] Очистка кэша npm...
call npm cache clean --force >nul 2>&1
echo ✓ Кэш npm очищен

echo.
echo [4/4] Запуск проекта...
echo.
echo ====================================
echo   Сервер запускается...
echo   Откроется страница входа:
echo   http://localhost:3006/#/auth/login
echo.
echo   Для остановки нажмите Ctrl+C
echo ====================================
echo.

set "PATH=%PATH%;C:\Program Files\nodejs"
npm run dev

pause
