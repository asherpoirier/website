#!/bin/bash

# Flux IPTV Website Installation Script
# This script installs all dependencies and sets up the website
# Includes automatic .env file creation and all compatibility fixes

set -e  # Exit on any error

echo "================================================"
echo "  Flux IPTV Website - Installation Script"
echo "  (Auto-configuring - Python 3.12 Compatible)"
echo "================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "This script must be run as root or with sudo"
        echo "Please run: sudo bash install.sh"
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

# Update system packages
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
        print_success "Node.js is already installed: $NODE_VERSION"
        return
    fi
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        # Install Node.js 20.x LTS
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
        print_success "Node.js installed successfully"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
        yum install -y nodejs
        print_success "Node.js installed successfully"
    fi
    
    NODE_VERSION=$(node -v)
    print_success "Node.js version: $NODE_VERSION"
}

# Install Yarn
install_yarn() {
    print_info "Installing Yarn..."
    if command -v yarn &> /dev/null; then
        YARN_VERSION=$(yarn -v)
        print_success "Yarn is already installed: $YARN_VERSION"
        return
    fi
    
    npm install -g yarn
    YARN_VERSION=$(yarn -v)
    print_success "Yarn installed successfully: $YARN_VERSION"
}

# Install Python (PEP 668 Compliant)
install_python() {
    print_info "Installing Python and pip..."
    
    # Check if Python is installed
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python is already installed: $PYTHON_VERSION"
    else
        if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
            apt-get install -y python3 python3-pip python3-venv python3-full
            print_success "Python installed successfully"
        elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
            yum install -y python3 python3-pip python3-virtualenv
            print_success "Python installed successfully"
        fi
    fi
    
    # Install pip via system package manager (PEP 668 compliant - no get-pip.py)
    print_info "Ensuring pip is installed via system packages..."
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y python3-pip python3-venv python3-full
        print_success "pip and venv installed via apt"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        yum install -y python3-pip python3-virtualenv
        print_success "pip and virtualenv installed via yum"
    fi
    
    PYTHON_VERSION=$(python3 --version)
    print_success "Python version: $PYTHON_VERSION"
    print_success "pip will be used inside virtual environment (PEP 668 compliant)"
}

# Install MongoDB (optional - for local development)
install_mongodb() {
    print_info "Checking MongoDB..."
    if command -v mongod &> /dev/null; then
        MONGO_VERSION=$(mongod --version | head -n 1)
        print_success "MongoDB is already installed"
        return
    fi
    
    echo ""
    read -p "Do you want to install MongoDB locally? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing MongoDB..."
        if [[ "$OS" == "ubuntu" ]]; then
            # Determine Ubuntu codename - use jammy for noble (24.04) since noble isn't supported yet
            UBUNTU_CODENAME=$(lsb_release -cs)
            if [[ "$UBUNTU_CODENAME" == "noble" ]]; then
                UBUNTU_CODENAME="jammy"
                print_info "Using Ubuntu 22.04 (jammy) repository for MongoDB (compatible with 24.04)"
            fi
            
            # Install MongoDB 7.0 for Ubuntu
            curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
            echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_CODENAME}/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
            
            apt-get update
            if apt-get install -y mongodb-org; then
                systemctl start mongod
                systemctl enable mongod
                print_success "MongoDB installed and started"
            else
                print_error "MongoDB installation failed"
                print_info "You can use remote MongoDB instead. Just skip this step."
            fi
        else
            print_info "Skipping MongoDB installation. Please install manually or use remote MongoDB."
        fi
    else
        print_info "Skipping MongoDB installation. Will use configuration from .env file"
    fi
}

# Install Backend Dependencies
install_backend() {
    print_info "Installing Backend Dependencies..."
    
    # Change to backend directory and verify
    cd /app/backend || {
        print_error "Failed to change to /app/backend"
        exit 1
    }
    
    # Verify requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        print_error "requirements.txt not found in /app/backend"
        ls -la /app/backend/
        exit 1
    fi
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_info "Creating Python virtual environment..."
        python3 -m venv venv
        if [ $? -ne 0 ]; then
            print_error "Failed to create virtual environment"
            print_info "Trying alternative method..."
            python3 -m venv venv --system-site-packages
        fi
        print_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    print_info "Activating virtual environment..."
    source venv/bin/activate
    
    # Verify we're in the right directory
    print_info "Current directory: $(pwd)"
    
    # Upgrade pip in virtual environment
    print_info "Upgrading pip in virtual environment..."
    python -m pip install --upgrade pip
    
    # Install requirements with full path to be safe
    print_info "Installing Python packages from requirements.txt..."
    pip install -r /app/backend/requirements.txt
    print_success "Backend dependencies installed"
    
    # Show installed packages count
    PKG_COUNT=$(pip list | wc -l)
    print_success "Installed $PKG_COUNT Python packages"
    
    deactivate
    cd /app
}

