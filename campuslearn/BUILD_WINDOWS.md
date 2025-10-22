# Building Windows Executable for CampusLearn

## Prerequisites

1. **Visual Studio 2022** with "Desktop development with C++" workload
2. **Flutter SDK** installed and in PATH
3. **Both backends running:**
   - ASP.NET backend on port 5000
   - Python chatbot on port 5001

## Build Instructions

### Step 1: Open Windows Command Prompt or PowerShell

Navigate to your project folder:
```cmd
cd C:\Users\Ken\Desktop\SEN_RESTART\campuslearn
```

### Step 2: Clean Previous Builds (Optional)

```cmd
flutter clean
flutter pub get
```

### Step 3: Build Release Executable

```cmd
flutter build windows --release
```

This will take a few minutes. The build process will:
- Compile your Dart code to native Windows code
- Bundle all dependencies
- Create an optimized release build

### Step 4: Find Your Executable

After successful build, your executable will be at:
```
build\windows\x64\runner\Release\campuslearn.exe
```

The complete application folder is:
```
build\windows\x64\runner\Release\
```

**IMPORTANT:** You need to distribute the ENTIRE `Release` folder, not just the `.exe` file!

The folder contains:
- `campuslearn.exe` - Main executable
- `flutter_windows.dll` - Flutter runtime
- `data/` folder - Flutter assets and resources
- Other required DLLs

## Running the Executable

### Option 1: Run from Build Location

Double-click:
```
build\windows\x64\runner\Release\campuslearn.exe
```

### Option 2: Create Distribution Package

Copy the entire `Release` folder to wherever you want:

```cmd
xcopy build\windows\x64\runner\Release "C:\Program Files\CampusLearn\" /E /I
```

Then run from there:
```cmd
"C:\Program Files\CampusLearn\campuslearn.exe"
```

## Important Notes

### Backend Requirements

The app requires both backends to be running:

1. **Start ASP.NET Backend (Port 5000):**
   ```cmd
   cd backend
   dotnet run
   ```

2. **Start Python Chatbot (Port 5001):**
   ```cmd
   cd "CHATBOT TEMP"
   python app.py
   ```

Or use the provided batch file (if created).

### API Configuration

The app is currently configured for `localhost:5000` and `localhost:5001`.

If you want to deploy for other users, you'll need to:
1. Deploy backends to a server with public IP or domain
2. Update API URLs in the code:
   - `lib/services/api_config.dart` - Main backend URL
   - `lib/services/chatbot_service.dart` - Chatbot URL

### Firewall & Antivirus

Windows Defender or antivirus may flag the executable on first run. This is normal for new executables. You may need to:
- Allow through Windows Defender
- Add exception in antivirus software

## Build Troubleshooting

### Error: "Visual Studio not found"
- Install Visual Studio 2022
- Make sure "Desktop development with C++" is installed

### Error: "CMake not found"
- Install CMake or reinstall Visual Studio with C++ workload

### Error: "Flutter not recognized"
- Make sure Flutter is in your PATH
- Run `flutter doctor` to check setup

### Build takes forever
- First build is slow (5-10 minutes)
- Subsequent builds are faster
- Use `--release` flag for smaller, optimized builds

## Creating a Shortcut

Right-click `campuslearn.exe` → Send to → Desktop (create shortcut)

## File Size

The release build folder will be approximately:
- **Executable:** ~15-20 MB
- **Total folder:** ~30-50 MB (with all DLLs and assets)

## Distribution

To share with others:

1. **Zip the Release folder:**
   ```cmd
   cd build\windows\x64\runner
   tar -a -c -f CampusLearn-Setup.zip Release
   ```

2. **Share CampusLearn-Setup.zip**

3. **Instructions for users:**
   - Extract the ZIP file
   - Run `campuslearn.exe`
   - Backends must be running on their machine or accessible server

## Advanced: Create Installer

For a professional installer, consider:
- **Inno Setup** - Free Windows installer creator
- **WiX Toolset** - Microsoft's installer framework
- **NSIS** - Nullsoft Scriptable Install System

These tools can create a single `.exe` installer that:
- Installs to Program Files
- Creates Start Menu shortcuts
- Handles uninstallation
- Checks for dependencies
