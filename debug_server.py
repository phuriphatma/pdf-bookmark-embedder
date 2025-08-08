#!/usr/bin/env python3
"""
Simple test script that just starts the server and shows debug output
"""
import sys
import os
sys.path.append('/Users/xeno/webdev/pdfbookmark/server')

# Import our server
from bookmark_server_clean import PDFBookmarkHandler
from http.server import HTTPServer

def main():
    port = 8081
    server_address = ('', port)
    
    print(f"🚀 Starting PDF Bookmark Server on port {port}")
    print(f"📄 Debug mode enabled")
    
    try:
        httpd = HTTPServer(server_address, PDFBookmarkHandler)
        print(f"✅ Server ready! Listening on port {port}")
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")

if __name__ == '__main__':
    main()
