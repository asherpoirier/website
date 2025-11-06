#!/bin/bash

# Fix MongoDB installation for Ubuntu 24.04

echo "Fixing MongoDB repository for Ubuntu 24.04..."

# Remove broken repository
sudo rm -f /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB using Ubuntu 22.04 repository (compatible)
echo "Installing MongoDB using Ubuntu 22.04 (jammy) repository..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Check status
if systemctl is-active --quiet mongod; then
    echo "✓ MongoDB installed and running successfully"
    mongod --version | head -n 1
else
    echo "✗ MongoDB installation completed but service not running"
    echo "Check logs: sudo journalctl -u mongod"
fi
