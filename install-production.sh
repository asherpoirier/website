#!/bin/bash

# Flux IPTV Production Installation Script
# Installs to /var/www/html
# Can be run from any directory

set -e

# Installation directory
INSTALL_DIR="/var/www/html"

echo "================================================"
echo "  Flux IPTV - Production Installation"
echo "  Installing to: $INSTALL_DIR"
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}➜ $1${NC}"; }

# Check root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "This script must be run as root or with sudo"
        echo "Please run: sudo bash install-production.sh"
        exit 1
    else
        print_success "Running as root"
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        print_info "Detected OS: $OS $VER"
    else
        print_error "Cannot detect OS"
        exit 1
    fi
}

# Update system
update_system() {
    print_info "Updating system packages..."
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get update -y
        apt-get upgrade -y
        print_success "System updated"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        yum update -y
        print_success "System updated"
    fi
}

# Install basic dependencies
install_basic_deps() {
    print_info "Installing basic dependencies..."
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y curl wget git build-essential software-properties-common
        print_success "Basic dependencies installed"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        yum install -y curl wget git gcc gcc-c++ make
        print_success "Basic dependencies installed"
    fi
}

# Install Node.js
install_nodejs() {
    print_info "Installing Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        print_success "Node.js already installed: $NODE_VERSION"
        return
    fi
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
        print_success "Node.js installed"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
        yum install -y nodejs
        print_success "Node.js installed"
    fi
    
    print_success "Node.js version: $(node -v)"
}

# Install Yarn
install_yarn() {
    print_info "Installing Yarn..."
    if command -v yarn &> /dev/null; then
        print_success "Yarn already installed: $(yarn -v)"
        return
    fi
    
    npm install -g yarn
    print_success "Yarn installed: $(yarn -v)"
}

# Install Python (PEP 668 compliant)
install_python() {
    print_info "Installing Python and pip..."
    
    if command -v python3 &> /dev/null; then
        print_success "Python already installed: $(python3 --version)"
    else
        if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
            apt-get install -y python3 python3-pip python3-venv python3-full
            print_success "Python installed"
        elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
            yum install -y python3 python3-pip python3-virtualenv
            print_success "Python installed"
        fi
    fi
    
    # Install pip via system package manager
    print_info "Installing pip via system packages..."
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y python3-pip python3-venv python3-full
        print_success "pip installed via apt"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        yum install -y python3-pip python3-virtualenv
        print_success "pip installed via yum"
    fi
    
    print_success "Python: $(python3 --version)"
}

# Install MongoDB
install_mongodb() {
    print_info "Checking MongoDB..."
    if command -v mongod &> /dev/null; then
        print_success "MongoDB already installed"
        return
    fi
    
    echo ""
    read -p "Install MongoDB locally? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing MongoDB..."
        if [[ "$OS" == "ubuntu" ]]; then
            UBUNTU_CODENAME=$(lsb_release -cs)
            if [[ "$UBUNTU_CODENAME" == "noble" ]]; then
                UBUNTU_CODENAME="jammy"
                print_info "Using Ubuntu 22.04 repository (compatible)"
            fi
            
            curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
            echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_CODENAME}/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
            
            apt-get update
            if apt-get install -y mongodb-org; then
                systemctl start mongod
                systemctl enable mongod
                print_success "MongoDB installed and started"
            else
                print_error "MongoDB installation failed"
            fi
        fi
    else
        print_info "Skipping MongoDB - will use configuration from .env"
    fi
}

# Copy project files
copy_project_files() {
    print_info "Setting up project structure..."
    
    # Create installation directory
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    # If running from /app, copy files
    if [ -d "/app/backend" ] && [ -d "/app/frontend" ]; then
        print_info "Copying project files from /app..."
        
        # Copy backend
        if [ ! -d "$INSTALL_DIR/backend" ]; then
            cp -r /app/backend $INSTALL_DIR/
            print_success "Backend files copied"
        else
            print_success "Backend directory exists"
        fi
        
        # Copy frontend
        if [ ! -d "$INSTALL_DIR/frontend" ]; then
            cp -r /app/frontend $INSTALL_DIR/
            print_success "Frontend files copied"
        else
            print_success "Frontend directory exists"
        fi
    else
        print_info "Creating project structure..."
        mkdir -p $INSTALL_DIR/backend
        mkdir -p $INSTALL_DIR/frontend
        print_success "Directories created"
    fi
}

# Create environment files
create_env_files() {
    print_info "Creating environment files..."
    
    # Backend .env
    if [ ! -f "$INSTALL_DIR/backend/.env" ]; then
        print_info "Creating backend .env..."
        cat > $INSTALL_DIR/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
EOF
        print_success "Backend .env created"
    else
        print_success "Backend .env exists"
    fi
    
    # Frontend .env
    if [ ! -f "$INSTALL_DIR/frontend/.env" ]; then
        print_info "Creating frontend .env..."
        cat > $INSTALL_DIR/frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
EOF
        print_success "Frontend .env created"
    else
        print_success "Frontend .env exists"
    fi
}

