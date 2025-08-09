#!/bin/bash

# Quick Xcode Launcher for PDF Bookmark App
echo "🚀 Opening PDF Bookmark App in Xcode..."
echo ""
echo "📱 Next steps after Xcode opens:"
echo "1. Connect your iPhone/iPad via USB"
echo "2. Select your device from the dropdown (top-left)"
echo "3. Go to Signing & Capabilities → Set Team to your Apple ID"
echo "4. Press Cmd+R to build and install on your device"
echo ""

# Open the project in Xcode
open ios-app/PDFBookmarkApp.xcodeproj

echo "✅ Xcode should be opening now!"
echo ""
echo "💡 If you need the easy installation guide:"
echo "   cat EASY_INSTALL_GUIDE.md"
