#!/bin/bash

# PDF Bookmark App - IPA Builder
# This script builds the iOS app and creates an IPA file for installation

set -e

PROJECT_NAME="PDFBookmarkApp"
SCHEME_NAME="PDFBookmarkApp"
WORKSPACE_PATH="ios-app/PDFBookmarkApp.xcodeproj"
BUILD_DIR="build"
IPA_DIR="ipa-output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏗️  PDF Bookmark App - IPA Builder${NC}"
echo -e "${GREEN}=====================================${NC}"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script must be run on macOS with Xcode installed${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: Xcode command line tools are not installed${NC}"
    echo -e "${YELLOW}Please install Xcode and run: xcode-select --install${NC}"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo -e "${YELLOW}📂 Setting up build directories...${NC}"
mkdir -p "$BUILD_DIR"
mkdir -p "$IPA_DIR"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"/*
rm -rf "$IPA_DIR"/*

# Build for device (Release configuration)
echo -e "${YELLOW}🔨 Building for iOS device (Release)...${NC}"
xcodebuild \
    -project "$WORKSPACE_PATH" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$BUILD_DIR/$PROJECT_NAME.xcarchive" \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive created successfully!${NC}"

# Export IPA
echo -e "${YELLOW}📦 Exporting IPA...${NC}"

# Create export options plist
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string></string>
    <key>signingCertificate</key>
    <string>-</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.pdfbookmark.app</key>
        <string></string>
    </dict>
</dict>
</plist>
EOF

# Export the archive to IPA
xcodebuild \
    -exportArchive \
    -archivePath "$BUILD_DIR/$PROJECT_NAME.xcarchive" \
    -exportPath "$IPA_DIR" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Signed export failed, trying ad-hoc export...${NC}"
    
    # Try ad-hoc export
    cat > "$BUILD_DIR/ExportOptionsAdHoc.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
    
    xcodebuild \
        -exportArchive \
        -archivePath "$BUILD_DIR/$PROJECT_NAME.xcarchive" \
        -exportPath "$IPA_DIR" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptionsAdHoc.plist"
fi

# Check if IPA was created
IPA_FILE="$IPA_DIR/$PROJECT_NAME.ipa"
if [ -f "$IPA_FILE" ]; then
    echo -e "${GREEN}🎉 IPA created successfully!${NC}"
    echo -e "${GREEN}📍 Location: $(pwd)/$IPA_FILE${NC}"
    
    # Get file size
    FILE_SIZE=$(ls -lh "$IPA_FILE" | awk '{print $5}')
    echo -e "${GREEN}📊 File size: $FILE_SIZE${NC}"
    
    echo -e "\n${YELLOW}📱 Installation Instructions:${NC}"
    echo -e "1. Transfer the IPA file to your iOS device"
    echo -e "2. Use a tool like AltStore, Sideloadly, or Xcode to install"
    echo -e "3. Or use iTunes/Finder to install if you have a developer certificate"
    
    echo -e "\n${YELLOW}🔧 Alternative Installation Methods:${NC}"
    echo -e "• AltStore: https://altstore.io/"
    echo -e "• Sideloadly: https://sideloadly.io/"
    echo -e "• 3uTools: http://www.3u.com/"
    
else
    echo -e "${RED}❌ IPA creation failed!${NC}"
    echo -e "${YELLOW}💡 This might be due to code signing requirements${NC}"
    echo -e "${YELLOW}   You may need to open the project in Xcode and configure signing${NC}"
    exit 1
fi

echo -e "\n${GREEN}✨ Build complete!${NC}"
