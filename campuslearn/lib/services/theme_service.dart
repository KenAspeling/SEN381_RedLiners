import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _primaryColorKey = 'primary_color';
  static const String _darkModeKey = 'dark_mode';
  static const String _fontSizeKey = 'font_size';
  
  // Default values
  static const Color defaultPrimaryColor = Color.fromARGB(255, 172, 30, 73);
  static const bool defaultDarkMode = false;
  static const double defaultFontSize = 1.0; // Scale factor
  
  /// Save primary color to storage
  static Future<void> savePrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }
  
  /// Load primary color from storage
  static Future<Color> loadPrimaryColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_primaryColorKey);
      return colorValue != null ? Color(colorValue) : defaultPrimaryColor;
    } catch (e) {
      print('Error loading primary color: $e');
      return defaultPrimaryColor;
    }
  }
  
  /// Save dark mode preference
  static Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }
  
  /// Load dark mode preference
  static Future<bool> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? defaultDarkMode;
    } catch (e) {
      print('Error loading dark mode: $e');
      return defaultDarkMode;
    }
  }
  
  /// Save font size scale
  static Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }
  
  /// Load font size scale
  static Future<double> loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_fontSizeKey) ?? defaultFontSize;
    } catch (e) {
      print('Error loading font size: $e');
      return defaultFontSize;
    }
  }
  
  /// Clear all theme preferences
  static Future<void> clearThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_darkModeKey);
    await prefs.remove(_fontSizeKey);
  }
  
  /// Load all theme preferences at once
  static Future<Map<String, dynamic>> loadAllThemePreferences() async {
    return {
      'primaryColor': await loadPrimaryColor(),
      'darkMode': await loadDarkMode(),
      'fontSize': await loadFontSize(),
    };
  }
}