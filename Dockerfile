FROM php:8.1

# Install required extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working dir
WORKDIR /var/www

# Copy app files
COPY . .

# Copy .env if missing
RUN cp .env.example .env || true

# Install dependencies
RUN composer install || true

# Laravel key (optional here)
RUN php artisan config:clear || true

# Permissions
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose port
EXPOSE 8000

# Debug CMD — safer startup
CMD php artisan serve --host=0.0.0.0 --port=8000
