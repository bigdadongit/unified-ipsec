# Windows Installer for Unified IPsec
# Installs and configures the unified IPsec solution on Windows systems

param(
    [switch]$NoScheduledTask
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Unified IPsec - Windows Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "ERROR: This installer must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Running as Administrator" -ForegroundColor Green

# Determine installation directory
$InstallDir = "C:\Program Files\UnifiedIPsec"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "Installation directory: $InstallDir"
Write-Host "Source directory: $ProjectRoot"
Write-Host ""

# Check dependencies
Write-Host "Checking dependencies..."

# Check Python
$PythonCmd = $null
$PythonCandidates = @("python", "python3", "py")
foreach ($cmd in $PythonCandidates) {
    try {
        $version = & $cmd --version 2>&1
        if ($version -match "Python 3") {
            $PythonCmd = $cmd
            Write-Host "✓ Python 3 found: $version" -ForegroundColor Green
            break
        }
    } catch {
        continue
    }
}

if (-not $PythonCmd) {
    Write-Host "✗ Python 3 not found" -ForegroundColor Red
    Write-Host "Please install Python 3 from https://www.python.org/" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

# Check PyYAML
Write-Host "Checking for PyYAML..."
try {
    & $PythonCmd -c "import yaml" 2>$null
    Write-Host "✓ PyYAML installed" -ForegroundColor Green
} catch {
    Write-Host "⚠ PyYAML not found, installing..." -ForegroundColor Yellow
    & $PythonCmd -m pip install pyyaml
    Write-Host "✓ PyYAML installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Creating installation directory..."

# Create installation directory
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallDir\logs" -Force | Out-Null

# Copy files
Write-Host "Copying files..."
Copy-Item -Path "$ProjectRoot\controller" -Destination $InstallDir -Recurse -Force
Copy-Item -Path "$ProjectRoot\adapters" -Destination $InstallDir -Recurse -Force
if (Test-Path "$ProjectRoot\logs") {
    Copy-Item -Path "$ProjectRoot\logs" -Destination $InstallDir -Recurse -Force
}

Write-Host "✓ Files copied to $InstallDir" -ForegroundColor Green

# Create wrapper script for easy execution
$WrapperScript = @"
@echo off
REM Unified IPsec Launcher
$PythonCmd "$InstallDir\controller\policy_engine.py" %*
"@

$WrapperPath = "$InstallDir\unified-ipsec.bat"
Set-Content -Path $WrapperPath -Value $WrapperScript
Write-Host "✓ Launcher script created" -ForegroundColor Green

# Add to PATH
Write-Host ""
Write-Host "Adding to system PATH..."
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($CurrentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$InstallDir", "Machine")
    Write-Host "✓ Added to PATH (restart terminal to use 'unified-ipsec.bat')" -ForegroundColor Green
} else {
    Write-Host "✓ Already in PATH" -ForegroundColor Green
}

# Create scheduled task for auto-start
if (-not $NoScheduledTask) {
    Write-Host ""
    $CreateTask = Read-Host "Do you want to create a scheduled task for auto-start? (Y/N)"
    if ($CreateTask -eq "Y" -or $CreateTask -eq "y") {
        Write-Host "Creating scheduled task..."
        
        $TaskName = "UnifiedIPsec"
        $TaskDescription = "Unified IPsec Policy Engine - Automatically configures IPsec on boot"
        $TaskAction = New-ScheduledTaskAction -Execute $PythonCmd -Argument "`"$InstallDir\controller\policy_engine.py`""
        $TaskTrigger = New-ScheduledTaskTrigger -AtStartup
        $TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        
        # Remove existing task if it exists
        $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($ExistingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }
        
        # Register task
        Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskSettings | Out-Null
        
        Write-Host "✓ Scheduled task created" -ForegroundColor Green
    } else {
        Write-Host "⚠ Scheduled task not created" -ForegroundColor Yellow
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Edit policy: $InstallDir\controller\policy.yaml"
Write-Host "2. Run manually: $InstallDir\unified-ipsec.bat"
Write-Host "3. Or run: unified-ipsec.bat (after restarting terminal)"
Write-Host "4. View logs: $InstallDir\logs\ipsec.log"
Write-Host ""
Write-Host "Scheduled Task commands:"
Write-Host "  Start:   Start-ScheduledTask -TaskName 'UnifiedIPsec'"
Write-Host "  Stop:    Stop-ScheduledTask -TaskName 'UnifiedIPsec'"
Write-Host "  Status:  Get-ScheduledTask -TaskName 'UnifiedIPsec' | Get-ScheduledTaskInfo"
Write-Host "  Remove:  Unregister-ScheduledTask -TaskName 'UnifiedIPsec'"
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
