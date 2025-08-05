# MongoDB Database Export Script for Windows PowerShell
# This script exports MongoDB database using mongodump with timestamp-based folder naming

param(
    [switch]$Help
)

# Function to display help
function Show-Help {
    Write-Host "MongoDB Database Export Script" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script exports MongoDB database using mongodump with timestamp-based folder naming."
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor Yellow
    Write-Host "1. MongoDB Database Tools must be installed"
    Write-Host "2. Environment variables must be set for MongoDB credentials"
    Write-Host ""
    Write-Host "Required Environment Variables:" -ForegroundColor Yellow
    Write-Host "  MONGODB_USERNAME - MongoDB username"
    Write-Host "  MONGODB_PASSWORD - MongoDB password"
    Write-Host "  MONGODB_HOST     - MongoDB host (default: 192.168.1.10)"
    Write-Host "  MONGODB_PORT     - MongoDB port (default: 27018)"
    Write-Host ""
    Write-Host "To set environment variables:" -ForegroundColor Green
    Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_USERNAME', 'db_username', 'User')"
    Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PASSWORD', 'db_password', 'User')"
    Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_HOST', 'db_ip', 'User')"
    Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PORT', 'db_port', 'User')"
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Green
    Write-Host "  .\dbexport.ps1"
    Write-Host "  .\dbexport.ps1 -Help"
}

# Function to write colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check if mongodump is available
function Test-MongoDump {
    try {
        $null = Get-Command mongodump -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "mongodump command not found!"
        Write-Info "Please install MongoDB Database Tools:"
        Write-Info "1. Download from: https://www.mongodb.com/try/download/database-tools"
        Write-Info "2. Or use chocolatey: choco install mongodb-database-tools"
        Write-Info "3. Or use winget: winget install MongoDB.DatabaseTools"
        Write-Info "4. Make sure the tools are added to your PATH environment variable"
        return $false
    }
}

# Function to get MongoDB credentials from environment variables
function Get-MongoDBCredentials {
    $username = [Environment]::GetEnvironmentVariable('MONGODB_USERNAME', 'User')
    $password = [Environment]::GetEnvironmentVariable('MONGODB_PASSWORD', 'User')
    $mongoHost = [Environment]::GetEnvironmentVariable('MONGODB_HOST', 'User')
    $mongoPort = [Environment]::GetEnvironmentVariable('MONGODB_PORT', 'User')

    # Set defaults if not provided
    if (-not $mongoHost) { $mongoHost = "192.168.1.10" }
    if (-not $mongoPort) { $mongoPort = "27018" }

    if (-not $username -or -not $password) {
        Write-Warning "MongoDB credentials not found in environment variables."
        Write-Info "Please set the following environment variables:"
        Write-Info "Run these commands in PowerShell as Administrator or current user:"
        Write-Info ""
        Write-Info "For current user:"
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_USERNAME', 'db_username', 'User')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PASSWORD', 'db_password', 'User')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_HOST', '192.168.1.10', 'User')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PORT', '27018', 'User')" -ForegroundColor Cyan
        Write-Info ""
        Write-Info "For system-wide (requires Administrator):"
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_USERNAME', 'db_username', 'Machine')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PASSWORD', 'db_password', 'Machine')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_HOST', '192.168.1.10', 'Machine')" -ForegroundColor Cyan
        Write-Host "  [Environment]::SetEnvironmentVariable('MONGODB_PORT', '27018', 'Machine')" -ForegroundColor Cyan
        Write-Info ""
        Write-Warning "After setting environment variables, restart PowerShell or your IDE."
        throw "Missing MongoDB credentials"
    }

    return @{
        Username = $username
        Password = $password
        Host = $mongoHost
        Port = $mongoPort
    }
}

# Function to create backup directory
function New-BackupDirectory {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupDirName = "dbbackup-$timestamp-qos-bigmenu"

    # Try to create in current directory first
    try {
        $currentDir = Get-Location
        $targetDir = Join-Path $currentDir $backupDirName
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Success "Created backup directory: $targetDir"
        return $targetDir
    }
    catch {
        Write-Warning "Cannot create directory in current location. Trying Desktop..."

        # Fallback to Desktop
        try {
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $targetDir = Join-Path $desktopPath $backupDirName
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-Success "Created backup directory: $targetDir"
            return $targetDir
        }
        catch {
            Write-Error "Failed to create backup directory in both current location and Desktop"
            throw "Directory creation failed"
        }
    }
}

# Function to perform MongoDB export
function Invoke-MongoExport {
    param(
        [string]$BackupDir,
        [hashtable]$Credentials
    )

    $mongoUri = "mongodb://$($Credentials.Username):$($Credentials.Password)@$($Credentials.Host):$($Credentials.Port)/?authSource=admin"

    Write-Info "Starting MongoDB export..."
    Write-Info "Target directory: $BackupDir"

    try {
        # Perform the mongodump
        $process = Start-Process -FilePath "mongodump" -ArgumentList "--uri=`"$mongoUri`"", "--out=`"$BackupDir`"" -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Success "MongoDB export completed successfully!"
            Write-Info "Backup saved to: $BackupDir"

            # Show directory contents
            Write-Info "Exported databases:"
            Get-ChildItem -Path $BackupDir | Format-Table Name, Length, LastWriteTime -AutoSize
        }
        else {
            Write-Error "MongoDB export failed with exit code: $($process.ExitCode)"
            throw "Export failed"
        }
    }
    catch {
        Write-Error "MongoDB export failed: $($_.Exception.Message)"
        throw
    }
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
        return
    }

    try {
        Write-Info "MongoDB Database Export Script"
        Write-Info "=============================="

        # Check if mongodump is available
        if (-not (Test-MongoDump)) {
            exit 1
        }

        # Get MongoDB credentials
        $credentials = Get-MongoDBCredentials

        # Create backup directory
        $backupDir = New-BackupDirectory

        # Perform export
        Invoke-MongoExport -BackupDir $backupDir -Credentials $credentials

        Write-Success "Export process completed!"
    }
    catch {
        Write-Error "Script execution failed: $($_.Exception.Message)"
        exit 1
    }
}

# Run main function
Main