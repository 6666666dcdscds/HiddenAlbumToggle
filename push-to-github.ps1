# GitHub Push Script
# PowerShell version

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Push to GitHub - Auto Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "[1/5] Initializing Git repository..." -ForegroundColor Yellow
    git init
    git branch -M main
} else {
    Write-Host "[1/5] Git repository already initialized" -ForegroundColor Green
}

# Add all files
Write-Host "[2/5] Adding files..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "[3/5] Committing changes..." -ForegroundColor Yellow
git commit -m "Add GitHub Actions build workflow"

# Ask for repository URL
Write-Host ""
Write-Host "[4/5] Please enter your GitHub repository URL" -ForegroundColor Yellow
Write-Host "Example: https://github.com/username/HiddenAlbumToggle.git" -ForegroundColor Gray
Write-Host ""
$REPO_URL = Read-Host "Repository URL"

if ([string]::IsNullOrWhiteSpace($REPO_URL)) {
    Write-Host "ERROR: Repository URL cannot be empty" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if origin exists
$remotes = git remote
if ($remotes -contains "origin") {
    Write-Host "Updating remote repository URL..." -ForegroundColor Yellow
    git remote set-url origin $REPO_URL
} else {
    Write-Host "Adding remote repository..." -ForegroundColor Yellow
    git remote add origin $REPO_URL
}

# Push to GitHub
Write-Host "[5/5] Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Visit your GitHub repository" -ForegroundColor White
    Write-Host "2. Click 'Actions' tab" -ForegroundColor White
    Write-Host "3. Wait for build to complete" -ForegroundColor White
    Write-Host "4. Download .deb from 'Artifacts'" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  PUSH FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "- Your GitHub credentials" -ForegroundColor White
    Write-Host "- Repository URL is correct" -ForegroundColor White
    Write-Host "- You have push permission" -ForegroundColor White
    Write-Host ""
}

Read-Host "Press Enter to exit"

