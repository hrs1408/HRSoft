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

### Với Docker (Khuyến nghị)

1. **Clone dự án và di chuyển vào thư mục:**
```bash
cd HRSOFT
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
