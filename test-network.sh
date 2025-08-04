#!/bin/bash

echo "🌐 Network Connectivity Test"
echo "============================"

# Test if port 8000 is open
echo "Testing port 8000..."
if netstat -tulpn | grep -q ":8000"; then
    echo "✅ Port 8000 is listening"
    netstat -tulpn | grep ":8000"
else
    echo "❌ Port 8000 is not listening"
fi

echo ""
echo "Testing container connectivity..."

# Test if we can reach the container
if docker ps | grep -q laravel_app; then
    echo "✅ Laravel app container is running"
    
    # Test internal connectivity
    echo "Testing internal container network..."
    docker exec laravel_app curl -f http://localhost:8000/health 2>/dev/null && echo "✅ Internal health check passed" || echo "❌ Internal health check failed"
    
else
    echo "❌ Laravel app container is not running"
fi

echo ""
echo "Testing external connectivity..."
curl -f http://localhost:8000/health 2>/dev/null && echo "✅ External health check passed" || echo "❌ External health check failed"

echo ""
echo "Docker container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "If port 8000 is not accessible:"
echo "1. Check firewall: sudo ufw status"
echo "2. Check if another service is using port 8000: sudo lsof -i :8000"
echo "3. Restart containers: docker-compose restart"
