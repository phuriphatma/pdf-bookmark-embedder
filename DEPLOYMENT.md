# 🚀 Deployment Guide - PDF Bookmark Embedder

Deploy your PDF Bookmark Embedder to the cloud so you can access it from anywhere, even when your computer is off.

## 🌟 Recommended: Railway (Easiest)

Railway offers free hosting and automatic deployments from GitHub.

### Steps:

1. **Create GitHub Repository**
```bash
# In your project directory
git init
git add .
git commit -m "Initial commit"
# Create a repo on GitHub and push
git remote add origin https://github.com/yourusername/pdf-bookmark-embedder.git
git push -u origin main
```

2. **Deploy to Railway**
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository
   - Railway will automatically detect and deploy your app!

3. **Access Your App**
   - Railway will provide a URL like `https://yourapp.railway.app`
   - Your app will be accessible worldwide!

---

## 🔵 Alternative: Render (Free Tier)

### Steps:

1. **Create GitHub Repository** (same as above)

2. **Deploy to Render**
   - Go to [render.com](https://render.com)
   - Sign up with GitHub
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Use these settings:
     - **Build Command**: `chmod +x start_production.sh && ./start_production.sh`
     - **Start Command**: `python server/production_server.py`
     - **Environment**: `Python 3`

---

## 🟢 Alternative: Heroku

### Steps:

1. **Install Heroku CLI**
```bash
# macOS
brew install heroku/brew/heroku
```

2. **Deploy**
```bash
# Login to Heroku
heroku login

# Create app
heroku create your-pdf-bookmark-app

# Add Node.js and Python buildpacks
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/python

# Deploy
git push heroku main
```

---

## 🟡 Alternative: Google Cloud Platform

### Steps:

1. **Install Google Cloud CLI**
2. **Deploy**
```bash
gcloud app deploy app.yaml
```

---

## 🔧 Environment Variables

For any platform, you may need to set:
- `PORT`: Server port (usually auto-detected)
- `NODE_ENV`: Set to `production`

---

## 📱 Usage After Deployment

1. **Access your app** at the provided URL
2. **Upload PDFs** and create bookmarks
3. **Works on any device** - iOS Safari, Android, desktop
4. **Always available** - even when your computer is off!

---

## 🆓 Free Tier Limits

- **Railway**: 500 hours/month, 1GB RAM
- **Render**: 750 hours/month, 512MB RAM
- **Heroku**: 1000 hours/month (with credit card)

All should be sufficient for personal use!

---

## 🐛 Troubleshooting

If deployment fails:

1. **Check build logs** in your platform's dashboard
2. **Ensure all files are committed** to Git
3. **Verify Python dependencies** in `server/requirements.txt`
4. **Test locally first** with `./start_production.sh`

---

## 🔄 Updates

To update your deployed app:
1. Make changes locally
2. Commit to Git: `git add . && git commit -m "Update"`
3. Push to GitHub: `git push`
4. Most platforms auto-deploy from GitHub!

Your PDF bookmark tool will be available 24/7 from anywhere in the world! 🌍
