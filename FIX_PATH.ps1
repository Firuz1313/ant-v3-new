# Установка кодировки UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║       ИСПРАВЛЕНИЕ PATH ДЛЯ NODE.JS И NPM                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "[INFO] Проверка прав администратора..." -ForegroundColor Yellow
Write-Host ""

if ($isAdmin) {
    Write-Host "[OK] Запущено с правами администратора" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Скрипт запущен БЕЗ прав администратора" -ForegroundColor Yellow
    Write-Host "[INFO] Будет выполнено добавление в PATH только для текущего пользователя" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Нажмите Enter для продолжения"
}

Write-Host ""
Write-Host "[1/3] Проверка наличия Node.js..." -ForegroundColor Yellow

$nodejsPath = "C:\Program Files\nodejs"

if (Test-Path "$nodejsPath\node.exe") {
    Write-Host "[OK] Node.js найден: $nodejsPath" -ForegroundColor Green
    Write-Host ""

    # Показываем текущую версию
    $nodeVersion = & "$nodejsPath\node.exe" --version 2>&1
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Cyan

    if (Test-Path "$nodejsPath\npm.cmd") {
        $npmVersion = & "$nodejsPath\npm.cmd" --version 2>&1
        Write-Host "npm: $npmVersion" -ForegroundColor Cyan
    }
    Write-Host ""
} else {
    Write-Host "[ERROR] Node.js не найден в $nodejsPath" -ForegroundColor Red
    Write-Host "[INFO] Установите Node.js с https://nodejs.org/" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

Write-Host "[2/3] Добавление Node.js в PATH пользователя..." -ForegroundColor Yellow
Write-Host ""

# Получаем текущий PATH пользователя
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

# Проверяем, есть ли уже Node.js в PATH
if ($userPath -like "*nodejs*") {
    Write-Host "[OK] Node.js уже есть в PATH" -ForegroundColor Green
} else {
    Write-Host "[INFO] Добавление Node.js в PATH..." -ForegroundColor Cyan

    try {
        # Добавляем Node.js в PATH пользователя
        $newPath = "$userPath;$nodejsPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)

        Write-Host "[OK] Node.js добавлен в PATH пользователя" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Ошибка при добавлении в PATH: $_" -ForegroundColor Red
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
}

Write-Host ""
Write-Host "[3/3] Применение изменений..." -ForegroundColor Yellow
Write-Host ""

# Обновляем PATH для текущей сессии
$env:Path = "$env:Path;$nodejsPath"

Write-Host "[OK] Изменения применены" -ForegroundColor Green
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ ГОТОВО! Node.js и npm добавлены в PATH" -ForegroundColor Green
Write-Host ""
Write-Host "ВАЖНО:" -ForegroundColor Yellow
Write-Host "1. Закройте ВСЕ окна PowerShell и командной строки" -ForegroundColor White
Write-Host "2. Откройте НОВОЕ окно PowerShell" -ForegroundColor White
Write-Host "3. Теперь команда 'npm run dev' должна работать" -ForegroundColor White
Write-Host ""
Write-Host "Или просто используйте START_HERE.bat для запуска" -ForegroundColor Cyan
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Тест в текущей сессии
Write-Host "Тест в текущей сессии:" -ForegroundColor Yellow
try {
    $testNode = & node --version 2>&1
    $testNpm = & npm --version 2>&1
    Write-Host "[OK] node: $testNode" -ForegroundColor Green
    Write-Host "[OK] npm: $testNpm" -ForegroundColor Green
} catch {
    Write-Host "[INFO] В текущей сессии еще не работает - откройте новое окно" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Нажмите Enter для выхода"
