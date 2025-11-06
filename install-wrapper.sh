#!/bin/bash

# Wrapper script to ensure install.sh runs correctly

# Change to /app directory
cd /app || {
    echo "Error: Cannot change to /app directory"
    exit 1
}

# Check if install.sh exists
if [ ! -f "install.sh" ]; then
    echo "Error: install.sh not found in /app"
    exit 1
fi

# Make it executable
chmod +x install.sh

# Run the installation script
bash ./install.sh "$@"
