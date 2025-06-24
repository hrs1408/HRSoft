# HRSOFT - Hệ thống quản lý nhân sự

## Mô tả

HRSOFT là một hệ thống microservices được xây dựng bằng FastAPI để quản lý hệ thống nhân sự. Dự án bao gồm nhiều service độc lập, mỗi service chịu trách nhiệm cho một domain cụ thể.

## Kiến trúc Microservices

### Cấu trúc dự án:

```
HRSOFT/
├── docker-compose.yml          # Docker Compose cho toàn bộ hệ thống
├── nginx/                      # API Gateway & Load Balancer
│   ├── nginx.conf
│   └── Dockerfile
├── shared/                     # Shared modules cho tất cả services
│   ├── auth/                   # JWT handling & dependencies
│   ├── database/               # Database configuration
│   ├── models/                 # Base models
│   ├── utils/                  # Exceptions & logging
│   └── config/                 # Settings
├── services/                   # Microservices
│   ├── auth-service/           # Authentication & Authorization
│   │   ├── app/
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   ├── user-service/           # User & Employee Management
│   │   ├── app/
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── [other services...]
└── tests/                      # Test suites
    ├── unit/
    ├── integration/
    └── e2e/
```

## Services

### 1. Auth Service (Port 8001)
- **Chức năng**: Authentication, Authorization, JWT Token management
- **Endpoints**: `/api/auth/*`
- **Database**: Users, Refresh Tokens

### 2. User Service (Port 8002)
- **Chức năng**: Employee management, Department management
- **Endpoints**: `/api/users/*`
- **Database**: Employees, Departments, Employee Profiles

### 3. API Gateway (Nginx - Port 80)
- **Chức năng**: Load balancing, Routing, SSL termination
- **Routes**:
  - `/api/auth/*` → Auth Service
  - `/api/users/*` → User Service

## Cài đặt và Chạy

### Quick Start (Khuyến nghị)

**Windows PowerShell:**
```powershell
.\dev.ps1 setup
.\dev.ps1 up
```

**Windows Command Prompt:**
```cmd
dev.bat setup
dev.bat up
```

**Linux/Mac:**
```bash
make setup && make up
```

### Với Docker (Manual)

1. **Setup môi trường:**
```bash
# Tạo file .env từ template
cp .env.example .env
```

2. **Chạy toàn bộ hệ thống:**
```bash
docker-compose up -d
```

3. **Kiểm tra trạng thái services:**
```bash
docker-compose ps
```

### Development Mode (Local)

1. **Cài đặt dependencies cho shared modules:**
```bash
pip install pydantic sqlalchemy fastapi uvicorn python-jose passlib
```

2. **Chạy từng service riêng lẻ:**

**Auth Service:**
```bash
cd services/auth-service
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

**User Service:**
```bash
cd services/user-service
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8002
```

## API Documentation

Sau khi chạy hệ thống, bạn có thể truy cập:

- **API Gateway**: http://localhost
- **Auth Service**: http://localhost:8001/docs
- **User Service**: http://localhost:8002/docs

## API Endpoints

### Authentication Service (`/api/auth/`)
- `POST /api/auth/register` - Đăng ký người dùng mới
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - Đăng xuất
- `POST /api/auth/validate-token` - Validate token
- `GET /api/auth/me` - Thông tin user hiện tại

### User Service (`/api/users/`)

**Employees:**
- `POST /api/users/employees/` - Tạo nhân viên mới (HR only)
- `GET /api/users/employees/` - Danh sách nhân viên (có phân trang)
- `GET /api/users/employees/{id}` - Chi tiết nhân viên
- `PUT /api/users/employees/{id}` - Cập nhật nhân viên (HR only)
- `DELETE /api/users/employees/{id}` - Xóa nhân viên (HR only)

**Departments:**
- `POST /api/users/departments/` - Tạo phòng ban (HR only)
- `GET /api/users/departments/` - Danh sách phòng ban
- `GET /api/users/departments/{id}` - Chi tiết phòng ban
- `PUT /api/users/departments/{id}` - Cập nhật phòng ban (HR only)

## Authentication & Authorization

Hệ thống sử dụng JWT tokens với phân quyền theo roles:

- **admin**: Toàn quyền
- **hr**: Quản lý nhân sự
- **manager**: Quản lý nhóm
- **user**: Quyền cơ bản

### Sử dụng API với Authentication:

1. **Đăng nhập:**
```bash
curl -X POST "http://localhost/api/auth/login" \
     -H "Content-Type: application/json" \
     -d '{
       "username": "admin",
       "password": "admin123"
     }'
