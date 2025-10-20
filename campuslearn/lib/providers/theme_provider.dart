import 'package:flutter/material.dart';
import 'package:campuslearn/services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = ThemeService.defaultPrimaryColor;
  bool _isDarkMode = ThemeService.defaultDarkMode;
  double _fontSize = ThemeService.defaultFontSize;
  bool _isLoading = true;

  // Getters
  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  bool get isLoading => _isLoading;

  // Computed colors based on primary color
  Color get primaryDark => _darkenColor(_primaryColor, 0.2);
  Color get primaryLight => _lightenColor(_primaryColor, 0.1);
  
  // Background colors
  Color get backgroundColor => _isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get surfaceColor => _isDarkMode ? Colors.grey[850]! : const Color.fromARGB(255, 250, 250, 250);
  Color get cardBackground => _isDarkMode ? Colors.grey[800]! : Colors.white;
  
  // Text colors
  Color get textPrimary => _isDarkMode ? Colors.white : const Color.fromARGB(255, 33, 33, 33);
  Color get textSecondary => _isDarkMode ? Colors.grey[300]! : const Color.fromARGB(255, 117, 117, 117);
  Color get textLight => _isDarkMode ? Colors.grey[400]! : const Color.fromARGB(255, 173, 173, 173);
  Color get textOnPrimary => Colors.white;
  
  // Status colors
  Color get success => const Color.fromARGB(255, 76, 175, 80);
  Color get warning => const Color.fromARGB(255, 255, 152, 0);
  Color get error => const Color.fromARGB(255, 244, 67, 54);
  Color get info => const Color.fromARGB(255, 33, 150, 243);
  
  // Other colors
  Color get border => _isDarkMode ? Colors.grey[700]! : const Color.fromARGB(255, 224, 224, 224);
  Color get divider => _isDarkMode ? Colors.grey[700]! : const Color.fromARGB(255, 238, 238, 238);
  Color get overlay => const Color.fromARGB(128, 0, 0, 0);
  Color get primaryOverlay => _primaryColor.withOpacity(0.2);

  /// Initialize theme provider by loading saved preferences
  Future<void> initialize() async {
    try {
      final preferences = await ThemeService.loadAllThemePreferences();
      _primaryColor = preferences['primaryColor'];
      _isDarkMode = preferences['darkMode'];
      _fontSize = preferences['fontSize'];
    } catch (e) {
      print('Error initializing theme: $e');
      // Use default values
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update primary color
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await ThemeService.savePrimaryColor(color);
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await ThemeService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await ThemeService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Update font size
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await ThemeService.saveFontSize(size);
    notifyListeners();
  }

  /// Reset to default theme
  Future<void> resetToDefaults() async {
    await ThemeService.clearThemePreferences();
    _primaryColor = ThemeService.defaultPrimaryColor;
    _isDarkMode = ThemeService.defaultDarkMode;
    _fontSize = ThemeService.defaultFontSize;
    notifyListeners();
  }

  /// Helper method to darken a color
  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDarker = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDarker.toColor();
  }

  /// Helper method to lighten a color
  Color _lightenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslLighter = hsl.withLightness((hsl.lightness + factor).clamp(0.0, 1.0));
    return hslLighter.toColor();
  }

  /// Get brightness for status bar
  Brightness get statusBarBrightness => _isDarkMode ? Brightness.light : Brightness.dark;

  /// Get theme brightness
  Brightness get brightness => _isDarkMode ? Brightness.dark : Brightness.light;
}