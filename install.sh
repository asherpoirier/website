#!/bin/bash

# Flux IPTV Website Installation Script
# This script installs all dependencies and sets up the website

set -e  # Exit on any error

echo "================================================"
echo "  Flux IPTV Website - Installation Script"
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

# Check if running as root for system packages
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        print_info "Running as root"
    else
        print_info "Running as non-root user (may need sudo for system packages)"
    fi
}

# Check Node.js installation
check_nodejs() {
    print_info "Checking Node.js installation..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        print_success "Node.js is installed: $NODE_VERSION"
    else
        print_error "Node.js is not installed!"
        echo "Please install Node.js 16+ from: https://nodejs.org/"
        exit 1
    fi
}

# Check Yarn installation
check_yarn() {
    print_info "Checking Yarn installation..."
    if command -v yarn &> /dev/null; then
        YARN_VERSION=$(yarn -v)
        print_success "Yarn is installed: $YARN_VERSION"
    else
        print_info "Yarn is not installed. Installing Yarn..."
        npm install -g yarn
        print_success "Yarn installed successfully"
    fi
}

# Check Python installation
check_python() {
    print_info "Checking Python installation..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python is installed: $PYTHON_VERSION"
    else
        print_error "Python 3 is not installed!"
        echo "Please install Python 3.8+ from: https://www.python.org/"
        exit 1
    fi
}

# Check pip installation
check_pip() {
    print_info "Checking pip installation..."
    if command -v pip3 &> /dev/null; then
        PIP_VERSION=$(pip3 --version)
        print_success "pip is installed: $PIP_VERSION"
    else
        print_error "pip3 is not installed!"
        echo "Please install pip3"
        exit 1
    fi
}

# Check MongoDB installation (optional)
check_mongodb() {
    print_info "Checking MongoDB..."
    if command -v mongod &> /dev/null; then
        MONGO_VERSION=$(mongod --version | head -n 1)
        print_success "MongoDB is installed: $MONGO_VERSION"
    else
        print_info "MongoDB is not installed locally (you may be using a remote MongoDB)"
    fi
}

# Install Backend Dependencies
install_backend() {
    print_info "Installing Backend Dependencies..."
    cd /app/backend
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_info "Creating Python virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    print_info "Upgrading pip..."
    pip install --upgrade pip
    
    # Install requirements
    print_info "Installing Python packages from requirements.txt..."
    pip install -r requirements.txt
    print_success "Backend dependencies installed"
    
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

# Check environment files
check_env_files() {
    print_info "Checking environment files..."
    
    # Check backend .env
    if [ -f "/app/backend/.env" ]; then
        print_success "Backend .env file exists"
    else
        print_error "Backend .env file not found!"
        echo "Please create /app/backend/.env with required variables"
        exit 1
    fi
    
    # Check frontend .env
    if [ -f "/app/frontend/.env" ]; then
        print_success "Frontend .env file exists"
    else
        print_error "Frontend .env file not found!"
        echo "Please create /app/frontend/.env with required variables"
        exit 1
    fi
}

# Display MongoDB connection info
display_mongo_info() {
    print_info "MongoDB Configuration..."
    if [ -f "/app/backend/.env" ]; then
        MONGO_URL=$(grep MONGO_URL /app/backend/.env | cut -d '=' -f2)
        if [ -n "$MONGO_URL" ]; then
            print_success "MongoDB URL is configured"
        else
            print_error "MONGO_URL not found in backend/.env"
        fi
    fi
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
    
    # Check prerequisites
    print_info "Step 1: Checking Prerequisites..."
    check_nodejs
    check_yarn
    check_python
    check_pip
    check_mongodb
    echo ""
    
    # Check environment files
    print_info "Step 2: Checking Environment Configuration..."
    check_env_files
    display_mongo_info
    echo ""
    
    # Install backend
    print_info "Step 3: Installing Backend..."
    install_backend
    echo ""
    
    # Install frontend
    print_info "Step 4: Installing Frontend..."
    install_frontend
    echo ""
    
    # Create start script
    print_info "Step 5: Creating Helper Scripts..."
    create_start_script
    echo ""
    
    # Installation complete
    echo "================================================"
    echo -e "${GREEN}  Installation Complete! ✓${NC}"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "  1. Configure WHMCS URLs in /app/frontend/src/data/mock.js"
    echo "  2. Update Telegram username if needed (currently: @customcloudtv)"
    echo "  3. Start the website:"
    echo "     - Using supervisor: sudo supervisorctl start all"
    echo "     - Or manually: ./start.sh"
    echo ""
    echo "Access your website at:"
    echo "  - Frontend: http://localhost:3000"
    echo "  - Backend:  http://localhost:8001/api"
    echo ""
}

# Run main installation
main
