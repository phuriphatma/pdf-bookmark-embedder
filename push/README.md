# PDF Bookmark Manager

A web application that allows users to upload PDF files and automatically add bookmarks to pages 1, 2, and 5. The application runs entirely in the browser using PyMuPDF via Pyodide, making it perfect for GitHub Pages hosting.

## Features

- 📱 **Cross-platform**: Works on all devices including iPads
- 🔒 **Privacy-focused**: All processing happens in your browser - no files are uploaded to any server
- 📖 **Automatic bookmarks**: Adds bookmarks to pages 1, 2, and 5
- 💾 **Easy download**: Download the modified PDF with bookmarks
- 🎨 **Modern UI**: Clean, responsive interface that works on mobile devices

## How it works

1. **Upload**: Drop a PDF file or click to browse
2. **Process**: The app uses PyMuPDF (running via Pyodide) to add bookmarks
3. **Download**: Get your PDF back with bookmarks added

## Technical Details

- **Frontend**: HTML5, CSS3, JavaScript
- **PDF Processing**: PyMuPDF (via Pyodide WebAssembly)
- **Hosting**: GitHub Pages compatible
- **File Limit**: 50MB maximum file size
- **Browser Support**: Modern browsers with WebAssembly support

## Bookmarks Added

The application automatically adds the following bookmarks:
- Page 1: "Page 1"
- Page 2: "Page 2" 
- Page 5: "Page 5"

Note: Bookmarks are only added if the corresponding pages exist in the PDF.

## Local Development

1. Clone the repository
2. Serve the files using a local web server (required for Pyodide to work):
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js
   npx serve .
   
   # Using PHP
   php -S localhost:8000
   ```
3. Open `http://localhost:8000` in your browser

## GitHub Pages Deployment

1. Push the code to a GitHub repository
2. Go to Settings > Pages
3. Select "Deploy from a branch"
4. Choose "main" branch and "/ (root)" folder
5. Your app will be available at `https://yourusername.github.io/repository-name`

## Browser Compatibility

- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support  
- Safari: ✅ Full support (including iOS/iPadOS)
- Opera: ✅ Full support

## Privacy & Security

- No data is sent to any external servers
- All PDF processing happens locally in your browser
- Files are processed in memory and not stored anywhere
- Uses secure WebAssembly technology

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Pull requests are welcome! Please feel free to submit issues and enhancement requests.
