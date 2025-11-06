# Flux IPTV - Automated Installation Guide

## Overview

The `install.sh` script automatically installs **ALL** dependencies and sets up the Flux IPTV website. No manual dependency installation required!

## What Gets Installed

The script automatically installs:

1. **System Updates** - Latest security patches and updates
2. **Basic Tools** - curl, wget, git, build-essential
3. **Node.js 20.x LTS** - JavaScript runtime for frontend
4. **Yarn** - Package manager for Node.js
5. **Python 3** - Backend runtime
6. **pip** - Python package manager
7. **MongoDB** (optional) - Database (you can skip if using remote MongoDB)
8. **Backend Dependencies** - All Python packages from requirements.txt
9. **Frontend Dependencies** - All npm packages from package.json

## Supported Operating Systems

- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8
- ✅ RHEL 7, 8, 9

## Prerequisites

- **Root Access** or sudo privileges
- **Internet Connection** for downloading packages
- **Minimum 2GB RAM** recommended
- **5GB Free Disk Space**

## Installation Steps

### Step 1: Get the Installation Script

If you already have the project:
```bash
cd /app
```

If you're downloading fresh:
```bash
# Download the install script
curl -O https://your-server/install.sh
# Or copy it to /app/install.sh
```

### Step 2: Make the Script Executable

```bash
chmod +x install.sh
```

### Step 3: Run the Installer as Root

```bash
sudo bash install.sh
```

**Or if you're already root:**
```bash
bash install.sh
```

### Step 4: Follow the Prompts

The script will:
1. Auto-detect your operating system
2. Update system packages
3. Install all dependencies automatically
4. Ask if you want MongoDB installed locally (type 'y' or 'n')
5. Install backend and frontend packages
6. Create helper scripts

### Step 5: Start the Website

After installation completes:

```bash
sudo supervisorctl start all
```

Or:

```bash
cd /app
./start.sh
```

## Installation Output

You'll see output like this:

```
================================================
  Flux IPTV Website - Installation Script
================================================

✓ Running as root
➜ Detected OS: ubuntu 22.04
✓ System updated
✓ Basic dependencies installed
✓ Node.js installed successfully
✓ Node.js version: v20.10.0
✓ Yarn installed successfully: 1.22.19
✓ Python installed successfully
✓ Python version: 3.10.12
✓ pip version: 23.3.1
✓ Backend dependencies installed
✓ Frontend dependencies installed
✓ Start script created at /app/start.sh

================================================
  Installation Complete! ✓
================================================
```

## Troubleshooting

### Script Fails with Permission Error

**Problem**: Script says it needs root access

**Solution**:
```bash
sudo bash install.sh
```

### MongoDB Installation Fails

**Problem**: MongoDB fails to install on your OS

**Solution**: Skip MongoDB installation when prompted and use remote MongoDB:
- Press 'n' when asked about MongoDB
- Configure remote MongoDB in `/app/backend/.env`

### Port 3000 or 8001 Already in Use

**Problem**: Another service is using the ports

**Solution**:
```bash
# Kill processes using those ports
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:8001 | xargs kill -9
```

### Node.js Installation Fails

**Problem**: Repository errors or network issues

**Solution**: Try installing Node.js manually first:
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs

# Then run install.sh again
sudo bash install.sh
```

### Package Installation Timeout

**Problem**: Slow internet connection causes timeouts

**Solution**: Increase timeout and retry:
```bash
export YARN_NETWORK_TIMEOUT=600000
sudo bash install.sh
```

### Python PEP 668 Error (externally-managed-environment)

**Problem**: Error when installing pip on Python 3.12+

**Solution**: This is now handled automatically by the updated script. If you encounter this:
```bash
# Run the fix script
sudo bash fix-python.sh

# Or manually install pip via apt
sudo apt-get install -y python3-pip python3-venv python3-full

# Then continue with installation
sudo bash install.sh
```

The backend uses a virtual environment, so this won't affect the application.

### Behind a Proxy

**Problem**: Corporate firewall or proxy

**Solution**: Set proxy environment variables:
```bash
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
sudo -E bash install.sh
```

## Verification

After installation, verify everything is installed:

```bash
# Check Node.js
node -v
# Should show: v20.x.x

# Check Yarn
yarn -v
# Should show: 1.22.x

# Check Python
python3 --version
# Should show: Python 3.x.x

# Check pip
pip3 --version
# Should show: pip 23.x.x

# Check MongoDB (if installed)
mongod --version
# Should show MongoDB version

# Check services
sudo supervisorctl status
# Should show: frontend RUNNING, backend RUNNING
```

## What Happens Behind the Scenes

1. **OS Detection**: Script detects Ubuntu/Debian/CentOS/RHEL
2. **Package Manager Setup**: Configures apt or yum repositories
3. **Node.js Repository**: Adds NodeSource repository for latest Node.js
4. **Python Setup**: Installs Python 3 and creates virtual environment
5. **Dependency Installation**: Installs all npm and pip packages
6. **Configuration**: Sets up environment files
7. **Helper Scripts**: Creates start.sh for easy launching

## Files Created

After installation:

```
/app
├── install.sh                    # This installation script
├── start.sh                      # Created by install.sh
├── backend/
│   └── venv/                     # Python virtual environment (created)
└── frontend/
    └── node_modules/             # npm packages (created)
```

## Post-Installation

### 1. Configure WHMCS URLs

Edit `/app/frontend/src/data/mock.js`:
```javascript
whmcsLink: "https://your-actual-whmcs.com/cart.php?a=add&pid=1"
```

### 2. Configure MongoDB (if remote)

Edit `/app/backend/.env`:
```env
MONGO_URL=mongodb+srv://user:pass@cluster.mongodb.net/
DB_NAME=fluxiptv
```

### 3. Start Website

```bash
sudo supervisorctl start all
```

### 4. Access Website

- Frontend: http://localhost:3000
- Backend: http://localhost:8001/api
- API Docs: http://localhost:8001/docs

## Need Help?

- Check logs: `sudo supervisorctl tail frontend`
- View errors: `sudo supervisorctl tail backend stderr`
- Telegram Support: @customcloudtv

## Uninstall (if needed)

To remove everything:

```bash
# Stop services
sudo supervisorctl stop all

# Remove Node.js
sudo apt-get remove -y nodejs  # Ubuntu/Debian
sudo yum remove -y nodejs      # CentOS/RHEL

# Remove project files
rm -rf /app

# Remove MongoDB (if installed)
sudo apt-get remove -y mongodb-org  # Ubuntu
sudo yum remove -y mongodb-org      # CentOS
```

---

**For quick start guide, see [QUICKSTART.md](QUICKSTART.md)**

**For full documentation, see [README.md](README.md)**
