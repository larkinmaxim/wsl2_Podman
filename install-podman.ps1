# install-podman.ps1
# Script to install Podman Desktop and CLI on Windows

#Requires -RunAsAdministrator

Write-Host "=== Podman Installation Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed and running
Write-Host "Checking WSL installation..." -ForegroundColor Yellow
try {
    $wslCheck = wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not properly configured"
    }
    Write-Host "WSL is installed and configured!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: WSL is not installed or not properly configured." -ForegroundColor Red
    Write-Host "Please run the WSL installation scripts first." -ForegroundColor Yellow
    exit 1
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
    exit 1
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
    exit 1
}
Write-Host ""

# Clean up installer
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue

# Wait for installation to complete
Write-Host "Waiting for installation to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Step 3: Verify Podman CLI installation (Option 3 - Simplified)
Write-Host "Step 3: Verifying Podman CLI installation..." -ForegroundColor Cyan

$podmanFound = $false
for ($i = 1; $i -le 3; $i++) {
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + 
                [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if podman command exists
    if (Get-Command podman -ErrorAction SilentlyContinue) {
        $version = podman --version
        Write-Host "Podman CLI found: $version" -ForegroundColor Green
        $podmanFound = $true
        break
    }
    
    if ($i -lt 3) {
        Write-Host "Podman not found yet, waiting... ($i/3)" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

if (-not $podmanFound) {
    Write-Host "ERROR: Podman CLI not found after installation." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try the following:" -ForegroundColor Yellow
    Write-Host "  1. Close and reopen PowerShell as Administrator" -ForegroundColor White
    Write-Host "  2. Run: podman --version" -ForegroundColor White
    Write-Host "  3. If still not found, check if Podman is in:" -ForegroundColor White
    Write-Host "     C:\Program Files\RedHat\Podman" -ForegroundColor White
    Write-Host ""
    Write-Host "Then manually run the rest of the setup:" -ForegroundColor Yellow
    Write-Host "  podman machine init" -ForegroundColor White
    Write-Host "  podman machine start" -ForegroundColor White
    exit 1
}
Write-Host ""

# Step 4: Initialize Podman machine
Write-Host "Step 4: Initializing Podman machine..." -ForegroundColor Cyan

try {
    # Check if machine already exists
    $machineList = podman machine list --format json 2>$null
    
    if ($machineList -and $machineList.Trim() -ne "[]" -and $machineList.Trim() -ne "") {
        Write-Host "Podman machine already exists. Skipping initialization." -ForegroundColor Yellow
        $machineListObj = $machineList | ConvertFrom-Json
        Write-Host "Existing machine(s):" -ForegroundColor Yellow
        $machineListObj | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    } else {
        Write-Host "Creating Podman machine (this may take a few minutes)..." -ForegroundColor Yellow
        podman machine init
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Podman machine initialized successfully!" -ForegroundColor Green
        } else {
            throw "Failed to initialize Podman machine (exit code: $LASTEXITCODE)"
        }
    }
} catch {
    Write-Host "ERROR: Failed to initialize Podman machine" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manually:" -ForegroundColor Yellow
    Write-Host "  podman machine init" -ForegroundColor White
    exit 1
}
Write-Host ""

# Step 5: Start Podman machine
Write-Host "Step 5: Starting Podman machine..." -ForegroundColor Cyan

try {
    # Check if machine is already running
    $machineStatus = podman machine list --format json 2>$null | ConvertFrom-Json
    $runningMachine = $machineStatus | Where-Object { $_.Running -eq $true }
    
    if ($runningMachine) {
        Write-Host "Podman machine '$($runningMachine.Name)' is already running." -ForegroundColor Green
    } else {
        Write-Host "Starting machine (this may take a minute)..." -ForegroundColor Yellow
        podman machine start
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Podman machine started successfully!" -ForegroundColor Green
        } else {
            throw "Failed to start Podman machine (exit code: $LASTEXITCODE)"
        }
    }
} catch {
    Write-Host "ERROR: Failed to start Podman machine" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manually:" -ForegroundColor Yellow
    Write-Host "  podman machine start" -ForegroundColor White
    exit 1
}
Write-Host ""

# Step 6: Verify installation
Write-Host "Step 6: Verifying Podman installation..." -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Podman Version ===" -ForegroundColor Yellow
podman --version
Write-Host ""

Write-Host "=== Podman Machine Status ===" -ForegroundColor Yellow
podman machine list
Write-Host ""

Write-Host "=== Podman System Information ===" -ForegroundColor Yellow
podman info
Write-Host ""

# Test with hello-world
Write-Host "=== Running Test Container ===" -ForegroundColor Yellow
Write-Host "Testing with hello-world container..." -ForegroundColor Yellow
podman run hello-world

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Installation Complete! ✓" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Podman is now ready to use!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Quick start commands:" -ForegroundColor Cyan
    Write-Host "  podman ps                 # List running containers" -ForegroundColor White
    Write-Host "  podman images             # List images" -ForegroundColor White
    Write-Host "  podman run -it ubuntu     # Run Ubuntu container" -ForegroundColor White
    Write-Host "  podman machine stop       # Stop Podman machine" -ForegroundColor White
    Write-Host "  podman machine start      # Start Podman machine" -ForegroundColor White
    Write-Host ""
    Write-Host "Podman Desktop GUI is also installed." -ForegroundColor Cyan
    Write-Host "Find it in your Start Menu as 'Podman Desktop'" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "   Installation Complete with Warnings" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Podman is installed but the test container failed." -ForegroundColor Yellow
    Write-Host "This might be normal on first run." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try running: podman run hello-world" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "If issues persist, try:" -ForegroundColor Yellow
    Write-Host "  podman machine stop" -ForegroundColor White
    Write-Host "  podman machine start" -ForegroundColor White
}

Write-Host ""
Write-Host "Installation log saved to: $env:TEMP\podman-install.log" -ForegroundColor Gray