# Install Frontend Dependencies
install_frontend() {
    print_info "Installing Frontend Dependencies..."
    cd /app/frontend
    
    # Remove node_modules if exists (for clean install)
    if [ -d "node_modules" ]; then
        print_info "Removing existing node_modules..."
        rm -rf node_modules
    fi
    
    # Install dependencies
    print_info "Installing npm packages with Yarn..."
    yarn install
    print_success "Frontend dependencies installed"
    
    cd /app
}

# Create environment files
create_env_files() {
    print_info "Creating environment configuration files..."
    
    # Ensure directories exist
    mkdir -p /app/backend
    mkdir -p /app/frontend
    
    # Create backend .env
    if [ ! -f "/app/backend/.env" ]; then
        print_info "Creating backend .env file..."
        cat > /app/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
EOF
        print_success "Backend .env created"
    else
        print_success "Backend .env already exists"
    fi
    
    # Create frontend .env
    if [ ! -f "/app/frontend/.env" ]; then
        print_info "Creating frontend .env file..."
        
        # Try to detect the server's public URL
        if [ -n "$REACT_APP_BACKEND_URL" ]; then
            BACKEND_URL="$REACT_APP_BACKEND_URL"
        else
            BACKEND_URL="http://localhost:8001"
        fi
        
        cat > /app/frontend/.env << EOF
REACT_APP_BACKEND_URL=${BACKEND_URL}
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
EOF
        print_success "Frontend .env created"
    else
        print_success "Frontend .env already exists"
    fi
    
    # Display configuration
    echo ""
    print_info "Environment Configuration:"
    echo "  Backend .env:"
    if [ -f "/app/backend/.env" ]; then
        echo "    - MONGO_URL: $(grep MONGO_URL /app/backend/.env | cut -d'=' -f2)"
        echo "    - DB_NAME: $(grep DB_NAME /app/backend/.env | cut -d'=' -f2)"
    fi
    echo "  Frontend .env:"
    if [ -f "/app/frontend/.env" ]; then
        echo "    - REACT_APP_BACKEND_URL: $(grep REACT_APP_BACKEND_URL /app/frontend/.env | cut -d'=' -f2)"
    fi
    echo ""
}

# Create start script
create_start_script() {
    print_info "Creating start script..."
    cat > /app/start.sh << 'EOF'
#!/bin/bash

# Start Flux IPTV Website

echo "Starting Flux IPTV Website..."

# Start backend
echo "Starting backend server..."
cd /app/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
BACKEND_PID=$!
echo "Backend started (PID: $BACKEND_PID)"

# Start frontend
echo "Starting frontend server..."
cd /app/frontend
yarn start &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"

echo ""
echo "================================================"
echo "  Flux IPTV Website is running!"
echo "================================================"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8001"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
EOF

    chmod +x /app/start.sh
    print_success "Start script created at /app/start.sh"
}

# Main installation flow
main() {
    echo ""
    check_root
    echo ""
    
    # Detect OS
    print_info "Step 1: Detecting Operating System..."
    detect_os
    echo ""
    
    # Update system
    print_info "Step 2: Updating System Packages..."
    update_system
    echo ""
    
    # Install basic dependencies
    print_info "Step 3: Installing Basic Dependencies..."
    install_basic_deps
    echo ""
    
    # Install Node.js
    print_info "Step 4: Installing Node.js..."
    install_nodejs
    echo ""
    
    # Install Yarn
    print_info "Step 5: Installing Yarn..."
    install_yarn
    echo ""
    
    # Install Python
    print_info "Step 6: Installing Python..."
    install_python
    echo ""
    
    # Install MongoDB (optional)
    print_info "Step 7: MongoDB Setup..."
    install_mongodb
    echo ""
    
    # Create environment files
    print_info "Step 8: Creating Environment Configuration..."
    create_env_files
    echo ""
    
    # Install backend
    print_info "Step 9: Installing Backend Dependencies..."
    install_backend
    echo ""
    
    # Install frontend
    print_info "Step 10: Installing Frontend Dependencies..."
    install_frontend
    echo ""
    
    # Create start script
    print_info "Step 11: Creating Helper Scripts..."
    create_start_script
    echo ""
    
    # Installation complete
    echo "================================================"
    echo -e "${GREEN}  Installation Complete! ✓${NC}"
    echo "================================================"
    echo ""
    echo "All dependencies have been installed:"
    echo "  ✓ Node.js $(node -v)"
    echo "  ✓ Yarn $(yarn -v)"
    echo "  ✓ Python $(python3 --version | cut -d' ' -f2)"
    echo "  ✓ Backend dependencies"
    echo "  ✓ Frontend dependencies"
    echo ""
    echo "Next steps:"
    echo "  1. Configure WHMCS URLs in /app/frontend/src/data/mock.js"
    echo "  2. Update Telegram username if needed (currently: @customcloudtv)"
    echo "  3. Start the website:"
    echo "     - Using supervisor: sudo supervisorctl start all"
    echo "     - Or manually: cd /app && ./start.sh"
    echo ""
    echo "Access your website at:"
    echo "  - Frontend: http://localhost:3000"
    echo "  - Backend:  http://localhost:8001/api"
    echo ""
}

# Run main installation
main
