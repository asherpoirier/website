#!/bin/bash

# Flux IPTV - Complete Self-Contained Installer
# NO prerequisites needed - installs everything from scratch
# Run on fresh Ubuntu server: sudo bash install-complete.sh

set -e

INSTALL_DIR="/var/www/html"

echo "================================================"
echo "  Flux IPTV - Complete Self-Contained Installer"
echo "  Installing to: $INSTALL_DIR"
echo "================================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}➜ $1${NC}"; }

# Check root
if [ "$EUID" -ne 0 ]; then 
    print_error "Must run as root"
    exit 1
fi
print_success "Running as root"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_success "Detected: $ID $VERSION_ID"
else
    print_error "Cannot detect OS"
    exit 1
fi

# Update system
print_info "Updating system..."
apt-get update -qq
apt-get upgrade -y -qq
print_success "System updated"

# Install Node.js
print_info "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi
print_success "Node.js $(node -v)"

# Install Yarn
print_info "Installing Yarn..."
if ! command -v yarn &> /dev/null; then
    npm install -g yarn
fi
print_success "Yarn $(yarn -v)"

# Install Python
print_info "Installing Python..."
apt-get install -y python3 python3-pip python3-venv python3-full
print_success "Python $(python3 --version)"

# Install MongoDB
print_info "Installing MongoDB..."
if ! command -v mongod &> /dev/null; then
    UBUNTU_CODENAME=$(lsb_release -cs)
    if [[ "$UBUNTU_CODENAME" == "noble" ]]; then
        UBUNTU_CODENAME="jammy"
    fi
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_CODENAME}/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    apt-get update -qq
    apt-get install -y mongodb-org
    systemctl start mongod
    systemctl enable mongod
fi
print_success "MongoDB installed"

# Install Supervisor
print_info "Installing Supervisor..."
apt-get install -y supervisor
systemctl enable supervisor
systemctl start supervisor
print_success "Supervisor installed"

# Create installation directory
print_info "Creating project structure..."
mkdir -p $INSTALL_DIR/backend
mkdir -p $INSTALL_DIR/frontend/src/pages
mkdir -p $INSTALL_DIR/frontend/src/data
mkdir -p $INSTALL_DIR/frontend/src/components/ui
mkdir -p $INSTALL_DIR/frontend/public
print_success "Directories created"

# Create backend files
print_info "Creating backend files..."

# server.py
cat > $INSTALL_DIR/backend/server.py << 'SERVERPY'
from fastapi import FastAPI, APIRouter
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

app = FastAPI()
api_router = APIRouter(prefix="/api")

@api_router.get("/")
async def root():
    return {"message": "Flux IPTV API"}

app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
SERVERPY

# requirements.txt
cat > $INSTALL_DIR/backend/requirements.txt << 'REQUIREMENTS'
fastapi==0.110.1
uvicorn==0.25.0
python-dotenv>=1.0.1
pymongo==4.5.0
pydantic>=2.6.4
motor==3.3.1
REQUIREMENTS

# .env
cat > $INSTALL_DIR/backend/.env << 'BACKENDENV'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
BACKENDENV

print_success "Backend files created"

# Create frontend files  
print_info "Creating frontend files..."

