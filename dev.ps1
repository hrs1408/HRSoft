# HRSOFT PowerShell Scripts for Windows

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    [string]$File = ""
)

function Show-Help {
    Write-Host "🚀 HRSOFT Development Commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  setup           Setup development environment" -ForegroundColor Yellow
    Write-Host "  build           Build all services" -ForegroundColor Yellow
    Write-Host "  up              Start all services" -ForegroundColor Yellow
    Write-Host "  down            Stop all services" -ForegroundColor Yellow
    Write-Host "  logs            View logs from all services" -ForegroundColor Yellow
    Write-Host "  clean           Clean up containers and volumes" -ForegroundColor Yellow
    Write-Host "  test            Run tests" -ForegroundColor Yellow
    Write-Host "  dev-up          Start development environment with hot reload" -ForegroundColor Yellow
    Write-Host "  dev-down        Stop development environment" -ForegroundColor Yellow
    Write-Host "  health          Check service health" -ForegroundColor Yellow
    Write-Host "  install-dev     Install development dependencies" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Demo Mode:" -ForegroundColor Magenta  
    Write-Host "  demo            Show HRSOFT demo (no MySQL required)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Database Operations:" -ForegroundColor Green
    Write-Host "  db-check        Check MySQL setup and connection" -ForegroundColor Yellow
    Write-Host "  db-deploy       Deploy database schema" -ForegroundColor Yellow
    Write-Host "  db-backup       Create database backup" -ForegroundColor Yellow
    Write-Host "  db-restore      Restore database from backup file" -ForegroundColor Yellow
    Write-Host "  db-migrate      Run database migrations" -ForegroundColor Yellow
    Write-Host "  db-seed         Seed database with sample data" -ForegroundColor Yellow
    Write-Host "  db-reset        Reset database (delete all data)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\dev.ps1 setup" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 up" -ForegroundColor Gray  
    Write-Host "  .\dev.ps1 db-deploy" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 db-backup" -ForegroundColor Gray
    Write-Host ""
}

