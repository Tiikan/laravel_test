# Laravel Application Deployment with Portainer

This guide explains how to deploy the Laravel application using Portainer on Ubuntu server.

## Prerequisites

1. Ubuntu server with Docker and Docker Compose installed
2. Portainer installed and running
3. Git repository access from the server

## Deployment Steps

### Method 1: Using Portainer Stacks (Recommended)

1. **Access Portainer Web Interface**
   - Open your browser and go to `http://your-server-ip:9000`
   - Login to Portainer

2. **Create a New Stack**
   - Go to "Stacks" in the left sidebar
   - Click "Add stack"
   - Give it a name: `laravel-app`

3. **Configure the Stack**
   - Choose "Repository" as the build method
   - Repository URL: `https://github.com/your-username/your-repo.git`
   - Repository reference: `refs/heads/main` (or your branch)
   - Compose path: `docker-compose.prod.yml`

4. **Environment Variables (Optional)**
   Add these environment variables if you want to override defaults:
   ```
   APP_KEY=base64:/X+K6OEClrSLDlq0zN8i4J1VGCKTnQa3j5/XSvEePSg=
   DB_PASSWORD=your_secure_password
   MYSQL_ROOT_PASSWORD=your_secure_root_password
   ```

5. **Deploy the Stack**
   - Click "Deploy the stack"
   - Wait for the deployment to complete

### Method 2: Using Git Repository Clone

1. **SSH into your Ubuntu server**
   ```bash
   ssh user@your-server-ip
   ```

2. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

3. **Deploy using Docker Compose**
   ```bash
   # For production deployment
   docker-compose -f docker-compose.prod.yml up -d --build
   
   # Or for development
   docker-compose up -d --build
   ```

## Configuration Files

### Production Configuration
- Use `docker-compose.prod.yml` for production deployment
- This file excludes development overrides and uses production settings

### Development Configuration  
- Use `docker-compose.yml` with `docker-compose.override.yml` for development
- Includes volume mounts for live code editing

## Accessing the Application

After successful deployment:
- Laravel App: `http://your-server-ip:8000`
- Database: `your-server-ip:3307` (external access)
- Health Check: `http://your-server-ip:8000/health`

## Troubleshooting

### Common Issues

1. **"Could not open input file: artisan" error**
   - This is fixed in the current configuration
   - The startup script waits for database before running artisan commands

2. **Database connection errors**
   - Check if MySQL container is healthy: `docker-compose ps`
   - Verify environment variables are correct
   - Check logs: `docker-compose logs db`

3. **Permission errors**
   - The Dockerfile sets proper permissions for www-data user
   - Storage and cache directories are properly configured

### Useful Commands

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs app
docker-compose logs db

# Restart services
docker-compose restart

# Update application
git pull
docker-compose up -d --build

# Access application container
docker-compose exec app bash
```

## Security Notes

1. Change default passwords in production
2. Use environment variables for sensitive data
3. Consider using Docker secrets for production
4. Ensure firewall is properly configured
5. Use HTTPS in production (add reverse proxy like Nginx)

## Monitoring

- Check application health: `http://your-server-ip:8000/health`
- Monitor logs through Portainer interface
- Set up log rotation for production use
