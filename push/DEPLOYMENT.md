# Deployment Guide for PDF Bookmark Manager

## Quick Start

### Local Testing
1. **Start local server:**
   ```bash
   ./start-server.sh
   ```
   Or manually:
   ```bash
   python -m http.server 8000
   ```

2. **Open in browser:**
   - Main app: http://localhost:8000
   - Test page: http://localhost:8000/test.html

### GitHub Pages Deployment

#### Option 1: Using GitHub Web Interface
1. Create a new repository on GitHub
2. Upload all files from this folder to the repository
3. Go to Settings > Pages
4. Select "Deploy from a branch"
5. Choose "main" branch and "/ (root)" folder
6. Wait for deployment (usually 1-2 minutes)
7. Access your app at: `https://yourusername.github.io/repository-name`

#### Option 2: Using Git Commands
```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - PDF Bookmark Manager"

# Add remote (replace with your repository URL)
git remote add origin https://github.com/yourusername/pdf-bookmark-manager.git

# Push to GitHub
git branch -M main
git push -u origin main
```

Then follow steps 3-7 from Option 1.

## Features

✅ **Client-side processing** - No server required  
✅ **Works on iPads and mobile devices**  
✅ **GitHub Pages compatible**  
✅ **Privacy-focused** - files never leave your browser  
✅ **Automatic bookmarks** for pages 1, 2, and 5  

## Browser Requirements

- Modern browser with WebAssembly support
- JavaScript enabled
- File API support (for file uploads)

## File Structure

```
pdf-bookmark-manager/
├── index.html          # Main application
├── style.css           # Styling
├── script.js           # Application logic
├── test.html           # Browser compatibility test
├── README.md           # Documentation
├── package.json        # Project metadata
├── start-server.sh     # Local server script
├── _config.yml         # GitHub Pages config
└── .github/
    └── workflows/
        └── deploy.yml   # GitHub Actions deployment
```

## Troubleshooting

### "Failed to initialize" error
- Ensure you're serving files via HTTP/HTTPS (not file:// protocol)
- Check browser console for specific error messages
- Try the test.html page to verify browser compatibility

### Pyodide loading issues
- Check internet connection (Pyodide loads from CDN)
- Verify WebAssembly support in browser
- Some corporate firewalls may block CDN resources

### GitHub Pages not updating
- Check Actions tab for deployment status
- Ensure all files are committed and pushed
- GitHub Pages may take a few minutes to update

## Customization

### Changing bookmark labels
Edit the `script.js` file and modify the bookmark creation section:

```python
# Add bookmark for page 1 if it exists
if len(doc) >= 1:
    bookmarks.append([1, "Your Custom Label", 1])
```

### Adding more bookmarks
Modify the Python code in `script.js` to add bookmarks for additional pages:

```python
# Add bookmark for page 10 if it exists
if len(doc) >= 10:
    bookmarks.append([1, "Page 10", 10])
```

### Styling changes
Modify `style.css` to change the appearance, colors, or layout.

## Security Notes

- All processing happens in the browser
- No files are uploaded to external servers
- Uses secure WebAssembly technology
- No personal data is collected or stored
