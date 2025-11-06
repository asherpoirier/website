#!/bin/bash

# Quick script to copy Flux IPTV from /app to /var/www/html

INSTALL_DIR="/var/www/html"

echo "Copying Flux IPTV to $INSTALL_DIR..."

# Create directory
sudo mkdir -p $INSTALL_DIR

# Copy backend
echo "Copying backend..."
sudo rm -rf $INSTALL_DIR/backend
sudo cp -r /app/backend $INSTALL_DIR/
echo "✓ Backend copied"

# Copy frontend
echo "Copying frontend..."
sudo rm -rf $INSTALL_DIR/frontend
sudo cp -r /app/frontend $INSTALL_DIR/
echo "✓ Frontend copied"

# Copy documentation
echo "Copying documentation..."
sudo cp /app/README.md $INSTALL_DIR/ 2>/dev/null || true
sudo cp /app/QUICKSTART.md $INSTALL_DIR/ 2>/dev/null || true
sudo cp /app/*.sh $INSTALL_DIR/ 2>/dev/null || true
echo "✓ Documentation copied"

# Verify
echo ""
echo "Verifying files..."
if [ -f "$INSTALL_DIR/backend/requirements.txt" ]; then
    echo "✓ Backend files OK"
else
    echo "✗ Backend files missing"
fi

if [ -f "$INSTALL_DIR/frontend/package.json" ]; then
    echo "✓ Frontend files OK"
else
    echo "✗ Frontend files missing"
fi

echo ""
echo "Files copied to: $INSTALL_DIR"
echo ""
echo "Now you can run:"
echo "  cd /root && sudo bash install-production.sh"
