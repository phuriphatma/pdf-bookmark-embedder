#!/usr/bin/env python3
"""
PDF Bookmark Embedder Server
Automatically adds bookmarks to pages 1, 3, and 6 of uploaded PDFs
Optimized for iOS Safari compatibility
"""

import fitz  # PyMuPDF
import io
import json
import traceback
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer


class PDFBookmarkHandler(BaseHTTPRequestHandler):
    """HTTP handler for PDF bookmark embedding"""

    def log_message(self, format, *args):
        """Custom logging with timestamps"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {format % args}")

    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/health':
            self.send_health_check()
        elif self.path == '/' or self.path == '/index.html':
            self.serve_static_file('dist/index.html', 'text/html')
        elif self.path.startswith('/assets/'):
            # Serve CSS and JS files from dist/assets/
            file_path = f"dist{self.path}"
            if self.path.endswith('.css'):
                self.serve_static_file(file_path, 'text/css')
            elif self.path.endswith('.js'):
                self.serve_static_file(file_path, 'application/javascript')
            elif self.path.endswith('.js.map'):
                self.serve_static_file(file_path, 'application/json')
            else:
                self.send_error(404, "File not found")
        else:
            self.send_error(404, "Endpoint not found")

    def do_POST(self):
        """Handle POST requests for PDF processing"""
        if self.path == '/embed-bookmarks':
            self.handle_bookmark_embedding()
        else:
            self.send_error(404, "Endpoint not found")

    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_cors_headers()
        self.end_headers()

    def send_cors_headers(self):
        """Send CORS headers for browser compatibility"""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Access-Control-Max-Age', '86400')

    def serve_static_file(self, file_path, content_type):
        """Serve static files (HTML, CSS, JS)"""
        try:
            import os
            print(f"🔍 Attempting to serve: {file_path}")
            print(f"📁 Current working directory: {os.getcwd()}")
            print(f"📂 File exists: {os.path.exists(file_path)}")
            
            if os.path.exists(file_path):
                with open(file_path, 'rb') as f:
                    content = f.read()
                
                print(f"✅ Serving {file_path} ({len(content)} bytes)")
                self.send_response(200)
                self.send_cors_headers()
                self.send_header('Content-Type', content_type)
                self.send_header('Content-Length', str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                # List directory contents for debugging
                dir_path = os.path.dirname(file_path) or '.'
                if os.path.exists(dir_path):
                    files = os.listdir(dir_path)
                    print(f"📂 Directory {dir_path} contents: {files}")
                print(f"❌ File not found: {file_path}")
                self.send_error(404, f"File not found: {file_path}")
        except Exception as e:
            print(f"❌ Error serving static file {file_path}: {e}")
            import traceback
            traceback.print_exc()
            self.send_error(500, f"Internal server error: {str(e)}")

    def send_health_check(self):
        """Send health check response"""
        self.send_response(200)
        self.send_cors_headers()
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        response = {
            'status': 'healthy',
            'service': 'PDF Bookmark Embedder',
            'version': '1.2.0',
            'library': 'PyMuPDF',
            'features': ['bookmark_embedding', 'ios_safari_compatible']
        }
        self.wfile.write(json.dumps(response).encode('utf-8'))

    def handle_bookmark_embedding(self):
        """Handle PDF bookmark embedding requests"""
        try:
            print(f"📥 Received POST request to /embed-bookmarks")
            print(f"📋 Headers: {dict(self.headers)}")
            
            # Parse multipart form data
            content_type = self.headers.get('Content-Type', '')
            print(f"📄 Content-Type: {content_type}")
            
            if not content_type.startswith('multipart/form-data'):
                self.send_error(400, "Expected multipart/form-data")
                return

            # Get content length
            content_length_header = self.headers.get('Content-Length')
            if not content_length_header:
                self.send_error(400, "No Content-Length header")
                return
                
            content_length = int(content_length_header)
            print(f"📏 Content-Length: {content_length}")
            
            if content_length == 0:
                self.send_error(400, "No content provided")
                return

            # Read the entire request body
            print("📖 Reading request body...")
            post_data = self.rfile.read(content_length)
            print(f"📦 Read {len(post_data)} bytes")
            
            # Extract PDF data from multipart form
            pdf_data, bookmark_data = self.extract_pdf_from_multipart(post_data, content_type)
            if not pdf_data:
                self.send_error(400, "No valid PDF file found in request")
                return

            print(f"📁 Processing PDF: {len(pdf_data)} bytes")
            if bookmark_data:
                print(f"📋 Custom bookmarks provided: {len(bookmark_data)} items")

            # Process PDF with bookmarks
            processed_pdf = self.add_bookmarks_to_pdf(pdf_data, bookmark_data)

            # Send response
            self.send_response(200)
            self.send_cors_headers()
            self.send_header('Content-Type', 'application/pdf')
            self.send_header('Content-Disposition', 'attachment; filename="pdf_with_bookmarks.pdf"')
            self.send_header('Content-Length', str(len(processed_pdf)))
            self.end_headers()
            self.wfile.write(processed_pdf)

            print(f"✅ PDF processed successfully: {len(processed_pdf)} bytes")

        except Exception as e:
            print(f"❌ Error processing PDF: {str(e)}")
            print(f"📋 Traceback: {traceback.format_exc()}")
            
            self.send_response(500)
            self.send_cors_headers()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            error_response = {
                'success': False,
                'error': str(e),
                'message': 'Failed to process PDF'
            }
            self.wfile.write(json.dumps(error_response).encode('utf-8'))

    def extract_pdf_from_multipart(self, post_data, content_type):
        """Extract PDF data and optional bookmark data from multipart form data"""
        try:
            # Extract boundary from content type
            if 'boundary=' not in content_type:
                print("❌ No boundary found in Content-Type")
                return None, None
                
            boundary = content_type.split('boundary=')[1]
            # Remove quotes if present
            if boundary.startswith('"') and boundary.endswith('"'):
                boundary = boundary[1:-1]
                
            boundary_bytes = boundary.encode()
            print(f"🔗 Boundary: {boundary}")
            
            # Split by boundary
            parts = post_data.split(b'--' + boundary_bytes)
            print(f"📂 Found {len(parts)} parts")
            
            pdf_data = None
            bookmark_data = None
            
            for i, part in enumerate(parts):
                print(f"📄 Part {i}: {len(part)} bytes")
                if len(part) > 10:  # Show content for all substantial parts
                    # Show the beginning of each part to see headers
                    part_preview = part[:300].decode('utf-8', errors='ignore')
                    print(f"📋 Part {i} headers: {part_preview}")
                
                # Extract PDF file
                if b'name="pdf"' in part:  # More flexible matching
                    print("✅ Found PDF part")
                    header_end = part.find(b'\r\n\r\n')
                    if header_end != -1:
                        pdf_data = part[header_end + 4:]
                        # Remove trailing boundary markers and newlines
                        if pdf_data.endswith(b'\r\n'):
                            pdf_data = pdf_data[:-2]
                        if pdf_data.endswith(b'--'):
                            pdf_data = pdf_data[:-2]
                        print(f"📄 Extracted PDF data: {len(pdf_data)} bytes")
                        
                        # Validate PDF data
                        if len(pdf_data) < 100:
                            print("❌ PDF data too small")
                            continue
                        
                        if not pdf_data.startswith(b'%PDF'):
                            print("❌ Invalid PDF header")
                            continue
                
                # Extract bookmark data (optional)
                elif b'name="bookmarks"' in part:  # More flexible matching
                    print("✅ Found bookmarks part")
                    header_end = part.find(b'\r\n\r\n')
                    if header_end != -1:
                        bookmark_data = part[header_end + 4:]
                        if bookmark_data.endswith(b'\r\n'):
                            bookmark_data = bookmark_data[:-2]
                        if bookmark_data.endswith(b'--'):
                            bookmark_data = bookmark_data[:-2]
                        
                        try:
                            bookmark_data = json.loads(bookmark_data.decode('utf-8'))
                            print(f"📋 Extracted bookmark data: {len(bookmark_data)} bookmarks")
                        except:
                            print("⚠️ Invalid bookmark data, using defaults")
                            bookmark_data = None

            if not pdf_data:
                print("❌ No PDF data found")
                return None, None
                
            return pdf_data, bookmark_data
            
        except Exception as e:
            print(f"❌ Error extracting data: {e}")
            return None, None

    def add_bookmarks_to_pdf(self, pdf_data, custom_bookmarks=None):
        """Add bookmarks to PDF using PyMuPDF with custom or default bookmarks"""
        try:
            # Open PDF document
            doc = fitz.open(stream=pdf_data, filetype="pdf")
            print(f"📄 PDF loaded: {doc.page_count} pages")

            # Create Table of Contents (TOC) structure
            toc = []
            
            if custom_bookmarks:
                # Use custom bookmarks from the viewer
                print(f"📋 Using custom bookmarks: {len(custom_bookmarks)} items")
                for bookmark in custom_bookmarks:
                    if bookmark['page'] <= doc.page_count:
                        toc.append([
                            bookmark.get('level', 1),
                            bookmark['title'],
                            bookmark['page']
                        ])
                        print(f"✅ Added custom bookmark: {bookmark['title']} (Page {bookmark['page']})")
                    else:
                        print(f"⚠️ Skipped bookmark {bookmark['title']} - page {bookmark['page']} exceeds document length")
            else:
                # Use default bookmarks for pages 1, 3, and 6
                print("📋 Using default bookmarks (pages 1, 3, 6)")
                if doc.page_count >= 1:
                    toc.append([1, "📄 Page 1", 1])
                    print("✅ Added default bookmark for Page 1")
                
                if doc.page_count >= 3:
                    toc.append([1, "📄 Page 3", 3])
                    print("✅ Added default bookmark for Page 3")
                
                if doc.page_count >= 6:
                    toc.append([1, "📄 Page 6", 6])
                    print("✅ Added default bookmark for Page 6")

            print(f"📋 Final TOC structure: {toc}")

            # Set the table of contents
            if toc:
                doc.set_toc(toc)
                print("✅ Table of contents set successfully")
            else:
                print("⚠️ No bookmarks to add")

            # Save to bytes
            pdf_bytes = doc.tobytes()
            doc.close()
            
            # Verify the result by reopening and checking TOC
            doc_verify = fitz.open(stream=pdf_bytes, filetype="pdf")
            verify_toc = doc_verify.get_toc()
            print(f"✅ Verification - TOC in result: {verify_toc}")
            doc_verify.close()

            print(f"📄 PDF with bookmarks created: {len(pdf_bytes)} bytes")
            return pdf_bytes

        except Exception as e:
            print(f"❌ Error adding bookmarks: {e}")
            print(f"📋 Traceback: {traceback.format_exc()}")
            raise


def main():
    """Start the PDF bookmark server"""
    import os
    port = int(os.environ.get('PORT', 8081))
    server_address = ('', port)
    
    print(f"🚀 Starting PDF Bookmark Server on port {port}")
    print(f"📱 iOS Safari compatible")
    print(f"🔗 Health check: http://localhost:{port}/health")
    print(f"📄 API endpoint: http://localhost:{port}/embed-bookmarks")
    print(f"🌐 Network access: http://0.0.0.0:{port}")
    
    try:
        httpd = HTTPServer(server_address, PDFBookmarkHandler)
        print(f"✅ Server ready! Listening on all interfaces, port {port}")
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")


def run_server(port=8081):
    """Start server with specified port (for production use)"""
    server_address = ('', port)
    
    print(f"🚀 Starting PDF Bookmark Server on port {port}")
    print(f"📱 iOS Safari compatible")
    
    try:
        httpd = HTTPServer(server_address, PDFBookmarkHandler)
        print(f"✅ Server ready! Listening on all interfaces, port {port}")
        httpd.serve_forever()
    except Exception as e:
        print(f"❌ Server error: {e}")
        raise


if __name__ == '__main__':
    main()
