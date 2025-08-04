FROM php:8.1-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    unzip zip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy source (Laravel files)
COPY . .

# 👇 TEMP DEBUG: Show directory and files
RUN ls -la && cat composer.json

# Run Composer install
RUN composer install --no-interaction --prefer-dist || cat /var/www/storage/logs/laravel.log

# Laravel setup
RUN php artisan key:generate || true

CMD php artisan serve --host=0.0.0.0 --port=8000
