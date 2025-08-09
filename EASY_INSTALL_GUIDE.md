# 📱 PDF Bookmark App - Easy Installation Guide

Since building IPAs requires complex setup, here are the **easiest ways** to get the PDF Bookmark app on your iOS device:

## 🎯 Recommended Approach: Use Xcode Directly

### Option 1: Install via Xcode (Simplest)
1. **Open the project in Xcode:**
   ```bash
   open ios-app/PDFBookmarkApp.xcodeproj
   ```

2. **Connect your iPhone/iPad** via USB cable

3. **Trust your computer** on the iOS device when prompted

4. **In Xcode:**
   - Select your device from the dropdown (top-left)
   - Go to **Signing & Capabilities** tab
   - Set **Team** to your Apple ID (sign in if needed)
   - Enable **"Automatically manage signing"**

5. **Press Cmd+R** (or click the Play button) to build and install

✅ **The app will install directly on your device!**

---

## 🔧 Alternative: Create IPA for Sideloading

If you prefer an IPA file for sideloading tools:

### 1. Build with Xcode GUI
1. Open `ios-app/PDFBookmarkApp.xcodeproj` in Xcode
2. **Product → Archive** (make sure "Any iOS Device" is selected)
3. **Distribute App → Development → Next → Export**
4. Save the IPA file

### 2. Install with Sideloading Tools
- **AltStore** (Free): https://altstore.io/
- **Sideloadly** (Free): https://sideloadly.io/
- **3uTools** (Free): http://www.3u.com/

---

## 📋 Features You'll Get

✅ **Native PDF Viewing** - Smooth, fast PDF rendering  
✅ **Custom Bookmarks** - Add bookmarks to any page  
✅ **Large File Support** - Handle files up to 200MB  
✅ **Export with Bookmarks** - Save PDFs with embedded bookmarks  
✅ **iOS Integration** - Native file picker and sharing  

---

## 🆘 Troubleshooting

### "Untrusted Developer" Error
1. Go to **Settings → General → VPN & Device Management**
2. Find your Apple ID under "Developer App"
3. Tap **Trust**

### App Crashes or Won't Open
1. Make sure iOS version is 17.0+
2. Restart your device
3. Reinstall the app

### File Import Issues
1. Make sure you're selecting PDF files
2. Try copying PDFs to Files app first
3. Check file isn't corrupted

---

## 💡 Why This App vs Web Version?

| Feature         | Web App              | iOS App                  |
| --------------- | -------------------- | ------------------------ |
| **Large Files** | ❌ 165MB limit issues | ✅ 200MB+ supported       |
| **Performance** | ⚠️ Browser dependent  | ✅ Native speed           |
| **File Access** | ❌ Upload required    | ✅ Direct file access     |
| **Reliability** | ⚠️ Network timeouts   | ✅ Local processing       |
| **Integration** | ❌ Limited            | ✅ Files app, Share sheet |

The iOS app solves all the large file issues you experienced with the web version! 🎉

---

## 🚀 Quick Start

1. **Install** using Option 1 above (Xcode direct install)
2. **Open** the PDF Bookmark app on your device
3. **Tap "Choose PDF File"** and select a PDF
4. **Double-tap** any page to add a bookmark
5. **Tap "Export PDF with Bookmarks"** when done
6. **Share** your bookmarked PDF via the share sheet

That's it! Your PDFs now have native bookmarks that work in any PDF viewer. 📚
