#!/bin/bash

# HRSOFT Development Setup Script

echo "🚀 Setting up HRSOFT Development Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created. Please update the values as needed."
fi

# Build and start services
echo "🏗️  Building and starting services..."
docker-compose up -d --build

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
echo "Auth Service: $(curl -s http://localhost:8001/health | jq -r .status 2>/dev/null || echo 'Not ready')"
echo "User Service: $(curl -s http://localhost:8002/health | jq -r .status 2>/dev/null || echo 'Not ready')"
echo "API Gateway: $(curl -s http://localhost/health 2>/dev/null || echo 'Not ready')"

echo ""
echo "🎉 HRSOFT is ready!"
echo "📚 API Documentation:"
echo "   - Auth Service: http://localhost:8001/docs"
echo "   - User Service: http://localhost:8002/docs"
echo "   - API Gateway: http://localhost"
echo ""
echo "🔧 To stop services: docker-compose down"
echo "📊 To view logs: docker-compose logs -f"
