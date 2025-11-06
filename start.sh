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
