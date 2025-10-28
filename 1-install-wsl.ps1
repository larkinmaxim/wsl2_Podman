# install-wsl.ps1
# Script to install WSL with system checks

#Requires -RunAsAdministrator

# Function to pause before exit to prevent window from closing
function Pause-BeforeExit {
    param([int]$ExitCode = 0)
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $ExitCode
}

Write-Host "=== WSL Installation Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is already installed
Write-Host "Checking for existing WSL installation..." -ForegroundColor Yellow
try {
    wsl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WSL is already installed!" -ForegroundColor Green
        Write-Host "Current WSL version information:" -ForegroundColor Cyan
        wsl --version
        Write-Host ""
        
        $continue = Read-Host "WSL is already installed. Do you want to continue anyway? (Y/N)"
        if ($continue -ne 'Y' -and $continue -ne 'y') {
            Write-Host "Installation cancelled by user." -ForegroundColor Yellow
            Pause-BeforeExit 0
        }
        Write-Host "Continuing with installation..." -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "WSL not found. Proceeding with installation..." -ForegroundColor Green
    Write-Host ""
}

# Check system RAM (minimum 6 GB)
Write-Host "Checking system RAM..." -ForegroundColor Yellow
$totalRAM = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
$totalRAMGB = [math]::Round($totalRAM / 1GB, 2)

Write-Host "Total RAM: $totalRAMGB GB" -ForegroundColor Green

if ($totalRAMGB -lt 6) {
    Write-Host "ERROR: Insufficient RAM. At least 6 GB required. Found: $totalRAMGB GB" -ForegroundColor Red
    Pause-BeforeExit 1
}

Write-Host "RAM check passed!" -ForegroundColor Green
Write-Host ""

# Enable WSL feature
Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to enable WSL feature" -ForegroundColor Red
    Pause-BeforeExit 1
}

Write-Host "WSL feature enabled successfully!" -ForegroundColor Green
Write-Host ""

# Enable Virtual Machine Platform
Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to enable Virtual Machine Platform" -ForegroundColor Red
    Pause-BeforeExit 1
}

Write-Host "Virtual Machine Platform enabled successfully!" -ForegroundColor Green
Write-Host ""

# Set WSL 2 as default (optional, after restart)
Write-Host "Note: After restart, run 'wsl --set-default-version 2' to use WSL 2 by default" -ForegroundColor Cyan
Write-Host ""

# Prompt for restart
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host "A system restart is required to complete the installation." -ForegroundColor Yellow
Write-Host ""

$restart = Read-Host "Do you want to restart now? (Y/N)"
if ($restart -eq 'Y' -or $restart -eq 'y') {
    Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Please restart your computer manually to complete the installation." -ForegroundColor Yellow
    Pause-BeforeExit 0
}