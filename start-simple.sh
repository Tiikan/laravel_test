#!/bin/bash
set -e

echo "🚀 Starting Laravel Application..."
echo "Working directory: $(pwd)"
echo "PHP version: $(php --version | head -n 1)"

# Change to the correct directory
cd /var/www

# List files to debug
echo "Files in /var/www:"
ls -la

# Check if artisan exists
if [ ! -f "artisan" ]; then
    echo "❌ ERROR: artisan file not found!"
    echo "Current directory: $(pwd)"
    echo "Files in current directory:"
    ls -la
    exit 1
fi

echo "✅ artisan file found"

# Wait for database
echo "Waiting for database connection..."
for i in {1..30}; do
    if php -r "
        try {
            \$pdo = new PDO('mysql:host=db;port=3306;dbname=laravel', 'pixelip', 'Kang@2k25');
            echo 'Database connected!';
            exit(0);
        } catch (Exception \$e) {
            exit(1);
        }
    " > /dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo "❌ Database connection timeout"
        exit 1
    fi
    
    echo "Waiting for database... ($i/30)"
    sleep 2
done

# Run Laravel commands
echo "Running Laravel setup..."

# Generate key if needed
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Cache configuration
echo "Caching configuration..."
php artisan config:cache

# Start server
echo "🚀 Starting Laravel development server..."
echo "Application will be available at:"
echo "  - http://localhost:8000"
echo "  - http://192.168.10.200:8000"
echo ""

exec php artisan serve --host=0.0.0.0 --port=8000
