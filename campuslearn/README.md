# 📚 CampusLearn

A cross-platform learning management system built with Flutter and ASP.NET Core, designed for students and tutors to collaborate, share resources, and learn together.

## ✨ Features

- **Multi-Platform Support:** Android, iOS, Windows, macOS, Linux, and Web
- **User Authentication:** Secure login with JWT tokens and password reset via email
- **Discussion Forums:** Create posts, comment, and engage with peers
- **File Sharing:** Upload and download study materials
- **AI Chatbot:** Integrated Gemini AI for learning assistance
- **Module Management:** Organize content by academic modules
- **Real-time Notifications:** Stay updated on new posts and comments
- **Dark Mode Support:** Comfortable viewing in any environment
- **Tutor/Student Roles:** Role-based access and permissions

## 🚀 Quick Start

### For Users (Download & Use)

**No setup required!** Download the latest release:

👉 **[Download CampusLearn](https://github.com/YOUR_USERNAME/campuslearn/releases/latest)**

- **Android:** Download and install the APK
- **Windows:** Download ZIP, extract, and run

### For Developers (Local Development)

#### Prerequisites

- Flutter SDK 3.9.2 or higher
- .NET 8 SDK
- PostgreSQL 14+
- Git

#### Backend Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/campuslearn.git
cd campuslearn/backend

# Install dependencies
dotnet restore

# Update database connection in appsettings.json
# Then run the backend
dotnet run
```

Backend will be available at `http://localhost:5000`

#### Flutter Setup

```bash
cd campuslearn

# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run -d windows     # Windows
flutter run -d chrome      # Web
flutter run                # Connected device
```

## 📖 Documentation

- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Complete guide to hosting your app
- **[Quick Start Deployment](QUICK_START_DEPLOYMENT.md)** - 30-minute deployment checklist
- **[Password Reset Setup](PASSWORD_RESET_EMAIL_SETUP.md)** - Email integration guide
- **[Code Cleanup Report](CLEANUP_REPORT.md)** - Codebase health status

## 🛠 Technology Stack

### Frontend
- **Flutter 3.9.2** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - API communication
- **File Picker** - File uploads
- **Shared Preferences** - Local storage

### Backend
- **ASP.NET Core 8** - Web API framework
- **Entity Framework Core** - ORM
- **PostgreSQL** - Database
- **JWT** - Authentication
- **BCrypt** - Password hashing
- **MailKit** - Email service
- **Firebase Admin** - Push notifications

## 📁 Project Structure

```
campuslearn/
├── lib/                    # Flutter source code
│   ├── main.dart          # App entry point
│   ├── pages/             # UI screens
│   ├── services/          # API & business logic
│   ├── models/            # Data models
│   ├── widgets/           # Reusable components
│   ├── providers/         # State management
│   └── theme/             # Theme configuration
├── backend/               # ASP.NET Core API
│   ├── Controllers/       # API endpoints
│   ├── Services/          # Business logic
│   ├── Models/            # Entity models
│   ├── DTOs/              # Data transfer objects
│   └── Data/              # Database context
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── windows/               # Windows-specific code
├── web/                   # Web-specific code
└── CHATBOT TEMP/          # AI chatbot service
```

## 🌐 Deployment

### Free Hosting Options

1. **Railway.app** (Recommended)
   - 500 hours/month free
   - Built-in PostgreSQL
   - Auto-deployment from GitHub

2. **Render.com**
   - Free tier available
   - PostgreSQL included
   - Easy setup

### Deploy in 30 Minutes

Follow the [Quick Start Deployment Guide](QUICK_START_DEPLOYMENT.md) to deploy your app for free!

## 🔧 Configuration

### Backend (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Your PostgreSQL connection string"
  },
  "JwtSettings": {
    "SecretKey": "Your secret key",
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

### Frontend (lib/services/api_config.dart)

```dart
static const String productionUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://your-backend-url.railway.app',
);
```

## 📱 Building for Distribution

### Android

```bash
# Build APK with production backend
build_android.bat https://your-backend-url.railway.app
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Windows

```bash
# Build Windows executable
build_windows.bat https://your-backend-url.railway.app
```

Output: `CampusLearn-Windows-v1.0.0/`

## 🧪 Testing

```bash
# Flutter tests
flutter test

# Backend tests
cd backend
dotnet test

# Code analysis
flutter analyze
dotnet format --verify-no-changes
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - Initial work

## 🙏 Acknowledgments

- Belgium Campus ITversity for the educational environment
- Flutter team for the amazing cross-platform framework
- ASP.NET Core team for the robust backend framework
- All contributors and testers

## 📞 Support

For issues, questions, or suggestions:

1. Check the [Deployment Guide](DEPLOYMENT_GUIDE.md)
2. Review [existing issues](https://github.com/YOUR_USERNAME/campuslearn/issues)
3. Create a new issue if needed

## 🔒 Security

- Never commit credentials to GitHub
- Use environment variables for secrets
- Keep dependencies updated
- Use HTTPS in production

## 📊 Status

- ✅ Core Features Complete
- ✅ Multi-platform Support
- ✅ Email Integration
- ✅ AI Chatbot Integration
- ✅ File Upload/Download
- ✅ Push Notifications
- ✅ Production Ready

---

**Made with ❤️ for students, by students**
