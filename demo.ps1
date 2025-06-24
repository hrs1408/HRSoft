# HRSOFT Demo Mode Script
# This script demonstrates HRSOFT features without requiring MySQL

param(
    [string]$Command = "help"
)

function Show-DemoHelp {
    Write-Host "🎭 HRSOFT Demo Mode" -ForegroundColor Magenta
    Write-Host "===================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Available Demo Commands:" -ForegroundColor Cyan
    Write-Host "  schema      Show database schema overview" -ForegroundColor Yellow
    Write-Host "  features    List HRSOFT features" -ForegroundColor Yellow  
    Write-Host "  structure   Show project structure" -ForegroundColor Yellow
    Write-Host "  setup       Show setup instructions" -ForegroundColor Yellow
    Write-Host "  api         Show API endpoints example" -ForegroundColor Yellow
    Write-Host ""
}

function Show-Schema {
    Write-Host "📊 HRSOFT Database Schema Overview" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🏢 Organizations Module:" -ForegroundColor Green
    Write-Host "  • companies (Company master data)" -ForegroundColor White
    Write-Host "  • company_addresses (Multiple addresses per company)" -ForegroundColor White
    Write-Host "  • departments (Organizational departments)" -ForegroundColor White
    Write-Host "  • positions (Job positions/titles)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "👥 Employee Management:" -ForegroundColor Green  
    Write-Host "  • employees (Employee master records)" -ForegroundColor White
    Write-Host "  • employee_addresses (Employee addresses)" -ForegroundColor White
    Write-Host "  • employee_positions (Position assignments)" -ForegroundColor White
    Write-Host "  • employee_emergency_contacts (Emergency contacts)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⏰ Attendance & Time:" -ForegroundColor Green
    Write-Host "  • work_schedules (Work schedule definitions)" -ForegroundColor White
    Write-Host "  • employee_work_schedules (Schedule assignments)" -ForegroundColor White
    Write-Host "  • attendance_records (Daily attendance)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🏖️ Leave Management:" -ForegroundColor Green
    Write-Host "  • leave_types (Leave type definitions)" -ForegroundColor White
    Write-Host "  • employee_leave_balances (Leave balances)" -ForegroundColor White
    Write-Host "  • leave_requests (Leave applications)" -ForegroundColor White
    Write-Host "  • holidays (Company holidays)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "💰 Payroll System:" -ForegroundColor Green
    Write-Host "  • salary_components (Earnings/deductions)" -ForegroundColor White
    Write-Host "  • employee_salary_structures (Salary structures)" -ForegroundColor White
    Write-Host "  • payroll_cycles (Payroll periods)" -ForegroundColor White
    Write-Host "  • payroll_records (Payroll calculations)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📈 Performance Management:" -ForegroundColor Green
    Write-Host "  • performance_cycles (Review cycles)" -ForegroundColor White
    Write-Host "  • performance_goals (Employee goals)" -ForegroundColor White
    Write-Host "  • performance_reviews (Reviews & ratings)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎓 Training & Development:" -ForegroundColor Green
    Write-Host "  • training_categories (Training categories)" -ForegroundColor White
    Write-Host "  • training_programs (Training catalog)" -ForegroundColor White
    Write-Host "  • training_sessions (Training schedules)" -ForegroundColor White
    Write-Host "  • training_enrollments (Employee enrollments)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "💻 Asset Management:" -ForegroundColor Green
    Write-Host "  • asset_categories (Asset categories)" -ForegroundColor White
    Write-Host "  • assets (Company assets)" -ForegroundColor White
    Write-Host "  • asset_assignments (Asset assignments)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔍 Recruitment:" -ForegroundColor Green
    Write-Host "  • job_postings (Job listings)" -ForegroundColor White
    Write-Host "  • candidates (Candidate database)" -ForegroundColor White
    Write-Host "  • job_applications (Applications)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⚙️ System Tables:" -ForegroundColor Green
    Write-Host "  • audit_logs (Change tracking)" -ForegroundColor White
    Write-Host "  • system_settings (Configuration)" -ForegroundColor White
    Write-Host "  • file_attachments (Document management)" -ForegroundColor White
    Write-Host "  • notifications (User notifications)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📊 Total: 50+ normalized tables with full relationships" -ForegroundColor Magenta
}

