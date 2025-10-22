# Firebase Cloud Messaging Setup Guide (100% FREE)

Firebase Cloud Messaging (FCM) will send push notifications to users' phones - just like WhatsApp notifications!

## Part 1: Create Firebase Project (5 minutes)

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com
2. Click "Add project" or "Create a project"
3. Enter project name: **CampusLearn**
4. Click "Continue"

### Step 2: Configure Google Analytics (Optional)
1. You can disable Google Analytics for this project (not needed)
2. Click "Continue"
3. Click "Create project"
4. Wait for project creation (30 seconds)
5. Click "Continue" when done

---

## Part 2: Add Android App to Firebase

### Step 3: Register Android App
1. In Firebase Console, click the Android icon (robot)
2. **Android package name:** `com.example.campuslearn`
   - This MUST match your Flutter app package name
   - Find it in: `android/app/build.gradle.kts` (look for `applicationId`)
3. **App nickname (optional):** Campus Learn Android
4. **Debug signing certificate SHA-1:** Leave empty for now
5. Click "Register app"

### Step 4: Download google-services.json
1. Click "Download google-services.json"
2. **IMPORTANT:** Save this file - you'll need it!
3. Click "Next" then "Continue to console"

---

## Part 3: Get Firebase Admin SDK Credentials for Backend

### Step 5: Generate Service Account Key
1. In Firebase Console, click the gear icon ⚙️ (top left)
2. Click "Project settings"
3. Click "Service accounts" tab
4. Click "Generate new private key"
5. Click "Generate key" in the popup
6. **IMPORTANT:** A JSON file will download - save it securely!
7. Rename it to: `firebase-admin-sdk.json`

---

## Part 4: Configure Flutter App (Next Steps)

You'll need to:
1. Copy `google-services.json` to `android/app/` directory
2. Add Firebase dependencies to `pubspec.yaml`
3. Initialize Firebase in your Flutter app

**I'll help you with these steps in the code implementation!**

---

## Part 5: Configure Backend (Next Steps)

You'll need to:
1. Copy `firebase-admin-sdk.json` to `backend/` directory
2. Add path to `appsettings.json`
3. Install Firebase Admin SDK NuGet package

**I'll handle this in the next steps!**

---

## Important Files Checklist

After setup, you should have:

✅ `google-services.json` - for Flutter Android app
✅ `firebase-admin-sdk.json` - for C# backend

**SECURITY WARNING:**
- ❌ Do NOT commit these files to Git
- ❌ Do NOT share them publicly
- ✅ Add them to `.gitignore`

---

## Troubleshooting

**Can't find package name?**
- Open `android/app/build.gradle.kts`
- Look for: `applicationId = "com.example.campuslearn"`
- Use that exact string

**Download didn't work?**
- Make sure pop-ups are not blocked
- Try a different browser (Chrome works best)
- You can always download again from Firebase Console

**Lost the JSON files?**
- `google-services.json`: Download again from Firebase Console > Project Settings > General
- `firebase-admin-sdk.json`: Generate new key from Service Accounts tab

---

## Next Steps

Once you've completed these steps:
1. Tell me: "I've created the Firebase project"
2. Make sure you have both JSON files downloaded
3. I'll help you integrate them into the app!

**Cost: R0.00 (Free Forever)**
- Firebase FCM is completely free
- No credit card required
- Unlimited push notifications
