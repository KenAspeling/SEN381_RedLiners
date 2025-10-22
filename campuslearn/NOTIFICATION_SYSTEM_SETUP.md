# Complete Notification System Setup Guide

This guide will help you set up **Email + Push Notifications** for Campus Learn - completely FREE!

## 📋 Overview

You'll be setting up:
✅ **Email Notifications** - via Gmail SMTP (FREE)
✅ **Push Notifications** - via Firebase (FREE)

**Total Cost: R0.00**
**Estimated Time: 30 minutes**

---

## 🚀 Step-by-Step Setup

### STEP 1: Database Setup (5 minutes)

Run these SQL scripts in pgAdmin or your PostgreSQL client:

```sql
-- 1. Create notifications table
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    message VARCHAR(500) NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id INTEGER,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    time_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- 2. Create fcm_tokens table
CREATE TABLE fcm_tokens (
    token_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    fcm_token VARCHAR(500) NOT NULL UNIQUE,
    device_type VARCHAR(50) NOT NULL DEFAULT 'android',
    device_info VARCHAR(200),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    time_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    time_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fcm_tokens_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. Create indexes for better performance
CREATE INDEX idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_active ON fcm_tokens(is_active);
```

---

### STEP 2: Email Setup - Gmail SMTP (10 minutes)

📖 **Detailed guide:** See `backend/EMAIL_SETUP.md`

**Quick Steps:**
1. Enable 2-Factor Authentication on your Gmail account
2. Generate App Password at https://myaccount.google.com/apppasswords
3. Update `backend/appsettings.json`:

```json
"Email": {
  "SmtpHost": "smtp.gmail.com",
  "SmtpPort": "587",
  "SmtpUsername": "your-actual-email@gmail.com",
  "SmtpPassword": "your-16-char-app-password",
  "FromEmail": "your-actual-email@gmail.com",
  "FromName": "Campus Learn"
}
```

**IMPORTANT:** Remove spaces from the app password!

---

### STEP 3: Firebase Setup (15 minutes)

📖 **Detailed guide:** See `FIREBASE_SETUP.md`

**Quick Steps:**
1. Go to https://console.firebase.google.com
2. Create new project named "CampusLearn"
3. Add Android app with package name: `com.example.campuslearn`
4. Download `google-services.json`
5. Generate service account key (Project Settings → Service Accounts)
6. Download and rename to `firebase-admin-sdk.json`

**Files you should now have:**
- ✅ `google-services.json` (for Flutter Android)
- ✅ `firebase-admin-sdk.json` (for C# backend)

---

### STEP 4: Backend Configuration (2 minutes)

1. **Copy Firebase credentials:**
   ```bash
   # Copy the service account JSON to backend folder
   cp ~/Downloads/firebase-admin-sdk.json backend/
   ```

2. **Update `backend/appsettings.json`:**
   ```json
   "Firebase": {
     "CredentialsPath": "firebase-admin-sdk.json"
   }
   ```

3. **Install Firebase Admin SDK:**
   ```bash
   cd backend
   dotnet add package FirebaseAdmin
   dotnet restore
   ```

---

### STEP 5: Flutter Configuration (5 minutes)

1. **Copy google-services.json:**
   ```bash
   cp ~/Downloads/google-services.json android/app/
   ```

2. **Add Firebase dependencies to `pubspec.yaml`:**
   ```yaml
   dependencies:
     firebase_core: ^2.24.2
     firebase_messaging: ^14.7.10
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Update `android/app/build.gradle`:**
   Add at the TOP of the file:
   ```gradle
   plugins {
       id "com.android.application"
       id "kotlin-android"
       id "dev.flutter.flutter-gradle-plugin"
       id "com.google.gms.google-services"  // ADD THIS LINE
   }
   ```

5. **Update `android/build.gradle`:**
   In the `dependencies` section, add:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'  // ADD THIS
   }
   ```

---

### STEP 6: Test Everything! (5 minutes)

1. **Restart backend:**
   ```bash
   cd backend
   dotnet run
   ```

2. **Run Flutter app:**
   ```bash
   flutter run
   ```

3. **Test notifications:**
   - Login with User A
   - Subscribe to a topic
   - Logout and login as User B
   - Comment on that topic
   - Login back as User A
   - ✅ Check email inbox for notification email
   - ✅ Check app for push notification
   - ✅ See notification badge on bell icon

---

## ✅ Verification Checklist

After setup, verify:

- [ ] notifications table exists in database
- [ ] fcm_tokens table exists in database
- [ ] `appsettings.json` has Gmail credentials
- [ ] `backend/firebase-admin-sdk.json` exists
- [ ] `android/app/google-services.json` exists
- [ ] Backend runs without errors (`dotnet run`)
- [ ] Flutter app builds successfully (`flutter run`)
- [ ] Email received when notification created
- [ ] Push notification appears on device
- [ ] Notification bell shows unread count

---

## 🐛 Troubleshooting

### Email not sending?
- Check Gmail app password is correct (no spaces!)
- Verify 2FA is enabled on Gmail
- Check backend console for `[EMAIL]` logs

### Push notifications not working?
- Verify `google-services.json` is in `android/app/`
- Check package name matches in Firebase Console
- Look for Firebase initialization errors in console

### Database errors?
- Make sure both SQL scripts ran successfully
- Check table names are lowercase
- Verify foreign key constraints exist

---

## 📞 Support

If you encounter issues:
1. Check the detailed guides: `EMAIL_SETUP.md` and `FIREBASE_SETUP.md`
2. Look for error messages in:
   - Backend console (`dotnet run` output)
   - Flutter console (`flutter run` output)
   - Browser developer console (for debugging)

---

## 🎉 Success!

Once everything is working, you'll have:
- ✅ **Email notifications** sent to all users
- ✅ **Push notifications** delivered instantly to phones
- ✅ **In-app notification badge** showing unread count
- ✅ **100% FREE** - no monthly costs!

Users will be notified when:
- Someone comments on topics they've subscribed to
- New posts/topics are created in subscribed modules
- And any other events you configure!

**Congratulations on building a complete notification system!** 🚀
