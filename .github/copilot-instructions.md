<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# PDF Bookmark Embedder Project

This is a web application for embedding bookmarks into PDF files, optimized for iOS Safari compatibility.

## Project Structure
- **Frontend**: Vite + Vanilla JavaScript with iOS Safari optimizations
- **Backend**: Python HTTP server using PyMuPDF for reliable bookmark embedding
- **Target**: Automatically add bookmarks to pages 1, 3, and 6 of uploaded PDFs

## Key Features
- Drag & drop PDF upload interface
- Automatic bookmark embedding on specific pages
- iOS Safari mobile-optimized UI
- CORS-enabled server for cross-origin requests
- Client-side fallback using pdf-lib when server unavailable
- Touch-friendly interface with proper mobile interactions

## Development Guidelines
- Maintain iOS Safari compatibility in all code changes
- Use semantic HTML and proper ARIA labels for accessibility
- Implement proper error handling for network failures
- Keep the UI simple and focused on the core functionality
- Use modern JavaScript (ES6+) with proper error boundaries
- Ensure CORS headers are properly configured for mobile browsers

## Technical Constraints
- PDF processing must work reliably on mobile devices
- File upload should handle large PDFs (up to 50MB)
- UI should be responsive and touch-friendly
- Server must handle multipart form uploads properly
- Bookmark embedding should create native PDF bookmarks visible in all PDF viewers
