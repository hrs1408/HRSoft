-- =============================================================================
-- DATABASE MAINTENANCE SCRIPT FOR HRSOFT
-- =============================================================================
-- This script contains maintenance queries for database optimization and cleanup

-- =============================================================================
-- 1. ANALYZE TABLE STATISTICS
-- =============================================================================

-- Analyze all tables in HR database
ANALYZE TABLE hrsoft_hr.companies;
ANALYZE TABLE hrsoft_hr.employees;
ANALYZE TABLE hrsoft_hr.departments;
ANALYZE TABLE hrsoft_hr.positions;
ANALYZE TABLE hrsoft_hr.attendance_records;
ANALYZE TABLE hrsoft_hr.leave_requests;
ANALYZE TABLE hrsoft_hr.payroll_records;
ANALYZE TABLE hrsoft_hr.performance_reviews;
ANALYZE TABLE hrsoft_hr.training_enrollments;
ANALYZE TABLE hrsoft_hr.assets;

-- =============================================================================
-- 2. OPTIMIZE TABLES
-- =============================================================================

-- Optimize frequently used tables
OPTIMIZE TABLE hrsoft_hr.attendance_records;
OPTIMIZE TABLE hrsoft_hr.payroll_records;
OPTIMIZE TABLE hrsoft_hr.leave_requests;
OPTIMIZE TABLE hrsoft_hr.employees;
OPTIMIZE TABLE hrsoft_hr.audit_logs;

-- =============================================================================
-- 3. CHECK TABLE INTEGRITY
-- =============================================================================

-- Check tables for corruption
CHECK TABLE hrsoft_hr.companies;
CHECK TABLE hrsoft_hr.employees;
CHECK TABLE hrsoft_hr.attendance_records;
CHECK TABLE hrsoft_hr.payroll_records;

-- =============================================================================
-- 4. DATABASE SIZE ANALYSIS
-- =============================================================================

-- Check database sizes
SELECT 
    table_schema as 'Database',
    table_name as 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as 'Size (MB)',
    table_rows as 'Rows'
FROM information_schema.TABLES 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
ORDER BY (data_length + index_length) DESC;

-- Total database size
SELECT 
    table_schema as 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Total Size (MB)'
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
GROUP BY table_schema;

-- =============================================================================
-- 5. INDEX ANALYSIS
-- =============================================================================

-- Check unused indexes
SELECT 
    t.table_schema as 'Database',
    t.table_name as 'Table',
    s.index_name as 'Index',
    s.column_name as 'Column',
    s.cardinality as 'Cardinality'
FROM information_schema.statistics s
JOIN information_schema.tables t ON s.table_name = t.table_name
WHERE t.table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
    AND s.index_name != 'PRIMARY'
ORDER BY s.cardinality DESC;

-- Check duplicate indexes
SELECT 
    table_schema,
    table_name,
    index_name,
    GROUP_CONCAT(column_name ORDER BY seq_in_index) as columns
FROM information_schema.statistics
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
GROUP BY table_schema, table_name, index_name
HAVING COUNT(*) > 1;

-- =============================================================================
-- 6. CLEANUP OLD RECORDS
-- =============================================================================

-- Delete old audit logs (older than 1 year)
DELETE FROM hrsoft_hr.audit_logs 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Delete old attendance records (older than 2 years)
DELETE FROM hrsoft_hr.attendance_records 
WHERE attendance_date < DATE_SUB(NOW(), INTERVAL 2 YEAR);

-- Delete cancelled leave requests (older than 6 months)
DELETE FROM hrsoft_hr.leave_requests 
WHERE status = 'CANCELLED' 
    AND created_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Delete old notifications (older than 3 months)
DELETE FROM hrsoft_hr.notifications 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH);

-- =============================================================================
-- 7. REBUILD FOREIGN KEY CONSTRAINTS
-- =============================================================================

-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Check foreign key constraints
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- =============================================================================
-- 8. PERFORMANCE MONITORING QUERIES
-- =============================================================================

-- Check slow queries configuration
SHOW VARIABLES LIKE 'slow_query_log%';
SHOW VARIABLES LIKE 'long_query_time';

-- Check connection status
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Max_used_connections';
SHOW STATUS LIKE 'Threads_connected';

-- Check buffer pool status
SHOW STATUS LIKE 'Innodb_buffer_pool%';

-- =============================================================================
-- 9. USER ACTIVITY ANALYSIS
-- =============================================================================

