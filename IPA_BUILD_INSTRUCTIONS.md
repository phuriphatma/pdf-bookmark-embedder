# Manual IPA Build Instructions

## Prerequisites
- macOS with Xcode installed
- Xcode command line tools: `xcode-select --install`

## Quick Build Steps

### 1. Open Terminal and navigate to project
```bash
cd /Users/xeno/webdev/pdfbookmark
```

### 2. Build the archive
```bash
xcodebuild archive \
    -project ios-app/PDFBookmarkApp.xcodeproj \
    -scheme PDFBookmarkApp \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath build/PDFBookmarkApp.xcarchive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO
```

### 3. Create export options
```bash
mkdir -p build
cat > build/ExportOptions.plist << 'EOF'
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
```

### 4. Export IPA
```bash
mkdir -p ipa-output
xcodebuild -exportArchive \
    -archivePath build/PDFBookmarkApp.xcarchive \
    -exportPath ipa-output \
    -exportOptionsPlist build/ExportOptions.plist
```

### 5. Install IPA
The IPA will be created at `ipa-output/PDFBookmarkApp.ipa`

## Installation Options

### Option 1: AltStore (Recommended)
1. Install AltStore from https://altstore.io/
2. Install AltServer on your Mac
3. Connect your iPhone/iPad
4. Open AltStore on device and install the IPA

### Option 2: Sideloadly
1. Download Sideloadly from https://sideloadly.io/
2. Connect your device
3. Drag the IPA file to Sideloadly
4. Enter your Apple ID and install

### Option 3: Xcode (if you have developer account)
1. Open Xcode
2. Window → Devices and Simulators
3. Select your device
4. Drag the IPA to the "Installed Apps" section

## Alternative: Use Xcode directly

1. Open `ios-app/PDFBookmarkApp.xcodeproj` in Xcode
2. Select your connected device as target
3. Configure signing with your Apple ID
4. Press Cmd+R to build and install directly

## Troubleshooting

### Build Errors
- Ensure Xcode command line tools are installed
- Check that all Swift files are in the project
- Try cleaning: `rm -rf build ipa-output` and rebuild

### Signing Issues
- For personal use, you can use your Apple ID for signing
- Open project in Xcode → Signing & Capabilities → Team (select your Apple ID)
- Enable "Automatically manage signing"

### Installation Issues
- Make sure device trusts your computer
- Enable "Trust this computer" on iOS device
- For unsigned IPAs, you'll need sideloading tools like AltStore
