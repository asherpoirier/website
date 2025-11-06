# Flux IPTV - Deployment Guide

## Fresh Server Installation

Follow these steps to deploy Flux IPTV on a fresh server.

### Prerequisites

- Fresh Ubuntu 20.04/22.04 or Debian server
- Root or sudo access
- Public IP address or domain name
- Minimum 2GB RAM, 5GB disk space

## Step-by-Step Deployment

### 1. Connect to Your Server

```bash
ssh root@your-server-ip
```

### 2. Update Server (Optional - install.sh does this)

```bash
apt update && apt upgrade -y
```

### 3. Create Project Directory

```bash
mkdir -p /app
cd /app
```

### 4. Upload Your Files

**Option A: Using SCP (from your local machine)**
```bash
scp -r /path/to/flux-iptv/* root@your-server-ip:/app/
```

**Option B: Using Git**
```bash
git clone https://github.com/yourusername/flux-iptv.git /app
cd /app
```

**Option C: Manual Upload**
Upload these files to `/app`:
- All project files
- install.sh script
- .env files

### 5. Run Automated Installation

```bash
cd /app
chmod +x install.sh
sudo bash install.sh
```

The script will:
- Install Node.js 20.x
- Install Yarn
- Install Python 3
- Install all dependencies
- Set up virtual environment
- Ask about MongoDB (choose based on your setup)

### 6. Configure Environment Variables

#### Backend Configuration
Edit `/app/backend/.env`:

```env
# For Remote MongoDB (Recommended for production)
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME=fluxiptv_production

# For Local MongoDB
MONGO_URL=mongodb://localhost:27017/
DB_NAME=fluxiptv
```

#### Frontend Configuration
Edit `/app/frontend/.env`:

```env
# For Production
REACT_APP_BACKEND_URL=https://api.yourdomain.com

# For Development
REACT_APP_BACKEND_URL=http://your-server-ip:8001
```

### 7. Configure WHMCS Integration

Edit `/app/frontend/src/data/mock.js`:

```javascript
export const subscriptionPlans = [
  {
    id: 1,
    name: "1 Month",
    price: 10,
    whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=1"
  },
  {
    id: 2,
    name: "3 Months",
    price: 25,
    whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=2"
  },
  {
    id: 3,
    name: "6 Months",
    price: 45,
    whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=3"
  },
  {
    id: 4,
    name: "12 Months",
    price: 80,
    whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=4"
  }
];

export const freeTrialWhmcsUrl = "https://billing.yourdomain.com/cart.php?a=add&pid=trial";
export const telegramSupportUrl = "https://t.me/customcloudtv";
```

### 8. Test Installation

```bash
cd /app
./test-install.sh
```

Should show all green checkmarks.

### 9. Start Services

```bash
sudo supervisorctl start all
sudo supervisorctl status
```

Should show:
```
backend    RUNNING
frontend   RUNNING
```

### 10. Test Website

```bash
# Test backend
curl http://localhost:8001/api/

# Test frontend
curl http://localhost:3000
```

## Production Setup with Nginx

### Install Nginx

```bash
sudo apt install -y nginx
```

### Configure Nginx

Create `/etc/nginx/sites-available/fluxiptv`:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS Configuration
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL Certificates (use Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Frontend (React)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/fluxiptv /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Install SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (already set up by certbot)
sudo certbot renew --dry-run
```

## Firewall Configuration

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

## Production Build (Optional)

For better performance, build the frontend:

```bash
cd /app/frontend
yarn build
```

Then serve the `build` folder with Nginx instead of the development server.

Update Nginx config:
```nginx
location / {
    root /app/frontend/build;
    try_files $uri $uri/ /index.html;
}
```

## Monitoring

### View Logs

```bash
# Frontend logs
sudo supervisorctl tail frontend
sudo supervisorctl tail frontend stderr

# Backend logs
sudo supervisorctl tail backend
sudo supervisorctl tail backend stderr

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Check Service Status

```bash
sudo supervisorctl status
```

### Restart Services

```bash
sudo supervisorctl restart frontend
sudo supervisorctl restart backend
sudo supervisorctl restart all
```

## Backup Strategy

### Database Backup (MongoDB)

```bash
# Create backup script
cat > /root/backup-mongodb.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mongodump --uri="$MONGO_URL" --out=/backup/mongodb_$DATE
# Keep only last 7 days
find /backup -name "mongodb_*" -mtime +7 -exec rm -rf {} \;
EOF

chmod +x /root/backup-mongodb.sh

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup-mongodb.sh") | crontab -
```

### Application Backup

```bash
# Backup entire application
tar -czf /backup/fluxiptv_$(date +%Y%m%d).tar.gz /app
```

## Updating the Application

```bash
# Stop services
sudo supervisorctl stop all

# Pull updates (if using Git)
cd /app
git pull

# Update dependencies if needed
cd /app/backend
source venv/bin/activate
pip install -r requirements.txt

cd /app/frontend
yarn install

# Start services
sudo supervisorctl start all
```

## Troubleshooting Production Issues

### Services Won't Start

```bash
# Check logs
sudo supervisorctl tail backend stderr
sudo supervisorctl tail frontend stderr

# Check ports
sudo lsof -i :3000
sudo lsof -i :8001
```

### Website Not Accessible

```bash
# Check Nginx
sudo nginx -t
sudo systemctl status nginx

# Check firewall
sudo ufw status
```

### MongoDB Connection Issues

```bash
# Test connection
mongo "$MONGO_URL"

# Check MongoDB status (if local)
sudo systemctl status mongod
```

## Security Checklist

- [ ] SSL/TLS enabled (HTTPS)
- [ ] Firewall configured
- [ ] MongoDB authentication enabled
- [ ] Strong passwords in .env files
- [ ] Regular backups configured
- [ ] Server updates automated
- [ ] Non-root user for application (optional)
- [ ] Fail2ban installed (optional)

## Performance Optimization

### Enable Gzip in Nginx

Add to nginx config:
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

### Use PM2 Instead of Supervisor (Optional)

```bash
npm install -g pm2

# Frontend
cd /app/frontend
pm2 start "yarn start" --name fluxiptv-frontend

# Backend
cd /app/backend
source venv/bin/activate
pm2 start "uvicorn server:app --host 0.0.0.0 --port 8001" --name fluxiptv-backend

pm2 save
pm2 startup
```

## Support

- Telegram: @customcloudtv
- GitHub Issues: [If applicable]

---

**Deployment Complete! Your Flux IPTV website should now be live.**
