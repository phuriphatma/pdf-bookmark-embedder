#!/usr/bin/env python3
"""
PDF Bookmark Embedding Server
Reliable bookmark embedding using PyMuPDF for iOS Safari compatibility
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import fitz  # PyMuPDF
import tempfile
import os
from urllib.parse import parse_qs
import traceback

class BookmarkServerHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/health':
            self.send_health_check()
        else:
            self.send_response(404)
            self.send_cors_headers()
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b"Endpoint not found")

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
            'service': 'PDF Bookmark Embedder',
            'version': '1.0.0',
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

            # Get content length with fallback
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
            
            # Simple multipart parsing for PDF files
            # Extract boundary from content type
            if 'boundary=' not in content_type:
                self.send_error(400, "No boundary found in Content-Type")
                return
                
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
                        break

            if not pdf_data or len(pdf_data) < 100:  # PDF files should be at least 100 bytes
                print("❌ No valid PDF data found")
                self.send_error(400, "No valid PDF file found in request")
                return

            print(f"📁 Processing PDF: {len(pdf_data)} bytes")

            # Process PDF with bookmarks
            processed_pdf = self.add_bookmarks_to_pdf(pdf_data)

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

    def add_bookmarks_to_pdf(self, pdf_data):
        """Add bookmarks to pages 1, 3, and 6 using PyMuPDF"""
        try:
            # Open PDF document
            doc = fitz.open(stream=pdf_data, filetype="pdf")
            print(f"📄 PDF loaded: {doc.page_count} pages")

            # Create Table of Contents (TOC) structure
            toc = []
            
            # Add bookmarks for available pages
            if doc.page_count >= 1:
                toc.append([1, "📄 Page 1", 1])  # [level, title, page]
                print("✅ Added bookmark for Page 1")
            
            if doc.page_count >= 3:
                toc.append([1, "📄 Page 3", 3])
                print("✅ Added bookmark for Page 3")
            
            if doc.page_count >= 6:
                toc.append([1, "📄 Page 6", 6])
                print("✅ Added bookmark for Page 6")

            print(f"📋 TOC structure: {toc}")

            # Set the table of contents
            if toc:
                doc.set_toc(toc)
                print("✅ Table of contents set successfully")
            else:
                print("⚠️ No bookmarks to add (document too short)")

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
            
            if doc.page_count >= 3:
                bookmarks.append([1, "📄 Page 3", 3])
            
            if doc.page_count >= 6:
                bookmarks.append([1, "📄 Page 6", 6])

            # Set bookmarks if any were added
            if bookmarks:
                doc.set_toc(bookmarks)
                print(f"📚 Added {len(bookmarks)} bookmarks")
            else:
                print("⚠️ PDF has fewer than 1 page, no bookmarks added")

            # Get the modified PDF data
            modified_pdf = doc.tobytes()
            doc.close()

            return modified_pdf

        except Exception as e:
            print(f"❌ PyMuPDF processing failed: {str(e)}")
            raise

    def log_message(self, format, *args):
        """Override to customize log format"""
        print(f"🌐 {self.address_string()} - {format % args}")

def main():
    """Start the bookmark embedding server"""
    port = 8081  # Changed to avoid conflict with other services
    
    print("🚀 Starting PDF Bookmark Embedding Server")
    print(f"📡 Server will run on http://localhost:{port}")
    print("🔗 Endpoints:")
    print("   GET  /health - Server health check")
    print("   POST /embed-bookmarks - Process PDF with bookmarks")
    print("📱 Optimized for iOS Safari compatibility")
    print("📚 Adds bookmarks to pages 1, 3, and 6")
    print()
    
    try:
        # Check if PyMuPDF is available
        import fitz
        print("✅ PyMuPDF (fitz) is available")
        
        # Start server
        server = HTTPServer(('0.0.0.0', port), BookmarkServerHandler)  # Bind to all interfaces
        print(f"🎯 Server running at http://localhost:{port}")
        print(f"📱 iPad access: http://[YOUR_IP_ADDRESS]:{port}")
        print("Press Ctrl+C to stop the server")
        print("=" * 50)
        
        server.serve_forever()
        
    except ImportError:
        print("❌ PyMuPDF not installed. Install with: pip install pymupdf")
        return 1
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
        return 0
    except Exception as e:
        print(f"❌ Server error: {e}")
        return 1

if __name__ == "__main__":
    exit(main())
