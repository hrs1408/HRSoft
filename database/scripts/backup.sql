-- =============================================================================
-- BACKUP SCRIPT FOR HRSOFT DATABASE
-- =============================================================================
-- This script contains common backup and restore commands
-- Run these commands from MySQL command line or phpMyAdmin

-- =============================================================================
-- 1. FULL DATABASE BACKUP
-- =============================================================================

-- Backup all HRSOFT databases
-- mysqldump -u root -p --databases hrsoft_auth hrsoft_hr hrsoft_inventory > hrsoft_full_backup.sql

-- Backup with data compression
-- mysqldump -u root -p --databases hrsoft_auth hrsoft_hr hrsoft_inventory --single-transaction --routines --triggers | gzip > hrsoft_backup_$(date +%Y%m%d_%H%M%S).sql.gz

-- =============================================================================
-- 2. INDIVIDUAL DATABASE BACKUP
-- =============================================================================

-- Backup Authentication Database
-- mysqldump -u root -p hrsoft_auth > hrsoft_auth_backup.sql

-- Backup HR Database
-- mysqldump -u root -p hrsoft_hr > hrsoft_hr_backup.sql

-- Backup Inventory Database
-- mysqldump -u root -p hrsoft_inventory > hrsoft_inventory_backup.sql

-- =============================================================================
-- 3. SCHEMA ONLY BACKUP (No Data)
-- =============================================================================

-- Backup schema structure only
-- mysqldump -u root -p --no-data --databases hrsoft_auth hrsoft_hr hrsoft_inventory > hrsoft_schema_only.sql

-- =============================================================================
-- 4. DATA ONLY BACKUP (No Schema)
-- =============================================================================

-- Backup data only
-- mysqldump -u root -p --no-create-info --databases hrsoft_auth hrsoft_hr hrsoft_inventory > hrsoft_data_only.sql

-- =============================================================================
-- 5. SELECTIVE TABLE BACKUP
-- =============================================================================

-- Backup specific tables from HR database
-- mysqldump -u root -p hrsoft_hr companies departments employees positions > hrsoft_hr_core_tables.sql

-- Backup attendance related tables
-- mysqldump -u root -p hrsoft_hr attendance_records attendance_adjustments work_schedules > hrsoft_attendance_backup.sql

-- Backup payroll related tables
-- mysqldump -u root -p hrsoft_hr payroll_cycles payroll_records payroll_details salary_components employee_salary_structures > hrsoft_payroll_backup.sql

-- =============================================================================
-- 6. RESTORE COMMANDS
-- =============================================================================

-- Restore full backup
-- mysql -u root -p < hrsoft_full_backup.sql

-- Restore compressed backup
-- gunzip < hrsoft_backup_20241208_143000.sql.gz | mysql -u root -p

-- Restore specific database
-- mysql -u root -p hrsoft_hr < hrsoft_hr_backup.sql

-- =============================================================================
-- 7. INCREMENTAL BACKUP QUERIES
-- =============================================================================

-- Get all records modified in last 24 hours
SELECT 'employees' as table_name, COUNT(*) as modified_count 
FROM hrsoft_hr.employees 
WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

UNION ALL

SELECT 'attendance_records' as table_name, COUNT(*) as modified_count 
FROM hrsoft_hr.attendance_records 
WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

UNION ALL

SELECT 'leave_requests' as table_name, COUNT(*) as modified_count 
FROM hrsoft_hr.leave_requests 
WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

UNION ALL

SELECT 'payroll_records' as table_name, COUNT(*) as modified_count 
FROM hrsoft_hr.payroll_records 
WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- =============================================================================
-- 8. CLEANUP OLD BACKUP FILES (Run from command line)
-- =============================================================================

-- Remove backup files older than 30 days (Linux/Mac)
-- find /path/to/backup/directory -name "hrsoft_backup_*.sql*" -mtime +30 -delete

-- Remove backup files older than 30 days (Windows PowerShell)
-- Get-ChildItem -Path "C:\path\to\backup\directory" -Name "hrsoft_backup_*.sql*" | Where-Object CreationTime -lt (Get-Date).AddDays(-30) | Remove-Item

-- =============================================================================
-- 9. BACKUP VERIFICATION QUERIES
-- =============================================================================

-- Check table counts after restore
SELECT 
    'companies' as table_name, 
    COUNT(*) as record_count 
FROM hrsoft_hr.companies
UNION ALL
SELECT 'employees', COUNT(*) FROM hrsoft_hr.employees
UNION ALL
SELECT 'departments', COUNT(*) FROM hrsoft_hr.departments
UNION ALL
SELECT 'positions', COUNT(*) FROM hrsoft_hr.positions
UNION ALL
SELECT 'attendance_records', COUNT(*) FROM hrsoft_hr.attendance_records
UNION ALL
SELECT 'leave_requests', COUNT(*) FROM hrsoft_hr.leave_requests
UNION ALL
SELECT 'payroll_records', COUNT(*) FROM hrsoft_hr.payroll_records;

-- Check database sizes
SELECT 
    table_schema as 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
GROUP BY table_schema;

-- =============================================================================
-- 10. AUTOMATED BACKUP SCRIPT TEMPLATE
-- =============================================================================

/*
Create a shell script for automated backups:

#!/bin/bash
# hrsoft_backup.sh

BACKUP_DIR="/var/backups/hrsoft"
DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_USER="backup_user"
MYSQL_PASSWORD="your_password"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Full backup
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD \
    --single-transaction \
    --routines \
    --triggers \
    --databases hrsoft_auth hrsoft_hr hrsoft_inventory \
    | gzip > $BACKUP_DIR/hrsoft_full_backup_$DATE.sql.gz

# Schema only backup
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD \
    --no-data \
    --databases hrsoft_auth hrsoft_hr hrsoft_inventory \
    > $BACKUP_DIR/hrsoft_schema_$DATE.sql

# Remove backups older than 30 days
find $BACKUP_DIR -name "hrsoft_*_backup_*.sql.gz" -mtime +30 -delete
find $BACKUP_DIR -name "hrsoft_schema_*.sql" -mtime +30 -delete

echo "Backup completed: $DATE"
*/

-- =============================================================================
-- 11. WINDOWS POWERSHELL BACKUP SCRIPT
-- =============================================================================

/*
Create hrsoft_backup.ps1:

# HRSOFT Database Backup Script
$BackupDir = "C:\Backups\HRSOFT"
$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$MySQLPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin"

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force
}

# Full backup
& "$MySQLPath\mysqldump.exe" -u root -p --single-transaction --routines --triggers --databases hrsoft_auth hrsoft_hr hrsoft_inventory | Out-File -FilePath "$BackupDir\hrsoft_full_backup_$Date.sql" -Encoding UTF8

# Compress backup
Compress-Archive -Path "$BackupDir\hrsoft_full_backup_$Date.sql" -DestinationPath "$BackupDir\hrsoft_full_backup_$Date.zip"
Remove-Item "$BackupDir\hrsoft_full_backup_$Date.sql"

# Remove old backups (older than 30 days)
Get-ChildItem -Path $BackupDir -Name "hrsoft_full_backup_*.zip" | Where-Object CreationTime -lt (Get-Date).AddDays(-30) | Remove-Item

Write-Host "Backup completed: $Date"
*/
