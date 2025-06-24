# =============================================================================
# HRSOFT DATABASE DEPLOYMENT SCRIPT FOR WINDOWS
# =============================================================================
# This PowerShell script helps deploy the HRSOFT database schema and initial data
# Usage: .\deploy_database.ps1 [environment]
# Environments: dev, staging, prod

param(
    [string]$Environment = "dev",
    [string]$MySQLHost = $env:MYSQL_HOST ?? "localhost",
    [string]$MySQLPort = $env:MYSQL_PORT ?? "3306",
    [string]$MySQLUser = $env:MYSQL_ROOT_USER ?? "root",
    [string]$MySQLPassword = $env:MYSQL_ROOT_PASSWORD ?? ""
)

# Script configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DatabaseDir = Split-Path -Parent $ScriptDir

# MySQL executable path (adjust as needed)
$MySQLPath = "C:\xampp\mysql\bin\mysql.exe"

# Check if MySQL path exists, try alternative locations
if (-not (Test-Path $MySQLPath)) {
    $AlternativePaths = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
        "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe",
        "C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe"
    )
    
    foreach ($Path in $AlternativePaths) {
        if (Test-Path $Path) {
            $MySQLPath = $Path
            break
        }
    }
}

# Helper function to build MySQL command arguments
function Get-MySQLArgs {
    param([string]$AdditionalArgs = "")
    
    $MySQLArgs = @("-h", $MySQLHost, "-P", $MySQLPort, "-u", $MySQLUser)
    
    if ($MySQLPassword -ne "") {
        $MySQLArgs += "-p$MySQLPassword"
    }
    
    return $MySQLArgs
}

# Color functions
function Write-Success {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INFO: $Message" -ForegroundColor Blue
}

# Check if MySQL is accessible
function Test-MySQLConnection {
    Write-Success "Checking MySQL connection..."
    
    if (-not (Test-Path $MySQLPath)) {
        Write-Error "MySQL executable not found at: $MySQLPath"
        Write-Error "Please install MySQL or update the MySQLPath variable"
        exit 1
    }
    
    try {
        $TestQuery = "SELECT 1"
        $ErrorActionPreference = "SilentlyContinue"
        $MySQLArgs = Get-MySQLArgs
        $MySQLArgs += @("-e", $TestQuery)
        $null = & $MySQLPath @MySQLArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "MySQL connection successful"
        } else {
            throw "Connection failed"
        }
    } catch {
        Write-Error "Cannot connect to MySQL server at $MySQLHost`:$MySQLPort"
        Write-Error "Please check your MySQL credentials and server status"
        exit 1
    }
}

# Check if required files exist
function Test-RequiredFiles {
    Write-Success "Checking required files..."
    
    $RequiredFiles = @(
        "$DatabaseDir\init\01-databases.sql",
        "$DatabaseDir\init\02-auth-schema.sql",
        "$DatabaseDir\init\03-hr-schema.sql",
        "$DatabaseDir\init\04-inventory-schema.sql",
        "$DatabaseDir\init\05-hrsoft-normalized-schema.sql"
    )
    
    foreach ($File in $RequiredFiles) {
        if (-not (Test-Path $File)) {
            Write-Error "Required file not found: $File"
            exit 1
        }
    }
    
    Write-Success "All required files found"
}

# Execute SQL file
function Invoke-SQLFile {
    param(
        [string]$SqlFile,
        [string]$Description
    )
    
    Write-Success "Executing: $Description"
    Write-Info "File: $(Split-Path -Leaf $SqlFile)"
    
    try {
        $MySQLArgs = Get-MySQLArgs
        $MySQLArgs += @("--verbose")
        
        # Execute the SQL file and capture output
        $Output = Get-Content $SqlFile | & $MySQLPath @MySQLArgs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ $Description completed successfully"
            if ($Output) {
                $OutputString = $Output -join ' '
                if ($OutputString.Trim() -ne "") {
                    Write-Host "   Output: $OutputString" -ForegroundColor Gray
                }
            }
        } else {
            Write-Error "MySQL execution failed with exit code: $LASTEXITCODE"
            if ($Output) {
                Write-Error "Error output: $($Output -join '; ')"
            }
            throw "MySQL execution failed"
        }
    } catch {
        Write-Error "✗ Failed to execute: $Description"
        Write-Error "Exception: $($_.Exception.Message)"
        exit 1
    }
}

