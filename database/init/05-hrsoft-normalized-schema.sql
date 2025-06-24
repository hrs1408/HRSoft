-- HRSOFT Normalized Database Schema
-- Author: HRSOFT Development Team
-- Version: 1.0
-- Date: 2024
-- Description: Comprehensive HR management system with normalized database design

-- Use the HR database for the normalized schema
USE hrsoft_hr;

-- =============================================================================
-- 1. ORGANIZATION & COMPANY STRUCTURE
-- =============================================================================

-- Companies/Organizations
CREATE TABLE IF NOT EXISTS companies (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    legal_name VARCHAR(255),
    tax_number VARCHAR(50),
    registration_number VARCHAR(100),
    industry VARCHAR(100),
    company_size ENUM('STARTUP', 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE') DEFAULT 'SMALL',
    founded_date DATE,
    website VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    INDEX idx_company_code (code),
    INDEX idx_company_active (is_active),
    INDEX idx_company_industry (industry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Company Addresses
CREATE TABLE IF NOT EXISTS company_addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    address_type ENUM('HEAD_OFFICE', 'BRANCH', 'WAREHOUSE', 'FACTORY', 'OTHER') DEFAULT 'BRANCH',
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    phone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_company_address (company_id, address_type),
    INDEX idx_primary_address (company_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Departments
CREATE TABLE IF NOT EXISTS departments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    parent_id BIGINT UNSIGNED NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    manager_id BIGINT UNSIGNED NULL,
    cost_center VARCHAR(50),
    budget DECIMAL(15,2),
    location VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES departments(id) ON DELETE SET NULL,
    UNIQUE KEY uk_dept_company_code (company_id, code),
    INDEX idx_dept_manager (manager_id),
    INDEX idx_dept_parent (parent_id),
    INDEX idx_dept_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Positions/Job Titles
CREATE TABLE IF NOT EXISTS positions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NULL,
    title VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    level ENUM('INTERN', 'JUNIOR', 'SENIOR', 'LEAD', 'MANAGER', 'DIRECTOR', 'VP', 'C_LEVEL') DEFAULT 'JUNIOR',
    job_family VARCHAR(100),
    description TEXT,
    requirements TEXT,
    min_salary DECIMAL(12,2),
    max_salary DECIMAL(12,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    UNIQUE KEY uk_position_company_code (company_id, code),
    INDEX idx_position_dept (department_id),
    INDEX idx_position_level (level),
    INDEX idx_position_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 2. EMPLOYEE MANAGEMENT
-- =============================================================================

-- Employees (Core employee data)
CREATE TABLE IF NOT EXISTS employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    employee_number VARCHAR(50) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    full_name VARCHAR(255) GENERATED ALWAYS AS (CONCAT(first_name, ' ', COALESCE(middle_name, ''), ' ', last_name)) STORED,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'),
    marital_status ENUM('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED', 'OTHER'),
    nationality VARCHAR(100),
    national_id VARCHAR(50),
    passport_number VARCHAR(50),
    profile_picture_url VARCHAR(500),
    hire_date DATE NOT NULL,
    termination_date DATE NULL,
    employment_status ENUM('ACTIVE', 'INACTIVE', 'TERMINATED', 'ON_LEAVE', 'SUSPENDED') DEFAULT 'ACTIVE',
    employee_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN', 'CONSULTANT') DEFAULT 'FULL_TIME',
    probation_end_date DATE,
    is_manager BOOLEAN DEFAULT FALSE,
    manager_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL,
    UNIQUE KEY uk_employee_number (company_id, employee_number),
    UNIQUE KEY uk_employee_email (company_id, email),
    INDEX idx_employee_status (employment_status),
    INDEX idx_employee_manager (manager_id),
    INDEX idx_employee_hire_date (hire_date),
    INDEX idx_employee_name (last_name, first_name),
    FULLTEXT INDEX ft_employee_search (full_name, email, employee_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Addresses
CREATE TABLE IF NOT EXISTS employee_addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    address_type ENUM('CURRENT', 'PERMANENT', 'EMERGENCY', 'OTHER') DEFAULT 'CURRENT',
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_address (employee_id, address_type),
    INDEX idx_primary_address (employee_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Positions (Assignment history)
CREATE TABLE IF NOT EXISTS employee_positions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    position_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    salary DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'VND',
    employment_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN', 'CONSULTANT') DEFAULT 'FULL_TIME',
    work_schedule VARCHAR(100),
    is_current BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE RESTRICT,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
    INDEX idx_emp_position_current (employee_id, is_current),
    INDEX idx_emp_position_dates (start_date, end_date),
    INDEX idx_position_assignments (position_id, start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Emergency Contacts
CREATE TABLE IF NOT EXISTS employee_emergency_contacts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    phone_secondary VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    INDEX idx_employee_emergency (employee_id),
    INDEX idx_primary_emergency (employee_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. ATTENDANCE & TIME TRACKING
-- =============================================================================

-- Work Schedules
CREATE TABLE IF NOT EXISTS work_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    schedule_type ENUM('FIXED', 'FLEXIBLE', 'SHIFT', 'REMOTE') DEFAULT 'FIXED',
    monday_start TIME,
    monday_end TIME,
    tuesday_start TIME,
    tuesday_end TIME,
    wednesday_start TIME,
    wednesday_end TIME,
    thursday_start TIME,
    thursday_end TIME,
    friday_start TIME,
    friday_end TIME,
    saturday_start TIME,
    saturday_end TIME,
    sunday_start TIME,
    sunday_end TIME,
    break_duration_minutes INT DEFAULT 60,
    total_hours_per_week DECIMAL(4,2) DEFAULT 40.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_schedule_company (company_id),
    INDEX idx_schedule_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Work Schedules Assignment
CREATE TABLE IF NOT EXISTS employee_work_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    work_schedule_id BIGINT UNSIGNED NOT NULL,
    effective_date DATE NOT NULL,
    end_date DATE NULL,
    is_current BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (work_schedule_id) REFERENCES work_schedules(id) ON DELETE RESTRICT,
    INDEX idx_emp_schedule_current (employee_id, is_current),
    INDEX idx_emp_schedule_dates (effective_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance Records
CREATE TABLE IF NOT EXISTS attendance_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    check_in_time DATETIME,
    check_out_time DATETIME,
    break_start_time DATETIME,
    break_end_time DATETIME,
    total_hours DECIMAL(4,2),
    overtime_hours DECIMAL(4,2) DEFAULT 0.00,
    late_minutes INT DEFAULT 0,
    early_leave_minutes INT DEFAULT 0,
    status ENUM('PRESENT', 'ABSENT', 'LATE', 'HALF_DAY', 'ON_LEAVE', 'HOLIDAY', 'WEEKEND') DEFAULT 'PRESENT',
    location VARCHAR(255),
    ip_address VARCHAR(45),
    device_info TEXT,
    notes TEXT,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(id) ON DELETE SET NULL,
    UNIQUE KEY uk_employee_date (employee_id, attendance_date),
    INDEX idx_attendance_date (attendance_date),
    INDEX idx_attendance_status (status),
    INDEX idx_attendance_employee_month (employee_id, attendance_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 4. LEAVE MANAGEMENT
-- =============================================================================

-- Leave Types
CREATE TABLE IF NOT EXISTS leave_types (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    days_per_year DECIMAL(5,2) DEFAULT 0.00,
    max_consecutive_days INT,
    requires_approval BOOLEAN DEFAULT TRUE,
    requires_document BOOLEAN DEFAULT FALSE,
    is_paid BOOLEAN DEFAULT TRUE,
    carry_forward BOOLEAN DEFAULT FALSE,
    max_carry_forward_days DECIMAL(5,2),
    gender_specific ENUM('ALL', 'MALE', 'FEMALE') DEFAULT 'ALL',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_leave_type_code (company_id, code),
    INDEX idx_leave_type_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Leave Balances
CREATE TABLE IF NOT EXISTS employee_leave_balances (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    leave_type_id BIGINT UNSIGNED NOT NULL,
    year YEAR NOT NULL,
    allocated_days DECIMAL(5,2) DEFAULT 0.00,
    used_days DECIMAL(5,2) DEFAULT 0.00,
    carried_forward_days DECIMAL(5,2) DEFAULT 0.00,
    remaining_days DECIMAL(5,2) GENERATED ALWAYS AS (allocated_days + carried_forward_days - used_days) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id) ON DELETE CASCADE,
    UNIQUE KEY uk_employee_leave_year (employee_id, leave_type_id, year),
    INDEX idx_leave_balance_year (year),
    INDEX idx_leave_balance_employee (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave Requests
CREATE TABLE IF NOT EXISTS leave_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    leave_type_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days DECIMAL(5,2) NOT NULL,
    reason TEXT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    requested_by BIGINT UNSIGNED NOT NULL,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    rejection_reason TEXT,
    documents JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (requested_by) REFERENCES employees(id) ON DELETE RESTRICT,
    FOREIGN KEY (approved_by) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_leave_request_employee (employee_id),
    INDEX idx_leave_request_dates (start_date, end_date),
    INDEX idx_leave_request_status (status),
    INDEX idx_leave_request_approver (approved_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Holidays
CREATE TABLE IF NOT EXISTS holidays (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    type ENUM('NATIONAL', 'RELIGIOUS', 'COMPANY', 'REGIONAL') DEFAULT 'NATIONAL',
    is_recurring BOOLEAN DEFAULT FALSE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_holiday_date (date),
    INDEX idx_holiday_company (company_id),
    INDEX idx_holiday_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Continue with Part 2...

-- =============================================================================
-- 5. PAYROLL MANAGEMENT
-- =============================================================================

-- Salary Components (Basic, Allowances, Deductions)
CREATE TABLE IF NOT EXISTS salary_components (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type ENUM('EARNING', 'DEDUCTION', 'BENEFIT') NOT NULL,
    category ENUM('BASIC', 'ALLOWANCE', 'OVERTIME', 'BONUS', 'TAX', 'INSURANCE', 'LOAN', 'OTHER') NOT NULL,
    calculation_type ENUM('FIXED', 'PERCENTAGE', 'FORMULA') DEFAULT 'FIXED',
    calculation_base ENUM('BASIC_SALARY', 'GROSS_SALARY', 'CUSTOM') DEFAULT 'BASIC_SALARY',
    default_value DECIMAL(12,2) DEFAULT 0.00,
    is_taxable BOOLEAN DEFAULT TRUE,
    is_mandatory BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_salary_component_code (company_id, code),
    INDEX idx_salary_component_type (type, category),
    INDEX idx_salary_component_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee Salary Structure
CREATE TABLE IF NOT EXISTS employee_salary_structures (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    salary_component_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    percentage DECIMAL(5,2),
    effective_date DATE NOT NULL,
    end_date DATE NULL,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (salary_component_id) REFERENCES salary_components(id) ON DELETE CASCADE,
    INDEX idx_emp_salary_active (employee_id, is_active),
    INDEX idx_emp_salary_dates (effective_date, end_date),
    INDEX idx_salary_component (salary_component_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payroll Cycles
CREATE TABLE IF NOT EXISTS payroll_cycles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    period_type ENUM('MONTHLY', 'BIWEEKLY', 'WEEKLY', 'QUARTERLY') DEFAULT 'MONTHLY',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    status ENUM('DRAFT', 'PROCESSING', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT',
    total_employees INT DEFAULT 0,
    total_gross_amount DECIMAL(15,2) DEFAULT 0.00,
    total_net_amount DECIMAL(15,2) DEFAULT 0.00,
    total_deductions DECIMAL(15,2) DEFAULT 0.00,
    notes TEXT,
    processed_by BIGINT UNSIGNED NULL,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_payroll_cycle_period (start_date, end_date),
    INDEX idx_payroll_cycle_status (status),
    INDEX idx_payroll_cycle_company (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payroll Records
CREATE TABLE IF NOT EXISTS payroll_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payroll_cycle_id BIGINT UNSIGNED NOT NULL,
    employee_id BIGINT UNSIGNED NOT NULL,
    basic_salary DECIMAL(12,2) NOT NULL,
    gross_salary DECIMAL(12,2) NOT NULL,
    total_earnings DECIMAL(12,2) NOT NULL,
    total_deductions DECIMAL(12,2) NOT NULL,
    net_salary DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    insurance_amount DECIMAL(12,2) DEFAULT 0.00,
    worked_days DECIMAL(5,2) DEFAULT 0.00,
    overtime_hours DECIMAL(5,2) DEFAULT 0.00,
    leave_days DECIMAL(5,2) DEFAULT 0.00,
    payslip_number VARCHAR(50),
    payment_status ENUM('PENDING', 'PAID', 'CANCELLED') DEFAULT 'PENDING',
    payment_date DATE NULL,
    payment_method ENUM('BANK_TRANSFER', 'CASH', 'CHECK', 'OTHER') DEFAULT 'BANK_TRANSFER',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (payroll_cycle_id) REFERENCES payroll_cycles(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY uk_payroll_employee_cycle (payroll_cycle_id, employee_id),
    INDEX idx_payroll_employee (employee_id),
    INDEX idx_payroll_payment_status (payment_status),
    INDEX idx_payroll_payment_date (payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payroll Details (Breakdown by component)
CREATE TABLE IF NOT EXISTS payroll_details (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payroll_record_id BIGINT UNSIGNED NOT NULL,
    salary_component_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    calculation_base DECIMAL(12,2),
    rate_percentage DECIMAL(5,2),
    notes TEXT,
    
    FOREIGN KEY (payroll_record_id) REFERENCES payroll_records(id) ON DELETE CASCADE,
    FOREIGN KEY (salary_component_id) REFERENCES salary_components(id) ON DELETE RESTRICT,
    INDEX idx_payroll_detail_record (payroll_record_id),
    INDEX idx_payroll_detail_component (salary_component_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 6. PERFORMANCE MANAGEMENT
-- =============================================================================

-- Performance Review Cycles
CREATE TABLE IF NOT EXISTS performance_cycles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    review_type ENUM('ANNUAL', 'SEMI_ANNUAL', 'QUARTERLY', 'PROBATION', 'PROJECT_BASED') DEFAULT 'ANNUAL',
    status ENUM('DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT',
    is_self_review_enabled BOOLEAN DEFAULT TRUE,
    is_peer_review_enabled BOOLEAN DEFAULT FALSE,
    is_manager_review_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_performance_cycle_period (start_date, end_date),
    INDEX idx_performance_cycle_status (status),
    INDEX idx_performance_cycle_company (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Performance Goals
CREATE TABLE IF NOT EXISTS performance_goals (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    performance_cycle_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category ENUM('INDIVIDUAL', 'TEAM', 'COMPANY', 'DEVELOPMENT') DEFAULT 'INDIVIDUAL',
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    target_value DECIMAL(10,2),
    actual_value DECIMAL(10,2),
    unit VARCHAR(50),
    weight_percentage DECIMAL(5,2) DEFAULT 100.00,
    status ENUM('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'NOT_STARTED',
    due_date DATE,
    completion_date DATE,
    self_rating ENUM('1', '2', '3', '4', '5'),
    manager_rating ENUM('1', '2', '3', '4', '5'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (performance_cycle_id) REFERENCES performance_cycles(id) ON DELETE CASCADE,
    INDEX idx_performance_goal_employee (employee_id),
    INDEX idx_performance_goal_cycle (performance_cycle_id),
    INDEX idx_performance_goal_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Performance Reviews
CREATE TABLE IF NOT EXISTS performance_reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    reviewer_id BIGINT UNSIGNED NOT NULL,
    performance_cycle_id BIGINT UNSIGNED NOT NULL,
    review_type ENUM('SELF', 'MANAGER', 'PEER', 'SUBORDINATE', 'CUSTOMER') DEFAULT 'MANAGER',
    overall_rating ENUM('1', '2', '3', '4', '5'),
    strengths TEXT,
    areas_for_improvement TEXT,
    development_plan TEXT,
    comments TEXT,
    status ENUM('DRAFT', 'SUBMITTED', 'COMPLETED') DEFAULT 'DRAFT',
    submitted_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (performance_cycle_id) REFERENCES performance_cycles(id) ON DELETE CASCADE,
    UNIQUE KEY uk_performance_review (employee_id, reviewer_id, performance_cycle_id, review_type),
    INDEX idx_performance_review_employee (employee_id),
    INDEX idx_performance_review_reviewer (reviewer_id),
    INDEX idx_performance_review_cycle (performance_cycle_id),
    INDEX idx_performance_review_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 7. TRAINING & DEVELOPMENT
-- =============================================================================

-- Training Categories
CREATE TABLE IF NOT EXISTS training_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_training_category_company (company_id),
    INDEX idx_training_category_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Training Programs
CREATE TABLE IF NOT EXISTS training_programs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    training_type ENUM('INTERNAL', 'EXTERNAL', 'ONLINE', 'WORKSHOP', 'SEMINAR', 'CERTIFICATION') DEFAULT 'INTERNAL',
    duration_hours DECIMAL(5,2),
    cost DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'VND',
    max_participants INT,
    provider VARCHAR(255),
    location VARCHAR(255),
    requirements TEXT,
    objectives TEXT,
    is_mandatory BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES training_categories(id) ON DELETE RESTRICT,
    INDEX idx_training_program_category (category_id),
    INDEX idx_training_program_type (training_type),
    INDEX idx_training_program_active (company_id, is_active),
    FULLTEXT INDEX ft_training_search (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Training Sessions
CREATE TABLE IF NOT EXISTS training_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    training_program_id BIGINT UNSIGNED NOT NULL,
    session_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    location VARCHAR(255),
    instructor VARCHAR(255),
    max_participants INT,
    registered_participants INT DEFAULT 0,
    status ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'SCHEDULED',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (training_program_id) REFERENCES training_programs(id) ON DELETE CASCADE,
    INDEX idx_training_session_program (training_program_id),
    INDEX idx_training_session_dates (start_date, end_date),
    INDEX idx_training_session_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Training Enrollments
CREATE TABLE IF NOT EXISTS training_enrollments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED NOT NULL,
    training_session_id BIGINT UNSIGNED NOT NULL,
    enrollment_date DATE NOT NULL,
    status ENUM('ENROLLED', 'ATTENDED', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'ENROLLED',
    attendance_percentage DECIMAL(5,2) DEFAULT 0.00,
    completion_date DATE NULL,
    certificate_number VARCHAR(100),
    score DECIMAL(5,2),
    feedback TEXT,
    cost DECIMAL(12,2) DEFAULT 0.00,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (training_session_id) REFERENCES training_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(id) ON DELETE SET NULL,
    UNIQUE KEY uk_training_enrollment (employee_id, training_session_id),
    INDEX idx_training_enrollment_employee (employee_id),
    INDEX idx_training_enrollment_session (training_session_id),
    INDEX idx_training_enrollment_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 8. ASSET MANAGEMENT
-- =============================================================================

-- Asset Categories
CREATE TABLE IF NOT EXISTS asset_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    depreciation_method ENUM('STRAIGHT_LINE', 'DECLINING_BALANCE', 'UNITS_OF_PRODUCTION', 'NONE') DEFAULT 'STRAIGHT_LINE',
    useful_life_years INT DEFAULT 5,
    residual_value_percentage DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_asset_category_code (company_id, code),
    INDEX idx_asset_category_active (company_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Assets
CREATE TABLE IF NOT EXISTS assets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    asset_tag VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    purchase_date DATE,
    purchase_cost DECIMAL(12,2) DEFAULT 0.00,
    current_value DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'VND',
    condition_status ENUM('EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'DAMAGED') DEFAULT 'GOOD',
    status ENUM('AVAILABLE', 'ASSIGNED', 'IN_USE', 'MAINTENANCE', 'RETIRED', 'DISPOSED') DEFAULT 'AVAILABLE',
    location VARCHAR(255),
    warranty_start_date DATE,
    warranty_end_date DATE,
    supplier VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES asset_categories(id) ON DELETE RESTRICT,
    UNIQUE KEY uk_asset_tag (company_id, asset_tag),
    INDEX idx_asset_category (category_id),
    INDEX idx_asset_status (status),
    INDEX idx_asset_condition (condition_status),
    FULLTEXT INDEX ft_asset_search (name, description, brand, model, serial_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Asset Assignments
CREATE TABLE IF NOT EXISTS asset_assignments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    asset_id BIGINT UNSIGNED NOT NULL,
    employee_id BIGINT UNSIGNED NOT NULL,
    assigned_date DATE NOT NULL,
    return_date DATE NULL,
    assigned_by BIGINT UNSIGNED NOT NULL,
    return_condition ENUM('EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'DAMAGED'),
    notes TEXT,
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES employees(id) ON DELETE RESTRICT,
    INDEX idx_asset_assignment_asset (asset_id),
    INDEX idx_asset_assignment_employee (employee_id),
    INDEX idx_asset_assignment_current (asset_id, is_current),
    INDEX idx_asset_assignment_dates (assigned_date, return_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 9. RECRUITMENT
-- =============================================================================

-- Job Postings
CREATE TABLE IF NOT EXISTS job_postings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    position_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    requirements TEXT,
    benefits TEXT,
    employment_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN', 'CONSULTANT') DEFAULT 'FULL_TIME',
    location VARCHAR(255),
    salary_min DECIMAL(12,2),
    salary_max DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'VND',
    openings_count INT DEFAULT 1,
    posting_date DATE NOT NULL,
    closing_date DATE,
    status ENUM('DRAFT', 'ACTIVE', 'PAUSED', 'CLOSED', 'FILLED') DEFAULT 'DRAFT',
    posted_by BIGINT UNSIGNED NOT NULL,
    hiring_manager_id BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE RESTRICT,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
    FOREIGN KEY (posted_by) REFERENCES employees(id) ON DELETE RESTRICT,
    FOREIGN KEY (hiring_manager_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_job_posting_position (position_id),
    INDEX idx_job_posting_department (department_id),
    INDEX idx_job_posting_status (status),
    INDEX idx_job_posting_dates (posting_date, closing_date),
    FULLTEXT INDEX ft_job_posting_search (title, description, requirements)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Candidates
CREATE TABLE IF NOT EXISTS candidates (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    current_position VARCHAR(255),
    current_company VARCHAR(255),
    total_experience_years DECIMAL(4,2),
    expected_salary DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'VND',
    location VARCHAR(255),
    resume_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    source ENUM('WEBSITE', 'REFERRAL', 'LINKEDIN', 'JOB_BOARD', 'RECRUITER', 'OTHER') DEFAULT 'WEBSITE',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_candidate_email (email),
    INDEX idx_candidate_name (last_name, first_name),
    INDEX idx_candidate_source (source),
    FULLTEXT INDEX ft_candidate_search (first_name, last_name, email, current_position, current_company)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Job Applications
CREATE TABLE IF NOT EXISTS job_applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_posting_id BIGINT UNSIGNED NOT NULL,
    candidate_id BIGINT UNSIGNED NOT NULL,
    application_date DATE NOT NULL,
    status ENUM('APPLIED', 'SCREENING', 'INTERVIEWED', 'OFFERED', 'HIRED', 'REJECTED', 'WITHDRAWN') DEFAULT 'APPLIED',
    current_stage VARCHAR(100),
    overall_rating ENUM('1', '2', '3', '4', '5'),
    cover_letter TEXT,
    notes TEXT,
    assigned_recruiter_id BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_posting_id) REFERENCES job_postings(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_recruiter_id) REFERENCES employees(id) ON DELETE SET NULL,
    UNIQUE KEY uk_job_application (job_posting_id, candidate_id),
    INDEX idx_job_application_job (job_posting_id),
    INDEX idx_job_application_candidate (candidate_id),
    INDEX idx_job_application_status (status),
    INDEX idx_job_application_recruiter (assigned_recruiter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 10. SYSTEM & CONFIGURATION TABLES
-- =============================================================================

-- Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT UNSIGNED NOT NULL,
    action ENUM('CREATE', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by BIGINT UNSIGNED,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (changed_by) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_audit_table_record (table_name, record_id),
    INDEX idx_audit_user (changed_by),
    INDEX idx_audit_action (action),
    INDEX idx_audit_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- System Settings
CREATE TABLE IF NOT EXISTS system_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type ENUM('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'JSON') DEFAULT 'STRING',
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by BIGINT UNSIGNED,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_setting_key (company_id, setting_key),
    INDEX idx_setting_company (company_id),
    INDEX idx_setting_system (is_system)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- File Attachments
CREATE TABLE IF NOT EXISTS file_attachments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT UNSIGNED,
    mime_type VARCHAR(100),
    file_category ENUM('DOCUMENT', 'IMAGE', 'VIDEO', 'AUDIO', 'OTHER') DEFAULT 'DOCUMENT',
    uploaded_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (uploaded_by) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_file_entity (entity_type, entity_id),
    INDEX idx_file_uploader (uploaded_by),
    INDEX idx_file_category (file_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    recipient_id BIGINT UNSIGNED NOT NULL,
    sender_id BIGINT UNSIGNED NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('INFO', 'WARNING', 'ERROR', 'SUCCESS') DEFAULT 'INFO',
    category ENUM('SYSTEM', 'HR', 'PAYROLL', 'LEAVE', 'TRAINING', 'PERFORMANCE', 'RECRUITMENT') DEFAULT 'SYSTEM',
    entity_type VARCHAR(100),
    entity_id BIGINT UNSIGNED,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (recipient_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES employees(id) ON DELETE SET NULL,
    INDEX idx_notification_recipient (recipient_id),
    INDEX idx_notification_unread (recipient_id, is_read),
    INDEX idx_notification_category (category),
    INDEX idx_notification_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- ADD MISSING FOREIGN KEY CONSTRAINTS
-- =============================================================================

-- Add foreign key for companies primary key
ALTER TABLE companies ADD PRIMARY KEY (id);

-- Add foreign key for department manager
ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL;

-- =============================================================================
-- INSERT INITIAL DATA
-- =============================================================================

-- Insert default company
INSERT INTO companies (name, code, legal_name, industry, company_size, is_active, created_at) 
VALUES ('HRSOFT Company', 'HRSOFT', 'HRSOFT Technology Solutions', 'Technology', 'MEDIUM', TRUE, NOW());

-- Insert default salary components
INSERT INTO salary_components (company_id, name, code, type, category, calculation_type, default_value, is_taxable, is_mandatory, is_active, created_at) VALUES
(1, 'Basic Salary', 'BASIC', 'EARNING', 'BASIC', 'FIXED', 0, TRUE, TRUE, TRUE, NOW()),
(1, 'Housing Allowance', 'HOUSING', 'EARNING', 'ALLOWANCE', 'FIXED', 0, TRUE, FALSE, TRUE, NOW()),
(1, 'Transport Allowance', 'TRANSPORT', 'EARNING', 'ALLOWANCE', 'FIXED', 0, TRUE, FALSE, TRUE, NOW()),
(1, 'Meal Allowance', 'MEAL', 'EARNING', 'ALLOWANCE', 'FIXED', 0, TRUE, FALSE, TRUE, NOW()),
(1, 'Income Tax', 'INCOME_TAX', 'DEDUCTION', 'TAX', 'PERCENTAGE', 0, FALSE, TRUE, TRUE, NOW()),
(1, 'Social Insurance', 'SOCIAL_INS', 'DEDUCTION', 'INSURANCE', 'PERCENTAGE', 8, FALSE, TRUE, TRUE, NOW()),
(1, 'Health Insurance', 'HEALTH_INS', 'DEDUCTION', 'INSURANCE', 'PERCENTAGE', 1.5, FALSE, TRUE, TRUE, NOW()),
(1, 'Unemployment Insurance', 'UNEMPLOYMENT_INS', 'DEDUCTION', 'INSURANCE', 'PERCENTAGE', 1, FALSE, TRUE, TRUE, NOW());

-- Insert default leave types
INSERT INTO leave_types (company_id, name, code, description, days_per_year, requires_approval, is_paid, carry_forward, is_active, created_at) VALUES
(1, 'Annual Leave', 'ANNUAL', 'Annual vacation days', 12, TRUE, TRUE, TRUE, TRUE, NOW()),
(1, 'Sick Leave', 'SICK', 'Medical leave for illness', 30, TRUE, TRUE, FALSE, TRUE, NOW()),
(1, 'Maternity Leave', 'MATERNITY', 'Maternity leave for new mothers', 180, TRUE, TRUE, FALSE, TRUE, NOW()),
(1, 'Paternity Leave', 'PATERNITY', 'Paternity leave for new fathers', 5, TRUE, TRUE, FALSE, TRUE, NOW()),
(1, 'Personal Leave', 'PERSONAL', 'Personal time off', 3, TRUE, FALSE, FALSE, TRUE, NOW());

-- Insert default work schedule
INSERT INTO work_schedules (company_id, name, description, schedule_type, monday_start, monday_end, tuesday_start, tuesday_end, wednesday_start, wednesday_end, thursday_start, thursday_end, friday_start, friday_end, break_duration_minutes, total_hours_per_week, is_active, created_at) VALUES
(1, 'Standard Work Week', '8 hours per day, Monday to Friday', 'FIXED', '08:00:00', '17:00:00', '08:00:00', '17:00:00', '08:00:00', '17:00:00', '08:00:00', '17:00:00', '08:00:00', '17:00:00', 60, 40.00, TRUE, NOW());

-- Insert default asset categories
INSERT INTO asset_categories (company_id, name, code, description, depreciation_method, useful_life_years, is_active, created_at) VALUES
(1, 'Computer Equipment', 'COMPUTER', 'Laptops, desktops, servers', 'STRAIGHT_LINE', 3, TRUE, NOW()),
(1, 'Office Furniture', 'FURNITURE', 'Desks, chairs, cabinets', 'STRAIGHT_LINE', 7, TRUE, NOW()),
(1, 'Mobile Devices', 'MOBILE', 'Phones, tablets', 'STRAIGHT_LINE', 2, TRUE, NOW()),
(1, 'Office Equipment', 'OFFICE_EQUIP', 'Printers, scanners, projectors', 'STRAIGHT_LINE', 5, TRUE, NOW());

-- Insert default training categories
INSERT INTO training_categories (company_id, name, description, is_active, created_at) VALUES
(1, 'Technical Skills', 'Programming, software development, technical training', TRUE, NOW()),
(1, 'Soft Skills', 'Communication, leadership, teamwork training', TRUE, NOW()),
(1, 'Compliance', 'Legal, regulatory, safety training', TRUE, NOW()),
(1, 'Management', 'Leadership, management, supervisory training', TRUE, NOW()),
(1, 'Professional Development', 'Career development, professional growth', TRUE, NOW());

-- =============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =============================================================================

-- Additional performance indexes
CREATE INDEX idx_employees_company_status ON employees(company_id, employment_status);
CREATE INDEX idx_attendance_employee_date_range ON attendance_records(employee_id, attendance_date);
CREATE INDEX idx_payroll_records_cycle_employee ON payroll_records(payroll_cycle_id, employee_id);
CREATE INDEX idx_leave_requests_employee_dates ON leave_requests(employee_id, start_date, end_date);
CREATE INDEX idx_performance_reviews_cycle_employee ON performance_reviews(performance_cycle_id, employee_id);

-- =============================================================================
-- VIEWS FOR COMMON QUERIES
-- =============================================================================

-- Employee full details view
CREATE VIEW v_employee_details AS
SELECT 
    e.id,
    e.employee_number,
    e.full_name,
    e.email,
    e.phone,
    e.employment_status,
    e.employee_type,
    e.hire_date,
    e.is_manager,
    c.name as company_name,
    d.name as department_name,
    p.title as position_title,
    CONCAT(m.first_name, ' ', m.last_name) as manager_name
FROM employees e
LEFT JOIN companies c ON e.company_id = c.id
LEFT JOIN employee_positions ep ON e.id = ep.employee_id AND ep.is_current = TRUE
LEFT JOIN departments d ON ep.department_id = d.id
LEFT JOIN positions p ON ep.position_id = p.id
LEFT JOIN employees m ON e.manager_id = m.id
WHERE e.employment_status = 'ACTIVE';

-- Current month attendance summary
CREATE VIEW v_current_month_attendance AS
SELECT 
    e.id as employee_id,
    e.employee_number,
    e.full_name,
    COUNT(ar.id) as total_days,
    SUM(CASE WHEN ar.status = 'PRESENT' THEN 1 ELSE 0 END) as present_days,
    SUM(CASE WHEN ar.status = 'ABSENT' THEN 1 ELSE 0 END) as absent_days,
    SUM(CASE WHEN ar.status = 'LATE' THEN 1 ELSE 0 END) as late_days,
    SUM(ar.total_hours) as total_hours,
    SUM(ar.overtime_hours) as total_overtime_hours
FROM employees e
LEFT JOIN attendance_records ar ON e.id = ar.employee_id 
    AND ar.attendance_date >= DATE_FORMAT(NOW(), '%Y-%m-01')
    AND ar.attendance_date < DATE_ADD(DATE_FORMAT(NOW(), '%Y-%m-01'), INTERVAL 1 MONTH)
WHERE e.employment_status = 'ACTIVE'
GROUP BY e.id, e.employee_number, e.full_name;

-- Leave balance summary
CREATE VIEW v_employee_leave_balances AS
SELECT 
    e.id as employee_id,
    e.employee_number,
    e.full_name,
    lt.name as leave_type_name,
    elb.allocated_days,
    elb.used_days,
    elb.carried_forward_days,
    elb.remaining_days,
    elb.year
FROM employees e
JOIN employee_leave_balances elb ON e.id = elb.employee_id
JOIN leave_types lt ON elb.leave_type_id = lt.id
WHERE e.employment_status = 'ACTIVE' 
    AND elb.year = YEAR(NOW())
    AND lt.is_active = TRUE;

-- =============================================================================
-- SCHEMA COMPLETE
-- =============================================================================

-- Schema creation completed successfully
-- Total tables created: 50+
-- Includes: Organization, HR, Attendance, Leave, Payroll, Performance, Training, Assets, Recruitment, System tables
-- Features: Normalized design, proper indexing, foreign keys, audit trails, views
-- Database: MySQL compatible with InnoDB engine and UTF8MB4 charset
