#!/bin/bash

# Laravel Debug Script for Docker
echo "🔍 Laravel Docker Debug Information"
echo "=================================="

# Check if containers are running
echo "📦 Container Status:"
docker-compose ps

echo ""
echo "🔗 Database Connection Test:"
docker-compose exec -T app php artisan tinker --execute="DB::connection()->getPdo(); echo 'Database connected successfully!';"

echo ""
echo "📋 Laravel Application Status:"
docker-compose exec -T app php artisan about

echo ""
echo "🗂️ Storage Permissions:"
docker-compose exec -T app ls -la storage/

echo ""
echo "📝 Recent Application Logs:"
docker-compose exec -T app tail -n 20 storage/logs/laravel.log

echo ""
echo "🐳 Container Logs (last 50 lines):"
docker-compose logs --tail=50 app

echo ""
echo "🌐 Test Routes:"
echo "Testing if Laravel is responding..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8000

echo ""
echo "🔧 Environment Check:"
docker-compose exec -T app php artisan env

echo ""
echo "Debug complete! Check the output above for any errors."
