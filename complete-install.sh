#!/bin/bash

# Complete the Flux IPTV installation
# Use this if the main install.sh had issues

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}➜ $1${NC}"; }

echo "================================================"
echo "  Completing Flux IPTV Installation"
echo "================================================"
echo ""

# Backend installation
print_info "Installing Backend Dependencies..."

cd /app/backend || {
    print_error "Backend directory not found"
    exit 1
}

if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found"
    exit 1
fi

# Create venv if needed
if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate and install
print_info "Installing packages..."
source venv/bin/activate
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt
PKG_COUNT=$(pip list | wc -l)
print_success "Backend: $PKG_COUNT packages installed"
deactivate

# Frontend installation
print_info "Installing Frontend Dependencies..."

cd /app/frontend || {
    print_error "Frontend directory not found"
    exit 1
}

if [ ! -f "package.json" ]; then
    print_error "package.json not found"
    exit 1
fi

print_info "Running yarn install..."
yarn install
print_success "Frontend dependencies installed"

# Create start script
print_info "Creating start script..."
cd /app

cat > start.sh << 'EOF'
#!/bin/bash

echo "Starting Flux IPTV Website..."

# Start backend
echo "Starting backend..."
cd /app/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
BACKEND_PID=$!
echo "Backend started (PID: $BACKEND_PID)"

# Start frontend
echo "Starting frontend..."
cd /app/frontend
yarn start &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"

echo ""
echo "Flux IPTV Website is running!"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8001"
echo ""
echo "Press Ctrl+C to stop"

trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
EOF

chmod +x start.sh
print_success "Start script created"

echo ""
echo "================================================"
echo -e "${GREEN}  Installation Complete! ✓${NC}"
echo "================================================"
echo ""
echo "Start the website:"
echo "  sudo supervisorctl start all"
echo ""
echo "Or manually:"
echo "  cd /app && ./start.sh"
echo ""
echo "Access at: http://localhost:3000"
echo ""
