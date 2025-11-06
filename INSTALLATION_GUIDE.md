# Flux IPTV - Complete Installation Guide

## Overview

This guide covers the complete installation of the Flux IPTV website using the **fully automated** `install.sh` script.

## Features of install.sh

✅ **Automatic Dependency Installation**
- Node.js 20.x LTS
- Yarn package manager
- Python 3.x + pip (PEP 668 compliant)
- MongoDB 7.0 (optional)
- All system dependencies

✅ **Automatic Configuration**
- Creates `.env` files automatically
- Configures MongoDB connection
- Sets up backend API URL
- Creates start scripts

✅ **Smart Compatibility**
- Works with Python 3.12+ (PEP 668 compliant)
- Ubuntu 24.04 (noble) support with MongoDB workaround
- Ubuntu 20.04, 22.04, Debian support
- CentOS/RHEL support

✅ **Zero Manual Configuration Required**
- No need to create files manually
- No need to edit configurations
- Just run and go!

## Prerequisites

- **Fresh Ubuntu/Debian/CentOS Server**
- **Root or sudo access**
- **Internet connection**
- **Minimum 2GB RAM, 5GB disk space**

## One-Command Installation

```bash
cd /app
sudo bash install.sh
```

That's it! The script will:
1. Detect your OS
2. Update system packages
3. Install all dependencies
4. Create .env files automatically
5. Install backend packages (in virtual environment)
6. Install frontend packages
7. Create helper scripts

## Installation Steps Explained

### Step 1: OS Detection
The script automatically detects:
- Ubuntu (20.04, 22.04, 24.04)
- Debian (10, 11, 12)
- CentOS (7, 8)
- RHEL (7, 8, 9)

### Step 2: System Update
Updates all system packages to latest versions.

### Step 3: Basic Dependencies
Installs: curl, wget, git, build-essential, etc.

### Step 4: Node.js Installation
- Installs Node.js 20.x LTS from NodeSource repository
- Automatically detects if already installed

### Step 5: Yarn Installation
- Installs Yarn globally via npm
- Skips if already installed

### Step 6: Python Installation (PEP 668 Compliant)
- Installs Python 3 via system package manager
- Installs pip via apt/yum (NOT get-pip.py)
- Installs python3-venv for virtual environments
- **Fully compliant with Python 3.12+ PEP 668**

### Step 7: MongoDB Setup (Optional)
You'll be asked:
```
Do you want to install MongoDB locally? (y/N):
```

**Choose 'y' if:**
- You want local MongoDB for development
- You don't have a remote MongoDB server

**Choose 'n' if:**
- You have MongoDB Atlas (remote)
- You'll configure remote MongoDB later

**Ubuntu 24.04 Note:** Script automatically uses Ubuntu 22.04 repository (fully compatible)

### Step 8: Environment Configuration (Automatic)

The script creates two `.env` files:

#### Backend .env (`/app/backend/.env`)
```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
```

#### Frontend .env (`/app/frontend/.env`)
```env
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
```

**These are created automatically - no manual action needed!**

### Step 9: Backend Installation
- Creates Python virtual environment
- Upgrades pip inside venv
- Installs all packages from requirements.txt
- All packages isolated in venv (PEP 668 safe)

### Step 10: Frontend Installation
- Installs all npm packages via Yarn
- Downloads and sets up dependencies
- Prepares React application

### Step 11: Helper Scripts
Creates `/app/start.sh` for easy server startup.

## Post-Installation

### Starting the Website

**Option 1: Using Supervisor (Recommended)**
```bash
sudo supervisorctl start all
sudo supervisorctl status
```

**Option 2: Using Start Script**
```bash
cd /app
./start.sh
```

### Accessing the Website

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001/api
- **API Documentation**: http://localhost:8001/docs

### Verifying Installation

Run the test script:
```bash
cd /app
./test-install.sh
```

Should show all green checkmarks.

## Customization

### Update WHMCS URLs

Edit `/app/frontend/src/data/mock.js`:
```javascript
export const subscriptionPlans = [
  {
    id: 1,
    name: "1 Month",
    price: 10,
    whmcsLink: "https://billing.yourdomain.com/cart.php?a=add&pid=1"
  },
  // ... update all plans
];
```

### Configure Remote MongoDB

If you chose not to install MongoDB locally, edit `/app/backend/.env`:
```env
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME=fluxiptv_production
```

Then restart backend:
```bash
sudo supervisorctl restart backend
```

### Update Backend URL (Production)

For production deployment, edit `/app/frontend/.env`:
```env
REACT_APP_BACKEND_URL=https://api.yourdomain.com
```

Then rebuild frontend:
```bash
cd /app/frontend
yarn build
```

