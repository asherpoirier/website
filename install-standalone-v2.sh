#!/bin/bash

# Flux IPTV Standalone Production Installer v2
# Enhanced with full debugging and verification

set -e

INSTALL_DIR="/var/www/html"

echo "================================================"
echo "  Flux IPTV - Production Installer v2"
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
    exit 1
fi
print_success "Running as root"

# Verify source files
print_info "Verifying source files in /app..."

if [ ! -d "/app/backend" ]; then
    print_error "/app/backend directory not found"
    exit 1
fi

if [ ! -d "/app/frontend" ]; then
    print_error "/app/frontend directory not found"
    exit 1
fi

if [ ! -f "/app/backend/server.py" ]; then
    print_error "/app/backend/server.py not found"
    ls -la /app/backend/
    exit 1
fi

if [ ! -f "/app/backend/requirements.txt" ]; then
    print_error "/app/backend/requirements.txt not found"
    exit 1
fi

if [ ! -f "/app/frontend/package.json" ]; then
    print_error "/app/frontend/package.json not found"
    ls -la /app/frontend/
    exit 1
fi

print_success "All source files verified"

# Install supervisor
print_info "Installing supervisor..."
apt-get update -qq
apt-get install -y supervisor >/dev/null 2>&1
print_success "Supervisor ready"

# Create installation directory
print_info "Preparing installation directory..."
mkdir -p $INSTALL_DIR

# Copy backend with verification
print_info "Copying backend..."
print_info "  Source: /app/backend"
print_info "  Destination: $INSTALL_DIR/backend"

# Remove old if exists
if [ -d "$INSTALL_DIR/backend" ]; then
    print_info "  Removing old backend..."
    rm -rf $INSTALL_DIR/backend
fi

# Copy with verbose
cp -rv /app/backend $INSTALL_DIR/ >/dev/null 2>&1

# Verify immediately
if [ -f "$INSTALL_DIR/backend/server.py" ]; then
    print_success "Backend copied successfully"
    print_info "  Files: $(ls $INSTALL_DIR/backend/ | wc -l) files/dirs"
else
    print_error "Backend copy failed!"
    print_info "Checking what was copied:"
    ls -la $INSTALL_DIR/backend/ || echo "Directory doesn't exist"
    exit 1
fi

# Copy frontend with verification
print_info "Copying frontend..."
print_info "  Source: /app/frontend"
print_info "  Destination: $INSTALL_DIR/frontend"

if [ -d "$INSTALL_DIR/frontend" ]; then
    print_info "  Removing old frontend..."
    rm -rf $INSTALL_DIR/frontend
fi

cp -rv /app/frontend $INSTALL_DIR/ >/dev/null 2>&1

if [ -f "$INSTALL_DIR/frontend/package.json" ]; then
    print_success "Frontend copied successfully"
    print_info "  Files: $(ls $INSTALL_DIR/frontend/ | wc -l) files/dirs"
else
    print_error "Frontend copy failed!"
    print_info "Checking what was copied:"
    ls -la $INSTALL_DIR/frontend/ || echo "Directory doesn't exist"
    exit 1
fi

# Final verification
print_info "Final verification..."
VERIFIED=true

if [ ! -f "$INSTALL_DIR/backend/server.py" ]; then
    print_error "server.py missing"
    VERIFIED=false
fi

if [ ! -f "$INSTALL_DIR/backend/requirements.txt" ]; then
    print_error "requirements.txt missing"
    VERIFIED=false
fi

if [ ! -f "$INSTALL_DIR/frontend/package.json" ]; then
    print_error "package.json missing"
    VERIFIED=false
fi

if [ "$VERIFIED" = false ]; then
    print_error "Verification failed!"
    echo ""
    echo "Backend directory:"
    ls -la $INSTALL_DIR/backend/
    echo ""
    echo "Frontend directory:"
    ls -la $INSTALL_DIR/frontend/
    exit 1
fi

print_success "All files verified in destination"

# Create environment files
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
    print_info "  Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
PACKAGES=$(pip list | wc -l)
deactivate

print_success "Backend installed ($PACKAGES packages)"

# Install frontend
print_info "Installing frontend dependencies..."
cd $INSTALL_DIR/frontend
yarn install --silent
print_success "Frontend installed"

# Set permissions
print_info "Setting permissions..."
chown -R www-data:www-data $INSTALL_DIR
print_success "Permissions set (www-data)"

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

supervisorctl reread >/dev/null 2>&1
supervisorctl update >/dev/null 2>&1
print_success "Supervisor configured"

# Create manual start script
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
echo ""
echo "Services started!"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8001"
echo ""
echo "Press Ctrl+C to stop"
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
STARTSCRIPT

chmod +x $INSTALL_DIR/start.sh
print_success "Start script created"

# Summary
echo ""
echo "================================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Installation details:"
echo "  Location: $INSTALL_DIR"
echo "  Backend:  $INSTALL_DIR/backend"
echo "  Frontend: $INSTALL_DIR/frontend"
echo ""
echo "Services (supervisor):"
echo "  sudo supervisorctl status"
echo "  sudo supervisorctl start fluxiptv-backend"
echo "  sudo supervisorctl start fluxiptv-frontend"
echo "  sudo supervisorctl restart fluxiptv-backend"
echo "  sudo supervisorctl restart fluxiptv-frontend"
echo ""
echo "Manual start:"
echo "  cd $INSTALL_DIR && ./start.sh"
echo ""
echo "Configuration files:"
echo "  Backend:  $INSTALL_DIR/backend/.env"
echo "  Frontend: $INSTALL_DIR/frontend/.env"
echo "  WHMCS:    $INSTALL_DIR/frontend/src/data/mock.js"
echo ""
echo "Logs:"
echo "  tail -f /var/log/fluxiptv-backend.out.log"
echo "  tail -f /var/log/fluxiptv-frontend.out.log"
echo ""
echo "Access: http://localhost:3000"
echo ""
