# Flux IPTV - Production Server Installation Guide

## Overview

This guide is for installing Flux IPTV on a production server where:
- Installation runs from any directory (including root home)
- All files are installed to `/var/www/html`
- Services run under `www-data` user
- Supervisor manages processes
- Ready for Nginx reverse proxy

## Quick Installation

### From Root Directory

```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/flux-iptv/main/install-production.sh

# Or if you have it locally
curl -o install-production.sh https://your-server/install-production.sh

# Make executable and run
chmod +x install-production.sh
sudo ./install-production.sh
```

### From Any Directory

The script will:
1. Install all dependencies
2. Copy/create project files in `/var/www/html`
3. Set up environment files
4. Install backend and frontend packages
5. Configure supervisor
6. Set correct permissions

## Installation Directory Structure

After installation, your files will be at:

```
/var/www/html/
├── backend/
│   ├── .env
│   ├── venv/
│   ├── server.py
│   └── requirements.txt
│
├── frontend/
│   ├── .env
│   ├── node_modules/
│   ├── src/
│   │   ├── pages/Home.jsx
│   │   └── data/mock.js
│   └── package.json
│
└── start.sh
```

## What Gets Installed

### System Packages
- Node.js 20.x LTS
- Yarn package manager
- Python 3 + pip (PEP 668 compliant)
- MongoDB 7.0 (optional)
- Supervisor process manager
- Build tools and dependencies

### Application
- Backend: FastAPI application with all dependencies
- Frontend: React application with all dependencies
- Environment files (.env) with default configuration
- Start scripts and supervisor configs

## Configuration Files

### Backend Environment
**Location:** `/var/www/html/backend/.env`

```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
```

**For production, update:**
```env
CORS_ORIGINS=https://yourdomain.com
```

### Frontend Environment
**Location:** `/var/www/html/frontend/.env`

```env
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
```

**For production, update:**
```env
REACT_APP_BACKEND_URL=https://api.yourdomain.com
```

### WHMCS Configuration
**Location:** `/var/www/html/frontend/src/data/mock.js`

Update subscription URLs:
```javascript
whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=1"
```

## Service Management

### Using Supervisor (Recommended)

```bash
# Check status
sudo supervisorctl status

# Start services
sudo supervisorctl start fluxiptv-backend
sudo supervisorctl start fluxiptv-frontend

# Stop services
sudo supervisorctl stop fluxiptv-backend
sudo supervisorctl stop fluxiptv-frontend

# Restart services
sudo supervisorctl restart fluxiptv-backend
sudo supervisorctl restart fluxiptv-frontend

# View logs
sudo supervisorctl tail fluxiptv-backend
sudo supervisorctl tail fluxiptv-frontend
```

### Manual Start

```bash
cd /var/www/html
./start.sh
```

## Nginx Configuration (Optional)

For production with domain name:

```bash
sudo nano /etc/nginx/sites-available/fluxiptv
```

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Frontend
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
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/fluxiptv /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL Certificate (Let's Encrypt)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is automatic
sudo certbot renew --dry-run
```

## Firewall Configuration

```bash
# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow SSH (if needed)
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable
```

## File Permissions

The script automatically sets:
```bash
chown -R www-data:www-data /var/www/html
```

If you need to update files:
```bash
# Temporarily as root
sudo nano /var/www/html/frontend/src/data/mock.js

# Fix permissions after
sudo chown -R www-data:www-data /var/www/html
```

## Logs

### Supervisor Logs
```bash
# Backend logs
tail -f /var/log/fluxiptv-backend.out.log
tail -f /var/log/fluxiptv-backend.err.log

# Frontend logs
tail -f /var/log/fluxiptv-frontend.out.log
tail -f /var/log/fluxiptv-frontend.err.log
```

### Nginx Logs
```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## Updating the Application

### Update Frontend Content
```bash
sudo nano /var/www/html/frontend/src/data/mock.js
sudo supervisorctl restart fluxiptv-frontend
```

### Update Backend Code
```bash
sudo nano /var/www/html/backend/server.py
sudo supervisorctl restart fluxiptv-backend
```

### Update Dependencies
```bash
# Backend
cd /var/www/html/backend
source venv/bin/activate
pip install -r requirements.txt
deactivate
sudo supervisorctl restart fluxiptv-backend

# Frontend
cd /var/www/html/frontend
yarn install
sudo supervisorctl restart fluxiptv-frontend
```

## Troubleshooting

### Services Won't Start

Check permissions:
```bash
sudo chown -R www-data:www-data /var/www/html
```

Check logs:
```bash
sudo supervisorctl tail fluxiptv-backend stderr
sudo supervisorctl tail fluxiptv-frontend stderr
```

### Port Already in Use

Find and kill:
```bash
sudo lsof -ti:3000 | xargs sudo kill -9
sudo lsof -ti:8001 | xargs sudo kill -9
```

### MongoDB Connection Issues

Check MongoDB status:
```bash
sudo systemctl status mongod
sudo systemctl start mongod
```

Update connection string in `/var/www/html/backend/.env`

## Production Checklist

Before going live:

- [ ] Update WHMCS URLs in `mock.js`
- [ ] Configure proper CORS in backend `.env`
- [ ] Set up domain name
- [ ] Install SSL certificate
- [ ] Configure firewall
- [ ] Test all subscription buttons
- [ ] Test Telegram support link
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Update backend URL in frontend `.env`

## Backup

### Database Backup
```bash
mongodump --out /backup/mongodb-$(date +%Y%m%d)
```

### Application Backup
```bash
tar -czf /backup/fluxiptv-$(date +%Y%m%d).tar.gz /var/www/html
```

### Automated Backups
Add to crontab:
```bash
# Daily backup at 2 AM
0 2 * * * mongodump --out /backup/mongodb-$(date +\%Y\%m\%d)
0 3 * * * tar -czf /backup/fluxiptv-$(date +\%Y\%m\%d).tar.gz /var/www/html
```

## Support

For issues:
- Check logs first
- Verify file permissions
- Ensure all services are running
- Test connectivity

Telegram: @customcloudtv

---

**Installation Path:** `/var/www/html`  
**Service User:** `www-data`  
**Process Manager:** Supervisor  
**Default Ports:** 3000 (frontend), 8001 (backend)