-- Most active employees (by login frequency)
SELECT 
    e.employee_number,
    e.full_name,
    COUNT(*) as login_count,
    MAX(al.created_at) as last_login
FROM hrsoft_hr.audit_logs al
JOIN hrsoft_hr.employees e ON al.changed_by = e.id
WHERE al.action = 'CREATE' 
    AND al.table_name = 'user_sessions'
    AND al.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY e.id, e.employee_number, e.full_name
ORDER BY login_count DESC
LIMIT 20;

-- Database activity by hour
SELECT 
    HOUR(created_at) as hour,
    COUNT(*) as activity_count
FROM hrsoft_hr.audit_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY HOUR(created_at)
ORDER BY hour;

-- =============================================================================
-- 10. DATA CONSISTENCY CHECKS
-- =============================================================================

-- Check for employees without department assignments
SELECT 
    e.id,
    e.employee_number,
    e.full_name,
    e.employment_status
FROM hrsoft_hr.employees e
LEFT JOIN hrsoft_hr.employee_positions ep ON e.id = ep.employee_id AND ep.is_current = TRUE
WHERE ep.id IS NULL 
    AND e.employment_status = 'ACTIVE';

-- Check for duplicate employee numbers
SELECT 
    employee_number,
    COUNT(*) as count
FROM hrsoft_hr.employees
GROUP BY employee_number
HAVING COUNT(*) > 1;

-- Check for orphaned attendance records
SELECT COUNT(*) as orphaned_attendance
FROM hrsoft_hr.attendance_records ar
LEFT JOIN hrsoft_hr.employees e ON ar.employee_id = e.id
WHERE e.id IS NULL;

-- Check for leave requests without valid leave types
SELECT COUNT(*) as invalid_leave_requests
FROM hrsoft_hr.leave_requests lr
LEFT JOIN hrsoft_hr.leave_types lt ON lr.leave_type_id = lt.id
WHERE lt.id IS NULL OR lt.is_active = FALSE;

-- =============================================================================
-- 11. REINDEX COMMANDS
-- =============================================================================

-- Rebuild all indexes for a table (example for attendance_records)
ALTER TABLE hrsoft_hr.attendance_records ENGINE=InnoDB;

-- Rebuild primary key
-- ALTER TABLE hrsoft_hr.table_name DROP PRIMARY KEY, ADD PRIMARY KEY (id);

-- =============================================================================
-- 12. AUTOMATED MAINTENANCE SCRIPT
-- =============================================================================

DELIMITER //

CREATE PROCEDURE MaintenanceCleanup()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Delete old audit logs
    DELETE FROM hrsoft_hr.audit_logs 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

    -- Delete old notifications
    DELETE FROM hrsoft_hr.notifications 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH);

    -- Optimize tables
    OPTIMIZE TABLE hrsoft_hr.attendance_records;
    OPTIMIZE TABLE hrsoft_hr.audit_logs;
    OPTIMIZE TABLE hrsoft_hr.notifications;

    -- Analyze tables
    ANALYZE TABLE hrsoft_hr.employees;
    ANALYZE TABLE hrsoft_hr.attendance_records;
    ANALYZE TABLE hrsoft_hr.payroll_records;

    COMMIT;

    SELECT 'Maintenance cleanup completed successfully' as status;
END //

DELIMITER ;

-- Run maintenance procedure
-- CALL MaintenanceCleanup();

-- =============================================================================
-- 13. MONITORING VIEWS
-- =============================================================================

-- Create monitoring views for easier access
CREATE OR REPLACE VIEW v_database_health AS
SELECT 
    'Table Count' as metric,
    COUNT(*) as value,
    'tables' as unit
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')

UNION ALL

SELECT 
    'Total Size' as metric,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as value,
    'MB' as unit
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')

UNION ALL

SELECT 
    'Active Employees' as metric,
    COUNT(*) as value,
    'employees' as unit
FROM hrsoft_hr.employees 
WHERE employment_status = 'ACTIVE';

-- View recent database activity
CREATE OR REPLACE VIEW v_recent_activity AS
SELECT 
    table_name,
    action,
    COUNT(*) as count,
    MAX(created_at) as last_action
FROM hrsoft_hr.audit_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY table_name, action
ORDER BY last_action DESC;

-- =============================================================================
-- MAINTENANCE SCRIPT COMPLETE
-- =============================================================================
