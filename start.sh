#!/bin/bash
set -e

# Function to wait for database
wait_for_database() {
    echo "Waiting for database connection..."
    local max_attempts=60
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: Checking database connection..."

        # Try to connect to database using PHP
        if php -r "
            try {
                \$pdo = new PDO('mysql:host=db;port=3306;dbname=laravel', 'pixelip', 'Kang@2k25');
                echo 'Database connection successful!';
                exit(0);
            } catch (Exception \$e) {
                echo 'Database connection failed: ' . \$e->getMessage();
                exit(1);
            }
        " > /dev/null 2>&1; then
            echo "✅ Database is ready!"
            return 0
        fi

        echo "Database not ready, waiting 5 seconds..."
        sleep 5
        attempt=$((attempt + 1))
    done

    echo "❌ Database connection timeout after $max_attempts attempts"
    return 1
}

# Wait for database
wait_for_database

# Check if artisan file exists
echo "Checking artisan file..."
if [ ! -f "/var/www/artisan" ]; then
    echo "❌ artisan file not found at /var/www/artisan"
    ls -la /var/www/
    exit 1
fi

echo "✅ artisan file found"
ls -la /var/www/artisan

# Change to working directory
cd /var/www

# Generate application key if not exists
echo "Checking application key..."
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    echo "Generating application key..."
    /usr/local/bin/php /var/www/artisan key:generate --force
fi

# Run database migrations
echo "Running database migrations..."
/usr/local/bin/php /var/www/artisan migrate --force

# Run Laravel optimizations
echo "Running Laravel optimizations..."
/usr/local/bin/php /var/www/artisan config:cache
/usr/local/bin/php /var/www/artisan route:cache
/usr/local/bin/php /var/www/artisan view:cache

# Start the server
echo "🚀 Starting Laravel server on 0.0.0.0:8000..."
echo "Server will be accessible at: http://$(hostname -I | awk '{print $1}'):8000"
exec /usr/local/bin/php /var/www/artisan serve --host=0.0.0.0 --port=8000 --env=production
