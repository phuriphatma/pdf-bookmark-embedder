#!/bin/bash

echo "🧪 Testing PDF Bookmark Embedder Full Workflow"
echo "=============================================="

# Test 1: Check if servers are running
echo "📡 Checking servers..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Vite dev server (port 3000) - Running"
else
    echo "❌ Vite dev server (port 3000) - Not running"
fi

if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ Python bookmark server (port 8081) - Running"
else
    echo "❌ Python bookmark server (port 8081) - Not running"
fi

# Test 2: Test PDF processing via API
echo ""
echo "📄 Testing PDF processing..."
if [ -f "examples/test_6_pages.pdf" ]; then
    echo "🔍 Processing test PDF..."
    if curl -X POST -F "pdf=@examples/test_6_pages.pdf" http://localhost:8081/embed-bookmarks -o test_workflow_output.pdf -s; then
        if [ -f "test_workflow_output.pdf" ]; then
            file_type=$(file test_workflow_output.pdf | grep -o "PDF document")
            if [ "$file_type" = "PDF document" ]; then
                echo "✅ PDF processing successful - Valid PDF returned"
                file_size=$(stat -f %z test_workflow_output.pdf)
                echo "📏 Output file size: $file_size bytes"
            else
                echo "❌ PDF processing failed - Invalid output file"
                echo "Output content:"
                head -n 3 test_workflow_output.pdf
            fi
        else
            echo "❌ PDF processing failed - No output file created"
        fi
    else
        echo "❌ PDF processing failed - curl request failed"
    fi
else
    echo "❌ Test PDF not found at examples/test_6_pages.pdf"
fi

# Test 3: Network accessibility test
echo ""
echo "🌐 Network accessibility test..."
local_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
if [ ! -z "$local_ip" ]; then
    echo "🔗 Local IP detected: $local_ip"
    echo "📱 iPad/Device access URLs:"
    echo "   Frontend: http://$local_ip:3000"
    echo "   API: http://$local_ip:8081/embed-bookmarks"
else
    echo "❌ Could not detect local IP address"
fi

echo ""
echo "🎯 Test Summary:"
echo "- Server status: Check above"
echo "- PDF processing: Check above"
echo "- Network access: Use the URLs above on your iPad"
echo ""
echo "💡 Next steps:"
echo "1. Open http://$local_ip:3000 on your iPad Safari"
echo "2. Upload a PDF file"
echo "3. Check if you receive the PDF with bookmarks"
