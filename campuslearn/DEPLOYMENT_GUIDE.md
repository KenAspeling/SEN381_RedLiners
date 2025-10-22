# CampusLearn Deployment Guide
## Host Your App for Free and Distribute to Users

This guide will help you deploy CampusLearn to the cloud so users can download and use the app without setting up their own backend.

---

## 📋 Overview

**What you'll accomplish:**
- Host backend API on Railway.app (free)
- Host PostgreSQL database on Railway (free)
- Build and distribute Android APK
- Build and distribute Windows Desktop app
- Users just download and run - no setup needed!

**Time required:** 2-3 hours
**Cost:** $0 (using free tiers)
**Prerequisites:** GitHub account, Railway.app account

---

## Part 1: Prepare Your GitHub Repository

### Step 1: Create a GitHub Account
1. Go to https://github.com and sign up (if you don't have an account)
2. Verify your email address

### Step 2: Create a New Repository
1. Click the "+" icon in the top right → "New repository"
2. Repository name: `campuslearn` (or any name you prefer)
3. **Important:** Set to **Private** (your credentials are in appsettings.json)
4. Do NOT initialize with README (we already have files)
5. Click "Create repository"

### Step 3: Prepare Your Local Repository

**Remove sensitive data from git tracking:**
```bash
cd /mnt/c/Users/Ken/Desktop/SEN_RESTART/campuslearn

# Initialize git if not already done
git init

# Add all files (sensitive files are already in .gitignore)
git add .
git commit -m "Initial commit - CampusLearn app"
```

**⚠️ IMPORTANT: Check appsettings.json**

Before pushing, create an appsettings.example.json without sensitive data:

```bash
cd backend
cp appsettings.json appsettings.example.json
```

Edit `appsettings.example.json` and replace sensitive values:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "YOUR_RAILWAY_POSTGRES_CONNECTION_STRING"
  },
  "JwtSettings": {
    "SecretKey": "your-secret-key-here",
    "Issuer": "CampusLearnAPI",
    "Audience": "CampusLearnUsers",
    "ExpirationInMinutes": 1440
  },
  "Email": {
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": "587",
    "SmtpUsername": "your-email@gmail.com",
    "SmtpPassword": "your-app-password",
    "FromEmail": "your-email@gmail.com",
    "FromName": "Campus Learn"
  }
}
```

### Step 4: Push to GitHub
```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/campuslearn.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Part 2: Deploy to Railway.app

### Step 1: Create Railway Account
1. Go to https://railway.app
2. Click "Start a New Project" → "Login with GitHub"
3. Authorize Railway to access your GitHub

### Step 2: Create PostgreSQL Database

1. Click "New Project"
2. Select "Provision PostgreSQL"
3. Wait for database to be created (30 seconds)
4. Click on the PostgreSQL service
5. Go to "Variables" tab
6. Copy the `DATABASE_URL` - you'll need this!

### Step 3: Import Your Database

**Option A: Using Railway CLI (Recommended)**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to your project
railway link

# Import database
cd backend
railway run psql $DATABASE_URL < your_export_file.sql
```

**Option B: Using pgAdmin or any PostgreSQL client**
1. Get connection details from Railway PostgreSQL variables
2. Connect using your favorite PostgreSQL tool
3. Run the SQL dump file

### Step 4: Deploy Backend API

1. In Railway dashboard, click "New"
2. Select "GitHub Repo"
3. Choose your `campuslearn` repository
4. Railway will detect it's a .NET project

**Configure Environment Variables:**
1. Click on your service → "Variables" tab
2. Add these variables:

```
ConnectionStrings__DefaultConnection = [Paste DATABASE_URL from PostgreSQL service]
JwtSettings__SecretKey = [Your JWT secret from appsettings.json]
JwtSettings__Issuer = CampusLearnAPI
JwtSettings__Audience = CampusLearnUsers
JwtSettings__ExpirationInMinutes = 1440
Email__SmtpHost = smtp.gmail.com
Email__SmtpPort = 587
Email__SmtpUsername = [Your Gmail address]
Email__SmtpPassword = [Your Gmail App Password]
Email__FromEmail = [Your Gmail address]
Email__FromName = Campus Learn
Firebase__CredentialsPath = campuslearn-2119c-firebase-adminsdk-fbsvc-aec1fa7bda.json
```

**Get Your Production URL:**
1. Go to "Settings" tab
2. Click "Generate Domain"
3. Copy the URL (e.g., `https://campuslearn-production.up.railway.app`)
4. **Save this URL - you'll need it for building the app!**

### Step 5: Verify Deployment

1. Wait for deployment to finish (2-5 minutes)
2. Visit your Railway URL
3. You should see the Swagger documentation page
4. Test the API: `https://your-url.railway.app/api/auth/login`

---

## Part 3: Build Distribution Packages

### For Android APK

1. **Update API URL in code:**
   Edit `lib/services/api_config.dart` line 9:
   ```dart
   static const String productionUrl = String.fromEnvironment(
     'API_URL',
     defaultValue: 'https://your-railway-url.railway.app', // ← Put your Railway URL here
   );
   ```

   **OR** build with environment variable:
   ```bash
   cd /mnt/c/Users/Ken/Desktop/SEN_RESTART/campuslearn
   flutter build apk --release --dart-define=API_URL=https://your-railway-url.railway.app
   ```

