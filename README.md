# WSL2 & Podman Installation Scripts

A comprehensive set of PowerShell scripts to automate the installation and configuration of Windows Subsystem for Linux 2 (WSL2) and Podman on Windows systems.

## 📋 Overview

This repository contains four PowerShell scripts that provide a complete containerization setup on Windows:

1. **`1-install-wsl.ps1`** - Initial WSL installation and system configuration
2. **`2-post-install-wsl.ps1`** - Post-reboot configuration and WSL2 setup
3. **`3-install-podman.ps1`** - Podman Desktop installation
4. **`4-post-install-podman.ps1`** - Podman machine setup and verification

## 🔧 System Requirements

### Minimum Requirements

- **Windows 10 version 2004** (Build 19041) or **Windows 11**
- **6 GB RAM minimum** (validated by script)

## 🚀 Quick Start Guide

### Step 1: Create Folder and Clone Repository

1. **Create a folder for scripts**

   - Open **File Explorer** (Windows key + E)
   - Navigate to your desired location (e.g., C:\ drive or Desktop)
   - **Right-click** in empty space
   - Select **New** → **Folder**
   - Name the folder `WSL-Scripts`
   - **Double-click** the folder to open it
2. **Open terminal in this folder and clone repository**

   - **Right-click** inside the `WSL-Scripts` folder
   - Select **"Open in Terminal"** or **"Open PowerShell window here"**
   - Run the git clone command:

   ```powershell
   git -c http.sslVerify=false clone https://github.com/larkinmaxim/wsl2_Podman.git .
   ```

### Step 2: Run WSL Installation