# Create databases and users
function New-Databases {
    Write-Success "Creating databases and users..."
    Invoke-SQLFile "$DatabaseDir\init\01-databases.sql" "Database and user creation"
}

# Deploy auth schema
function Deploy-AuthSchema {
    Write-Success "Deploying authentication schema..."
    Invoke-SQLFile "$DatabaseDir\init\02-auth-schema.sql" "Authentication schema deployment"
}

# Deploy HR schema
function Deploy-HRSchema {
    Write-Success "Deploying HR schema..."
    Invoke-SQLFile "$DatabaseDir\init\03-hr-schema.sql" "HR schema deployment"
}

# Deploy inventory schema
function Deploy-InventorySchema {
    Write-Success "Deploying inventory schema..."
    Invoke-SQLFile "$DatabaseDir\init\04-inventory-schema.sql" "Inventory schema deployment"
}

# Deploy normalized schema (optional)
function Deploy-NormalizedSchema {
    Write-Success "Deploying normalized HRSOFT schema (optional)..."
    Write-Warning "This may create conflicting table structures with existing schemas"
    
    if ($Environment -eq "dev") {
        $Confirmation = Read-Host "Deploy normalized schema? This may conflict with existing tables (yes/no)"
        if ($Confirmation -notmatch '^[Yy][Ee][Ss]$') {
            Write-Success "Skipping normalized schema deployment"
            return
        }
    }
    
    try {
        Invoke-SQLFile "$DatabaseDir\init\05-hrsoft-normalized-schema.sql" "Normalized schema deployment"
    } catch {
        Write-Warning "Normalized schema deployment failed - this is optional and may conflict with modular schemas"
        Write-Warning "Error: $($_.Exception.Message)"
        Write-Success "Continuing with deployment..."
    }
}

# Verify deployment
function Test-Deployment {
    Write-Success "Verifying deployment..."
    
    # Check if databases exist
    $Databases = @("hrsoft_auth", "hrsoft_hr", "hrsoft_inventory")
      foreach ($Database in $Databases) {
        try {
            $ErrorActionPreference = "SilentlyContinue"
            $MySQLArgs = Get-MySQLArgs
            $MySQLArgs += @("-e", "USE $Database; SELECT 1;")
            $null = & $MySQLPath @MySQLArgs
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✓ Database $Database exists and is accessible"
            } else {
                throw "Database not accessible"
            }
        } catch {
            Write-Error "✗ Database $Database is not accessible"
            exit 1
        }
    }
      # Check table count
    $TableCountQuery = @"
SELECT COUNT(*) 
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
"@
      try {
        $ErrorActionPreference = "SilentlyContinue"
        $MySQLArgs = Get-MySQLArgs
        $MySQLArgs += @("-e", $TableCountQuery, "-s", "-N")
        $TableCount = & $MySQLPath @MySQLArgs
        if ($TableCount -gt 0) {
            Write-Success "✓ Found $TableCount tables in HRSOFT databases"
        } else {
            Write-Error "✗ No tables found in HRSOFT databases"
            exit 1
        }
    } catch {
        Write-Error "✗ Failed to verify table count"
        exit 1
    }
    
    Write-Success "Deployment verification completed successfully"
}

# Show deployment summary
function Show-Summary {
    Write-Success "Deployment Summary:"    Write-Info "Environment: $Environment"
    Write-Info "MySQL Host: $MySQLHost`:$MySQLPort"
    Write-Info "Databases: hrsoft_auth, hrsoft_hr, hrsoft_inventory"
    
    # Get table counts
    $SummaryQuery = @"
SELECT 
    table_schema as 'Database',
    COUNT(*) as 'Tables'
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
GROUP BY table_schema
ORDER BY table_schema;
"@
    
    try {
        $MySQLArgs = Get-MySQLArgs
        $MySQLArgs += @("-e", $SummaryQuery)
        & $MySQLPath @MySQLArgs
    } catch {
        Write-Warning "Could not retrieve table summary"
    }
}

