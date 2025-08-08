# 📄 PDF Bookmark Embedder

A simple, iOS Safari-optimized web application that automatically adds bookmarks to PDF files on pages 1, 3, and 6.

## ✨ Features

- **🎯 Simple Interface**: Upload PDF → Get PDF with bookmarks
- **📱 iOS Safari Optimized**: Perfect touch interface for mobile devices
- **🔖 Automatic Bookmarks**: Adds bookmarks to pages 1, 3, and 6
- **📥 Drag & Drop**: Easy file upload with visual feedback
- **🔄 Reliable Processing**: Server-side PyMuPDF with client-side fallback
- **🌐 Cross-Origin Support**: CORS-enabled for mobile browser compatibility

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or later)
- Python 3.7+ with pip

### Installation

1. **Install dependencies**:
   ```bash
   npm install
   pip install -r server/requirements.txt
   ```

2. **Start the development servers**:
   ```bash
   # Option 1: Start both servers with network access
   npm run network
   
   # Option 2: Start servers separately
   # Terminal 1: Start the web server
   npm run dev
   
   # Terminal 2: Start the PDF processing server
   npm run server
   ```

3. **Access the application**:
   - **Desktop**: http://localhost:3000
   - **📱 iPad**: http://192.168.1.182:3000 (replace with your actual IP)

## 📱 iOS Safari Usage

1. Open the app in Safari on your iOS device
2. Tap "Choose PDF File" or drag a PDF to the upload area
3. Wait for processing (bookmarks added to pages 1, 3, 6)
4. Tap "Download PDF with Bookmarks" to save the result
5. Open the downloaded PDF in any app to see the bookmarks

## 🏗️ Architecture

### Frontend (Vite + Vanilla JS)
- **main.js**: Core application logic with iOS optimizations
- **style.css**: Mobile-first responsive design
- **index.html**: Semantic HTML with proper touch targets

### Backend (Python + PyMuPDF)
- **server/bookmark_server.py**: HTTP server for PDF processing
- **PyMuPDF Integration**: Reliable native bookmark embedding
- **CORS Support**: Cross-origin requests for mobile browsers

## 🔧 Development

### File Structure
```
pdfbookmark/
├── index.html          # Main HTML file
├── main.js            # Frontend application logic
├── style.css          # iOS Safari optimized styles
├── vite.config.js     # Vite configuration
├── package.json       # NPM dependencies and scripts
├── server/
│   ├── bookmark_server.py  # Python PDF processing server
│   └── requirements.txt    # Python dependencies
└── .github/
    └── copilot-instructions.md  # Development guidelines
```

### Available Scripts

```bash
# Development
npm run dev          # Start Vite dev server (frontend)
npm run server       # Start Python bookmark server (backend)

# Production
npm run build        # Build for production
npm run preview      # Preview production build
```

### Server Endpoints

- `GET /health` - Server health check
- `POST /embed-bookmarks` - Process PDF with bookmark embedding

## 🎨 iOS Safari Optimizations

- **Touch Targets**: Minimum 44px tap targets
- **Viewport**: Proper mobile viewport settings
- **Zoom Prevention**: Prevents unwanted zoom on input focus
- **Touch Scroll**: Smooth scrolling with momentum
- **File Upload**: Optimized file picker for iOS
- **Visual Feedback**: Clear loading and success states

## 🔖 Bookmark Details

The application automatically adds bookmarks to:
- **Page 1**: "📄 Page 1"
- **Page 3**: "📄 Page 3" (if document has 3+ pages)
- **Page 6**: "📄 Page 6" (if document has 6+ pages)

Bookmarks are embedded as native PDF outline entries, making them visible in:
- Adobe Reader
- Apple Preview
- PDF Expert
- Any other PDF viewer that supports bookmarks

## 🐛 Troubleshooting

### Common Issues

**Server not starting:**
```bash
# Install Python dependencies
pip install pymupdf

# Check Python version (requires 3.7+)
python --version
```

**iOS Safari file upload not working:**
- Ensure you're using Safari (not Chrome or Firefox)
- Try tapping the upload button instead of drag & drop
- Check that the file is actually a PDF

**Bookmarks not visible:**
- Ensure the PDF has at least 1 page for any bookmarks
- Some PDF viewers may hide empty bookmark sections
- Try opening in a different PDF viewer

## 📝 License

MIT License - feel free to use this for your own projects!

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes (keep iOS Safari compatibility in mind)
4. Test on both desktop and iOS Safari
5. Submit a pull request

---

**Made with ❤️ for iOS Safari compatibility**
