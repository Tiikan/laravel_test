FROM php:8.1-fpm

WORKDIR /var/www

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    unzip zip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel app
COPY . .

# Install dependencies
RUN composer install --no-interaction --prefer-dist

# Generate key
RUN php artisan key:generate

CMD php artisan serve --host=0.0.0.0 --port=8000
