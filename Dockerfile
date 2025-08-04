# Multi-stage build for production optimization
FROM node:18-alpine as frontend

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# PHP base image
FROM php:8.2-fpm as base

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

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install Composer dependencies (without dev dependencies for production)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy application files
COPY . .

# Copy built frontend assets from frontend stage
COPY --from=frontend /app/public/build ./public/build

# Install npm dependencies and build assets
RUN npm ci && npm run build

# Complete composer installation with scripts
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Create required directories and set permissions
RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Generate application key if not set
RUN php artisan key:generate --no-interaction || true

# Cache configuration and routes for better performance
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force
    
# Expose port 8000
EXPOSE 8000

# Create a non-root user
RUN useradd -ms /bin/bash laravel
USER laravel

# Start Laravel server
CMD php artisan serve --host=0.0.0.0 --port=8000
