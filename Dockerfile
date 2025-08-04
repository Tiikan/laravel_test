FROM php:8.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy app files
COPY . .

# Ensure .env exists
RUN cp .env.example .env || true

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist

# Laravel key generate will be run manually after container starts
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose port and start server
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
