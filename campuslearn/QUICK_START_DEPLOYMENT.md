# Quick Start: Deploy CampusLearn in 30 Minutes

This guide gets you from local development to publicly accessible app in about 30 minutes.

## TL;DR - What You'll Do

1. Export your database → Upload to Railway
2. Push code to GitHub → Connect to Railway
3. Build Android/Windows apps → Upload to GitHub Releases
4. Share download links with users

**Cost:** $0 (free tiers)
**Time:** ~30 minutes
**Result:** Users can download and use your app without any setup!

---

## Step-by-Step Checklist

### ☐ Part 1: Database Export (5 minutes)

```bash
cd backend
# On Windows:
export_database.bat

# On Linux/Mac:
bash export_database.sh
```

**Result:** You'll have a `.sql` file with your database backup

---

### ☐ Part 2: GitHub Setup (5 minutes)

1. **Create repository on GitHub** (Private!)
   - Go to https://github.com → New repository
   - Name: `campuslearn`
   - Privacy: **Private**
   - Don't initialize with README

2. **Push your code:**
   ```bash
   cd /mnt/c/Users/Ken/Desktop/SEN_RESTART/campuslearn

   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/campuslearn.git
   git branch -M main
   git push -u origin main
   ```

**Result:** Your code is on GitHub (but still private)

---

### ☐ Part 3: Railway Deployment (10 minutes)

1. **Sign up for Railway**
   - Go to https://railway.app
   - Login with GitHub

2. **Create PostgreSQL Database**
   - New Project → Provision PostgreSQL
   - Copy the `DATABASE_URL` from Variables tab

3. **Import your database**
   ```bash
   # Install Railway CLI
   npm install -g @railway/cli

   # Login and link
   railway login
   railway link

   # Import database
   cd backend
   railway run psql $DATABASE_URL < your_export_file.sql
   ```

4. **Deploy Backend**
   - Railway → New → GitHub Repo → Select `campuslearn`
   - Click on service → Variables tab
   - Add environment variables (copy from appsettings.json):

   ```
   ConnectionStrings__DefaultConnection = [DATABASE_URL from PostgreSQL]
   JwtSettings__SecretKey = [Your secret]
   Email__SmtpUsername = [Your Gmail]
   Email__SmtpPassword = [Your App Password]
   ```

5. **Get your production URL**
   - Settings tab → Generate Domain
   - Copy URL (e.g., `https://campuslearn-production.up.railway.app`)
   - **Save this URL!**

**Result:** Your backend is live and accessible!

---

### ☐ Part 4: Build Apps (10 minutes)

**Build Android APK:**
```bash
cd /mnt/c/Users/Ken/Desktop/SEN_RESTART/campuslearn

# Replace with YOUR Railway URL:
build_android.bat https://campuslearn-production.up.railway.app
```

**Build Windows App:**
```bash
# Replace with YOUR Railway URL:
build_windows.bat https://campuslearn-production.up.railway.app
```

**Result:**
- Android: `build/app/outputs/flutter-apk/app-release.apk`
- Windows: `CampusLearn-Windows-v1.0.0/` folder

---

### ☐ Part 5: Create GitHub Release (5 minutes)

1. **Go to your repository:**
   `https://github.com/YOUR_USERNAME/campuslearn/releases`

2. **Create new release:**
   - Click "Create a new release"
   - Tag: `v1.0.0`
   - Title: `CampusLearn v1.0.0`
   - Upload files:
     - `app-release.apk` → Rename to `campuslearn-v1.0.0.apk`
     - Create ZIP of Windows folder → `CampusLearn-Windows-v1.0.0.zip`

3. **Publish release**

**Result:** Download links for your users!

---

### ☐ Part 6: Share with Users

**Send them this link:**
```
https://github.com/YOUR_USERNAME/campuslearn/releases/latest
```

**Instructions for users:**

**Android:**
1. Download `campuslearn-v1.0.0.apk`
2. Allow installation from unknown sources
3. Install and open

**Windows:**
1. Download `CampusLearn-Windows-v1.0.0.zip`
2. Extract the ZIP file
3. Run `campuslearn.exe`

**That's it - no setup required!**

---

## Testing Before Sharing

Before sharing with users, test that everything works:

### ✓ Test Backend
Visit: `https://your-railway-url.railway.app/swagger`
- Should see Swagger API documentation
- Try the `/api/auth/login` endpoint

### ✓ Test Android APK
- Install on your phone
- Try logging in
- Create a post
- Upload a file

### ✓ Test Windows App
- Run the `.exe`
- Try all features
- Make sure it connects to Railway

---

## Common Issues

**"Connection refused" in app**
- Check Railway URL is correct in build scripts
- Verify backend is running in Railway dashboard

**"Database connection failed"**
- Verify DATABASE_URL environment variable in Railway
- Check PostgreSQL service is running

**"Forgot password email not sending"**
- Check Email environment variables in Railway
- Verify Gmail App Password is correct

**APK won't install**
- Enable "Install from Unknown Sources" on Android
- Make sure APK is built in release mode

---

## What's Next?

### Update the app:
```bash
# Make changes to your code
git add .
git commit -m "Your changes"
git push

# Railway auto-deploys backend!

# Rebuild apps if frontend changed
build_android.bat YOUR_RAILWAY_URL
build_windows.bat YOUR_RAILWAY_URL

# Create new GitHub release with updated files
```

### Monitor usage:
- Railway Dashboard → Your Service → Metrics
- Check logs for errors

### Add more users:
- Just share the GitHub releases link!

---

## Free Tier Limits

**Railway Free Tier:**
- ✅ 500 execution hours/month (~20 days uptime)
- ✅ 1GB database storage
- ✅ 100GB bandwidth
- ✅ Perfect for 1-50 users!

If you exceed limits, Railway will email you. For more users, upgrade to $5/month.

---

## Need Help?

1. Check `DEPLOYMENT_GUIDE.md` for detailed instructions
2. View Railway logs for backend errors
3. Test API endpoints using Swagger
4. Verify environment variables are set correctly

---

**You're done! 🎉**

Users can now download your app and start using it immediately!
