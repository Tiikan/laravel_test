# Use official PHP image with Apache
FROM php:8.2-apache

# Install system dependencies and PHP extensions needed by Laravel
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo_mysql zip

# Enable Apache mod_rewrite (required for Laravel routes)
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www

# Copy existing application files to the container
COPY . /var/www

# Set permissions for Laravel storage and bootstrap cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Install Composer (PHP package manager)
/usr/bin/env bash -c "\
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer"

# Run composer install to install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Expose port 80 (Apache default)
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
