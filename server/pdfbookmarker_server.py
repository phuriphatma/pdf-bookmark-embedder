#!/usr/bin/env python3
"""
PDF Bookmark Embedder Server using pdfbookmarker
Optimized for iOS Safari compatibility
"""

import io
import json
import os
import tempfile
import traceback
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

# Import pdfbookmarker
try:
    from pdfbookmarker import pdfbm
    print("✅ pdfbookmarker imported successfully")
except ImportError as e:
    print(f"❌ Failed to import pdfbookmarker: {e}")
    exit(1)


class PDFBookmarkHandler(BaseHTTPRequestHandler):
    """HTTP handler for PDF bookmark embedding using pdfbookmarker"""

    def log_message(self, format, *args):
        """Custom logging with timestamps"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {format % args}")

    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/health':
            self.send_health_check()
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

    def send_health_check(self):
        """Send health check response"""
        self.send_response(200)
        self.send_cors_headers()
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        response = {
            'status': 'healthy',
            'service': 'PDF Bookmark Embedder (pdfbookmarker)',
            'version': '1.1.0',
            'library': 'pdfbookmarker',
            'features': ['bookmark_embedding', 'ios_safari_compatible']
        }
        self.wfile.write(json.dumps(response).encode('utf-8'))

    def handle_bookmark_embedding(self):
        """Handle PDF bookmark embedding requests using pdfbookmarker"""
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
            pdf_data = self.extract_pdf_from_multipart(post_data, content_type)
            if not pdf_data:
                self.send_error(400, "No valid PDF file found in request")
                return

            print(f"📁 Processing PDF: {len(pdf_data)} bytes")

            # Process PDF with bookmarks using pdfbookmarker
            processed_pdf = self.add_bookmarks_with_pdfbookmarker(pdf_data)

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
        """Extract PDF data from multipart form data"""
        try:
            # Extract boundary from content type
            if 'boundary=' not in content_type:
                print("❌ No boundary found in Content-Type")
                return None
                
            boundary = content_type.split('boundary=')[1]
            # Remove quotes if present
            if boundary.startswith('"') and boundary.endswith('"'):
                boundary = boundary[1:-1]
                
            boundary_bytes = boundary.encode()
            print(f"🔗 Boundary: {boundary}")
            
            # Split by boundary
            parts = post_data.split(b'--' + boundary_bytes)
            print(f"📂 Found {len(parts)} parts")
            
            for i, part in enumerate(parts):
                print(f"📄 Part {i}: {len(part)} bytes")
                if b'Content-Disposition: form-data; name="pdf"' in part:
                    print("✅ Found PDF part")
                    # Find the start of file data (after headers)
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
                        if len(pdf_data) < 100:  # PDF files should be at least 100 bytes
                            print("❌ PDF data too small")
                            return None
                        
                        if not pdf_data.startswith(b'%PDF'):
                            print("❌ Invalid PDF header")
                            return None
                            
                        return pdf_data

            print("❌ No PDF part found")
            return None
            
        except Exception as e:
            print(f"❌ Error extracting PDF: {e}")
            return None

    def add_bookmarks_with_pdfbookmarker(self, pdf_data):
        """Add bookmarks using pdfbookmarker library"""
        try:
            # Create temporary files
            with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as input_pdf:
                input_pdf.write(pdf_data)
                input_pdf_path = input_pdf.name
            
            with tempfile.NamedTemporaryFile(suffix='.txt', delete=False) as bookmarks_file:
                # Create bookmark entries for pages 1, 3, and 6
                bookmarks_content = '1"📄 Page 1"|1\n1"📄 Page 3"|3\n1"📄 Page 6"|6\n'
                bookmarks_file.write(bookmarks_content.encode('utf-8'))
                bookmarks_file_path = bookmarks_file.name
            
            with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as output_pdf:
                output_pdf_path = output_pdf.name
            
            print(f"📂 Input PDF: {input_pdf_path}")
            print(f"📋 Bookmarks file: {bookmarks_file_path}")
            print(f"📁 Output PDF: {output_pdf_path}")
            
            try:
                # Use pdfbookmarker to add bookmarks
                print("🔖 Adding bookmarks with pdfbookmarker...")
                pdfbm(input_pdf_path, bookmarks_file_path, output_pdf_path)
                print("✅ Bookmarks added successfully")
                
                # Read the processed PDF
                with open(output_pdf_path, 'rb') as f:
                    processed_pdf_data = f.read()
                
                print(f"📄 Processed PDF size: {len(processed_pdf_data)} bytes")
                return processed_pdf_data
                
            finally:
                # Clean up temporary files
                try:
                    os.unlink(input_pdf_path)
                    os.unlink(bookmarks_file_path)
                    os.unlink(output_pdf_path)
                    print("🧹 Temporary files cleaned up")
                except:
                    pass
                    
        except Exception as e:
            print(f"❌ Error in pdfbookmarker processing: {e}")
            print(f"📋 Traceback: {traceback.format_exc()}")
            raise


def main():
    """Start the PDF bookmark server"""
    port = 8081
    server_address = ('', port)
    
    print(f"🚀 Starting PDF Bookmark Server (pdfbookmarker) on port {port}")
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


if __name__ == '__main__':
    main()
