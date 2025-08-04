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

# Generate application key if not exists
echo "Checking application key..."
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Run Laravel optimizations
echo "Running Laravel optimizations..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start the server
echo "🚀 Starting Laravel server..."
exec php artisan serve --host=0.0.0.0 --port=8000
