# post-install-wsl.ps1
# Script to configure WSL after restart

#Requires -RunAsAdministrator

Write-Host "=== WSL Post-Installation Configuration ===" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed
Write-Host "Checking WSL installation..." -ForegroundColor Yellow
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not found"
    }
    Write-Host "WSL is installed!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: WSL is not installed or not accessible." -ForegroundColor Red
    Write-Host "Please ensure you have restarted your computer after running the installation script." -ForegroundColor Yellow
    exit 1
}

# Display WSL version information
Write-Host "WSL Version Information:" -ForegroundColor Cyan
wsl --version
Write-Host ""

# Set WSL 2 as default version
Write-Host "Setting WSL 2 as default version..." -ForegroundColor Yellow
wsl --set-default-version 2

if ($LASTEXITCODE -eq 0) {
    Write-Host "WSL 2 set as default successfully!" -ForegroundColor Green
} else {
    Write-Host "Warning: Could not set WSL 2 as default. You may need to update WSL kernel." -ForegroundColor Yellow
    Write-Host "Run: wsl --update" -ForegroundColor Cyan
}
Write-Host ""

# Check installed distributions
Write-Host "Checking installed Linux distributions..." -ForegroundColor Yellow
$distros = wsl --list --verbose

if ($distros) {
    Write-Host "Installed distributions:" -ForegroundColor Green
    wsl --list --verbose
} else {
    Write-Host "No Linux distributions installed yet." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install a distribution, run one of:" -ForegroundColor Cyan
    Write-Host "  wsl --install -d Ubuntu" -ForegroundColor White
    Write-Host "  wsl --install -d Debian" -ForegroundColor White
    Write-Host "  wsl --install -d kali-linux" -ForegroundColor White
    Write-Host ""
    Write-Host "To see all available distributions:" -ForegroundColor Cyan
    Write-Host "  wsl --list --online" -ForegroundColor White
}
Write-Host ""

# Update WSL (optional but recommended)
Write-Host "Updating WSL to latest version..." -ForegroundColor Yellow
wsl --update

Write-Host ""
Write-Host "=== Configuration Complete ===" -ForegroundColor Green
Write-Host ""