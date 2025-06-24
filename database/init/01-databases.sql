-- Initialize databases for HRSOFT ERP
-- This script creates all necessary databases

CREATE DATABASE IF NOT EXISTS hrsoft_auth;
CREATE DATABASE IF NOT EXISTS hrsoft_hr;
CREATE DATABASE IF NOT EXISTS hrsoft_inventory;

-- Create dedicated users for each service
CREATE USER IF NOT EXISTS 'auth_user'@'%' IDENTIFIED BY 'auth_password';
CREATE USER IF NOT EXISTS 'hr_user'@'%' IDENTIFIED BY 'hr_password';
CREATE USER IF NOT EXISTS 'inventory_user'@'%' IDENTIFIED BY 'inventory_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON hrsoft_auth.* TO 'auth_user'@'%';
GRANT ALL PRIVILEGES ON hrsoft_hr.* TO 'hr_user'@'%';
GRANT ALL PRIVILEGES ON hrsoft_inventory.* TO 'inventory_user'@'%';

-- Allow root access to all databases
GRANT ALL PRIVILEGES ON hrsoft_auth.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON hrsoft_hr.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON hrsoft_inventory.* TO 'root'@'%';

FLUSH PRIVILEGES;
