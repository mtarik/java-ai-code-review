@echo off
REM ════════════════════════════════════════════════════════════════════════════
REM 🚀 Script de Déploiement Automatique - Windows
REM Déploie le workflow de revue de code sur tous vos repositories Java
REM ════════════════════════════════════════════════════════════════════════════

echo.
echo ════════════════════════════════════════════════════════════════
echo 🤖 Déploiement Automatique - Revue de Code IA
echo ════════════════════════════════════════════════════════════════
echo.

REM Vérifier que gh CLI est installé
where gh >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ GitHub CLI ^(gh^) n'est pas installé
    echo Installez-le: winget install GitHub.cli
    pause
    exit /b 1
)

echo ✅ GitHub CLI configuré
echo.

REM Exécuter le script bash via Git Bash
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" -c "./deploy-to-all-repos.sh"
) else (
    echo ❌ Git Bash non trouvé. Installez Git for Windows.
    pause
    exit /b 1
)

pause