2. **Build the APK:**
   ```bash
   flutter build apk --release
   ```

3. **Find your APK:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. **Test the APK:**
   - Install on your Android device
   - Test login, registration, and other features
   - Make sure it connects to your Railway backend

### For Windows Desktop

1. **Build Windows executable:**
   ```bash
   # Option 1: Hardcode the URL in api_config.dart (simpler)
   # Edit lib/services/api_config.dart defaultValue to your Railway URL

   flutter build windows --release

   # Option 2: Use environment variable
   flutter build windows --release --dart-define=API_URL=https://your-railway-url.railway.app
   ```

2. **Find your executable:**
   ```
   build/windows/x64/runner/Release/
   ```

   Files needed for distribution:
   - `campuslearn.exe`
   - All `.dll` files
   - `data/` folder

3. **Create a distributable package:**
   ```bash
   # Create a folder for distribution
   mkdir CampusLearn-Windows

   # Copy all necessary files
   cp -r build/windows/x64/runner/Release/* CampusLearn-Windows/

   # Create a zip file
   # On Windows: Right-click folder → "Send to" → "Compressed (zipped) folder"
   # Or use 7-Zip, WinRAR, etc.
   ```

---

## Part 4: Distribute to Users

### Option 1: GitHub Releases (Recommended)

1. **Create a Release on GitHub:**
   - Go to your repository on GitHub
   - Click "Releases" → "Create a new release"
   - Tag version: `v1.0.0`
   - Release title: `CampusLearn v1.0.0`
   - Description:
     ```markdown
     ## CampusLearn - Windows & Android Release

     Download and run the app - no setup required!

     ### Downloads:
     - **Android:** Download `campuslearn-v1.0.0.apk`
     - **Windows:** Download `CampusLearn-Windows-v1.0.0.zip`

     ### Installation:
     **Android:**
     1. Download the APK
     2. Enable "Install from Unknown Sources" in Settings
     3. Open the APK and install

     **Windows:**
     1. Download and extract the ZIP file
     2. Run `campuslearn.exe`

     No backend setup needed - connects automatically to hosted server!
     ```

2. **Upload Files:**
   - Drag and drop your APK file
   - Drag and drop your Windows ZIP file
   - Click "Publish release"

3. **Share the link with users:**
   ```
   https://github.com/YOUR_USERNAME/campuslearn/releases/latest
   ```

### Option 2: Google Drive / Dropbox

1. Upload APK and ZIP to your cloud storage
2. Set sharing to "Anyone with the link"
3. Share the links

### Option 3: Direct Download Page

Create a simple HTML page:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Download CampusLearn</title>
</head>
<body>
    <h1>📚 CampusLearn</h1>
    <h2>Download for:</h2>
    <ul>
        <li><a href="link-to-apk">Android (APK)</a></li>
        <li><a href="link-to-zip">Windows (ZIP)</a></li>
    </ul>
    <h3>No setup required - just download and run!</h3>
</body>
</html>
```

---

## Part 5: Maintenance

### Updating the App

**When you make changes to the code:**

1. **Commit and push to GitHub:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

2. **Railway auto-deploys** the backend automatically!

3. **Rebuild Flutter apps** if you changed frontend:
   ```bash
   flutter build apk --release --dart-define=API_URL=https://your-url.railway.app
   flutter build windows --release --dart-define=API_URL=https://your-url.railway.app
   ```

4. **Create new GitHub release** with updated files

### Monitoring

**Railway Dashboard:**
- View logs: Click service → "Logs" tab
- Monitor usage: Click service → "Metrics" tab
- Check database: Click PostgreSQL → "Metrics"

**Railway Free Tier Limits:**
- 500 execution hours/month (~20 days)
- 1GB database storage
- 100GB outbound bandwidth
- Perfect for 1-50 users!

---

## Part 6: Troubleshooting

### Backend won't deploy
- Check Railway logs for errors
- Verify environment variables are set correctly
- Ensure database connection string is correct

### App can't connect to backend
- Verify Railway URL is correct in api_config.dart
- Check that Railway service is running
- Test API URL in browser: `https://your-url.railway.app/swagger`

### Database connection issues
- Verify DATABASE_URL is set in environment variables
- Check PostgreSQL service is running in Railway
- Ensure database was imported correctly

### Email not sending
- Verify Gmail App Password is correct
- Check Email environment variables in Railway
- Look for email errors in Railway logs

---

## 🎉 Success Checklist

- [ ] Code pushed to GitHub (private repository)
- [ ] PostgreSQL database created on Railway
- [ ] Database imported successfully
- [ ] Backend deployed to Railway
- [ ] Environment variables configured
- [ ] Backend URL is accessible
- [ ] Android APK built and tested
- [ ] Windows build created and tested
- [ ] Files uploaded to GitHub Releases
- [ ] Download links shared with users

---

## 📞 Support

If you encounter issues:
1. Check Railway logs for backend errors
2. Test API endpoints using Swagger UI
3. Verify environment variables are set
4. Check Flutter build logs for errors

---

## 🔒 Security Notes

**Important:**
- Never commit `appsettings.json` with real credentials
- Keep GitHub repository private
- Use environment variables for all secrets
- Regularly update dependencies for security patches
- Monitor Railway logs for suspicious activity

---

Congratulations! Your app is now hosted and ready for users to download and use! 🚀
