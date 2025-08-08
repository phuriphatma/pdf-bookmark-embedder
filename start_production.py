#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path

def build_frontend():
    """Build the frontend using Vite"""
    print("Building frontend...")
    result = subprocess.run(["npm", "run", "build"], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Frontend build failed: {result.stderr}")
        return False
    print("Frontend built successfully!")
    return True

def start_server():
    """Start the Python server"""
    print("Starting Python server...")
    # Add the server directory to Python path
    server_dir = Path(__file__).parent / "server"
    sys.path.insert(0, str(server_dir))
    
    # Import and run the server
    from bookmark_server_clean import app, run_server
    
    port = int(os.environ.get("PORT", 8081))
    print(f"Server starting on port {port}")
    run_server(port)

if __name__ == "__main__":
    # Build frontend first
    if build_frontend():
        # Then start the server
        start_server()
    else:
        sys.exit(1)
