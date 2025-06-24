@echo off
REM HRSOFT Batch Scripts for Windows

setlocal enabledelayedexpansion

if "%1"=="" (
    goto :help
)

if "%1"=="help" goto :help
if "%1"=="setup" goto :setup
if "%1"=="build" goto :build
if "%1"=="up" goto :up
if "%1"=="down" goto :down
if "%1"=="logs" goto :logs
if "%1"=="clean" goto :clean
if "%1"=="test" goto :test
if "%1"=="dev-up" goto :dev-up
if "%1"=="dev-down" goto :dev-down
if "%1"=="health" goto :health
if "%1"=="backup-db" goto :backup-db
if "%1"=="install-dev" goto :install-dev
if "%1"=="db-check" (
    echo 🔍 Checking MySQL setup...
    powershell -ExecutionPolicy Bypass -File ".\database\scripts\check_mysql.ps1"
    goto :eof
)

if "%1"=="db-deploy" goto :db-deploy
if "%1"=="db-backup" goto :db-backup
if "%1"=="db-restore" goto :db-restore
if "%1"=="db-migrate" goto :db-migrate
if "%1"=="db-seed" goto :db-seed
if "%1"=="db-reset" goto :db-reset

echo ❌ Unknown command: %1
echo.
goto :help

:help
echo 🚀 HRSOFT Development Commands:
echo.
echo   setup           Setup development environment
echo   build           Build all services
echo   up              Start all services
echo   down            Stop all services
echo   logs            - Show docker compose logs
echo   shell ^<service^> - Open shell in service container
echo.
echo Database Commands:
echo   db-check        - Check MySQL setup and connection
echo   db-deploy       - Deploy database schema
echo   db-backup       - Create database backup
echo   db-restore ^<file^> - Restore database from backup
echo   db-migrate      - Run database migrations
echo   db-seed         - Seed database with sample data
echo   db-reset        - Reset database (WARNING: deletes all data)
echo.
echo Examples:
echo   dev.bat setup
echo   dev.bat up
echo   dev.bat health
echo.
goto :end

:setup
echo 🔧 Setting up development environment...
if not exist .env (
    copy .env.example .env
    echo 📝 Created .env file
)
echo ✅ Environment setup complete!
goto :end

:build
echo 🏗️  Building all services...
docker-compose build
echo ✅ Build complete!
goto :end

:up
echo 🚀 Starting all services...
docker-compose up -d
echo ✅ Services started!
echo 📚 API Documentation available at:
echo    - Auth Service: http://localhost:8001/docs
echo    - User Service: http://localhost:8002/docs
goto :end

:down
echo 🛑 Stopping all services...
docker-compose down
echo ✅ Services stopped!
goto :end

:logs
echo 📋 Viewing logs from all services...
docker-compose logs -f
goto :end

:clean
echo 🧹 Cleaning up...
docker-compose down -v --remove-orphans
docker system prune -f
echo ✅ Cleanup complete!
goto :end

:test
echo 🧪 Running tests...
cd tests
python -m pytest -v
cd ..
echo ✅ Tests complete!
goto :end

:dev-up
echo 🔥 Starting development environment...
docker-compose -f docker-compose.dev.yml up -d
echo ✅ Development environment started!
goto :end

:dev-down
echo 🛑 Stopping development environment...
docker-compose -f docker-compose.dev.yml down
echo ✅ Development environment stopped!
goto :end

:health
echo 🏥 Checking service health...
curl -s http://localhost:8001/health 2>nul || echo Auth Service: Not ready
curl -s http://localhost:8002/health 2>nul || echo User Service: Not ready
curl -s http://localhost/health 2>nul || echo API Gateway: Not ready
goto :end

:backup-db
echo 💾 Backing up database...
for /f "tokens=1-4 delims=/ " %%i in ('date /t') do (
    for /f "tokens=1-3 delims=: " %%a in ('time /t') do (
        set backup_name=backup_%%k%%j%%i_%%a%%b%%c.sql
    )
)
docker-compose exec postgres pg_dump -U hrsoft_user hrsoft_db > %backup_name%
echo ✅ Database backup complete! File: %backup_name%
goto :end

:install-dev
echo 📦 Installing development dependencies...
pip install -r tests/requirements.txt
pip install flake8 black
echo ✅ Development dependencies installed!
goto :end

:db-deploy
echo 🗄️  Deploying database schema...
powershell -ExecutionPolicy Bypass -File ".\database\scripts\deploy_database.ps1" "dev"
goto :end

:db-backup
echo 💾 Creating database backup...
echo Please run backup manually using MySQL tools
goto :end

:db-restore
if "%2"=="" (
    echo ❌ Please specify backup file: dev.bat db-restore ^<backup_file^>
    goto :end
)
echo 🔄 Restoring database from: %2
echo Please run restore manually using MySQL tools
goto :end

:db-migrate
echo 🚀 Running database migrations...
echo Migrations will be implemented in future versions
goto :end

:db-seed
echo 🌱 Seeding database with sample data...
echo Sample data seeding will be implemented in future versions
goto :end

:db-reset
echo ⚠️  Resetting database ^(this will delete all data^)...
set /p "confirm=Are you sure? (yes/no): "
if /i "%confirm%"=="yes" (
    echo 🗄️  Redeploying fresh database...
    powershell -ExecutionPolicy Bypass -File ".\database\scripts\deploy_database.ps1" "dev"
) else (
    echo Database reset cancelled
)
goto :end

:end
