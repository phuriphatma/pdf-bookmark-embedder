#!/bin/bash
# Startup script for PDF Bookmark Embedder

echo "🚀 Starting PDF Bookmark Embedder"
echo "================================="

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Run: python -m venv .venv"
    exit 1
fi

# Check if PyMuPDF is installed
if ! .venv/bin/python -c "import fitz" 2>/dev/null; then
    echo "❌ PyMuPDF not installed. Run: .venv/bin/pip install pymupdf"
    exit 1
fi

# Start the Python server in background
echo "🐍 Starting Python bookmark server..."
.venv/bin/python server/bookmark_server.py &
SERVER_PID=$!

# Wait a moment for server to start
sleep 2

# Start the Vite dev server
echo "⚡ Starting Vite dev server..."
npm run dev

# Cleanup: Kill the Python server when this script exits
trap "echo '🛑 Stopping servers...'; kill $SERVER_PID 2>/dev/null" EXIT
