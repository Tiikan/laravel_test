#!/bin/bash

# Laravel Application Server Deployment Script
# This script deploys the Laravel application on Ubuntu server

set -e

echo "🚀 Starting Laravel Application Deployment..."

# Configuration
COMPOSE_FILE="docker-compose.prod.yml"
APP_NAME="laravel-app"

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

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. Consider using a non-root user with Docker group membership."
fi

print_status "Checking Docker service..."
if ! systemctl is-active --quiet docker; then
    print_status "Starting Docker service..."
    sudo systemctl start docker
fi

print_status "Pulling latest changes from repository..."
if [ -d ".git" ]; then
    git pull origin main || git pull origin master
else
    print_warning "Not a git repository. Skipping git pull."
fi

print_status "Stopping existing containers..."
docker-compose -f $COMPOSE_FILE down || true

print_status "Removing old images (optional cleanup)..."
docker image prune -f || true

print_status "Building and starting containers..."
docker-compose -f $COMPOSE_FILE up -d --build

print_status "Waiting for services to be ready..."
sleep 10

# Check if containers are running
print_status "Checking container status..."
if docker-compose -f $COMPOSE_FILE ps | grep -q "Up"; then
    print_status "✅ Containers are running successfully!"
else
    print_error "❌ Some containers failed to start. Check logs:"
    docker-compose -f $COMPOSE_FILE logs
    exit 1
fi

# Wait for application to be ready
print_status "Waiting for application to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_status "✅ Application is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        print_warning "Application health check timeout. Check logs if needed."
    fi
    sleep 2
done

print_status "🎉 Deployment completed successfully!"
print_status ""
print_status "Application URLs:"
print_status "  - Main App: http://$(hostname -I | awk '{print $1}'):8000"
print_status "  - Health Check: http://$(hostname -I | awk '{print $1}'):8000/health"
print_status "  - Database: $(hostname -I | awk '{print $1}'):3307"
print_status ""
print_status "Useful commands:"
print_status "  - View logs: docker-compose -f $COMPOSE_FILE logs"
print_status "  - Restart: docker-compose -f $COMPOSE_FILE restart"
print_status "  - Stop: docker-compose -f $COMPOSE_FILE down"
print_status ""
print_status "Deployment completed at: $(date)"
