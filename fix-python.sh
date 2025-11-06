#!/bin/bash

# Quick fix for Python PEP 668 issue

echo "Fixing Python environment..."

# Install python3-pip via apt (the correct way for PEP 668)
if command -v apt-get &> /dev/null; then
    echo "Installing python3-pip, python3-venv, python3-full..."
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv python3-full
    echo "✓ Python packages installed"
fi

# Clean up any failed pip installation
if [ -f "get-pip.py" ]; then
    rm get-pip.py
    echo "✓ Cleaned up get-pip.py"
fi

# Verify pip is available
if command -v pip3 &> /dev/null; then
    echo "✓ pip3 is now available: $(pip3 --version)"
else
    echo "! pip3 will be available in virtual environment"
fi

# Continue with backend installation
cd /app/backend

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

echo "Installing backend dependencies..."
source venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
deactivate
echo "✓ Backend dependencies installed"

cd /app/frontend
echo "Installing frontend dependencies..."
yarn install
echo "✓ Frontend dependencies installed"

echo ""
echo "================================================"
echo "  Fix Complete!"
echo "================================================"
echo ""
echo "You can now start the website:"
echo "  sudo supervisorctl start all"
echo ""
