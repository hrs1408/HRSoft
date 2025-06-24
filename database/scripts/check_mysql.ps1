# =============================================================================
# HRSOFT Database Setup Check Script
# =============================================================================
# This script helps check if MySQL is properly configured for HRSOFT

param(
    [string]$MySQLHost = "localhost",
    [string]$MySQLPort = "3306", 
    [string]$MySQLUser = "root"
)

Write-Host "🔍 HRSOFT Database Setup Checker" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check MySQL installation paths
$MySQLPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe", 
    "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe",
    "mysql.exe"  # If in PATH
)

Write-Host "1. Checking MySQL Installation..." -ForegroundColor Yellow
$MySQLFound = $false
$MySQLPath = ""

foreach ($Path in $MySQLPaths) {
    if ($Path -eq "mysql.exe") {
        # Check if mysql is in PATH
        try {
            $null = Get-Command mysql -ErrorAction Stop
            Write-Host "   ✓ MySQL found in system PATH" -ForegroundColor Green
            $MySQLPath = "mysql.exe"
            $MySQLFound = $true
            break
        } catch {
            continue
        }
    } elseif (Test-Path $Path) {
        Write-Host "   ✓ MySQL found at: $Path" -ForegroundColor Green
        $MySQLPath = $Path
        $MySQLFound = $true
        break
    }
}

if (-not $MySQLFound) {
    Write-Host "   ✗ MySQL not found!" -ForegroundColor Red
    Write-Host "   Please install MySQL Server from: https://dev.mysql.com/downloads/mysql/" -ForegroundColor Yellow
    Write-Host "   Or install XAMPP from: https://www.apachefriends.org/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2. Checking MySQL Service..." -ForegroundColor Yellow

# Check if MySQL service is running (Windows services)
$MySQLServices = @("MySQL80", "MySQL", "wampmysqld64", "xampp_mysql")
$ServiceRunning = $false

foreach ($ServiceName in $MySQLServices) {
    try {
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($Service -and $Service.Status -eq "Running") {
            Write-Host "   ✓ MySQL service '$ServiceName' is running" -ForegroundColor Green
            $ServiceRunning = $true
            break
        }
    } catch {
        continue
    }
}

if (-not $ServiceRunning) {
    Write-Host "   ⚠️  MySQL service not found or not running" -ForegroundColor Yellow
    Write-Host "   Please start MySQL service manually or through XAMPP/WAMP control panel" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "3. Testing MySQL Connection..." -ForegroundColor Yellow

# Prompt for password securely
Write-Host "   Please enter MySQL root password (leave empty if no password):" -ForegroundColor Cyan
$SecurePassword = Read-Host -AsSecureString
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))

if ($Password -eq "") {
    $ConnectionArgs = @("-h", $MySQLHost, "-P", $MySQLPort, "-u", $MySQLUser)
} else {
    $ConnectionArgs = @("-h", $MySQLHost, "-P", $MySQLPort, "-u", $MySQLUser, "-p$Password")
}

try {
    $ErrorActionPreference = "Stop"
    $null = & $MySQLPath @ConnectionArgs -e "SELECT 1 as test;" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ MySQL connection successful!" -ForegroundColor Green
        
        # Set environment variables for deployment
        $env:MYSQL_HOST = $MySQLHost
        $env:MYSQL_PORT = $MySQLPort  
        $env:MYSQL_ROOT_USER = $MySQLUser
        $env:MYSQL_ROOT_PASSWORD = $Password
        
        Write-Host ""
        Write-Host "4. Environment Variables Set:" -ForegroundColor Yellow
        Write-Host "   MYSQL_HOST = $MySQLHost" -ForegroundColor Gray
        Write-Host "   MYSQL_PORT = $MySQLPort" -ForegroundColor Gray
        Write-Host "   MYSQL_ROOT_USER = $MySQLUser" -ForegroundColor Gray
        Write-Host "   MYSQL_ROOT_PASSWORD = [HIDDEN]" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "🎉 MySQL is ready for HRSOFT deployment!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "   .\dev.ps1 db-deploy  - Deploy HRSOFT database schema" -ForegroundColor White
        Write-Host "   .\dev.ps1 docker-up  - Start Docker services" -ForegroundColor White
        Write-Host "   .\dev.ps1 dev-up     - Start development environment" -ForegroundColor White
        
    } else {
        throw "Connection failed"
    }
} catch {
    Write-Host "   ✗ MySQL connection failed!" -ForegroundColor Red
    Write-Host "   Error: Access denied or server not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Make sure MySQL service is running" -ForegroundColor White
    Write-Host "   2. Check your MySQL root password" -ForegroundColor White  
    Write-Host "   3. Try connecting with MySQL Workbench first" -ForegroundColor White
    Write-Host "   4. For XAMPP users: Start MySQL from XAMPP Control Panel" -ForegroundColor White
    Write-Host "   5. For WAMP users: Start MySQL from WAMP Control Panel" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Database Setup Check Complete! ✨" -ForegroundColor Green
