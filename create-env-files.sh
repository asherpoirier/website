#!/bin/bash

# Quick script to create missing .env files

echo "Creating environment configuration files..."

# Ensure directories exist
mkdir -p /app/backend
mkdir -p /app/frontend

# Create backend .env
if [ ! -f "/app/backend/.env" ]; then
    echo "Creating backend .env file..."
    cat > /app/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*
EOF
    echo "✓ Backend .env created"
else
    echo "✓ Backend .env already exists"
fi

# Create frontend .env
if [ ! -f "/app/frontend/.env" ]; then
    echo "Creating frontend .env file..."
    cat > /app/frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
EOF
    echo "✓ Frontend .env created"
else
    echo "✓ Frontend .env already exists"
fi

echo ""
echo "Environment files created successfully!"
echo ""
echo "Backend .env:"
cat /app/backend/.env
echo ""
echo "Frontend .env:"
cat /app/frontend/.env
echo ""
echo "You can now continue with:"
echo "  sudo bash /app/continue-install.sh"
echo "or"
echo "  sudo bash /app/install.sh"
