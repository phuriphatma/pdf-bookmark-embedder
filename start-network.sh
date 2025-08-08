#!/bin/bash

# PDF Bookmark Embedder - Network Access Startup Script

echo "🚀 Starting PDF Bookmark Embedder with Network Access"
echo "=================================================="

# Get local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo "📡 Starting servers..."
echo ""

# Start Python server in background
echo "🐍 Starting Python bookmark server..."
.venv/bin/python server/bookmark_server.py &
PYTHON_PID=$!

# Wait a moment for server to start
sleep 2

# Start Vite dev server
echo "⚡ Starting Vite development server..."
echo ""
echo "🌐 Access URLs:"
echo "   Desktop: http://localhost:3000"
echo "   📱 iPad:  http://$LOCAL_IP:3000"
echo ""
echo "🔗 Backend Server:"
echo "   Desktop: http://localhost:8081"
echo "   📱 iPad:  http://$LOCAL_IP:8081"
echo ""
echo "📱 To access from iPad:"
echo "   1. Make sure iPad is on the same WiFi network"
echo "   2. Open Safari and go to: http://$LOCAL_IP:3000"
echo "   3. Upload a PDF and test the bookmark embedding"
echo ""
echo "Press Ctrl+C to stop both servers"
echo "=================================================="

# Start Vite (this will block until stopped)
npm run dev

# Clean up Python server when Vite stops
echo "🛑 Stopping Python server..."
kill $PYTHON_PID 2>/dev/null
