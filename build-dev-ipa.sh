#!/bin/bash

# Quick IPA Builder for Development
# This creates an unsigned IPA that can be installed via sideloading tools

set -e

echo "🏗️  Building PDF Bookmark App (Development IPA)"
echo "=============================================="

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found"
    echo "Please install Xcode and run: xcode-select --install"
    exit 1
fi

cd "$(dirname "$0")"

# Clean and create directories
rm -rf build ipa-output
mkdir -p build ipa-output

echo "🔨 Building archive..."

# Build the archive
xcodebuild archive \
    -project ios-app/PDFBookmarkApp.xcodeproj \
    -scheme PDFBookmarkApp \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath build/PDFBookmarkApp.xcarchive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo "📦 Creating IPA..."

# Create export options for unsigned build
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingCertificate</key>
    <string>-</string>
    <key>provisioningProfiles</key>
    <dict></dict>
</dict>
</plist>
EOF

# Export IPA
xcodebuild -exportArchive \
    -archivePath build/PDFBookmarkApp.xcarchive \
    -exportPath ipa-output \
    -exportOptionsPlist build/ExportOptions.plist

if [ -f "ipa-output/PDFBookmarkApp.ipa" ]; then
    echo "✅ IPA created successfully!"
    echo "📍 Location: $(pwd)/ipa-output/PDFBookmarkApp.ipa"
    echo "📊 Size: $(ls -lh ipa-output/PDFBookmarkApp.ipa | awk '{print $5}')"
    echo ""
    echo "📱 Install using:"
    echo "  • AltStore (recommended): https://altstore.io/"
    echo "  • Sideloadly: https://sideloadly.io/"
    echo "  • Or any other sideloading tool"
else
    echo "❌ IPA creation failed"
    echo "💡 Try opening the project in Xcode to resolve any issues"
    exit 1
fi
