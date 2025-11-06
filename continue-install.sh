#!/bin/bash

# Continue Flux IPTV installation without MongoDB
# Use this if MongoDB installation failed or you want to use remote MongoDB

echo "Continuing Flux IPTV installation..."
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Check environment files
print_info "Checking environment files..."
if [ ! -f "/app/backend/.env" ]; then
    echo "✗ Backend .env not found!"
    exit 1
fi
if [ ! -f "/app/frontend/.env" ]; then
    echo "✗ Frontend .env not found!"
    exit 1
fi
print_success "Environment files exist"
echo ""

# Install backend dependencies
print_info "Installing Backend Dependencies..."
cd /app/backend

if [ ! -d "venv" ]; then
    print_info "Creating Python virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

source venv/bin/activate
print_info "Upgrading pip..."
python -m pip install --upgrade pip

print_info "Installing Python packages..."
pip install -r requirements.txt
print_success "Backend dependencies installed"
deactivate
echo ""

# Install frontend dependencies
print_info "Installing Frontend Dependencies..."
cd /app/frontend

print_info "Installing npm packages with Yarn..."
yarn install
print_success "Frontend dependencies installed"
echo ""

# Create start script
print_info "Creating start script..."
cd /app
cat > /app/start.sh << 'EOF'
#!/bin/bash

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

trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
EOF

chmod +x /app/start.sh
print_success "Start script created"
echo ""

echo "================================================"
echo -e "${GREEN}  Installation Complete! ✓${NC}"
echo "================================================"
echo ""
echo "MongoDB: Using connection from .env file"
echo ""
echo "Start the website:"
echo "  sudo supervisorctl start all"
echo ""
echo "Or manually:"
echo "  ./start.sh"
echo ""
echo "Access your website at:"
echo "  - Frontend: http://localhost:3000"
echo "  - Backend:  http://localhost:8001/api"
echo ""
