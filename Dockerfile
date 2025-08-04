FROM php:8.1

# Install dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel source
COPY . .

# Install Laravel dependencies
RUN composer install

# Fix folder permissions (optional)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose the Laravel dev server
EXPOSE 8000

# Start Laravel dev server
CMD php artisan serve --host=0.0.0.0 --port=8000
