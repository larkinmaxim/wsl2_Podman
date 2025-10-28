# install-podman.ps1
# Script to install Podman Desktop and CLI on Windows

#Requires -RunAsAdministrator

# Function to pause before exit to prevent window from closing
function Pause-BeforeExit {
    param([int]$ExitCode = 0)
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $ExitCode
}

Write-Host "=== Podman Installation Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed and running
Write-Host "Checking WSL installation..." -ForegroundColor Yellow
try {
    wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not properly configured"
    }
    Write-Host "WSL is installed and configured!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: WSL is not installed or not properly configured." -ForegroundColor Red
    Write-Host "Please run the WSL installation scripts first." -ForegroundColor Yellow
    Pause-BeforeExit 1
}
Write-Host ""

# Step 1: Download Podman Desktop installer
Write-Host "Step 1: Downloading Podman Desktop..." -ForegroundColor Cyan
$downloadPath = "$env:TEMP\podman-desktop-setup.exe"

try {
    # Get the latest release URL from GitHub
    $latestReleaseUrl = "https://api.github.com/repos/podman-desktop/podman-desktop/releases/latest"
    Write-Host "Fetching latest release information..." -ForegroundColor Yellow
    $release = Invoke-RestMethod -Uri $latestReleaseUrl -Headers @{
        "User-Agent" = "PowerShell-PodmanInstaller"
    }
    
    # Find the Windows installer asset - look for setup.exe specifically
    $asset = $release.assets | Where-Object { 
        $_.name -match "^podman-desktop-.*-setup\.exe$" -and 
        $_.name -notmatch "airgap" 
    } | Select-Object -First 1
    
    if ($null -eq $asset) {
        Write-Host "Available assets:" -ForegroundColor Yellow
        $release.assets | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor Gray }
        throw "Could not find Windows installer (podman-desktop-*-setup.exe) in latest release"
    }
    
    Write-Host "Found: $($asset.name)" -ForegroundColor Green
    Write-Host "Version: $($release.tag_name)" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($asset.size / 1MB, 2)) MB" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Downloading from: $($asset.browser_download_url)" -ForegroundColor Gray
    
    # Download the installer with progress
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing
    $ProgressPreference = 'Continue'
    
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download Podman Desktop" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Pause-BeforeExit 1
}
Write-Host ""

# Step 2: Install Podman Desktop
Write-Host "Step 2: Installing Podman Desktop..." -ForegroundColor Cyan
Write-Host "Running silent installation..." -ForegroundColor Yellow

try {
    # Run the installer silently
    $installProcess = Start-Process -FilePath $downloadPath -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/LOG=`"$env:TEMP\podman-install.log`"" -Wait -PassThru
    
    if ($installProcess.ExitCode -eq 0) {
        Write-Host "Podman Desktop installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Installation may have issues. Exit code: $($installProcess.ExitCode)" -ForegroundColor Yellow
        Write-Host "Check log at: $env:TEMP\podman-install.log" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR: Failed to install Podman Desktop" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Check log at: $env:TEMP\podman-install.log" -ForegroundColor Yellow
    Pause-BeforeExit 1
}
Write-Host ""

# Clean up installer
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue

# Wait for installation to complete
Write-Host "Waiting for installation to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Podman Desktop Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Close this PowerShell window" -ForegroundColor White
Write-Host "2. Open a NEW PowerShell window as Administrator" -ForegroundColor White
Write-Host "3. Navigate to this folder and run:" -ForegroundColor White
Write-Host "   .\4-post-install-podman.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "This ensures Podman CLI is properly available in the new session." -ForegroundColor Gray
Write-Host ""
Write-Host "Installation log saved to: $env:TEMP\podman-install.log" -ForegroundColor Gray
Pause-BeforeExit 0