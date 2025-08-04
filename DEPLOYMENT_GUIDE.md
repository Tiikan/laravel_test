# Laravel Deployment Guide with Portainer on Ubuntu Server

## Prerequisites

### 1. Ubuntu Server Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git unzip
```

### 2. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
```

### 3. Install Docker Compose
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### 4. Install Portainer
```bash
# Create Portainer volume
docker volume create portainer_data

# Run Portainer
docker run -d -p 8080:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```

## Deployment Steps

### 1. Access Portainer
- Open browser: `http://your-server-ip:9443`
- Create admin account on first visit
- Login to Portainer dashboard

### 2. Prepare Laravel Project
```bash
# Clone your repository
git clone https://github.com/Tiikan/laravel_test.git
cd laravel_test

# Copy production environment
cp .env.production .env

# Generate new application key (if needed)
php artisan key:generate
```

### 3. Deploy via Portainer

#### Option A: Using Portainer Stacks (Recommended)
1. Go to **Stacks** in Portainer
2. Click **Add Stack**
3. Name: `laravel-app`
4. Copy the content of `docker-compose.yml`
5. Set environment variables if needed
6. Click **Deploy the stack**

#### Option B: Using Git Repository
1. Go to **Stacks** in Portainer
2. Click **Add Stack**
3. Choose **Repository**
4. Repository URL: `https://github.com/Tiikan/laravel_test.git`
5. Compose path: `docker-compose.yml`
6. Click **Deploy the stack**

### 4. Configure Environment Variables
In Portainer Stack configuration, add these environment variables:
```
APP_ENV=production
APP_DEBUG=false
APP_URL=http://your-domain.com
DB_HOST=db
DB_DATABASE=laravel
DB_USERNAME=pixelip
DB_PASSWORD=Kang@2k25
```

### 5. Access Your Application
- Laravel App: `http://your-server-ip:8000`
- With Nginx: `http://your-server-ip:80`
- Database: `your-server-ip:3307`

## Troubleshooting

### Common Issues

1. **Composer Install Fails**
   - Check PHP version compatibility
   - Ensure all required extensions are installed
   - Clear composer cache: `composer clear-cache`

2. **Permission Denied**
   ```bash
   # Fix storage permissions
   sudo chown -R www-data:www-data storage bootstrap/cache
   sudo chmod -R 775 storage bootstrap/cache
   ```

3. **Database Connection Failed**
   - Verify database credentials
   - Check if MySQL container is running
   - Ensure network connectivity between containers

4. **Port Already in Use**
   ```bash
   # Check what's using the port
   sudo netstat -tulpn | grep :8000
   
   # Kill process if needed
   sudo kill -9 <PID>
   ```

### Monitoring and Logs

1. **View Container Logs in Portainer**
   - Go to **Containers**
   - Click on container name
   - Click **Logs** tab

2. **Command Line Logs**
   ```bash
   # View all logs
   docker-compose logs
   
   # View specific service logs
   docker-compose logs app
   docker-compose logs db
   
   # Follow logs in real-time
   docker-compose logs -f
   ```

## Production Optimizations

### 1. SSL/HTTPS Setup
```bash
# Install Certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Update nginx.conf with SSL configuration
```

### 2. Performance Tuning
- Enable Redis for caching
- Configure queue workers
- Set up proper logging
- Implement monitoring

### 3. Security
- Change default passwords
- Use environment variables for secrets
- Enable firewall
- Regular security updates

## Backup Strategy
```bash
# Backup database
docker exec laravel_db mysqldump -u pixelip -pKang@2k25 laravel > backup.sql

# Backup application files
tar -czf laravel-backup.tar.gz /path/to/laravel_test

# Backup Docker volumes
docker run --rm -v laravel_test_dbdata:/data -v $(pwd):/backup alpine tar czf /backup/dbdata-backup.tar.gz /data
```
