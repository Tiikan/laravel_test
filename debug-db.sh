#!/bin/bash

# Database Debug Script for Laravel Application
# This script helps diagnose database connection issues

echo "🔍 Laravel Database Debug Script"
echo "================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if containers are running
print_status "Checking container status..."
docker-compose -f docker-compose.prod.yml ps

echo ""
print_status "Checking database container logs..."
docker-compose -f docker-compose.prod.yml logs db | tail -20

echo ""
print_status "Checking application container logs..."
docker-compose -f docker-compose.prod.yml logs app | tail -20

echo ""
print_status "Testing database connection from host..."
if command -v mysql &> /dev/null; then
    mysql -h 127.0.0.1 -P 3307 -u pixelip -pKang@2k25 -e "SELECT 'Database connection successful!' as status;" 2>/dev/null || print_error "Cannot connect to database from host"
else
    print_warning "MySQL client not installed on host"
fi

echo ""
print_status "Testing database connection from app container..."
docker-compose -f docker-compose.prod.yml exec app php -r "
try {
    \$pdo = new PDO('mysql:host=db;port=3306;dbname=laravel', 'pixelip', 'Kang@2k25');
    echo 'Database connection from app container: SUCCESS\n';
} catch (Exception \$e) {
    echo 'Database connection from app container: FAILED - ' . \$e->getMessage() . '\n';
}
" 2>/dev/null || print_error "Cannot execute command in app container"

echo ""
print_status "Checking database health..."
docker-compose -f docker-compose.prod.yml exec db mysqladmin ping -h localhost -u root -pKang@2k25 2>/dev/null && print_success "Database is responding to ping" || print_error "Database is not responding"

echo ""
print_status "Checking if Laravel tables exist..."
docker-compose -f docker-compose.prod.yml exec app php artisan migrate:status 2>/dev/null || print_warning "Cannot check migration status"

echo ""
print_status "Environment variables in app container:"
docker-compose -f docker-compose.prod.yml exec app env | grep -E "(DB_|APP_)" | sort

echo ""
print_status "Quick fixes to try:"
echo "1. Restart containers: docker-compose -f docker-compose.prod.yml restart"
echo "2. Rebuild containers: docker-compose -f docker-compose.prod.yml up -d --build"
echo "3. Reset database: docker-compose -f docker-compose.prod.yml down -v && docker-compose -f docker-compose.prod.yml up -d"
echo "4. Check firewall: sudo ufw status"
echo "5. Check disk space: df -h"

echo ""
print_status "Debug completed!"
