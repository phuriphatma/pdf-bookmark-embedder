#!/usr/bin/env python3
"""
Debug multipart form data exactly like browser FormData
"""
import requests
import json
from requests_toolbelt.multipart.encoder import MultipartEncoder

def test_browser_like_multipart():
    """Test using exact browser-like multipart encoding"""
    
    test_pdf = "/Users/xeno/webdev/pdfbookmark/examples/test_6_pages.pdf"
    
    try:
        with open(test_pdf, 'rb') as f:
            pdf_data = f.read()
        
        # Create custom bookmark data exactly like the browser
        custom_bookmarks = [
            {"title": "Custom Bookmark 1", "page": 2, "level": 1},
            {"title": "Custom Bookmark 2", "page": 4, "level": 1}, 
            {"title": "Custom Bookmark 3", "page": 5, "level": 1}
        ]
        
        bookmark_json = json.dumps(custom_bookmarks)
        print(f"📤 Sending bookmarks JSON: {bookmark_json}")
        
        # Use MultipartEncoder to exactly mimic browser behavior
        multipart_data = MultipartEncoder(
            fields={
                'pdf': ('test.pdf', pdf_data, 'application/pdf'),
                'bookmarks': (None, bookmark_json, 'text/plain')
            }
        )
        
        print(f"📤 Content-Type: {multipart_data.content_type}")
        
        response = requests.post(
            'http://localhost:8081/embed-bookmarks',
            data=multipart_data,
            headers={'Content-Type': multipart_data.content_type}
        )
        
        if response.status_code == 200:
            with open('/Users/xeno/webdev/pdfbookmark/test_browser_like_result.pdf', 'wb') as f:
                f.write(response.content)
            print("✅ Browser-like test completed - check test_browser_like_result.pdf")
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Test failed: {e}")

if __name__ == '__main__':
    test_browser_like_multipart()
