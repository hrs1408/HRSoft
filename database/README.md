# HRSOFT Database Documentation

This directory contains all database-related files for the HRSOFT ERP system.

## 📁 Directory Structure

```
database/
├── init/                           # Database initialization scripts
│   ├── 01-databases.sql           # Create databases and users
│   ├── 02-auth-schema.sql         # Authentication service schema
│   ├── 03-hr-schema.sql           # HR service schema (basic)
│   ├── 04-inventory-schema.sql    # Inventory service schema
│   └── 05-hrsoft-normalized-schema.sql # Complete normalized schema
├── scripts/                       # Database utility scripts
│   ├── deploy_database.sh         # Linux/Mac deployment script
│   ├── deploy_database.ps1        # Windows deployment script
│   ├── backup.sql                 # Backup commands and procedures
│   └── maintenance.sql            # Maintenance and optimization queries
└── README.md                      # This file
```

## 🗄️ Database Schema Overview

The HRSOFT system uses a normalized MySQL database design with the following main modules:

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

### System Modules
- **Authentication**: Users, roles, permissions
- **Audit**: Activity logs, change tracking
- **Configuration**: System settings, notifications
- **File Management**: Document attachments

## 🚀 Database Deployment

### Quick Start (Development)

```bash
# Using PowerShell (Windows)
.\dev.ps1 db-deploy

# Using Batch (Windows)
dev.bat db-deploy

# Manual deployment (Windows)
.\database\scripts\deploy_database.ps1 dev

# Manual deployment (Linux/Mac)
./database/scripts/deploy_database.sh dev
```

### Environment Variables

Set these environment variables before deployment:

```bash
# MySQL Connection
MYSQL_HOST=localhost          # MySQL server host
MYSQL_PORT=3306              # MySQL server port
MYSQL_ROOT_USER=root         # MySQL root username
MYSQL_ROOT_PASSWORD=yourpass # MySQL root password
```

### Deployment Process

The deployment script will:

1. **Check MySQL Connection** - Verify database server is accessible
2. **Create Databases** - Create `hrsoft_auth`, `hrsoft_hr`, `hrsoft_inventory`
3. **Create Users** - Create dedicated database users with proper permissions
4. **Deploy Schemas** - Execute all SQL scripts in order
5. **Insert Initial Data** - Add default configurations and sample data
6. **Verify Deployment** - Check tables and data integrity

## 📊 Database Features

### Normalized Design
- **3NF compliance** for data integrity
- **Foreign key constraints** for referential integrity
- **Proper indexing** for performance optimization
- **UTF8MB4 charset** for full Unicode support

### Key Features
- **Multi-tenancy support** via company_id isolation
- **Audit trail** for all data changes
- **Soft deletes** for important records
- **Flexible configuration** system
- **File attachment** support
- **Notification system**

### Performance Optimizations
- **Strategic indexes** on frequently queried columns
- **Compound indexes** for complex queries
- **Partitioning ready** for large tables
- **Query optimization** views
- **Database maintenance** procedures

## 🔧 Database Operations

### Backup & Restore

```bash
# Create backup
.\dev.ps1 db-backup

# Restore from backup
.\dev.ps1 db-restore backup_file.sql

# Manual backup (full)
mysqldump -u root -p --databases hrsoft_auth hrsoft_hr hrsoft_inventory > backup.sql

# Manual backup (compressed)
mysqldump -u root -p --databases hrsoft_auth hrsoft_hr hrsoft_inventory | gzip > backup.sql.gz
```

### Maintenance

```sql
-- Run maintenance procedures
CALL MaintenanceCleanup();

-- Check database health
SELECT * FROM v_database_health;

-- View recent activity
SELECT * FROM v_recent_activity;
```

### Reset Database

```bash
# Reset entire database (WARNING: Deletes all data)
.\dev.ps1 db-reset
```

## 📋 Schema Details

### Main Tables by Module

#### Employee Management
- `companies` - Company information
- `employees` - Employee master data
- `departments` - Organizational departments
- `positions` - Job positions
- `employee_positions` - Employee-position assignments

#### Attendance & Leave
- `work_schedules` - Work schedule definitions
- `attendance_records` - Daily attendance records
- `leave_types` - Leave type definitions
- `leave_requests` - Employee leave requests
- `employee_leave_balances` - Leave balance tracking

#### Payroll
- `salary_components` - Salary component definitions
- `employee_salary_structures` - Employee salary structures
- `payroll_cycles` - Payroll processing cycles
- `payroll_records` - Individual payroll records
- `payroll_details` - Detailed payroll breakdowns

#### Performance & Training
- `performance_cycles` - Review cycles
- `performance_goals` - Employee goals
- `performance_reviews` - Performance evaluations
- `training_programs` - Training program catalog
- `training_sessions` - Training session scheduling
- `training_enrollments` - Employee training enrollments

### Key Relationships

```
Companies (1) -> (*) Departments
Departments (1) -> (*) Positions
Employees (1) -> (*) Employee_Positions
Employees (1) -> (*) Attendance_Records
Employees (1) -> (*) Leave_Requests
Employees (1) -> (*) Payroll_Records
```

## 🔐 Security Features

### User Permissions
- **Database users** with minimal required permissions
- **Read-only users** for reporting
- **Service-specific users** for each microservice

### Data Protection
- **Sensitive data encryption** (planned)
- **Audit logging** for all changes
- **Input validation** via constraints
- **SQL injection prevention** via prepared statements

## 📈 Performance Monitoring

### Key Metrics
- Database size and growth
- Query performance
- Index utilization
- Connection counts
- Slow query analysis

### Monitoring Queries
```sql
-- Database sizes
SELECT table_schema, ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
GROUP BY table_schema;

-- Table sizes
SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES 
WHERE table_schema = 'hrsoft_hr'
ORDER BY (data_length + index_length) DESC;
```

## 🐛 Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check MySQL server is running
   - Verify credentials and host/port
   - Check firewall settings

2. **Permission Denied**
   - Ensure MySQL user has required permissions
   - Check database user grants

3. **Table Already Exists**
   - Drop existing databases before deployment
   - Use `db-reset` to clean deploy

4. **Foreign Key Constraint Errors**
   - Check data integrity
   - Verify reference table data exists

### Debug Commands

```sql
-- Check MySQL status
SHOW STATUS;

-- Check user permissions
SHOW GRANTS FOR 'hrsoft_user'@'localhost';

-- Check table constraints
SELECT * FROM information_schema.KEY_COLUMN_USAGE 
WHERE table_schema = 'hrsoft_hr';

-- Check foreign key constraints
SELECT * FROM information_schema.REFERENTIAL_CONSTRAINTS 
WHERE constraint_schema = 'hrsoft_hr';
```

## 🔄 Migration Strategy

### Version Control
- Schema changes tracked in migration files
- Rollback procedures for each migration
- Data migration scripts for major changes

### Deployment Environments
- **Development**: Full reset allowed
- **Staging**: Migration-based updates
- **Production**: Careful migration with backups

## 📞 Support

For database-related issues:

1. Check this documentation
2. Review error logs
3. Run diagnostic queries
4. Check GitHub issues
5. Contact development team

## 🚀 Future Enhancements

- **Database clustering** for high availability
- **Read replicas** for reporting
- **Automated backup** scheduling
- **Data archiving** for old records
- **Advanced monitoring** dashboard
- **Performance tuning** optimization
