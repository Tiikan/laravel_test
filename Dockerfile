FROM php:8.1

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel project files
COPY . .

# Ensure .env exists (skip if already there)
RUN cp .env.example .env || true

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist || true

# Set correct permissions
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose Laravel dev server
EXPOSE 8000

# Start Laravel dev server
CMD php artisan serve --host=0.0.0.0 --port=8000
