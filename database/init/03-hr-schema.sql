-- HR SERVICE TABLES
USE hrsoft_hr;

-- User profiles (extended user information)
CREATE TABLE IF NOT EXISTS user_profiles (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    auth_user_id CHAR(36) UNIQUE NOT NULL COMMENT 'Reference to auth_users.id',
    employee_code VARCHAR(20) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    birth_date DATE,
    gender ENUM('male', 'female', 'other'),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_auth_user_id (auth_user_id),
    INDEX idx_employee_code (employee_code),
    INDEX idx_name (first_name, last_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_is_active (is_active)
);

-- Permissions table
CREATE TABLE IF NOT EXISTS permissions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100) UNIQUE NOT NULL,
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_resource (resource),
    UNIQUE KEY unique_resource_action (resource, action)
);

-- Role permissions mapping
CREATE TABLE IF NOT EXISTS role_permissions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    role_id CHAR(36) NOT NULL,
    permission_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id),
    UNIQUE KEY unique_role_permission (role_id, permission_id)
);

-- User roles mapping
CREATE TABLE IF NOT EXISTS user_roles (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL COMMENT 'Reference to user_profiles.id',
    role_id CHAR(36) NOT NULL,
    assigned_by CHAR(36) COMMENT 'Reference to user_profiles.id',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    INDEX idx_is_active (is_active)
);

-- Departments table
CREATE TABLE IF NOT EXISTS departments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    parent_department_id CHAR(36),
    head_employee_id CHAR(36) COMMENT 'Reference to employees.id',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_department_id) REFERENCES departments(id),
    INDEX idx_code (code),
    INDEX idx_parent_department_id (parent_department_id),
    INDEX idx_head_employee_id (head_employee_id),
    INDEX idx_is_active (is_active)
);

-- Positions table
CREATE TABLE IF NOT EXISTS positions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    title VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    department_id CHAR(36) NOT NULL,
    level INT DEFAULT 1,
    min_salary DECIMAL(15,2),
    max_salary DECIMAL(15,2),
    description TEXT,
    requirements TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (department_id) REFERENCES departments(id),
    INDEX idx_code (code),
    INDEX idx_department_id (department_id),
    INDEX idx_level (level),
    INDEX idx_is_active (is_active)
);

-- Employees table
CREATE TABLE IF NOT EXISTS employees (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) UNIQUE NOT NULL COMMENT 'Reference to user_profiles.id',
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE NULL,
    employment_status ENUM('active', 'inactive', 'terminated', 'suspended') DEFAULT 'active',
    employment_type ENUM('full_time', 'part_time', 'contract', 'intern') NOT NULL,
    probation_end_date DATE,
    manager_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (manager_id) REFERENCES employees(id),
    INDEX idx_user_id (user_id),
    INDEX idx_employee_id (employee_id),
    INDEX idx_employment_status (employment_status),
    INDEX idx_manager_id (manager_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Employee positions mapping
CREATE TABLE IF NOT EXISTS employee_positions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    employee_id CHAR(36) NOT NULL,
    position_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    is_primary BOOLEAN DEFAULT TRUE,
    salary DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES positions(id),
    INDEX idx_employee_id (employee_id),
    INDEX idx_position_id (position_id),
    INDEX idx_date_range (start_date, end_date),
    INDEX idx_is_primary (is_primary)
);

-- Attendances table
CREATE TABLE IF NOT EXISTS attendances (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    employee_id CHAR(36) NOT NULL,
    date DATE NOT NULL,
    check_in_time TIMESTAMP NULL,
    check_out_time TIMESTAMP NULL,
    break_duration INT DEFAULT 0 COMMENT 'minutes',
    work_hours DECIMAL(4,2) COMMENT 'Calculated from check_in/out',
    overtime_hours DECIMAL(4,2) DEFAULT 0,
    status ENUM('present', 'absent', 'late', 'half_day', 'holiday', 'sick_leave') DEFAULT 'present',
    notes TEXT,
    approved_by CHAR(36) COMMENT 'Reference to user_profiles.id',
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_id (employee_id),
    INDEX idx_date (date),
    INDEX idx_status (status),
    INDEX idx_approved_by (approved_by),
    UNIQUE KEY unique_employee_date (employee_id, date)
);

-- Payrolls table
CREATE TABLE IF NOT EXISTS payrolls (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    employee_id CHAR(36) NOT NULL,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    basic_salary DECIMAL(15,2) NOT NULL,
    overtime_pay DECIMAL(15,2) DEFAULT 0,
    allowances DECIMAL(15,2) DEFAULT 0,
    bonuses DECIMAL(15,2) DEFAULT 0,
    deductions DECIMAL(15,2) DEFAULT 0,
    tax_deduction DECIMAL(15,2) DEFAULT 0,
    gross_pay DECIMAL(15,2),
    net_pay DECIMAL(15,2),
    status ENUM('draft', 'approved', 'paid') DEFAULT 'draft',
    processed_by CHAR(36) COMMENT 'Reference to user_profiles.id',
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_id (employee_id),
    INDEX idx_pay_period (pay_period_start, pay_period_end),
    INDEX idx_status (status),
    INDEX idx_processed_by (processed_by),
    UNIQUE KEY unique_employee_pay_period (employee_id, pay_period_start, pay_period_end)
);
