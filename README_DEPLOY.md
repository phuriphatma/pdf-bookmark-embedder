# PDF Bookmark Embedder

A web application for embedding bookmarks into PDF files, optimized for iOS Safari compatibility.

## Features
- Drag & drop PDF upload interface
- Interactive PDF viewer with touch controls
- Automatic bookmark embedding on specific pages
- iOS Safari mobile-optimized UI
- Client-side and server-side PDF processing

## Deployment

This app is deployed with:
- Frontend: Static site (Vite build)
- Backend: Python server (PyMuPDF)

## Local Development

1. Install dependencies:
```bash
npm install
pip install -r server/requirements.txt
```

2. Start development servers:
```bash
# Terminal 1: Frontend
npm run dev

# Terminal 2: Backend
npm run server
```

## Environment Variables

For production deployment:
- `PORT`: Server port (default: 8081)
- `NODE_ENV`: Set to 'production' for production builds