# Backup existing database
function Backup-ExistingDatabase {
    if ($Environment -ne "dev") {
        Write-Success "Creating backup of existing databases..."
        $BackupFile = "hrsoft_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
        
        try {
            $MySQLDumpPath = $MySQLPath.Replace("mysql.exe", "mysqldump.exe")
            $ErrorActionPreference = "SilentlyContinue"
            
            # Build mysqldump arguments
            $DumpArgs = @("-h", $MySQLHost, "-P", $MySQLPort, "-u", $MySQLUser)
            
            if ($MySQLPassword -ne "") {
                $DumpArgs += "-p$MySQLPassword"
            }
            
            $DumpArgs += @("--databases", "hrsoft_auth", "hrsoft_hr", "hrsoft_inventory")
            
            & $MySQLDumpPath @DumpArgs | Out-File -FilePath $BackupFile -Encoding UTF8
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✓ Backup created: $BackupFile"
            } else {
                throw "Backup failed"
            }
        } catch {
            Write-Warning "Could not create backup (databases might not exist yet)"
        }
    }
}

# Main deployment function
function Main {
    Write-Success "Starting HRSOFT Database Deployment"
    Write-Success "Environment: $Environment"
    Write-Success "Target: $MySQLHost`:$MySQLPort"
    
    # Confirmation for production
    if ($Environment -eq "prod") {
        Write-Warning "You are about to deploy to PRODUCTION environment!"
        $Confirmation = Read-Host "Are you sure you want to continue? (yes/no)"
        if ($Confirmation -notmatch '^[Yy][Ee][Ss]$') {
            Write-Success "Deployment cancelled by user"
            exit 0
        }
    }
    
    # Run deployment steps
    Test-MySQLConnection
    Test-RequiredFiles
    Backup-ExistingDatabase
    
    Write-Info "Starting database deployment..."
    New-Databases
    Start-Sleep -Seconds 2  # Allow time for database creation
    
    Deploy-AuthSchema
    Start-Sleep -Seconds 1
    
    Deploy-HRSchema
    Start-Sleep -Seconds 1
    
    Deploy-InventorySchema
    Start-Sleep -Seconds 1
    
    Deploy-NormalizedSchema
    Start-Sleep -Seconds 2  # Allow time for schema completion
    
    Test-Deployment
    Show-Summary
    
    Write-Success "🎉 HRSOFT Database Deployment completed successfully!"
    Write-Success "You can now start the application services"
    
    if ($Environment -eq "dev") {
        Write-Info "To start the development environment:"
        Write-Info "  .\dev.ps1 docker-up"
        Write-Info "  .\dev.ps1 start-all"
    }
}

# Handle script arguments
if ($args[0] -eq "help" -or $args[0] -eq "-h" -or $args[0] -eq "--help") {
    Write-Host "HRSOFT Database Deployment Script"
    Write-Host "Usage: .\deploy_database.ps1 [environment]"
    Write-Host ""
    Write-Host "Environments:"
    Write-Host "  dev      - Development environment (default)"
    Write-Host "  staging  - Staging environment"
    Write-Host "  prod     - Production environment"
    Write-Host ""
    Write-Host "Environment Variables:"
    Write-Host "  MYSQL_HOST           - MySQL host (default: localhost)"
    Write-Host "  MYSQL_PORT           - MySQL port (default: 3306)"
    Write-Host "  MYSQL_ROOT_USER      - MySQL root user (default: root)"
    Write-Host "  MYSQL_ROOT_PASSWORD  - MySQL root password"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\deploy_database.ps1 dev"
    Write-Host "  `$env:MYSQL_HOST='db.example.com'; .\deploy_database.ps1 prod"
    exit 0
}

# Run main function
try {
    Main
} catch {
    Write-Error "Deployment failed: $($_.Exception.Message)"
    exit 1
}
