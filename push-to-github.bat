@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Push to GitHub - Auto Script
echo ========================================
echo.

REM Check if Git is initialized
if not exist ".git" (
    echo [1/5] Initializing Git repository...
    git init
    git branch -M main
) else (
    echo [1/5] Git repository already initialized
)

REM Add all files
echo [2/5] Adding files...
git add .

REM Commit
echo [3/5] Committing changes...
git commit -m "Add GitHub Actions build workflow"

REM Ask for repository URL
echo.
echo [4/5] Please enter your GitHub repository URL
echo Example: https://github.com/username/HiddenAlbumToggle.git
echo.
set /p REPO_URL="Repository URL: "

if "%REPO_URL%"=="" (
    echo ERROR: Repository URL cannot be empty
    pause
    exit /b 1
)

REM Check if origin exists
git remote | findstr "origin" >nul 2>&1
if %errorlevel%==0 (
    echo Updating remote repository URL...
    git remote set-url origin "%REPO_URL%"
) else (
    echo Adding remote repository...
    git remote add origin "%REPO_URL%"
)

REM Push to GitHub
echo [5/5] Pushing to GitHub...
git push -u origin main

if %errorlevel%==0 (
    echo.
    echo ========================================
    echo   SUCCESS!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Visit your GitHub repository
    echo 2. Click 'Actions' tab
    echo 3. Wait for build to complete
    echo 4. Download .deb from 'Artifacts'
    echo.
) else (
    echo.
    echo ========================================
    echo   PUSH FAILED
    echo ========================================
    echo.
    echo Please check:
    echo - Your GitHub credentials
    echo - Repository URL is correct
    echo - You have push permission
    echo.
)

pause

