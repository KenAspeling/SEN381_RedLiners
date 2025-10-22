# Gmail SMTP Setup Guide (100% FREE)

## Step 1: Enable 2-Factor Authentication on Gmail

1. Go to https://myaccount.google.com/security
2. Click "2-Step Verification"
3. Follow the prompts to enable 2FA

## Step 2: Generate App Password

1. Go to https://myaccount.google.com/apppasswords
2. Select "Mail" as the app
3. Select "Other" as the device and name it "Campus Learn"
4. Click "Generate"
5. **Copy the 16-character password** (it looks like: `abcd efgh ijkl mnop`)

## Step 3: Update appsettings.json

Replace the placeholders in `backend/appsettings.json`:

```json
"Email": {
  "SmtpHost": "smtp.gmail.com",
  "SmtpPort": "587",
  "SmtpUsername": "ken.aspeling@gmail.com",
  "SmtpPassword": "fwrvraeqptqkftex",  // The 16-char app password (no spaces!)
  "FromEmail": "ken.aspeling@gmail.com",
  "FromName": "Campus Learn"
}
```

**IMPORTANT:**
- Remove the spaces from the app password (make it one continuous string)
- Do NOT use your regular Gmail password
- Use the app-specific password generated in Step 2

## Step 4: Test Email Sending

After updating the configuration, restart your backend:

```bash
cd backend
dotnet run
```

The first time a notification is created, you should see in the console:
```
[EMAIL] Sent to user@example.com: Campus Learn: New comment on...
```

## Troubleshooting

**Error: "Authentication failed"**
- Make sure you're using the app password, not your regular password
- Remove all spaces from the app password
- Verify 2FA is enabled on your Google account

**Error: "SMTP connection failed"**
- Check your internet connection
- Make sure port 587 is not blocked by your firewall

**Emails going to spam**
- This is normal for new senders
- Ask users to mark as "Not Spam" once
- After a few successful emails, Gmail will trust your address

## Gmail Sending Limits

- **FREE Gmail accounts:** 500 emails per day
- **Google Workspace (paid):** 2,000 emails per day
- For 1,000 notifications/month, you'll be well within the limit!

## Alternative: Use University SMTP

If your university provides SMTP access, you can use that instead:

```json
"Email": {
  "SmtpHost": "smtp.your-university.ac.za",
  "SmtpPort": "587",
  "SmtpUsername": "your-student-number@uni.ac.za",
  "SmtpPassword": "your-email-password",
  "FromEmail": "campuslearn@uni.ac.za",
  "FromName": "Campus Learn"
}
```

Contact your IT department for SMTP server details.
