# post-install-podman.ps1
# Script to initialize and configure Podman machine after Podman Desktop installation

#Requires -RunAsAdministrator

# Function to pause before exit to prevent window from closing
function Pause-BeforeExit {
    param([int]$ExitCode = 0)
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $ExitCode
}

Write-Host "=== Podman Post-Installation Configuration ===" -ForegroundColor Cyan
Write-Host ""

# Verify Podman CLI is available
Write-Host "Verifying Podman CLI availability..." -ForegroundColor Yellow

$podmanFound = $false
try {
    $podmanVersion = podman --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "+ Podman CLI is available: $podmanVersion" -ForegroundColor Green
        $podmanFound = $true
    }
} catch {
    # Podman not found in PATH
}

if (-not $podmanFound) {
    Write-Host "! Podman CLI not found in PATH. Attempting to locate..." -ForegroundColor Yellow
    
    # Quick search in common locations
    $searchPaths = @(
        "${env:ProgramFiles}\RedHat\Podman",
        "${env:ProgramFiles}\Podman Desktop\resources\bin",
        "${env:LOCALAPPDATA}\Programs\Podman Desktop\resources\bin",
        "${env:ProgramFiles(x86)}\Podman Desktop\resources\bin",
        "${env:APPDATA}\Podman Desktop\resources\bin"
    )
    
    $podmanExePath = $null
    foreach ($path in $searchPaths) {
        $testPath = Join-Path $path "podman.exe"
        if (Test-Path $testPath) {
            $podmanExePath = $testPath
            $env:PATH = "$path;$env:PATH"
            Write-Host "+ Found and added Podman to current session PATH" -ForegroundColor Green
            break
        }
    }
    
    if (-not $podmanExePath) {
        Write-Host "X Could not locate Podman CLI installation." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please ensure Podman Desktop is properly installed or run:" -ForegroundColor Yellow
        Write-Host "  .\3-install-podman.ps1" -ForegroundColor White
        Write-Host ""
        Pause-BeforeExit 1
    } else {
        $podmanFound = $true
    }
}
Write-Host ""

# Step 1: Initialize Podman machine
Write-Host "Step 1: Initializing Podman machine..." -ForegroundColor Cyan

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
    Pause-BeforeExit 1
}
Write-Host ""

# Step 2: Start Podman machine
Write-Host "Step 2: Starting Podman machine..." -ForegroundColor Cyan

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
    Pause-BeforeExit 1
}
Write-Host ""

# Step 3: Verify installation
Write-Host "Step 3: Verifying Podman installation..." -ForegroundColor Cyan
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
    Write-Host "   Installation Complete! +" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Podman is now ready to use!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Quick start commands:" -ForegroundColor Cyan
    Write-Host "  podman ps                 # List running containers" -ForegroundColor White
    Write-Host "  podman images             # List images" -ForegroundColor White
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
Pause-BeforeExit 0
