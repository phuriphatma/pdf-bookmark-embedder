#!/bin/bash

# Simple server setup script for local development
# This script starts a local server to test the PDF Bookmark Manager

echo "🚀 Starting PDF Bookmark Manager local server..."
echo "📁 Serving files from: $(pwd)"

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo "🐍 Using Python 3..."
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "🐍 Using Python..."
    python -m http.server 8000
elif command -v node &> /dev/null && command -v npx &> /dev/null; then
    echo "📦 Using Node.js serve..."
    npx serve . -p 8000
else
    echo "❌ Error: No suitable server found."
    echo "Please install Python or Node.js to run a local server."
    echo ""
    echo "Alternatives:"
    echo "- Python: python -m http.server 8000"
    echo "- Node.js: npx serve . -p 8000"
    echo "- PHP: php -S localhost:8000"
    exit 1
fi
