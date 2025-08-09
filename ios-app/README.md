# PDF Bookmark Embedder - iOS App

A native iOS application for viewing PDF files and embedding custom bookmarks, providing the same functionality as the web version but optimized for iOS devices and large file handling.

## Features

✅ **Native PDF Viewing**
- High-performance PDF rendering using PDFKit
- Smooth scrolling and zoom support
- Page navigation with visual indicators
- Touch-optimized interface

✅ **Bookmark Management**  
- Add custom bookmarks to any page
- Edit and delete existing bookmarks
- Persistent bookmark storage per PDF
- Visual bookmark indicators
- Quick navigation to bookmarked pages

✅ **PDF Export**
- Embed bookmarks directly into PDF structure
- Native PDF outline creation
- Export with sharing options
- Progress tracking for large files
- Memory-optimized processing

✅ **Large File Support**
- Handles files up to 200MB efficiently
- Memory-conscious processing
- Background export operations
- Progress indicators and status updates

✅ **iOS Integration**
- Document picker integration
- Share sheet for exporting
- Files app integration
- Native iOS UI components

## Technical Architecture

### Core Components

1. **PDFBookmarkApp.swift** - Main app entry point
2. **ContentView.swift** - Primary interface with sidebar and viewer
3. **PDFViewerView.swift** - Native PDF rendering and interaction
4. **BookmarkManager.swift** - Bookmark data management and persistence
5. **PDFProcessor.swift** - PDF bookmark embedding and export

### Data Flow

```
PDF File Selection → PDFKit Loading → Bookmark Management → Export Processing
     ↓                    ↓               ↓                   ↓
File Picker → PDFDocument → BookmarkManager → PDFProcessor → Share Sheet
```

### Key Technologies

- **SwiftUI** - Modern declarative UI framework
- **PDFKit** - Native PDF rendering and manipulation
- **Foundation** - Core data processing and file management
- **UniformTypeIdentifiers** - File type handling

## Development Setup

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- Swift 5.9+
- macOS development machine

### Building the App

1. **Create Xcode Project**
   ```bash
   # In Xcode, create new iOS App project
   # Project Name: PDFBookmarkApp
   # Bundle Identifier: com.yourcompany.pdfbookmark
   # Language: Swift
   # Interface: SwiftUI
   # Minimum Deployment: iOS 17.0
   ```

2. **Add Source Files**
   - Copy all `.swift` files to your Xcode project
   - Add `Info.plist` with proper configurations
   - Configure file import capabilities

3. **Configure Capabilities**
   - Enable File Sharing in project settings
   - Add Document Browser support
   - Configure PDF document types

4. **Build and Run**
   ```bash
   # Build for simulator
   cmd+R in Xcode
   
   # Build for device
   # Configure signing team and device
   # Build and install on connected device
   ```

### Project Structure

```
PDFBookmarkApp/
├── PDFBookmarkApp.swift      # App entry point
├── ContentView.swift         # Main interface
├── PDFViewerView.swift       # PDF rendering
├── BookmarkManager.swift     # Data management
├── PDFProcessor.swift        # Export processing
├── Info.plist               # App configuration
└── README.md                # This file
```

## Usage Guide

### Basic Workflow

1. **Open PDF File**
   - Tap "Choose PDF File" button
   - Select PDF from Files app or other sources
   - File loads in native PDF viewer

2. **Add Bookmarks**
   - Double-tap on any page to add bookmark
   - Enter bookmark name in dialog
   - Bookmark appears in sidebar list
   - Navigate by tapping bookmarks

3. **Manage Bookmarks**
   - View all bookmarks in left sidebar
   - Edit names by re-adding to same page
   - Delete with trash button
   - Bookmarks auto-save per PDF

4. **Export PDF**
   - Tap "Export PDF with Bookmarks" button
   - Watch progress indicator for large files
   - Use share sheet to save or send result
   - Exported PDF contains native bookmarks

### Advanced Features

- **Page Navigation**: Use arrow buttons or page input field
- **File Management**: Exported PDFs saved to Documents folder
- **Bookmark Persistence**: Each PDF's bookmarks saved separately
- **Memory Management**: Large files processed efficiently
- **Error Handling**: Clear error messages and recovery

## Performance Optimization

### Large File Handling

- **Memory Limits**: 200MB file size limit to prevent crashes
- **Background Processing**: Export operations run on background queue
- **Progress Tracking**: Real-time progress updates during export
- **Cleanup**: Automatic removal of old processed files

### UI Responsiveness

- **Async Operations**: All heavy operations run asynchronously
- **Native Components**: PDFKit provides smooth scrolling
- **Memory Efficient**: Lazy loading and view recycling
- **Touch Optimized**: Proper gesture handling for iOS

## Comparison with Web Version

| Feature          | Web Version          | iOS App            |
| ---------------- | -------------------- | ------------------ |
| PDF Viewing      | PDF.js rendering     | Native PDFKit      |
| Large Files      | 165MB limit issue    | 200MB optimized    |
| Bookmark Storage | Browser localStorage | iOS Documents      |
| Export Method    | Server processing    | Native processing  |
| Performance      | Network dependent    | Local processing   |
| File Access      | Upload required      | Direct file access |
| Sharing          | Download link        | Native share sheet |

## Future Enhancements

### Phase 1 - Core Improvements
- [ ] Bookmark import/export
- [ ] Default bookmark templates
- [ ] Bookmark categorization
- [ ] Search within PDFs

### Phase 2 - Advanced Features  
- [ ] Annotation support
- [ ] Bookmark thumbnails
- [ ] iCloud sync
- [ ] Apple Pencil support

### Phase 3 - Enterprise Features
- [ ] Batch processing
- [ ] Custom bookmark styles
- [ ] PDF metadata editing
- [ ] Integration APIs

## Troubleshooting

### Common Issues

1. **Large File Processing Fails**
   - Check available device storage
   - Ensure file is under 200MB limit
   - Close other apps to free memory

2. **Bookmarks Not Saving**
   - Verify Documents folder permissions
   - Check available storage space
   - Restart app if persistent

3. **Export Share Sheet Issues**
   - Ensure target app supports PDF files
   - Check network connectivity for cloud saves
   - Try alternative sharing methods

### Development Issues

1. **Build Errors**
   - Verify Xcode version compatibility
   - Check iOS deployment target
   - Ensure all files added to project

2. **Simulator vs Device**
   - File picker behaves differently
   - Memory limits vary by device
   - Test on actual hardware

## Contributing

When making changes to the iOS app:

1. Maintain compatibility with the web version's core functionality
2. Follow iOS Human Interface Guidelines
3. Test on both iPhone and iPad form factors
4. Ensure accessibility compliance
5. Document any new features or changes

## License

This iOS app maintains the same license as the parent PDF Bookmark Embedder project.
