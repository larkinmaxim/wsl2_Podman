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

# Verify and configure Podman CLI
Write-Host "Locating and configuring Podman CLI..." -ForegroundColor Yellow

# First, try to see if podman is already in PATH
$podmanFound = $false
try {
    $podmanVersion = podman --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Podman CLI is already available: $podmanVersion" -ForegroundColor Green
        $podmanFound = $true
    }
} catch {
    # Continue to search for it
}

if (-not $podmanFound) {
    Write-Host "Podman CLI not found in PATH. Searching for installation..." -ForegroundColor Yellow
    
    # Common installation paths for Podman Desktop
    $searchPaths = @(
        "${env:ProgramFiles}\Podman Desktop\resources\bin",
        "${env:LOCALAPPDATA}\Programs\Podman Desktop\resources\bin",
        "${env:ProgramFiles(x86)}\Podman Desktop\resources\bin",
        "${env:APPDATA}\Podman Desktop\resources\bin",
        "${env:ProgramFiles}\RedHat\Podman\bin",
        "${env:ProgramFiles(x86)}\RedHat\Podman\bin"
    )
    
    $podmanExePath = $null
    foreach ($path in $searchPaths) {
        $testPath = Join-Path $path "podman.exe"
        Write-Host "  Checking: $testPath" -ForegroundColor Gray
        
        if (Test-Path $testPath) {
            Write-Host "  ✓ Found Podman at: $testPath" -ForegroundColor Green
            $podmanExePath = $testPath
            $podmanDir = $path
            break
        }
    }
    
    if ($podmanExePath) {
        # Add to PATH for this session
        Write-Host "Adding Podman to PATH for this session..." -ForegroundColor Yellow
        $env:PATH = "$podmanDir;$env:PATH"
        
        # Verify it works now
        try {
            $podmanVersion = & $podmanExePath --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Podman CLI is now available: $podmanVersion" -ForegroundColor Green
                $podmanFound = $true
                
                # Offer to add to system PATH permanently
                Write-Host ""
                Write-Host "Would you like to add Podman to your system PATH permanently? (Y/N)" -ForegroundColor Cyan
                $response = Read-Host
                if ($response -match '^[Yy]') {
                    try {
                        # Get current system PATH
                        $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
                        if ($currentPath -notlike "*$podmanDir*") {
                            $newPath = "$currentPath;$podmanDir"
                            [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
                            Write-Host "✓ Podman added to system PATH permanently!" -ForegroundColor Green
                            Write-Host "  New PowerShell sessions will have podman available automatically." -ForegroundColor Gray
                        } else {
                            Write-Host "✓ Podman is already in system PATH." -ForegroundColor Green
                        }
                    } catch {
                        Write-Host "⚠ Could not modify system PATH. You may need to add it manually:" -ForegroundColor Yellow
                        Write-Host "  Path to add: $podmanDir" -ForegroundColor White
                    }
                }
            }
        } catch {
            Write-Host "✗ Found Podman but it's not working properly." -ForegroundColor Red
        }
    }
    
    if (-not $podmanFound) {
        Write-Host ""
        Write-Host "✗ Could not locate Podman CLI installation." -ForegroundColor Red
        Write-Host ""
        Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
        Write-Host "1. Check if Podman Desktop is installed:" -ForegroundColor White
        Write-Host "   - Look for 'Podman Desktop' in Start Menu" -ForegroundColor Gray
        Write-Host "   - Check Programs and Features / Add or Remove Programs" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Try reinstalling Podman Desktop:" -ForegroundColor White
        Write-Host "   - Download from: https://podman-desktop.io/" -ForegroundColor Gray
        Write-Host "   - Or run: .\3-install-podman.ps1" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Manual installation check:" -ForegroundColor White
        foreach ($path in $searchPaths) {
            Write-Host "   - Check: $path" -ForegroundColor Gray
        }
        Write-Host ""
        Pause-BeforeExit 1
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
    Write-Host "   Installation Complete! ✓" -ForegroundColor Green
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
