#!/bin/bash

# Simple test script to verify Flux IPTV installation

echo "Testing Flux IPTV Installation..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

# Test Node.js
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓ Node.js installed: $(node -v)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Node.js not found${NC}"
    ((FAIL++))
fi

# Test Yarn
if command -v yarn &> /dev/null; then
    echo -e "${GREEN}✓ Yarn installed: $(yarn -v)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Yarn not found${NC}"
    ((FAIL++))
fi

# Test Python
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓ Python installed: $(python3 --version)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Python3 not found${NC}"
    ((FAIL++))
fi

# Test pip
if command -v pip3 &> /dev/null; then
    echo -e "${GREEN}✓ pip installed: $(pip3 --version | cut -d' ' -f1-2)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ pip3 not found${NC}"
    ((FAIL++))
fi

# Test backend venv
if [ -d "/app/backend/venv" ]; then
    echo -e "${GREEN}✓ Backend virtual environment created${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Backend venv not found${NC}"
    ((FAIL++))
fi

# Test frontend node_modules
if [ -d "/app/frontend/node_modules" ]; then
    echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Frontend node_modules not found${NC}"
    ((FAIL++))
fi

# Test environment files
if [ -f "/app/backend/.env" ]; then
    echo -e "${GREEN}✓ Backend .env exists${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Backend .env not found${NC}"
    ((FAIL++))
fi

if [ -f "/app/frontend/.env" ]; then
    echo -e "${GREEN}✓ Frontend .env exists${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Frontend .env not found${NC}"
    ((FAIL++))
fi

# Test start script
if [ -f "/app/start.sh" ] && [ -x "/app/start.sh" ]; then
    echo -e "${GREEN}✓ Start script created and executable${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Start script not found or not executable${NC}"
    ((FAIL++))
fi

echo ""
echo "=========================================="
echo "Test Results: $PASS passed, $FAIL failed"
echo "=========================================="

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests passed! Installation successful.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Update WHMCS URLs in /app/frontend/src/data/mock.js"
    echo "  2. Start website: sudo supervisorctl start all"
    echo "  3. Access at: http://localhost:3000"
    exit 0
else
    echo -e "${RED}Some tests failed. Please check the installation.${NC}"
    exit 1
fi
