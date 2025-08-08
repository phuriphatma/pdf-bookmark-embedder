#!/bin/bash

# Build frontend
echo "Building frontend..."
npm run build

# Create a simple production server that serves both static files and API
cat > server/production_server.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
from pathlib import Path

# Add current directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from bookmark_server_clean import PDFBookmarkHandler
from http.server import HTTPServer, SimpleHTTPRequestHandler
import urllib.parse

class ProductionHandler(PDFBookmarkHandler):
    """Production handler that serves both static files and API"""
    
    def do_GET(self):
        """Handle GET requests - serve static files or API"""
        if self.path.startswith('/embed-bookmarks') or self.path.startswith('/health'):
            # API endpoints
            super().do_GET()
        else:
            # Serve static files from dist directory
            self.serve_static_file()
    
    def serve_static_file(self):
        """Serve static files from the dist directory"""
        # Remove query parameters
        path = urllib.parse.urlparse(self.path).path
        
        # Default to index.html for root path
        if path == '/' or path == '':
            path = '/index.html'
        
        # Remove leading slash
        if path.startswith('/'):
            path = path[1:]
        
        # Build file path
        dist_dir = Path(__file__).parent.parent / 'dist'
        file_path = dist_dir / path
        
        try:
            if file_path.exists() and file_path.is_file():
                # Determine content type
                content_type = 'text/html'
                if path.endswith('.js'):
                    content_type = 'application/javascript'
                elif path.endswith('.css'):
                    content_type = 'text/css'
                elif path.endswith('.ico'):
                    content_type = 'image/x-icon'
                elif path.endswith('.png'):
                    content_type = 'image/png'
                elif path.endswith('.jpg') or path.endswith('.jpeg'):
                    content_type = 'image/jpeg'
                
                # Send response
                self.send_response(200)
                self.send_header('Content-Type', content_type)
                self.send_cors_headers()
                self.end_headers()
                
                # Send file content
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                # File not found, serve index.html for SPA routing
                index_path = dist_dir / 'index.html'
                if index_path.exists():
                    self.send_response(200)
                    self.send_header('Content-Type', 'text/html')
                    self.send_cors_headers()
                    self.end_headers()
                    
                    with open(index_path, 'rb') as f:
                        self.wfile.write(f.read())
                else:
                    self.send_error(404, "File not found")
        except Exception as e:
            print(f"Error serving file {path}: {e}")
            self.send_error(500, "Internal server error")

def main():
    port = int(os.environ.get('PORT', 8081))
    server_address = ('', port)
    
    print(f"🚀 Starting Production PDF Bookmark Server on port {port}")
    print(f"📁 Serving static files from dist/")
    print(f"📄 API endpoint: /embed-bookmarks")
    
    try:
        httpd = HTTPServer(server_address, ProductionHandler)
        print(f"✅ Production server ready! http://0.0.0.0:{port}")
        httpd.serve_forever()
    except Exception as e:
        print(f"❌ Server error: {e}")
        raise

if __name__ == '__main__':
    main()
EOF

echo "Starting production server..."
python server/production_server.py
