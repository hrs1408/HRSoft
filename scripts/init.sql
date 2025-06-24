-- Initialize HRSOFT Database

-- Create additional schemas if needed
-- CREATE SCHEMA IF NOT EXISTS auth;
-- CREATE SCHEMA IF NOT EXISTS users;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Initial data can be inserted here
-- For example, create default admin user (this would typically be handled by the application)

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'HRSOFT Database initialized successfully';
END $$;
