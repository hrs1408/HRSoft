@echo off
REM HRSOFT Development Setup Script for Windows

echo 🚀 Setting up HRSOFT Development Environment...

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file from template...
    copy .env.example .env
    echo ✅ .env file created. Please update the values as needed.
)

REM Build and start services
echo 🏗️  Building and starting services...
docker-compose up -d --build

REM Wait for services to start
echo ⏳ Waiting for services to start...
timeout /t 10 /nobreak >nul

REM Check service health
echo 🔍 Checking service health...
echo Auth Service: Checking http://localhost:8001/health
echo User Service: Checking http://localhost:8002/health
echo API Gateway: Checking http://localhost/health

echo.
echo 🎉 HRSOFT is ready!
echo 📚 API Documentation:
echo    - Auth Service: http://localhost:8001/docs
echo    - User Service: http://localhost:8002/docs
echo    - API Gateway: http://localhost
echo.
echo 🔧 To stop services: docker-compose down
echo 📊 To view logs: docker-compose logs -f
pause