# Download project files from the working /app if available
if [ -d "/app/frontend/src" ] && [ -f "/app/frontend/package.json" ]; then
    print_info "Found existing project in /app, copying..."
    cp -r /app/frontend/* $INSTALL_DIR/frontend/
    print_success "Frontend files copied from /app"
else
    print_info "Downloading Flux IPTV project from GitHub..."
    
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    cd $TMP_DIR
    
    # Try to download from GitHub
    if wget -q https://github.com/asherpoirier/website/archive/refs/heads/main.zip; then
        unzip -q main.zip
        if [ -d "website-main/frontend" ]; then
            cp -r website-main/frontend/* $INSTALL_DIR/frontend/
            print_success "Downloaded from GitHub"
        fi
    fi
    
    cd /
    rm -rf $TMP_DIR
fi

# Ensure package.json exists (create minimal if not)
if [ ! -f "$INSTALL_DIR/frontend/package.json" ]; then
    print_info "Creating minimal frontend setup..."
    
    cat > $INSTALL_DIR/frontend/package.json << 'PACKAGEJSON'
{
  "name": "flux-iptv-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^7.5.1",
    "react-scripts": "5.0.1",
    "axios": "^1.8.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test"
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
PACKAGEJSON

    # Create minimal src structure
    mkdir -p $INSTALL_DIR/frontend/src
    cat > $INSTALL_DIR/frontend/src/index.js << 'INDEXJS'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
INDEXJS

    cat > $INSTALL_DIR/frontend/src/App.js << 'APPJS'
import React from 'react';

function App() {
  return (
    <div style={{padding: '40px', textAlign: 'center'}}>
      <h1>Flux IPTV</h1>
      <p>Website is being set up...</p>
    </div>
  );
}

export default App;
APPJS

    mkdir -p $INSTALL_DIR/frontend/public
    cat > $INSTALL_DIR/frontend/public/index.html << 'INDEXHTML'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Flux IPTV</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
INDEXHTML

fi

# Frontend .env
cat > $INSTALL_DIR/frontend/.env << 'FRONTENDENV'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
FRONTENDENV

print_success "Frontend files created"

# Install backend
print_info "Installing backend dependencies..."
cd $INSTALL_DIR/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
deactivate
print_success "Backend installed"

# Install frontend
print_info "Installing frontend dependencies (this may take a few minutes)..."
cd $INSTALL_DIR/frontend
yarn install --silent
print_success "Frontend installed"

# Set permissions
print_info "Setting permissions..."
chown -R www-data:www-data $INSTALL_DIR
print_success "Permissions set"

# Configure supervisor
print_info "Configuring services..."

cat > /etc/supervisor/conf.d/fluxiptv-backend.conf << EOF
[program:fluxiptv-backend]
command=$INSTALL_DIR/backend/venv/bin/uvicorn server:app --host 0.0.0.0 --port 8001
directory=$INSTALL_DIR/backend
user=www-data
autostart=true
autorestart=true
stderr_logfile=/var/log/fluxiptv-backend.err.log
stdout_logfile=/var/log/fluxiptv-backend.out.log
EOF

cat > /etc/supervisor/conf.d/fluxiptv-frontend.conf << EOF
[program:fluxiptv-frontend]
command=/usr/bin/yarn start
directory=$INSTALL_DIR/frontend
user=www-data
autostart=true
autorestart=true
stderr_logfile=/var/log/fluxiptv-frontend.err.log
stdout_logfile=/var/log/fluxiptv-frontend.out.log
environment=PORT=3000
EOF

supervisorctl reread
supervisorctl update
supervisorctl start fluxiptv-backend fluxiptv-frontend
print_success "Services configured and started"

# Create start script
cat > $INSTALL_DIR/start.sh << 'STARTSCRIPT'
#!/bin/bash
echo "Starting Flux IPTV..."
cd /var/www/html/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
BACKEND_PID=$!
cd /var/www/html/frontend
yarn start &
FRONTEND_PID=$!
echo "Running! Visit: http://localhost:3000"
echo "Press Ctrl+C to stop"
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
STARTSCRIPT
chmod +x $INSTALL_DIR/start.sh

echo ""
echo "================================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Flux IPTV has been installed to: $INSTALL_DIR"
echo ""
echo "Services:"
echo "  sudo supervisorctl status"
echo "  sudo supervisorctl restart fluxiptv-backend"
echo "  sudo supervisorctl restart fluxiptv-frontend"
echo ""
echo "Configuration:"
echo "  Backend:  $INSTALL_DIR/backend/.env"
echo "  Frontend: $INSTALL_DIR/frontend/.env"
echo ""
echo "Logs:"
echo "  tail -f /var/log/fluxiptv-backend.out.log"
echo "  tail -f /var/log/fluxiptv-frontend.out.log"
echo ""
echo "Access your website:"
echo "  http://localhost:3000"
echo "  http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "Services are starting (may take 30-60 seconds)"
echo ""