```

2. **Sử dụng token:**
```bash
curl -X GET "http://localhost/api/users/employees/" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Database

- **PostgreSQL**: Primary database cho tất cả services
- **Redis**: Caching và session storage
- **SQLAlchemy**: ORM cho Python

### Migration:
```bash
# Trong từng service directory
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

### Prerequisites Check

```bash
# Kiểm tra MySQL setup
.\dev.ps1 db-check

# Nếu chưa có MySQL, xem hướng dẫn
Get-Content database\MYSQL_SETUP.md
```

### Database Operations

```bash
# Deploy database schema
.\dev.ps1 db-deploy
# hoặc
dev.bat db-deploy

# Backup database
.\dev.ps1 db-backup

# Restore database
.\dev.ps1 db-restore <backup_file>

# Reset database (WARNING: xóa toàn bộ dữ liệu)
.\dev.ps1 db-reset
```

## 🎭 Demo Mode (Không cần MySQL)

Nếu chưa cài đặt MySQL, bạn có thể xem demo các tính năng:

```bash
# Xem tổng quan hệ thống
.\dev.ps1 demo

# Xem database schema
.\demo.ps1 schema

# Xem tính năng hệ thống  
.\demo.ps1 features

# Xem cấu trúc dự án
.\demo.ps1 structure

# Xem hướng dẫn setup
.\demo.ps1 setup

# Xem API endpoints
.\demo.ps1 api
```

## 🗄️ Database Schema

HRSOFT sử dụng thiết kế database chuẩn hóa (normalized) với MySQL, bao gồm các module:

### Core Modules
- **Organizations**: Companies, departments, positions, locations
- **Employee Management**: Employee records, positions, work schedules  
- **Attendance**: Time tracking, work schedules, overtime
- **Leave Management**: Leave types, requests, balances
- **Payroll**: Salary components, payroll cycles, records
- **Performance**: Review cycles, goals, evaluations
- **Training**: Programs, sessions, enrollments
- **Asset Management**: Categories, assets, assignments
- **Recruitment**: Job postings, candidates, applications

### System Features
- Multi-tenancy support via company isolation
- Complete audit trail for all changes
- Flexible configuration system
- File attachment support
- Notification system
- Performance optimized with strategic indexing

Chi tiết schema xem tại: [`database/README.md`](database/README.md)

## Development Commands

### Windows PowerShell
```powershell
.\dev.ps1 help           # Xem tất cả lệnh
.\dev.ps1 setup          # Setup môi trường
.\dev.ps1 up             # Start services
.\dev.ps1 down           # Stop services
.\dev.ps1 logs           # Xem logs
.\dev.ps1 health         # Kiểm tra health
.\dev.ps1 test           # Chạy tests
.\dev.ps1 clean          # Dọn dẹp containers
.\dev.ps1 dev-up         # Start development mode
```

### Windows Command Prompt
```cmd
dev.bat help             # Xem tất cả lệnh
dev.bat setup            # Setup môi trường
dev.bat up               # Start services
dev.bat down             # Stop services
dev.bat health           # Kiểm tra health
```

### Linux/Mac (Makefile)
```bash
make help                # Xem tất cả lệnh
make setup && make up    # Setup và start
make down                # Stop services
make clean               # Dọn dẹp
make test                # Chạy tests
```

## Testing

```bash
# Unit tests
pytest tests/unit/

# Integration tests
pytest tests/integration/

# E2E tests
pytest tests/e2e/
```

## Monitoring & Logging

- Logs được centralized qua shared logging utility
- Health checks cho tất cả services: `/health`
- Metrics có thể được thu thập qua prometheus (future implementation)

## Environment Variables

Tạo file `.env` từ `.env.example`:

```env
# Database
DATABASE_URL=postgresql://hrsoft_user:hrsoft_password@localhost/hrsoft_db

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Redis
REDIS_URL=redis://localhost:6379

# Services
AUTH_SERVICE_URL=http://localhost:8001
USER_SERVICE_URL=http://localhost:8002
```

## Roadmap

- [ ] ✅ Auth Service
- [ ] ✅ User Service  
- [ ] Attendance Service
- [ ] Payroll Service
- [ ] Notification Service
- [ ] Report Service
- [ ] File Upload Service
- [ ] API Rate Limiting
- [ ] Service Discovery
- [ ] Distributed Tracing
- [ ] Message Queue (RabbitMQ/Kafka)

## Đóng góp

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
# HRSoft
