-- Initialize Laravel database
-- This file helps speed up database initialization

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS laravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user if not exists
CREATE USER IF NOT EXISTS 'pixelip'@'%' IDENTIFIED BY 'Kang@2k25';

-- Grant privileges
GRANT ALL PRIVILEGES ON laravel.* TO 'pixelip'@'%';
GRANT ALL PRIVILEGES ON laravel.* TO 'pixelip'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Use the laravel database
USE laravel;

-- Basic health check table (optional)
CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(50) DEFAULT 'OK',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO health_check (status) VALUES ('Database initialized') ON DUPLICATE KEY UPDATE status = 'Database initialized';
