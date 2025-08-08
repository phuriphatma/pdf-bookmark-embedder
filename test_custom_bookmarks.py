#!/usr/bin/env python3
"""
Test script to check custom bookmark functionality
"""

import requests
import json

def test_custom_bookmarks():
    """Test sending custom bookmarks to the server"""
    
    # Test with a simple PDF file
    test_pdf = "/Users/xeno/webdev/pdfbookmark/examples/test_6_pages.pdf"
    
    try:
        with open(test_pdf, 'rb') as f:
            pdf_data = f.read()
        
        # Create custom bookmark data
        custom_bookmarks = [
            {"title": "Custom Bookmark 1", "page": 2, "level": 1},
            {"title": "Custom Bookmark 2", "page": 4, "level": 1},
            {"title": "Custom Bookmark 3", "page": 5, "level": 1}
        ]
        
        # Prepare form data like the browser does
        files = {
            'pdf': ('test.pdf', pdf_data, 'application/pdf'),
        }
        data = {
            'bookmarks': json.dumps(custom_bookmarks)
        }
        
        print(f"📤 Sending custom bookmarks: {custom_bookmarks}")
        print(f"📤 Bookmark JSON: {json.dumps(custom_bookmarks)}")
        
        # Send request
        response = requests.post('http://localhost:8081/embed-bookmarks', 
                               files=files, data=data)
        
        if response.status_code == 200:
            # Save result
            with open('/Users/xeno/webdev/pdfbookmark/test_custom_result.pdf', 'wb') as f:
                f.write(response.content)
            print("✅ Custom bookmark test completed - check test_custom_result.pdf")
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Test failed: {e}")

if __name__ == '__main__':
    test_custom_bookmarks()