function Setup-Environment {
    Write-Host "🔧 Setting up development environment..." -ForegroundColor Yellow
    
    if (!(Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Host "📝 Created .env file" -ForegroundColor Green
    }
    
    Write-Host "✅ Environment setup complete!" -ForegroundColor Green
}

function Build-Services {
    Write-Host "🏗️  Building all services..." -ForegroundColor Yellow
    docker-compose build
    Write-Host "✅ Build complete!" -ForegroundColor Green
}

function Start-Services {
    Write-Host "🚀 Starting all services..." -ForegroundColor Yellow
    docker-compose up -d
    Write-Host "✅ Services started!" -ForegroundColor Green
    Write-Host "📚 API Documentation available at:" -ForegroundColor Cyan
    Write-Host "   - Auth Service: http://localhost:8001/docs" -ForegroundColor Gray
    Write-Host "   - User Service: http://localhost:8002/docs" -ForegroundColor Gray
}

function Stop-Services {
    Write-Host "🛑 Stopping all services..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ Services stopped!" -ForegroundColor Green
}

function Show-Logs {
    Write-Host "📋 Viewing logs from all services..." -ForegroundColor Yellow
    docker-compose logs -f
}

function Clean-Environment {
    Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
    docker-compose down -v --remove-orphans
    docker system prune -f
    Write-Host "✅ Cleanup complete!" -ForegroundColor Green
}

function Run-Tests {
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow
    Set-Location tests
    python -m pytest -v
    Set-Location ..
    Write-Host "✅ Tests complete!" -ForegroundColor Green
}

function Start-DevEnvironment {
    Write-Host "🔥 Starting development environment..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml up -d
    Write-Host "✅ Development environment started!" -ForegroundColor Green
}

function Stop-DevEnvironment {
    Write-Host "🛑 Stopping development environment..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml down
    Write-Host "✅ Development environment stopped!" -ForegroundColor Green
}

function Check-Health {
    Write-Host "🏥 Checking service health..." -ForegroundColor Yellow
    
    try {
        $authHealth = (Invoke-RestMethod -Uri "http://localhost:8001/health" -Method Get -ErrorAction SilentlyContinue).status
        Write-Host "Auth Service: $authHealth" -ForegroundColor Green
    } catch {
        Write-Host "Auth Service: Not ready" -ForegroundColor Red
    }
    
    try {
        $userHealth = (Invoke-RestMethod -Uri "http://localhost:8002/health" -Method Get -ErrorAction SilentlyContinue).status
        Write-Host "User Service: $userHealth" -ForegroundColor Green
    } catch {
        Write-Host "User Service: Not ready" -ForegroundColor Red
    }
    
    try {
        $gatewayHealth = Invoke-RestMethod -Uri "http://localhost/health" -Method Get -ErrorAction SilentlyContinue
        Write-Host "API Gateway: healthy" -ForegroundColor Green
    } catch {
        Write-Host "API Gateway: Not ready" -ForegroundColor Red
    }
}

function Backup-Database {
    Write-Host "💾 Backing up database..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    docker-compose exec postgres pg_dump -U hrsoft_user hrsoft_db > "backup_$timestamp.sql"
    Write-Host "✅ Database backup complete! File: backup_$timestamp.sql" -ForegroundColor Green
}

function Restore-Database {
    param([string]$BackupFile)
    
    if (!$BackupFile) {
        Write-Host "❌ Please specify backup file with -File parameter" -ForegroundColor Red
        return
    }
    
    if (!(Test-Path $BackupFile)) {
        Write-Host "❌ Backup file not found: $BackupFile" -ForegroundColor Red
        return
    }
    
    Write-Host "📥 Restoring database from $BackupFile..." -ForegroundColor Yellow
    Get-Content $BackupFile | docker-compose exec -T postgres psql -U hrsoft_user hrsoft_db
    Write-Host "✅ Database restore complete!" -ForegroundColor Green
}

function Install-DevDependencies {
    Write-Host "📦 Installing development dependencies..." -ForegroundColor Yellow
    pip install -r tests/requirements.txt
    pip install flake8 black
    Write-Host "✅ Development dependencies installed!" -ForegroundColor Green
}

# Database operations
function Deploy-Database {
    Write-Host "🗄️  Deploying database schema..." -ForegroundColor Cyan
    & ".\database\scripts\deploy_database.ps1" "dev"
}

function Create-DatabaseBackup {
    Write-Host "💾 Creating database backup..." -ForegroundColor Cyan
    $BackupFile = "hrsoft_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    Write-Host "Backup file: $BackupFile"
    # Add mysqldump command here based on your MySQL installation
    Write-Host "Please run the backup manually using MySQL tools"
}

function Restore-DatabaseFromFile {
    param($BackupFile)
    if (-not $BackupFile) {
        Write-Host "❌ Please specify backup file: .\dev.ps1 db-restore <backup_file>" -ForegroundColor Red
        return
    }
    Write-Host "🔄 Restoring database from: $BackupFile" -ForegroundColor Cyan
    # Add mysql restore command here
    Write-Host "Please run the restore manually using MySQL tools"
}

function Run-Migrations {
    Write-Host "🚀 Running database migrations..." -ForegroundColor Cyan
    Write-Host "Migrations will be implemented in future versions"
}

function Seed-Database {
    Write-Host "🌱 Seeding database with sample data..." -ForegroundColor Cyan
    Write-Host "Sample data seeding will be implemented in future versions"
}

function Reset-Database {
    Write-Host "⚠️  Resetting database (this will delete all data)..." -ForegroundColor Yellow
    $Confirmation = Read-Host "Are you sure? (yes/no)"
    if ($Confirmation -match '^[Yy][Ee][Ss]$') {
        Write-Host "🗄️  Redeploying fresh database..." -ForegroundColor Cyan
        & ".\database\scripts\deploy_database.ps1" "dev"
    } else {
        Write-Host "Database reset cancelled" -ForegroundColor Green
    }
}

# Main command dispatcher
switch ($Command.ToLower()) {
    "help" { Show-Help }
    "setup" { Setup-Environment }
    "build" { Build-Services }
    "up" { Start-Services }
    "down" { Stop-Services }
    "logs" { Show-Logs }
    "clean" { Clean-Environment }
    "test" { Run-Tests }
    "dev-up" { Start-DevEnvironment }
    "dev-down" { Stop-DevEnvironment }
    "health" { Check-Health }
    "backup-db" { Backup-Database }
    "restore-db" { Restore-Database -BackupFile $File }
    "install-dev" { Install-DevDependencies }
    "db-check" {
        Write-Host "🔍 Checking MySQL setup..." -ForegroundColor Cyan
        & ".\database\scripts\check_mysql.ps1"
    }
    "db-deploy" { Deploy-Database }
    "db-backup" { Create-DatabaseBackup }
    "db-restore" { Restore-DatabaseFromFile -BackupFile $File }
    "db-migrate" { Run-Migrations }
    "db-seed" { Seed-Database }
    "db-reset" { Reset-Database }    "demo" {
        Write-Host "🎭 Starting HRSOFT Demo Mode..." -ForegroundColor Magenta
        & ".\demo.ps1" "help"
    }
    default { 
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help 
    }
}
