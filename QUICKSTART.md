# 🚀 HRSOFT Quick Start Guide for Windows

## Prerequisites

1. **Install Docker Desktop:**
   - Download from: https://www.docker.com/products/docker-desktop
   - Follow installation instructions
   - Make sure Docker is running

2. **Install Git:**
   - Download from: https://git-scm.com/download/win
   - Use default settings during installation

## Quick Setup (5 minutes)

1. **Open PowerShell as Administrator:**
   ```powershell
   # Clone the repository
   git clone <repository-url> HRSOFT
   cd HRSOFT
   ```

2. **Setup and Start:**
   ```powershell
   # Setup environment
   .\dev.ps1 setup
   
   # Start all services
   .\dev.ps1 up
   ```

3. **Verify Installation:**
   ```powershell
   # Check service health
   .\dev.ps1 health
   ```

## Access Your Application

After setup completes (2-3 minutes), you can access:

- **API Gateway**: http://localhost
- **Auth Service Docs**: http://localhost:8001/docs
- **User Service Docs**: http://localhost:8002/docs
- **Database Admin (Dev)**: http://localhost:5050

## Common Commands

```powershell
# View all available commands
.\dev.ps1 help

# Start services
.\dev.ps1 up

# Stop services  
.\dev.ps1 down

# View logs
.\dev.ps1 logs

# Check health
.\dev.ps1 health

# Clean up everything
.\dev.ps1 clean

# Start development mode (with hot reload)
.\dev.ps1 dev-up
```

## Alternative: Command Prompt

If you prefer Command Prompt over PowerShell:

```cmd
# Setup
dev.bat setup

# Start
dev.bat up

# Check health
dev.bat health
```

## First API Test

1. **Register a user:**
   ```powershell
   # Using PowerShell
   $body = @{
       username = "admin"
       email = "admin@hrsoft.com"
       full_name = "Administrator"
       password = "admin123"
   } | ConvertTo-Json
   
   Invoke-RestMethod -Uri "http://localhost/api/auth/register" -Method Post -Body $body -ContentType "application/json"
   ```

2. **Login:**
   ```powershell
   $loginBody = @{
       username = "admin"
       password = "admin123"
   } | ConvertTo-Json
   
   $response = Invoke-RestMethod -Uri "http://localhost/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
   $token = $response.access_token
   ```

3. **Create an employee:**
   ```powershell
   $headers = @{ Authorization = "Bearer $token" }
   $empBody = @{
       employee_id = "EMP001"
       first_name = "John"
       last_name = "Doe"
       email = "john.doe@company.com"
       position = "Software Engineer"
       salary = 5000000
   } | ConvertTo-Json
   
   Invoke-RestMethod -Uri "http://localhost/api/users/employees/" -Method Post -Body $empBody -ContentType "application/json" -Headers $headers
   ```

## Troubleshooting

### Docker Issues
```powershell
# Restart Docker Desktop
# Check if Docker is running:
docker version

# If containers fail to start:
.\dev.ps1 clean
.\dev.ps1 up
```

### Port Conflicts
If ports 80, 8001, or 8002 are busy:
```powershell
# Check what's using the ports:
netstat -ano | findstr :80
netstat -ano | findstr :8001
netstat -ano | findstr :8002

# Kill processes if needed:
taskkill /PID <PID_NUMBER> /F
```

### Permission Issues
```powershell
# Run PowerShell as Administrator
# Or allow script execution:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Next Steps

1. **Explore the API docs** at http://localhost:8001/docs
2. **Read the full README.md** for detailed documentation
3. **Check CONTRIBUTING.md** for development guidelines
4. **Start building your HR features!**

## Getting Help

- Check the logs: `.\dev.ps1 logs`
- View health status: `.\dev.ps1 health`
- Clean and restart: `.\dev.ps1 clean && .\dev.ps1 up`
- Open an issue on GitHub if you need help
