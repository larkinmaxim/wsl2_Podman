# WSL2 & Podman Installation Scripts

A comprehensive set of PowerShell scripts to automate the installation and configuration of Windows Subsystem for Linux 2 (WSL2) and Podman on Windows systems.

## 📋 Overview

This repository contains three PowerShell scripts that provide a complete containerization setup on Windows:

1. **`install-wsl.ps1`** - Initial WSL installation and system configuration
2. **`post-install-wsl.ps1`** - Post-reboot configuration and WSL2 setup
3. **`install-podman.ps1`** - Podman Desktop and CLI installation with machine setup

## 🔧 System Requirements

### Minimum Requirements

- **Windows 10 version 2004** (Build 19041) or **Windows 11**
- **6 GB RAM minimum** (validated by script)
- **Administrator privileges** (required for all scripts)
- **CPU virtualization support** (Intel VT-x or AMD-V)
- **Hyper-V compatible processor**
- **Git** (for cloning repository - [Download here](https://git-scm.com/downloads))
- **Stable internet connection** (for downloads and installation)

### Supported Windows Versions

- Windows 10 Home, Pro, Enterprise, Education (version 2004+)
- Windows 11 (all editions)

## 📦 What's Included

### install-wsl.ps1

**Purpose**: Initial WSL installation and system preparation

**Features**:

- ✅ Existing WSL installation detection with user choice
- ✅ System RAM validation (minimum 6GB check)
- ✅ Windows Subsystem for Linux feature enablement
- ✅ Virtual Machine Platform feature enablement
- ✅ User-friendly progress indicators
- ✅ Automatic restart handling
- ✅ Comprehensive error checking

### post-install-wsl.ps1

**Purpose**: Post-reboot configuration and WSL2 setup

**Features**:

- ✅ WSL installation verification
- ✅ WSL2 default version configuration
- ✅ Installed distributions detection
- ✅ WSL kernel updates
- ✅ Helpful next-step guidance

### install-podman.ps1

**Purpose**: Complete Podman containerization platform installation

**Features**:

- ✅ WSL dependency validation
- ✅ Automatic latest Podman Desktop download from GitHub
- ✅ Silent installation with progress tracking
- ✅ Podman machine initialization and startup
- ✅ Container functionality verification with test run
- ✅ Comprehensive installation validation

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
   .\install-wsl.ps1
   ```

### Step 3: Restart Computer

**Restart your computer when prompted**

### Step 4: Complete Installation

1. **Open PowerShell as Administrator again** (see [Running PowerShell as Administrator](#-running-powershell-as-administrator) section)

   ```powershell
   cd C:\WSL-Scripts
   ```
2. **Run post-installation script**

   ```powershell
   .\post-install-wsl.ps1
   ```
3. **Run Podman installation script**

   ```powershell
   .\install-podman.ps1
   ```

**✅ Done! Your WSL2 and Podman environment is ready.**

## 🔐 Running PowerShell as Administrator

**IMPORTANT**: All installation scripts require Administrator privileges. Here's how to open PowerShell as Administrator:

### Method 2: Search Menu

1. **Press Windows key** and type `powershell`
2. **Right-click** on "Windows PowerShell" in search results
3. **Select "Run as Administrator"** (see image below)
4. **Click "Yes"** when prompted by UAC

![PowerShell Run as Administrator][powershell-admin-menu]
*Example: Right-click PowerShell and select "Run as Administrator"*

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

### install-wsl.ps1 Analysis

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

### post-install-wsl.ps1 Analysis

**✅ Strengths**:

- Thorough WSL installation verification
- Informative status reporting
- Helpful guidance for next steps
- Robust error handling
- Automatic WSL updates

### install-podman.ps1 Analysis

**✅ Strengths**:

- Smart WSL dependency checking before installation
- Dynamic download from official GitHub releases API
- Silent installation with comprehensive progress feedback
- Automatic machine initialization and startup
- Thorough verification including test container execution
- Excellent error handling with troubleshooting guidance
- Proper cleanup of temporary files

**⚠️ Considerations**:

- Requires stable internet connection for downloads
- Downloads and executes binary from internet (from official source)
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

---

**⚠️ Important Notes:**

- Always run scripts as Administrator
- Ensure system restart after initial installation
- Keep Windows and WSL updated for best performance
- Review script contents before execution for security

[powershell-admin-menu]: images/powershell-admin-menu.png
