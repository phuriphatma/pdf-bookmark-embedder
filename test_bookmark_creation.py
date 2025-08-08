#!/usr/bin/env python3
"""
Quick test of PyMuPDF bookmark functionality
"""

import fitz

def test_bookmark_creation():
    """Test creating bookmarks with PyMuPDF"""
    print("🧪 Testing PyMuPDF bookmark creation...")
    
    # Open the test PDF
    doc = fitz.open("examples/test_6_pages.pdf")
    print(f"📄 Loaded PDF: {doc.page_count} pages")
    
    # Create table of contents
    toc = [
        [1, "📄 Page 1", 1],
        [1, "📄 Page 3", 3], 
        [1, "📄 Page 6", 6]
    ]
    
    print(f"📋 Setting TOC: {toc}")
    doc.set_toc(toc)
    
    # Save to new file
    doc.save("test_with_bookmarks.pdf")
    doc.close()
    
    # Verify by reopening
    doc_verify = fitz.open("test_with_bookmarks.pdf")
    verify_toc = doc_verify.get_toc()
    print(f"✅ Verification - TOC: {verify_toc}")
    doc_verify.close()
    
    print("🎉 Test completed!")

if __name__ == '__main__':
    test_bookmark_creation()
