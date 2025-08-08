# Test PDF Creation Script
# Run this to create a sample PDF for testing
# Usage: cd .. && .venv/bin/python examples/create_test_pdf.py

import fitz  # PyMuPDF

def create_test_pdf():
    """Create a simple test PDF with 6 pages"""
    doc = fitz.open()
    
    for i in range(1, 7):
        page = doc.new_page()
        text_rect = fitz.Rect(100, 100, 500, 200)
        page.insert_text(
            (100, 150), 
            f"This is page {i}", 
            fontsize=24, 
            color=(0, 0, 0)
        )
        page.insert_text(
            (100, 200), 
            f"Perfect for testing bookmark embedding!", 
            fontsize=14, 
            color=(0.5, 0.5, 0.5)
        )
    
    doc.save("examples/test_6_pages.pdf")
    doc.close()
    print("✅ Created examples/test_6_pages.pdf")

if __name__ == "__main__":
    create_test_pdf()