1. **Open PowerShell as Administrator** (see [Running PowerShell as Administrator](#-running-powershell-as-administrator) section below)
2. **Navigate to scripts folder**

   ```powershell
   cd C:\WSL-Scripts
   ```
3. **Run WSL installation script**

   ```powershell
   .\1-install-wsl.ps1
   ```

### Step 3: Restart Computer

**Restart your computer when prompted**

### Step 4: Complete WSL Setup

1. **Open PowerShell as Administrator again** (see [Running PowerShell as Administrator](#-running-powershell-as-administrator) section)

   ```powershell
   cd C:\WSL-Scripts
   ```
2. **Run post-installation script**

   ```powershell
   .\2-post-install-wsl.ps1
   ```

### Step 5: Install Podman Desktop

3. **Run Podman Desktop installation script**

   ```powershell
   .\3-install-podman.ps1
   ```

### Step 6: Complete Podman Setup

4. **Close PowerShell and open a NEW PowerShell window as Administrator**
5. **Navigate to scripts folder and run final setup**

   ```powershell
   cd C:\WSL-Scripts
   .\4-post-install-podman.ps1
   ```

**✅ Done! Your WSL2 and Podman environment is ready.**

## 🔐 Running PowerShell as Administrator

**IMPORTANT**: All installation scripts require Administrator privileges. Here's how to open PowerShell as Administrator:

### Search Menu (Recommended)

1. **Press Windows key** and type `powershell`
2. **Right-click** on "Windows PowerShell" in search results
3. **Select "Run as Administrator"** (see image below)
4. **Click "Yes"** when prompted by UAC

![PowerShell Run as Administrator][powershell-admin-menu]

### 💡 **PowerShell Pro Tips**

#### **Navigate to Your Scripts Folder**
Once PowerShell terminal opens, you need to change directory to where your installation scripts are located:
```powershell
cd C:\WSL-Scripts
```

#### **Tab Completion (Auto-Complete)**
PowerShell has smart auto-completion! Type the first few characters of a filename and press **TAB** to auto-complete:
- Type `1` + **TAB** → PowerShell completes to `1-install-wsl.ps1`
- Type `3-i` + **TAB** → PowerShell completes to `3-install-podman.ps1`
- Press **TAB** multiple times to cycle through matching files

#### **Command History Navigation**
PowerShell remembers your previous commands:
- Press **↑ (Up Arrow)** to recall the last command
- Keep pressing **↑** to browse through command history
- Press **↓ (Down Arrow)** to go forward in history
- Press **Enter** to execute the selected command

#### **Quick Script Execution**
```powershell
# Navigate to folder
cd C:\WSL-Scripts

# Run scripts in order (use Tab completion!)
.\1-install-wsl.ps1
# (Restart computer, then continue)
.\2-post-install-wsl.ps1
.\3-install-podman.ps1
# (Close PowerShell, open new one)
.\4-post-install-podman.ps1
```

## 📖 Detailed Usage Instructions

### Script Execution Policies

If you encounter execution policy errors, temporarily allow script execution:

```powershell
# Check current policy
Get-ExecutionPolicy

# Temporarily allow local scripts (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# After installation, restore original policy
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
```

## 🛠️ Script Analysis & Validation

### 1-install-wsl.ps1 Analysis

**✅ Strengths**:

- Detects existing WSL installations and provides user choice
- Comprehensive system checks before installation
- Proper error handling with meaningful messages
- User-friendly colored output
- Safe restart handling with confirmation
- Follows PowerShell best practices

**⚠️ Considerations**:

- RAM requirement (6GB) might be restrictive for some users
- No CPU virtualization capability check

### 2-post-install-wsl.ps1 Analysis

**✅ Strengths**:

- Thorough WSL installation verification
- Informative status reporting
- Helpful guidance for next steps
- Robust error handling
- Automatic WSL updates

### 3-install-podman.ps1 Analysis

**✅ Strengths**:

- Smart WSL dependency checking before installation
- Dynamic download from official GitHub releases API
- Silent installation with comprehensive progress feedback
- Proper cleanup of temporary files
- Clear guidance for next steps requiring fresh PowerShell session

**⚠️ Considerations**:

- Requires stable internet connection for downloads
- Downloads and executes binary from internet (from official source)
- Requires fresh PowerShell session for CLI access

### 4-post-install-podman.ps1 Analysis

**✅ Strengths**:

- Verifies Podman CLI availability in fresh session
- Automatic machine initialization and startup
- Thorough verification including test container execution
- Excellent error handling with troubleshooting guidance
- Clear success/failure reporting

**⚠️ Considerations**:

- Must be run in fresh PowerShell session after Podman Desktop installation
- Podman machine startup can take several minutes on first run

## 🐛 Troubleshooting

### WSL Detection Behavior

#### WSL Already Installed

**Scenario**: The installation script detects an existing WSL installation
**Behavior**:

- Script displays current WSL version information
- Prompts user with "Do you want to continue anyway? (Y/N)"
- **Y/Yes**: Continues with installation (useful for repairs, updates, or feature re-enablement)
- **N/No**: Safely exits without making changes

**When to Continue**:

- WSL features are partially installed or corrupted
- You want to ensure all required Windows features are properly enabled
- Performing maintenance or troubleshooting existing WSL installation

**When to Cancel**:

- WSL is working perfectly and no changes are needed
- You ran the script by mistake

### Common Issues

#### Administrator Permission Errors

**Problem**: Script fails with Administrator requirement messages
**Examples**:

```
The script cannot be run because it contains a "#requires" statement for running as Administrator
```

```
ERROR: This script must be run as Administrator!
```

**Solution**: See the complete [Running PowerShell as Administrator](#-running-powershell-as-administrator) section above for detailed instructions with visual guides.

#### "git is not recognized" Error

**Problem**: Git is not installed or not in PATH
**Solutions**:

1. **Install Git**: Download from [git-scm.com](https://git-scm.com/downloads)
2. **Restart PowerShell** after Git installation
3. **Alternative**: Download ZIP directly from [GitHub repository](https://github.com/larkinmaxim/wsl2_Podman/archive/refs/heads/master.zip) and extract

#### "Script cannot be loaded" Error

**Problem**: PowerShell execution policy blocks script
**Solution**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### "Insufficient RAM" Error

**Problem**: System has less than 6GB RAM
**Solution**:

- 💡 It's the right moment to request a new computer! 😄
- (Or you could try closing some memory-intensive applications, but where's the fun in that?)

## 🛠️ Quick Fix for Common WSL Errors

If you encounter errors like "WSL is not installed or not accessible" or Windows prompts to install WSL when running scripts:

### Most Likely Causes:

1. **Wrong Script Order** (Most Common)

   - Running `2-post-install-wsl.ps1` without running `1-install-wsl.ps1` first
   - **Solution**: Always follow the correct order: `1-install-wsl.ps1` → Restart → `2-post-install-wsl.ps1` → `3-install-podman.ps1` → `4-post-install-podman.ps1`
2. **Missing Restart**

   - Ran `1-install-wsl.ps1` but didn't restart the computer
   - **Solution**: Restart the computer and then run `2-post-install-wsl.ps1`
3. **Administrator Privileges**

   - Scripts not running with Administrator privileges
   - **Solution**: Right-click PowerShell → "Run as Administrator"

### Diagnostic Steps:

1. **Check if WSL features are enabled:**

   ```powershell
   Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
   ```
2. **If features show "Disabled":**

   - Run `.\1-install-wsl.ps1` as Administrator
   - Restart when prompted
3. **If features show "Enabled" but WSL still doesn't work:**

   - Restart the computer
   - Then run `.\2-post-install-wsl.ps1`

---

**⚠️ Important Notes:**

- Always run scripts as Administrator
- Ensure system restart after initial installation
- Keep Windows and WSL updated for best performance
- Review script contents before execution for security

[powershell-admin-menu]: images/powershell-admin-menu.png
