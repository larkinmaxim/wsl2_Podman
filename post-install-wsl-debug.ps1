# post-install-wsl-debug.ps1
# DEBUG VERSION - Script to configure WSL after restart

Write-Host "=== DEBUG: Script Starting ===" -ForegroundColor Magenta

# Try to catch ALL errors from the very beginning
try {
    Write-Host "DEBUG: Checking if running as Administrator..." -ForegroundColor Magenta
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $isAdmin) {
        Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
        Write-Host "Please right-click and 'Run as Administrator'" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "DEBUG: Administrator check passed" -ForegroundColor Green

    # Better pause function that's more compatible
    function Wait-ForUser {
        param([int]$ExitCode = 0)
        Write-Host ""
        Write-Host "Press Enter to continue..." -ForegroundColor Gray
        Read-Host
        exit $ExitCode
    }

    Write-Host "DEBUG: Function defined successfully" -ForegroundColor Green
    Write-Host "=== WSL Post-Installation Configuration ===" -ForegroundColor Cyan
    Write-Host ""

    # Check if WSL is installed
    Write-Host "DEBUG: About to check WSL installation..." -ForegroundColor Magenta
    Write-Host "Checking WSL installation..." -ForegroundColor Yellow
    
    try {
        Write-Host "DEBUG: Running wsl --version..." -ForegroundColor Magenta
        $wslOutput = wsl --version 2>&1
        Write-Host "DEBUG: WSL command completed with exit code: $LASTEXITCODE" -ForegroundColor Magenta
        
        if ($LASTEXITCODE -ne 0) {
            throw "WSL not found - Exit code: $LASTEXITCODE"
        }
        Write-Host "WSL is installed!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "ERROR: WSL is not installed or not accessible." -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please ensure you have restarted your computer after running the installation script." -ForegroundColor Yellow
        Wait-ForUser 1
    }

    # Display WSL version information
    Write-Host "DEBUG: About to display WSL version..." -ForegroundColor Magenta
    Write-Host "WSL Version Information:" -ForegroundColor Cyan
    wsl --version
    Write-Host ""

    # Set WSL 2 as default version
    Write-Host "DEBUG: About to set WSL 2 as default..." -ForegroundColor Magenta
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
    Write-Host "DEBUG: About to check distributions..." -ForegroundColor Magenta
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
    Write-Host "DEBUG: About to update WSL..." -ForegroundColor Magenta
    Write-Host "Updating WSL to latest version..." -ForegroundColor Yellow
    wsl --update

    Write-Host ""
    Write-Host "=== Configuration Complete ===" -ForegroundColor Green
    Write-Host ""
    Wait-ForUser 0

} catch {
    Write-Host ""
    Write-Host "CRITICAL ERROR CAUGHT:" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Command: $($_.InvocationInfo.Line)" -ForegroundColor Red
    Write-Host ""
    Write-Host "This debug information will help identify the issue." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}
