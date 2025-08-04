# 🚀 PORTAINER DEPLOYMENT INSTRUCTIONS

## Step 1: Stop Current Stack
1. Go to Portainer: http://192.168.10.200:9000
2. Navigate to **Stacks** → **testing**
3. Click **Stop** to stop the current stack
4. Click **Remove** to remove the stack completely

## Step 2: Create New Production Stack
1. Click **Add stack**
2. Stack name: `laravel-production`
3. Build method: **Repository**
4. Repository URL: `https://github.com/your-username/your-repo.git`
5. Repository reference: `refs/heads/main`
6. Compose path: `docker-compose.portainer.yml`

## Step 3: Environment Variables (Optional)
Add these if you want to customize:
```
APP_KEY=base64:/X+K6OEClrSLDlq0zN8i4J1VGCKTnQa3j5/XSvEePSg=
DB_PASSWORD=Kang@2k25
MYSQL_ROOT_PASSWORD=Kang@2k25
```

## Step 4: Deploy
1. Click **Deploy the stack**
2. Wait for deployment to complete (2-3 minutes)

## Step 5: Verify Deployment
After deployment, you should see:
- **laravel_app_prod**: Status = running, IP = 172.x.x.x, Ports = 0.0.0.0:8000->8000/tcp
- **laravel_db_prod**: Status = healthy, Ports = 0.0.0.0:3307->3306/tcp

## Step 6: Test Application
- Main app: http://192.168.10.200:8000
- Health check: http://192.168.10.200:8000/health
- Test page: http://192.168.10.200:8000/test

## Troubleshooting
If containers don't start:
1. Check logs in Portainer (click container → Logs)
2. Ensure repository is accessible
3. Check if ports 8000/3307 are free: `sudo netstat -tulpn | grep -E "(8000|3307)"`

## Alternative: Manual Docker Commands
If Portainer fails, SSH to server and run:
```bash
cd /path/to/your/repo
git pull
docker-compose -f docker-compose.portainer.yml down
docker-compose -f docker-compose.portainer.yml up -d --build
```
