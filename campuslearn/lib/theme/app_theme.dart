import 'package:flutter/material.dart';
import 'package:campuslearn/providers/theme_provider.dart';

/// Custom theme configuration for Campus Learn app
class AppTheme {
  /// Generate theme based on theme provider
  static ThemeData generateTheme(ThemeProvider themeProvider) {
    return ThemeData(
      useMaterial3: true,
      brightness: themeProvider.brightness,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProvider.primaryColor,
        brightness: themeProvider.brightness,
        primary: themeProvider.primaryColor,
        secondary: themeProvider.primaryColor,
        surface: themeProvider.surfaceColor,
        background: themeProvider.backgroundColor,
        error: themeProvider.error,
        onPrimary: themeProvider.textOnPrimary,
        onSecondary: themeProvider.textOnPrimary,
        onSurface: themeProvider.textPrimary,
        onBackground: themeProvider.textPrimary,
        onError: themeProvider.textOnPrimary,
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: themeProvider.textOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: themeProvider.textOnPrimary,
          fontSize: 20 * themeProvider.fontSize,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: themeProvider.textOnPrimary),
      ),
      
      // Bottom navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeProvider.primaryColor,
        selectedItemColor: themeProvider.textOnPrimary,
        unselectedItemColor: themeProvider.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: themeProvider.textOnPrimary,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16 * themeProvider.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
          textStyle: TextStyle(
            fontSize: 16 * themeProvider.fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: themeProvider.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.error),
        ),
        filled: true,
        fillColor: themeProvider.surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Text theme with font scaling
      textTheme: _generateTextTheme(themeProvider),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: themeProvider.textSecondary,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: themeProvider.divider,
        thickness: 1,
        space: 1,
      ),
      
      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: themeProvider.textPrimary,
        contentTextStyle: TextStyle(color: themeProvider.textOnPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: themeProvider.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.textPrimary,
          fontSize: 20 * themeProvider.fontSize,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: themeProvider.textSecondary,
          fontSize: 14 * themeProvider.fontSize,
        ),
      ),
      
      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: themeProvider.textOnPrimary,
        unselectedLabelColor: themeProvider.primaryLight,
        indicator: BoxDecoration(
          color: themeProvider.primaryDark,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
  
  /// Generate text theme with font scaling
  static TextTheme _generateTextTheme(ThemeProvider themeProvider) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 32 * themeProvider.fontSize,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 28 * themeProvider.fontSize,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 24 * themeProvider.fontSize,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 20 * themeProvider.fontSize,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 18 * themeProvider.fontSize,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: themeProvider.textSecondary,
        fontSize: 16 * themeProvider.fontSize,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 16 * themeProvider.fontSize,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 14 * themeProvider.fontSize,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: themeProvider.textSecondary,
        fontSize: 12 * themeProvider.fontSize,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: themeProvider.textPrimary,
        fontSize: 14 * themeProvider.fontSize,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: themeProvider.textSecondary,
        fontSize: 12 * themeProvider.fontSize,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: themeProvider.textLight,
        fontSize: 10 * themeProvider.fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}