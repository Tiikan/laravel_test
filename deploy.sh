#!/bin/bash

# Laravel Docker Deployment Script
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
PROJECT_NAME="laravel_test"

echo "🚀 Starting Laravel deployment for $ENVIRONMENT environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p storage/app/public
mkdir -p storage/framework/{cache,sessions,views}
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Set proper permissions
print_status "Setting proper permissions..."
chmod -R 775 storage bootstrap/cache

# Copy environment file
if [ ! -f .env ]; then
    if [ -f .env.$ENVIRONMENT ]; then
        print_status "Copying .env.$ENVIRONMENT to .env..."
        cp .env.$ENVIRONMENT .env
    else
        print_warning ".env file not found. Please create one before deployment."
        exit 1
    fi
fi

# Generate application key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    print_status "Generating application key..."
    # This will be done inside the container
    echo "APP_KEY will be generated during container build..."
fi

# Build and start containers
print_status "Building Docker containers..."
docker-compose down --remove-orphans
docker-compose build --no-cache

print_status "Starting containers..."
docker-compose up -d

# Wait for database to be ready
print_status "Waiting for database to be ready..."
sleep 30

# Run database migrations
print_status "Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Clear and cache configurations
print_status "Optimizing application..."
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

# Create storage link
print_status "Creating storage link..."
docker-compose exec -T app php artisan storage:link

print_status "✅ Deployment completed successfully!"
print_status "🌐 Application is available at: http://localhost:8000"
print_status "🗄️  Database is available at: localhost:3307"

# Show container status
print_status "Container status:"
docker-compose ps

echo ""
print_status "To view logs, run: docker-compose logs -f"
print_status "To stop the application, run: docker-compose down"
