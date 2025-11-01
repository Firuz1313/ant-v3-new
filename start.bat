@echo off
chcp 65001 >nul
echo ====================================
echo   Запуск проекта Ант Аналитика
echo ====================================
echo.

cd /d "%~dp0"

echo Проверка Node.js...
"C:\Program Files\nodejs\node.exe" --version >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Node.js не найден!
    echo Пожалуйста, установите Node.js с https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js найден:
"C:\Program Files\nodejs\node.exe" --version
echo.

echo Добавление Node.js в PATH...
set "PATH=%PATH%;C:\Program Files\nodejs"

echo Запуск проекта...
echo.
echo ====================================
echo   Сервер запускается...
echo   Откроется страница входа:
echo   http://localhost:3006/#/auth/login
echo.
echo   Для остановки нажмите Ctrl+C
echo ====================================
echo.

npm run dev

pause
