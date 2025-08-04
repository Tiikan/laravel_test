FROM php:8.1-fpm

WORKDIR /var/www

# System Dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel source
COPY . .

# Install dependencies
RUN composer install --no-interaction --prefer-dist

# Permissions (if needed)
RUN chmod -R 775 storage bootstrap/cache || true

# Generate app key (skip if already in .env)
RUN php artisan key:generate || true

CMD php artisan serve --host=0.0.0.0 --port=8000
