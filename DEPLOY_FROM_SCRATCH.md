# Flux IPTV - Deploy From Scratch Guide

## For Fresh Production Servers

This guide is for deploying Flux IPTV on a brand new server with no existing files.

## Prerequisites

- Fresh Ubuntu 20.04/22.04/24.04 server
- Root or sudo access
- Your project files (backend + frontend code)

## Option 1: Deploy via Git (Recommended)

### Step 1: Install Git
```bash
sudo apt update
sudo apt install -y git
```

### Step 2: Clone Your Repository
```bash
cd /tmp
git clone https://github.com/YOUR-USERNAME/flux-iptv.git
```

### Step 3: Move Files to /app
```bash
sudo mkdir -p /app
sudo cp -r /tmp/flux-iptv/backend /app/
sudo cp -r /tmp/flux-iptv/frontend /app/
```

### Step 4: Run Installer
```bash
cd /tmp/flux-iptv
sudo bash install-standalone-v2.sh
```

## Option 2: Upload Files via SCP

### From Your Local Machine:
```bash
# Upload backend
scp -r /path/to/backend root@your-server-ip:/app/

# Upload frontend
scp -r /path/to/frontend root@your-server-ip:/app/

# Upload installer
scp install-standalone-v2.sh root@your-server-ip:/root/
```

### On Server:
```bash
sudo bash /root/install-standalone-v2.sh
```

## Option 3: Manual File Creation

If you have the files locally on the server but not in /app:

```bash
# Create /app directory
sudo mkdir -p /app

# Copy your files
sudo cp -r /path/to/your/backend /app/
sudo cp -r /path/to/your/frontend /app/

# Verify
ls -la /app/backend/server.py
ls -la /app/frontend/package.json

# Run installer
sudo bash install-standalone-v2.sh
```

## What Files Are Needed in /app

```
/app/
├── backend/
│   ├── server.py          (required)
│   ├── requirements.txt   (required)
│   └── ... (other backend files)
│
└── frontend/
    ├── package.json       (required)
    ├── src/              (required)
    │   ├── pages/
    │   ├── components/
    │   └── data/mock.js
    └── ... (other frontend files)
```

## Quick Test

Before running the installer, verify files are present:

```bash
# Check backend
ls -la /app/backend/server.py
ls -la /app/backend/requirements.txt

# Check frontend
ls -la /app/frontend/package.json
ls -la /app/frontend/src/

# If all show files, you're ready to install:
sudo bash install-standalone-v2.sh
```

## Troubleshooting

### Error: /app/backend/server.py not found

**Problem:** Project files not in /app

**Solution:** 
1. Check if files exist: `ls -la /app/`
2. If empty, upload/clone your project first
3. Ensure correct structure (see above)

### Error: package.json not found

**Problem:** Frontend files missing or incomplete

**Solution:**
```bash
# Check what's in frontend
ls -la /app/frontend/

# Should see:
# - package.json
# - src/
# - public/
# - node_modules/ (optional, will be installed)
```

## Complete Example Workflow

### For a Fresh Ubuntu Server:

```bash
# 1. SSH into server
ssh root@your-server-ip

# 2. Install git
apt update && apt install -y git

# 3. Clone project
git clone https://github.com/YOUR-REPO/flux-iptv.git /app

# 4. Verify files
ls /app/backend/server.py
ls /app/frontend/package.json

# 5. Download installer
wget https://raw.githubusercontent.com/YOUR-REPO/install-standalone-v2.sh

# 6. Run installer
bash install-standalone-v2.sh
```

## After Installation

Once installation completes:

```bash
# Start services
sudo supervisorctl start fluxiptv-backend
sudo supervisorctl start fluxiptv-frontend

# Check status
sudo supervisorctl status

# Access website
# Visit: http://your-server-ip:3000
```

## Update WHMCS URLs

After installation, update your WHMCS URLs:

```bash
sudo nano /var/www/html/frontend/src/data/mock.js
```

Change:
```javascript
whmcsLink: "https://your-actual-whmcs.com/cart.php?a=add&pid=1"
```

Restart:
```bash
sudo supervisorctl restart fluxiptv-frontend
```

## Need Help?

The installer expects project files to exist in `/app` before running.

If you're setting up from scratch:
1. Get your project files on the server first (git clone, scp, etc.)
2. Put them in `/app/backend` and `/app/frontend`
3. Then run the installer

---

**Key Point:** The installer doesn't download project files - you need to provide them first!