function Show-Features {
    Write-Host "🚀 HRSOFT Features" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🏗️ Architecture:" -ForegroundColor Green
    Write-Host "  ✅ Microservices with FastAPI" -ForegroundColor White
    Write-Host "  ✅ Normalized MySQL database" -ForegroundColor White
    Write-Host "  ✅ Docker containerization" -ForegroundColor White  
    Write-Host "  ✅ Multi-tenant support" -ForegroundColor White
    Write-Host "  ✅ RESTful API design" -ForegroundColor White
    Write-Host ""
    
    Write-Host "👤 Employee Management:" -ForegroundColor Green
    Write-Host "  ✅ Complete employee profiles" -ForegroundColor White
    Write-Host "  ✅ Organizational hierarchy" -ForegroundColor White
    Write-Host "  ✅ Position management" -ForegroundColor White
    Write-Host "  ✅ Contact management" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⏱️ Time & Attendance:" -ForegroundColor Green
    Write-Host "  ✅ Flexible work schedules" -ForegroundColor White
    Write-Host "  ✅ Time tracking" -ForegroundColor White
    Write-Host "  ✅ Overtime calculation" -ForegroundColor White
    Write-Host "  ✅ Attendance reports" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🏝️ Leave Management:" -ForegroundColor Green
    Write-Host "  ✅ Multiple leave types" -ForegroundColor White
    Write-Host "  ✅ Leave balance tracking" -ForegroundColor White
    Write-Host "  ✅ Approval workflows" -ForegroundColor White
    Write-Host "  ✅ Holiday management" -ForegroundColor White
    Write-Host ""
    
    Write-Host "💸 Payroll Processing:" -ForegroundColor Green
    Write-Host "  ✅ Flexible salary components" -ForegroundColor White
    Write-Host "  ✅ Automated calculations" -ForegroundColor White
    Write-Host "  ✅ Tax and deduction handling" -ForegroundColor White
    Write-Host "  ✅ Payslip generation" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎯 Performance Management:" -ForegroundColor Green
    Write-Host "  ✅ Goal setting and tracking" -ForegroundColor White
    Write-Host "  ✅ 360-degree reviews" -ForegroundColor White
    Write-Host "  ✅ Performance analytics" -ForegroundColor White
    Write-Host "  ✅ Development planning" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📚 Training & Development:" -ForegroundColor Green
    Write-Host "  ✅ Training catalog" -ForegroundColor White
    Write-Host "  ✅ Course scheduling" -ForegroundColor White
    Write-Host "  ✅ Certification tracking" -ForegroundColor White
    Write-Host "  ✅ Training analytics" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔒 Security & Audit:" -ForegroundColor Green
    Write-Host "  ✅ Role-based access control" -ForegroundColor White
    Write-Host "  ✅ Complete audit trails" -ForegroundColor White
    Write-Host "  ✅ Data encryption ready" -ForegroundColor White
    Write-Host "  ✅ Compliance reporting" -ForegroundColor White
}

function Show-Structure {
    Write-Host "📁 HRSOFT Project Structure" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "HRSOFT/" -ForegroundColor Yellow
    Write-Host "├── services/" -ForegroundColor White
    Write-Host "│   ├── auth-service/     # Authentication & authorization" -ForegroundColor Gray
    Write-Host "│   ├── user-service/     # User management" -ForegroundColor Gray
    Write-Host "│   └── hr-service/       # HR operations (planned)" -ForegroundColor Gray
    Write-Host "├── shared/" -ForegroundColor White
    Write-Host "│   ├── config/          # Configuration management" -ForegroundColor Gray
    Write-Host "│   ├── database/        # Database connections" -ForegroundColor Gray
    Write-Host "│   ├── models/          # Shared data models" -ForegroundColor Gray
    Write-Host "│   ├── utils/           # Common utilities" -ForegroundColor Gray
    Write-Host "│   └── auth/            # Authentication helpers" -ForegroundColor Gray
    Write-Host "├── database/" -ForegroundColor White
    Write-Host "│   ├── init/            # Database initialization scripts" -ForegroundColor Gray
    Write-Host "│   ├── scripts/         # Utility scripts" -ForegroundColor Gray
    Write-Host "│   └── README.md        # Database documentation" -ForegroundColor Gray
    Write-Host "├── tests/" -ForegroundColor White
    Write-Host "│   └── test_services.py # Service tests" -ForegroundColor Gray
    Write-Host "├── scripts/" -ForegroundColor White
    Write-Host "│   ├── setup.sh         # Linux setup" -ForegroundColor Gray
    Write-Host "│   └── setup.bat        # Windows setup" -ForegroundColor Gray
    Write-Host "├── nginx/" -ForegroundColor White
    Write-Host "│   └── nginx.conf       # Reverse proxy config" -ForegroundColor Gray
    Write-Host "├── dev.ps1              # Windows development script" -ForegroundColor Green
    Write-Host "├── dev.bat              # Windows batch script" -ForegroundColor Green
    Write-Host "├── docker-compose.yml   # Docker orchestration" -ForegroundColor Green
    Write-Host "├── docker-compose.mysql.yml # MySQL development" -ForegroundColor Green
    Write-Host "└── README.md            # Project documentation" -ForegroundColor Green
}

