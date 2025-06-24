# HRSOFT Makefile

.PHONY: help setup build up down logs clean test lint format

help: ## Show this help message
	@echo "HRSOFT Development Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

setup: ## Setup development environment
	@echo "🔧 Setting up development environment..."
	@if [ ! -f .env ]; then cp .env.example .env; echo "📝 Created .env file"; fi
	@echo "✅ Environment setup complete!"

build: ## Build all services
	@echo "🏗️  Building all services..."
	@docker-compose build
	@echo "✅ Build complete!"

up: ## Start all services
	@echo "🚀 Starting all services..."
	@docker-compose up -d
	@echo "✅ Services started!"
	@echo "📚 API Documentation available at:"
	@echo "   - Auth Service: http://localhost:8001/docs"
	@echo "   - User Service: http://localhost:8002/docs"

down: ## Stop all services
	@echo "🛑 Stopping all services..."
	@docker-compose down
	@echo "✅ Services stopped!"

logs: ## View logs from all services
	@docker-compose logs -f

clean: ## Clean up containers and volumes
	@echo "🧹 Cleaning up..."
	@docker-compose down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup complete!"

test: ## Run tests
	@echo "🧪 Running tests..."
	@cd tests && python -m pytest -v
	@echo "✅ Tests complete!"

lint: ## Run linting
	@echo "🔍 Running linting..."
	@python -m flake8 services/ shared/ --max-line-length=100
	@echo "✅ Linting complete!"

format: ## Format code
	@echo "✨ Formatting code..."
	@python -m black services/ shared/ --line-length=100
	@echo "✅ Formatting complete!"

dev-up: ## Start development environment with hot reload
	@echo "🔥 Starting development environment..."
	@docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ Development environment started!"

dev-down: ## Stop development environment
	@echo "🛑 Stopping development environment..."
	@docker-compose -f docker-compose.dev.yml down
	@echo "✅ Development environment stopped!"

health: ## Check service health
	@echo "🏥 Checking service health..."
	@echo "Auth Service: $$(curl -s http://localhost:8001/health | jq -r .status 2>/dev/null || echo 'Not ready')"
	@echo "User Service: $$(curl -s http://localhost:8002/health | jq -r .status 2>/dev/null || echo 'Not ready')"
	@echo "API Gateway: $$(curl -s http://localhost/health 2>/dev/null | head -1 || echo 'Not ready')"

backup-db: ## Backup database
	@echo "💾 Backing up database..."
	@docker-compose exec postgres pg_dump -U hrsoft_user hrsoft_db > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup complete!"

restore-db: ## Restore database (usage: make restore-db FILE=backup.sql)
	@echo "📥 Restoring database from $(FILE)..."
	@docker-compose exec -T postgres psql -U hrsoft_user hrsoft_db < $(FILE)
	@echo "✅ Database restore complete!"

install-dev: ## Install development dependencies
	@echo "📦 Installing development dependencies..."
	@pip install -r tests/requirements.txt
	@pip install flake8 black
	@echo "✅ Development dependencies installed!"
