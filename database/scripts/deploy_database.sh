#!/bin/bash

# =============================================================================
# HRSOFT DATABASE DEPLOYMENT SCRIPT
# =============================================================================
# This script helps deploy the HRSOFT database schema and initial data
# Usage: ./deploy_database.sh [environment]
# Environments: dev, staging, prod

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DATABASE_DIR="$PROJECT_ROOT/database"

# Default values
ENVIRONMENT="${1:-dev}"
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_ROOT_USER="${MYSQL_ROOT_USER:-root}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if MySQL is running
check_mysql() {
    log "Checking MySQL connection..."
    if ! mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
        error "Cannot connect to MySQL server at $MYSQL_HOST:$MYSQL_PORT"
        error "Please check your MySQL credentials and server status"
        exit 1
    fi
    log "MySQL connection successful"
}

# Check if required files exist
check_files() {
    log "Checking required files..."
    
    local required_files=(
        "$DATABASE_DIR/init/01-databases.sql"
        "$DATABASE_DIR/init/02-auth-schema.sql"
        "$DATABASE_DIR/init/03-hr-schema.sql"
        "$DATABASE_DIR/init/04-inventory-schema.sql"
        "$DATABASE_DIR/init/05-hrsoft-normalized-schema.sql"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file not found: $file"
            exit 1
        fi
    done
    
    log "All required files found"
}

# Execute SQL file
execute_sql() {
    local sql_file="$1"
    local description="$2"
    
    log "Executing: $description"
    info "File: $(basename "$sql_file")"
    
    if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" < "$sql_file"; then
        log "✓ $description completed successfully"
    else
        error "✗ Failed to execute: $description"
        exit 1
    fi
}

# Create databases and users
create_databases() {
    log "Creating databases and users..."
    execute_sql "$DATABASE_DIR/init/01-databases.sql" "Database and user creation"
}

# Deploy auth schema
deploy_auth_schema() {
    log "Deploying authentication schema..."
    execute_sql "$DATABASE_DIR/init/02-auth-schema.sql" "Authentication schema deployment"
}

# Deploy HR schema
deploy_hr_schema() {
    log "Deploying HR schema..."
    execute_sql "$DATABASE_DIR/init/03-hr-schema.sql" "HR schema deployment"
}

# Deploy inventory schema
deploy_inventory_schema() {
    log "Deploying inventory schema..."
    execute_sql "$DATABASE_DIR/init/04-inventory-schema.sql" "Inventory schema deployment"
}

# Deploy normalized schema
deploy_normalized_schema() {
    log "Deploying normalized HRSOFT schema..."
    execute_sql "$DATABASE_DIR/init/05-hrsoft-normalized-schema.sql" "Normalized schema deployment"
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check if databases exist
    local databases=(
        "hrsoft_auth"
        "hrsoft_hr"
        "hrsoft_inventory"
    )
    
    for db in "${databases[@]}"; do
        if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "USE $db; SELECT 1;" &>/dev/null; then
            log "✓ Database $db exists and is accessible"
        else
            error "✗ Database $db is not accessible"
            exit 1
        fi
    done
    
    # Check if main tables exist
    local table_count=$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "
        SELECT COUNT(*) 
        FROM information_schema.tables 
        WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
    " -s -N)
    
    if [[ $table_count -gt 0 ]]; then
        log "✓ Found $table_count tables in HRSOFT databases"
    else
        error "✗ No tables found in HRSOFT databases"
        exit 1
    fi
    
    log "Deployment verification completed successfully"
}

# Show deployment summary
show_summary() {
    log "Deployment Summary:"
    info "Environment: $ENVIRONMENT"
    info "MySQL Host: $MYSQL_HOST:$MYSQL_PORT"
    info "Databases: hrsoft_auth, hrsoft_hr, hrsoft_inventory"
    
    # Get table counts
    mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "
        SELECT 
            table_schema as 'Database',
            COUNT(*) as 'Tables'
        FROM information_schema.tables 
        WHERE table_schema IN ('hrsoft_auth', 'hrsoft_hr', 'hrsoft_inventory')
        GROUP BY table_schema
        ORDER BY table_schema;
    "
}

# Backup existing database
backup_existing() {
    if [[ "$ENVIRONMENT" != "dev" ]]; then
        log "Creating backup of existing databases..."
        local backup_file="hrsoft_backup_$(date +%Y%m%d_%H%M%S).sql"
        
        if mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" \
            --databases hrsoft_auth hrsoft_hr hrsoft_inventory > "$backup_file" 2>/dev/null; then
            log "✓ Backup created: $backup_file"
        else
            warn "Could not create backup (databases might not exist yet)"
        fi
    fi
}

# Main deployment function
main() {
    log "Starting HRSOFT Database Deployment"
    log "Environment: $ENVIRONMENT"
    log "Target: $MYSQL_HOST:$MYSQL_PORT"
    
    # Confirmation for production
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        warn "You are about to deploy to PRODUCTION environment!"
        read -p "Are you sure you want to continue? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log "Deployment cancelled by user"
            exit 0
        fi
    fi
    
    # Run deployment steps
    check_mysql
    check_files
    backup_existing
    create_databases
    deploy_auth_schema
    deploy_hr_schema
    deploy_inventory_schema
    deploy_normalized_schema
    verify_deployment
    show_summary
    
    log "🎉 HRSOFT Database Deployment completed successfully!"
    log "You can now start the application services"
    
    if [[ "$ENVIRONMENT" == "dev" ]]; then
        info "To start the development environment:"
        info "  ./dev.sh docker-up"
        info "  ./dev.sh start-all"
    fi
}

# Handle script arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        echo "HRSOFT Database Deployment Script"
        echo "Usage: $0 [environment]"
        echo ""
        echo "Environments:"
        echo "  dev      - Development environment (default)"
        echo "  staging  - Staging environment"
        echo "  prod     - Production environment"
        echo ""
        echo "Environment Variables:"
        echo "  MYSQL_HOST           - MySQL host (default: localhost)"
        echo "  MYSQL_PORT           - MySQL port (default: 3306)"
        echo "  MYSQL_ROOT_USER      - MySQL root user (default: root)"
        echo "  MYSQL_ROOT_PASSWORD  - MySQL root password"
        echo ""
        echo "Examples:"
        echo "  $0 dev"
        echo "  MYSQL_HOST=db.example.com $0 prod"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
