#!/bin/bash

echo "🚀 PDF Bookmark Embedder - One-Click Deployment Setup"
echo "======================================================"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📝 Initializing Git repository..."
    git init
    echo "✅ Git initialized"
fi

# Add all files
echo "📦 Adding files to Git..."
git add .

# Commit if there are changes
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    echo "💾 Committing changes..."
    git commit -m "Prepare for deployment - $(date)"
    echo "✅ Changes committed"
fi

echo ""
echo "🎯 Choose your deployment platform:"
echo "1. Railway (Recommended - Free, Easy)"
echo "2. Render (Free tier available)"
echo "3. Heroku (Credit card required for free tier)"
echo "4. Manual setup (show instructions)"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🚂 Railway Deployment Instructions:"
        echo "1. Go to https://railway.app"
        echo "2. Sign up with GitHub"
        echo "3. Click 'New Project' → 'Deploy from GitHub repo'"
        echo "4. Select this repository"
        echo "5. Railway will auto-deploy!"
        echo ""
        echo "💡 Don't have a GitHub repo yet?"
        echo "   Create one at https://github.com/new"
        echo "   Then run: git remote add origin https://github.com/yourusername/reponame.git"
        echo "   And push: git push -u origin main"
        ;;
    2)
        echo ""
        echo "🎨 Render Deployment Instructions:"
        echo "1. Go to https://render.com"
        echo "2. Sign up with GitHub"
        echo "3. Click 'New' → 'Web Service'"
        echo "4. Connect your GitHub repository"
        echo "5. Use these settings:"
        echo "   - Build Command: npm run build"
        echo "   - Start Command: python server/bookmark_server_clean.py"
        echo "   - Environment: Python 3"
        ;;
    3)
        echo ""
        echo "🟣 Heroku Deployment Instructions:"
        echo "1. Install Heroku CLI: brew install heroku/brew/heroku"
        echo "2. Login: heroku login"
        echo "3. Create app: heroku create your-app-name"
        echo "4. Add buildpacks:"
        echo "   heroku buildpacks:add heroku/nodejs"
        echo "   heroku buildpacks:add heroku/python"
        echo "5. Deploy: git push heroku main"
        ;;
    4)
        echo ""
        echo "📖 Manual Setup:"
        echo "See DEPLOYMENT.md for detailed instructions for all platforms"
        echo "Run: cat DEPLOYMENT.md"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🌍 After deployment, your PDF Bookmark Embedder will be available 24/7!"
echo "📱 Works on iOS Safari, Android, and all modern browsers"
echo "🔗 You'll get a public URL that works from anywhere"
echo ""
echo "📁 All deployment files are ready:"
echo "   ✅ Procfile (Heroku)"
echo "   ✅ Dockerfile (Container platforms)"
echo "   ✅ app.yaml (Google Cloud)"
echo "   ✅ Production server script"
echo ""
echo "Happy deploying! 🎉"