# Install backend dependencies
install_backend() {
    print_info "Installing backend dependencies..."
    
    cd $INSTALL_DIR/backend || {
        print_error "Backend directory not found"
        exit 1
    }
    
    # Check for requirements.txt
    if [ ! -f "requirements.txt" ]; then
        print_error "requirements.txt not found"
        print_info "Creating minimal requirements.txt..."
        cat > requirements.txt << 'EOF'
fastapi==0.110.1
uvicorn==0.25.0
python-dotenv>=1.0.1
pymongo==4.5.0
pydantic>=2.6.4
motor==3.3.1
EOF
        print_success "Created requirements.txt"
    fi
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_info "Creating Python virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
    
    # Install packages
    print_info "Installing Python packages..."
    source venv/bin/activate
    python -m pip install --upgrade pip --quiet
    pip install -r requirements.txt
    PKG_COUNT=$(pip list | wc -l)
    print_success "Installed $PKG_COUNT packages"
    deactivate
}

# Install frontend dependencies
install_frontend() {
    print_info "Installing frontend dependencies..."
    
    cd $INSTALL_DIR/frontend || {
        print_error "Frontend directory not found"
        exit 1
    }
    
    # Check for package.json
    if [ ! -f "package.json" ]; then
        print_error "package.json not found"
        print_info "Please ensure frontend files are in $INSTALL_DIR/frontend"
        exit 1
    fi
    
    print_info "Running yarn install..."
    yarn install
    print_success "Frontend dependencies installed"
}

# Create start script
create_start_script() {
    print_info "Creating start script..."
    
    cat > $INSTALL_DIR/start.sh << EOF
#!/bin/bash

echo "Starting Flux IPTV Website..."

# Start backend
echo "Starting backend..."
cd $INSTALL_DIR/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
BACKEND_PID=\$!
echo "Backend started (PID: \$BACKEND_PID)"

# Start frontend
echo "Starting frontend..."
cd $INSTALL_DIR/frontend
yarn start &
FRONTEND_PID=\$!
echo "Frontend started (PID: \$FRONTEND_PID)"

echo ""
echo "Flux IPTV is running!"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8001"
echo ""
echo "Press Ctrl+C to stop"

trap "kill \$BACKEND_PID \$FRONTEND_PID; exit" INT
wait
EOF

    chmod +x $INSTALL_DIR/start.sh
    print_success "Start script created at $INSTALL_DIR/start.sh"
}

# Create supervisor config
create_supervisor_config() {
    print_info "Creating supervisor configuration..."
    
    # Check if supervisor is installed
    if ! command -v supervisorctl &> /dev/null; then
        print_info "Installing supervisor..."
        if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
            apt-get install -y supervisor
        elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
            yum install -y supervisor
        fi
        systemctl enable supervisor
        systemctl start supervisor
        print_success "Supervisor installed"
    fi
    
    # Create backend supervisor config
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

    # Create frontend supervisor config
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

    # Set correct permissions
    chown -R www-data:www-data $INSTALL_DIR
    
    # Reload supervisor
    supervisorctl reread
    supervisorctl update
    
    print_success "Supervisor configured"
}

# Main installation
main() {
    echo ""
    check_root
    echo ""
    
    print_info "Step 1: Detecting OS..."
    detect_os
    echo ""
    
    print_info "Step 2: Updating system..."
    update_system
    echo ""
    
    print_info "Step 3: Installing dependencies..."
    install_basic_deps
    echo ""
    
    print_info "Step 4: Installing Node.js..."
    install_nodejs
    echo ""
    
    print_info "Step 5: Installing Yarn..."
    install_yarn
    echo ""
    
    print_info "Step 6: Installing Python..."
    install_python
    echo ""
    
    print_info "Step 7: MongoDB setup..."
    install_mongodb
    echo ""
    
    print_info "Step 8: Setting up project..."
    copy_project_files
    echo ""
    
    print_info "Step 9: Creating configuration..."
    create_env_files
    echo ""
    
    print_info "Step 10: Installing backend..."
    install_backend
    echo ""
    
    print_info "Step 11: Installing frontend..."
    install_frontend
    echo ""
    
    print_info "Step 12: Creating scripts..."
    create_start_script
    echo ""
    
    print_info "Step 13: Configuring services..."
    create_supervisor_config
    echo ""
    
    echo "================================================"
    echo -e "${GREEN}  Installation Complete! ✓${NC}"
    echo "================================================"
    echo ""
    echo "Installation directory: $INSTALL_DIR"
    echo ""
    echo "Services:"
    echo "  sudo supervisorctl status"
    echo "  sudo supervisorctl start fluxiptv-backend"
    echo "  sudo supervisorctl start fluxiptv-frontend"
    echo ""
    echo "Or start manually:"
    echo "  cd $INSTALL_DIR && ./start.sh"
    echo ""
    echo "Access at: http://localhost:3000"
    echo ""
    echo "Configuration files:"
    echo "  Backend:  $INSTALL_DIR/backend/.env"
    echo "  Frontend: $INSTALL_DIR/frontend/.env"
    echo "  WHMCS:    $INSTALL_DIR/frontend/src/data/mock.js"
    echo ""
}

main
