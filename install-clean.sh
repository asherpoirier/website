#!/bin/bash

# Flux IPTV Installation Script v2.0
# Clean version with enhanced error handling

set -e

echo "================================================"
echo "  Flux IPTV Website - Installation Script v2.0"
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

# Create environment files first
create_env_files() {
    print_info "Creating environment configuration files..."
    
    # Create directories with full path
    print_info "Creating directories..."
    /bin/mkdir -p /app/backend || {
        print_error "Failed to create /app/backend"
        exit 1
    }
    /bin/mkdir -p /app/frontend || {
        print_error "Failed to create /app/frontend"
        exit 1
    }
    print_success "Directories created"
    
    # Create backend .env
    if [ ! -f "/app/backend/.env" ]; then
        print_info "Creating backend .env file..."
        /bin/cat > /app/backend/.env <<'ENVEOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
ENVEOF
        if [ $? -eq 0 ]; then
            print_success "Backend .env created"
        else
            print_error "Failed to create backend .env"
            exit 1
        fi
    else
        print_success "Backend .env already exists"
    fi
    
    # Create frontend .env
    if [ ! -f "/app/frontend/.env" ]; then
        print_info "Creating frontend .env file..."
        /bin/cat > /app/frontend/.env <<'ENVEOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
ENVEOF
        if [ $? -eq 0 ]; then
            print_success "Frontend .env created"
        else
            print_error "Failed to create frontend .env"
            exit 1
        fi
    else
        print_success "Frontend .env already exists"
    fi
    
    echo ""
    print_success "Environment files ready!"
    echo ""
}

# Run it
create_env_files

echo "Test completed successfully!"
echo ""
echo "Now you can run the full install.sh script"