## Troubleshooting

### Issue: MongoDB Repository Error (Ubuntu 24.04)

**Symptom:**
```
E: The repository 'https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 Release' does not have a Release file.
```

**Solution:** Already handled automatically! Script uses Ubuntu 22.04 repository for 24.04.

If you still see this error:
```bash
sudo bash /app/fix-mongodb.sh
```

### Issue: Python PEP 668 Error

**Symptom:**
```
error: externally-managed-environment
```

**Solution:** Already handled! Script installs pip via apt, uses virtual environment.

The install.sh script is **fully PEP 668 compliant** and won't trigger this error.

### Issue: Port Already in Use

**Symptom:** Services won't start

**Solution:**
```bash
# Kill processes using the ports
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:8001 | xargs kill -9

# Restart services
sudo supervisorctl restart all
```

### Issue: Frontend Build Errors

**Solution:**
```bash
cd /app/frontend
rm -rf node_modules .cache
yarn install
sudo supervisorctl restart frontend
```

### Issue: Backend Import Errors

**Solution:**
```bash
cd /app/backend
source venv/bin/activate
pip install -r requirements.txt
deactivate
sudo supervisorctl restart backend
```

## What Makes This Script Special?

### 1. **Zero Configuration Required**
- No manual .env file creation
- No manual dependency installation
- No configuration editing needed

### 2. **Modern Python Compatible**
- Works with Python 3.12+
- PEP 668 compliant (externally-managed-environment)
- Never uses get-pip.py
- Always uses virtual environments

### 3. **Ubuntu 24.04 Ready**
- Handles MongoDB repository issues
- Uses compatible repository fallback
- Fully tested on latest Ubuntu

### 4. **Intelligent**
- Detects existing installations
- Skips already installed components
- Handles errors gracefully
- Provides clear status messages

### 5. **Production Ready**
- Creates proper virtual environments
- Isolates dependencies
- Follows best practices
- Easy to customize later

## Files Created by Script

```
/app
├── backend/
│   ├── .env                  # ✓ Created automatically
│   └── venv/                 # ✓ Created automatically
├── frontend/
│   ├── .env                  # ✓ Created automatically
│   └── node_modules/         # ✓ Created automatically
├── install.sh                # Main installation script
├── start.sh                  # ✓ Created automatically
└── test-install.sh          # Installation verification
```

## Advanced Usage

### Silent Installation (Non-Interactive)

For automated deployments, skip MongoDB prompt:
```bash
echo "n" | sudo bash install.sh
```

### Custom MongoDB Configuration

To use remote MongoDB from the start:
1. Run install.sh
2. Choose 'n' when asked about MongoDB
3. Edit `/app/backend/.env` with your MongoDB connection
4. Start services

### Installing on CI/CD

The script is CI/CD friendly:
```yaml
# GitHub Actions example
- name: Install Flux IPTV
  run: |
    cd /app
    echo "n" | sudo bash install.sh
    
- name: Verify Installation
  run: |
    cd /app
    ./test-install.sh
```

## Security Considerations

### Production Deployment

Before deploying to production:

1. **Change CORS Settings**
   ```env
   # /app/backend/.env
   CORS_ORIGINS=https://yourdomain.com
   ```

2. **Use HTTPS**
   ```env
   # /app/frontend/.env
   REACT_APP_BACKEND_URL=https://api.yourdomain.com
   ```

3. **Secure MongoDB**
   - Enable authentication
   - Use strong passwords
   - Limit network access

4. **Use Environment Variables**
   - Store sensitive data in .env
   - Never commit .env to git
   - Use different .env for dev/prod

## Getting Help

### Check Logs

**Backend logs:**
```bash
sudo supervisorctl tail backend
sudo supervisorctl tail backend stderr
```

**Frontend logs:**
```bash
sudo supervisorctl tail frontend
sudo supervisorctl tail frontend stderr
```

**MongoDB logs:**
```bash
sudo journalctl -u mongod -f
```

### Common Commands

```bash
# Check all services
sudo supervisorctl status

# Restart all services
sudo supervisorctl restart all

# Stop all services
sudo supervisorctl stop all

# Reload configuration
sudo supervisorctl reread
sudo supervisorctl update
```

## Conclusion

The `install.sh` script provides a **completely automated installation** experience:
- ✅ No manual dependency installation
- ✅ No manual configuration needed
- ✅ No compatibility issues
- ✅ Production-ready setup
- ✅ One command to complete installation

Just run:
```bash
sudo bash install.sh
```

And your Flux IPTV website is ready to go!

---

**For quick reference, see [QUICKSTART.md](QUICKSTART.md)**

**For production deployment, see [DEPLOYMENT.md](DEPLOYMENT.md)**
