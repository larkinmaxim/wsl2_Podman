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

# Step 2.5: Install Standalone Podman CLI
Write-Host "Step 2.5: Installing Standalone Podman CLI..." -ForegroundColor Cyan

# Download and install standalone Podman CLI
$cliApiUrl = "https://api.github.com/repos/containers/podman/releases/latest"
Write-Host "Fetching latest Podman CLI release information..." -ForegroundColor Yellow

try {
    $cliResponse = Invoke-RestMethod -Uri $cliApiUrl -ErrorAction Stop
    $cliVersion = $cliResponse.tag_name.TrimStart('v')
    Write-Host "Latest Podman CLI version: $cliVersion" -ForegroundColor Green

    # Look for Windows installer
    $windowsAsset = $cliResponse.assets | Where-Object { $_.name -like "*setup*.exe" -or $_.name -like "*windows*.zip" -or $_.name -like "*win*.zip" }
    
    if ($windowsAsset) {
        $cliDownloadUrl = $windowsAsset[0].browser_download_url
        $cliFileName = $windowsAsset[0].name
        $cliDownloadPath = Join-Path $env:TEMP $cliFileName
        
        Write-Host "Downloading: $cliFileName" -ForegroundColor Yellow
        Write-Host "From: $cliDownloadUrl" -ForegroundColor Gray
        
        # Download with suppressed progress (same UX as Desktop)
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $cliDownloadPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        Write-Host "Download complete!" -ForegroundColor Green
        
        # Install based on file type
        if ($cliFileName -like "*.exe") {
            Write-Host "Installing Podman CLI (EXE)..." -ForegroundColor Yellow
            
            try {
                # Start the installer with a timeout to prevent hanging
                $cliInstall = Start-Process -FilePath $cliDownloadPath -ArgumentList "/S" -PassThru
                
                # Wait for installation with timeout (max 2 minutes)
                $timeout = 120 # seconds
                $timer = 0
                Write-Host "  Waiting for installation to complete..." -ForegroundColor Yellow
                
                while (!$cliInstall.HasExited -and $timer -lt $timeout) {
                    Start-Sleep -Seconds 5
                    $timer += 5
                    if (($timer % 20) -eq 0) {
                        Write-Host "  Still installing... ($timer/$timeout seconds)" -ForegroundColor Gray
                    }
                }
                
                if ($cliInstall.HasExited) {
                    if ($cliInstall.ExitCode -eq 0) {
                        Write-Host "+ Podman CLI installed successfully!" -ForegroundColor Green
                    } else {
                        Write-Host "! CLI installation completed with exit code: $($cliInstall.ExitCode)" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "! Installation timeout reached - continuing (installer may still be running)" -ForegroundColor Yellow
                    # Don't kill the process, just continue
                }
            } catch {
                Write-Host "! Error during CLI installation: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } elseif ($cliFileName -like "*.zip") {
            Write-Host "Extracting Podman CLI (ZIP)..." -ForegroundColor Yellow
            $extractPath = "${env:ProgramFiles}\Podman"
            if (!(Test-Path $extractPath)) {
                New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
            }
            Expand-Archive -Path $cliDownloadPath -DestinationPath $extractPath -Force
            Write-Host "+ Podman CLI extracted to: $extractPath" -ForegroundColor Green
        }
        
        # Clean up CLI installer
        Remove-Item -Path $cliDownloadPath -Force -ErrorAction SilentlyContinue
        
    } else {
        Write-Host "! No Windows installer found for Podman CLI" -ForegroundColor Yellow
        Write-Host "  Will attempt to use CLI from Podman Desktop installation" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "! Could not download standalone CLI: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Will attempt to use CLI from Podman Desktop installation" -ForegroundColor Gray
}

Write-Host ""

# Step 3: Configure Podman CLI PATH
Write-Host "Step 3: Configuring Podman CLI PATH..." -ForegroundColor Cyan

# Common installation paths for Podman CLI and Desktop
$searchPaths = @(
    "${env:ProgramFiles}\RedHat\Podman",
    "${env:ProgramFiles}\Podman",
    "${env:ProgramFiles}\Podman Desktop\resources\bin",
    "${env:LOCALAPPDATA}\Programs\Podman Desktop\resources\bin",
    "${env:ProgramFiles(x86)}\Podman Desktop\resources\bin",
    "${env:APPDATA}\Podman Desktop\resources\bin"
)

$podmanFound = $false
$podmanDir = $null

Write-Host "Searching for Podman CLI installation..." -ForegroundColor Yellow
foreach ($path in $searchPaths) {
    $testPath = Join-Path $path "podman.exe"
    Write-Host "  Checking: $testPath" -ForegroundColor Gray
    
    if (Test-Path $testPath) {
        Write-Host "  + Found Podman at: $testPath" -ForegroundColor Green
        $podmanDir = $path
        $podmanFound = $true
        break
    }
}

if ($podmanFound) {
    Write-Host "Adding Podman to system PATH..." -ForegroundColor Yellow
    
    try {
        # Get current system PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        
        if ($currentPath -notlike "*$podmanDir*") {
            # Add Podman directory to system PATH
            $newPath = "$currentPath;$podmanDir"
            [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-Host "+ Podman added to system PATH successfully!" -ForegroundColor Green
            
            # Also add to current session PATH for immediate availability
            $env:PATH = "$podmanDir;$env:PATH"
            
            # Verify it works
            Start-Sleep -Seconds 2
            try {
                $podmanVersion = podman --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "+ Podman CLI is now available: $podmanVersion" -ForegroundColor Green
                } else {
                    Write-Host "! Podman added to PATH but may need PowerShell restart to be fully available" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "! Podman added to PATH but may need PowerShell restart to be fully available" -ForegroundColor Yellow
            }
        } else {
            Write-Host "+ Podman is already in system PATH" -ForegroundColor Green
        }
    } catch {
        Write-Host "! Could not modify system PATH automatically" -ForegroundColor Yellow
        Write-Host "  You may need to add this path manually: $podmanDir" -ForegroundColor Gray
        Write-Host "  Or run the next script which will handle it automatically" -ForegroundColor Gray
    }
} else {
    Write-Host "! Could not locate Podman CLI after installation" -ForegroundColor Yellow
    Write-Host "  This will be handled by the next script (4-post-install-podman.ps1)" -ForegroundColor Gray
}

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
if ($podmanFound) {
    Write-Host "Note: Podman has been added to your system PATH." -ForegroundColor Green
    Write-Host "The next script will initialize and test your Podman installation." -ForegroundColor Gray
} else {
    Write-Host "The next script will locate Podman and complete the setup." -ForegroundColor Gray
}
Write-Host ""
Write-Host "Installation log saved to: $env:TEMP\podman-install.log" -ForegroundColor Gray
Pause-BeforeExit 0