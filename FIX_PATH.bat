@echo off
chcp 65001 >nul
cls

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                                                              ║
echo ║       ИСПРАВЛЕНИЕ PATH ДЛЯ NODE.JS И NPM                    ║
echo ║                                                              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo [INFO] Проверка прав администратора...
echo.

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Запущено с правами администратора
) else (
    echo [WARNING] Скрипт запущен БЕЗ прав администратора
    echo [INFO] Будет выполнено добавление в PATH только для текущего пользователя
    echo.
    pause
)

echo.
echo [1/3] Проверка наличия Node.js...

set "NODEJS_PATH=C:\Program Files\nodejs"

if exist "%NODEJS_PATH%\node.exe" (
    echo [OK] Node.js найден: %NODEJS_PATH%
    echo.

    :: Показываем текущую версию
    "%NODEJS_PATH%\node.exe" --version
    "%NODEJS_PATH%\npm.cmd" --version
    echo.
) else (
    echo [ERROR] Node.js не найден в %NODEJS_PATH%
    echo [INFO] Установите Node.js с https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [2/3] Добавление Node.js в PATH пользователя...
echo.

:: Получаем текущий PATH пользователя
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"

:: Проверяем, есть ли уже Node.js в PATH
echo %USER_PATH% | findstr /i /c:"nodejs" >nul
if %errorlevel% == 0 (
    echo [OK] Node.js уже есть в PATH
) else (
    echo [INFO] Добавление Node.js в PATH...

    :: Добавляем Node.js в PATH пользователя
    setx PATH "%USER_PATH%;%NODEJS_PATH%" >nul 2>&1

    if %errorlevel% == 0 (
        echo [OK] Node.js добавлен в PATH пользователя
    ) else (
        echo [ERROR] Ошибка при добавлении в PATH
        pause
        exit /b 1
    )
)

echo.
echo [3/3] Применение изменений...
echo.

:: Обновляем PATH для текущей сессии
set "PATH=%PATH%;%NODEJS_PATH%"

echo [OK] Изменения применены
echo.
echo ══════════════════════════════════════════════════════════════
echo.
echo ✓ ГОТОВО! Node.js и npm добавлены в PATH
echo.
echo ВАЖНО:
echo 1. Закройте ВСЕ окна PowerShell и командной строки
echo 2. Откройте НОВОЕ окно PowerShell
echo 3. Теперь команда "npm run dev" должна работать
echo.
echo Или просто используйте START_HERE.bat для запуска
echo.
echo ══════════════════════════════════════════════════════════════
echo.

pause
