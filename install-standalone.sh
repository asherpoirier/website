#!/bin/bash

# Flux IPTV Standalone Production Installer
# This script includes all necessary files and installs to /var/www/html

set -e

INSTALL_DIR="/var/www/html"

echo "================================================"
echo "  Flux IPTV - Standalone Production Installer"
echo "  Installing to: $INSTALL_DIR"
echo "================================================"
echo ""

# Colors
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
    echo "Run: sudo bash install-standalone.sh"
    exit 1
fi

print_success "Running as root"

# Check if source files exist
print_info "Checking for source files..."
if [ ! -d "/app/backend" ] || [ ! -d "/app/frontend" ]; then
    print_error "Project files not found in /app"
    echo ""
    echo "Please ensure your project exists in /app first"
    echo "Or upload files to /app/backend and /app/frontend"
    echo ""
    echo "Project structure needed:"
    echo "  /app/backend/  - FastAPI backend with server.py, requirements.txt"
    echo "  /app/frontend/ - React frontend with src/, package.json"
    echo ""
    exit 1
fi

print_success "Source files found in /app"

# Install system dependencies
print_info "Installing system dependencies..."
apt-get update -y
apt-get install -y supervisor

# Create installation directory
print_info "Creating installation directory..."
mkdir -p $INSTALL_DIR

# Copy files
print_info "Copying backend files..."
rm -rf $INSTALL_DIR/backend
cp -r /app/backend $INSTALL_DIR/
print_success "Backend copied"

print_info "Copying frontend files..."
rm -rf $INSTALL_DIR/frontend
cp -r /app/frontend $INSTALL_DIR/
print_success "Frontend copied"

# Verify critical files
if [ ! -f "$INSTALL_DIR/backend/server.py" ]; then
    print_error "server.py not found"
    exit 1
fi

if [ ! -f "$INSTALL_DIR/backend/requirements.txt" ]; then
    print_error "requirements.txt not found"
    exit 1
fi

if [ ! -f "$INSTALL_DIR/frontend/package.json" ]; then
    print_error "package.json not found"
    exit 1
fi

print_success "All critical files verified"

# Create/update .env files
print_info "Creating environment files..."

cat > $INSTALL_DIR/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
EOF
print_success "Backend .env created"

cat > $INSTALL_DIR/frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
EOF
print_success "Frontend .env created"

# Install backend
print_info "Installing backend dependencies..."
cd $INSTALL_DIR/backend

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt
deactivate
print_success "Backend installed"

# Install frontend
print_info "Installing frontend dependencies..."
cd $INSTALL_DIR/frontend
yarn install
print_success "Frontend installed"

# Set permissions
print_info "Setting permissions..."
chown -R www-data:www-data $INSTALL_DIR
print_success "Permissions set"

# Create supervisor configs
print_info "Configuring supervisor..."

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
print_success "Supervisor configured"

# Create start script
cat > $INSTALL_DIR/start.sh << 'EOF'
#!/bin/bash
echo "Starting Flux IPTV..."
cd /var/www/html/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
BACKEND_PID=$!
cd /var/www/html/frontend
yarn start &
FRONTEND_PID=$!
echo "Running! Press Ctrl+C to stop"
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
EOF
chmod +x $INSTALL_DIR/start.sh

echo ""
echo "================================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Installed to: $INSTALL_DIR"
echo ""
echo "Control services:"
echo "  sudo supervisorctl status"
echo "  sudo supervisorctl start fluxiptv-backend"
echo "  sudo supervisorctl start fluxiptv-frontend"
echo "  sudo supervisorctl restart fluxiptv-backend"
echo "  sudo supervisorctl restart fluxiptv-frontend"
echo ""
echo "Configuration:"
echo "  Backend:  $INSTALL_DIR/backend/.env"
echo "  Frontend: $INSTALL_DIR/frontend/.env"
echo "  WHMCS:    $INSTALL_DIR/frontend/src/data/mock.js"
echo ""
echo "Access: http://localhost:3000"
echo ""
