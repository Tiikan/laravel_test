# Stage 1: Build frontend
FROM node:18-alpine as frontend

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Laravel backend
FROM php:8.2-fpm

WORKDIR /var/www

# Install system dependencies & PHP extensions needed by Laravel
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip mbstring bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first
COPY composer.json composer.lock ./

# Install Composer dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy ALL application files (including artisan)
COPY . .

# Verify artisan file was copied
RUN ls -la /var/www/ && \
    if [ ! -f "/var/www/artisan" ]; then \
        echo "ERROR: artisan file not found after copy!"; \
        exit 1; \


# Copy built frontend assets
COPY --from=frontend /app/public/build ./public/build 2>/dev/null || echo "No frontend build found, skipping..."

# Copy and setup startup script
COPY start-simple.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Ensure artisan is executable and in the right place
RUN ls -la /var/www/ && \
    chmod +x /var/www/artisan && \
    ls -la /var/www/artisan

# Permissions + .env setup
RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache \
    && chmod +x /var/www/artisan

# Use www-data user
USER www-data

EXPOSE 8000

CMD ["/usr/local/bin/start.sh"]