function Show-Setup {
    Write-Host "🛠️ HRSOFT Setup Instructions" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📋 Prerequisites:" -ForegroundColor Yellow
    Write-Host "  1. Windows 10/11" -ForegroundColor White
    Write-Host "  2. Docker Desktop" -ForegroundColor White
    Write-Host "  3. MySQL (XAMPP recommended)" -ForegroundColor White
    Write-Host "  4. Python 3.8+" -ForegroundColor White
    Write-Host "  5. PowerShell 5.1+" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⚡ Quick Setup:" -ForegroundColor Yellow
    Write-Host "  1. git clone <repository>" -ForegroundColor White
    Write-Host "  2. cd HRSOFT" -ForegroundColor White
    Write-Host "  3. .\dev.ps1 setup" -ForegroundColor White
    Write-Host "  4. .\dev.ps1 db-check" -ForegroundColor White
    Write-Host "  5. .\dev.ps1 db-deploy" -ForegroundColor White
    Write-Host "  6. .\dev.ps1 dev-up" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔧 Development Commands:" -ForegroundColor Yellow
    Write-Host "  .\dev.ps1 help          # Show all commands" -ForegroundColor White
    Write-Host "  .\dev.ps1 db-check      # Check MySQL setup" -ForegroundColor White
    Write-Host "  .\dev.ps1 db-deploy     # Deploy database" -ForegroundColor White
    Write-Host "  .\dev.ps1 docker-up     # Start Docker services" -ForegroundColor White
    Write-Host "  .\dev.ps1 dev-up        # Start development" -ForegroundColor White
    Write-Host "  .\dev.ps1 logs          # View logs" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📖 Documentation:" -ForegroundColor Yellow
    Write-Host "  • README.md              # Main documentation" -ForegroundColor White
    Write-Host "  • QUICKSTART.md          # Quick start guide" -ForegroundColor White
    Write-Host "  • database/README.md     # Database guide" -ForegroundColor White
    Write-Host "  • database/MYSQL_SETUP.md # MySQL setup" -ForegroundColor White
}

function Show-API {
    Write-Host "🌐 HRSOFT API Endpoints (Demo)" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔐 Authentication Service (Port 8001):" -ForegroundColor Green
    Write-Host "  POST /auth/login         # User login" -ForegroundColor White
    Write-Host "  POST /auth/logout        # User logout" -ForegroundColor White
    Write-Host "  POST /auth/refresh       # Refresh token" -ForegroundColor White
    Write-Host "  GET  /auth/me            # Current user info" -ForegroundColor White
    Write-Host ""
    
    Write-Host "👤 User Service (Port 8002):" -ForegroundColor Green
    Write-Host "  GET    /users            # List users" -ForegroundColor White
    Write-Host "  POST   /users            # Create user" -ForegroundColor White
    Write-Host "  GET    /users/{id}       # Get user by ID" -ForegroundColor White
    Write-Host "  PUT    /users/{id}       # Update user" -ForegroundColor White
    Write-Host "  DELETE /users/{id}       # Delete user" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🏢 HR Service (Planned - Port 8003):" -ForegroundColor Green
    Write-Host "  # Employees" -ForegroundColor Yellow
    Write-Host "  GET    /employees        # List employees" -ForegroundColor White
    Write-Host "  POST   /employees        # Create employee" -ForegroundColor White
    Write-Host "  GET    /employees/{id}   # Get employee" -ForegroundColor White
    Write-Host "  PUT    /employees/{id}   # Update employee" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Departments" -ForegroundColor Yellow
    Write-Host "  GET    /departments      # List departments" -ForegroundColor White
    Write-Host "  POST   /departments      # Create department" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Attendance" -ForegroundColor Yellow
    Write-Host "  GET    /attendance       # Get attendance records" -ForegroundColor White
    Write-Host "  POST   /attendance/checkin  # Check in" -ForegroundColor White
    Write-Host "  POST   /attendance/checkout # Check out" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Leave Management" -ForegroundColor Yellow
    Write-Host "  GET    /leave/requests   # List leave requests" -ForegroundColor White
    Write-Host "  POST   /leave/requests   # Submit leave request" -ForegroundColor White
    Write-Host "  PUT    /leave/requests/{id}/approve # Approve leave" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Payroll" -ForegroundColor Yellow
    Write-Host "  GET    /payroll/cycles   # List payroll cycles" -ForegroundColor White
    Write-Host "  POST   /payroll/process  # Process payroll" -ForegroundColor White
    Write-Host "  GET    /payroll/payslips # Get payslips" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔄 Gateway (Port 80):" -ForegroundColor Green
    Write-Host "  All services accessible through gateway" -ForegroundColor White
    Write-Host "  /api/auth/*             # → Auth Service" -ForegroundColor Gray
    Write-Host "  /api/users/*            # → User Service" -ForegroundColor Gray
    Write-Host "  /api/hr/*               # → HR Service" -ForegroundColor Gray
}

# Main execution
switch ($Command.ToLower()) {
    "help" { Show-DemoHelp }
    "schema" { Show-Schema }
    "features" { Show-Features }
    "structure" { Show-Structure }
    "setup" { Show-Setup }
    "api" { Show-API }
    default { 
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-DemoHelp
    }
}
