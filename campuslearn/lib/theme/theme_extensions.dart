import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campuslearn/providers/theme_provider.dart';
import 'app_colors.dart';

/// Theme extension methods for easy access to custom colors and styles
extension ThemeExtensions on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Get the current color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get theme provider
  ThemeProvider get themeProvider => Provider.of<ThemeProvider>(this, listen: true);
  
  /// Quick access to commonly used colors
  Color get primaryColor => colors.primary;
  Color get secondaryColor => colors.secondary;
  Color get backgroundColor => colors.background;
  Color get surfaceColor => colors.surface;
  Color get errorColor => colors.error;
  
  /// Custom app colors (dynamic access)
  AppColorsExtension get appColors => AppColorsExtension(this);
  
  /// Media query shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  /// Common padding values
  EdgeInsets get paddingAll16 => EdgeInsets.all(16);
  EdgeInsets get paddingHorizontal16 => EdgeInsets.symmetric(horizontal: 16);
  EdgeInsets get paddingVertical16 => EdgeInsets.symmetric(vertical: 16);
  
  /// Common spacing
  SizedBox get spacing8 => SizedBox(height: 8, width: 8);
  SizedBox get spacing16 => SizedBox(height: 16, width: 16);
  SizedBox get spacing24 => SizedBox(height: 24, width: 24);
  SizedBox get spacing32 => SizedBox(height: 32, width: 32);
}

/// Extension for dynamic access to AppColors
class AppColorsExtension {
  final BuildContext context;
  
  AppColorsExtension(this.context);
  
  // Primary brand colors
  Color get primary => AppColors.primary(context);
  Color get primaryDark => AppColors.primaryDark(context);
  Color get primaryLight => AppColors.primaryLight(context);
  
  // Secondary colors
  Color get secondary => AppColors.secondary;
  Color get secondaryLight => AppColors.secondaryLight;
  
  // Neutral colors
  Color get background => AppColors.background(context);
  Color get surface => AppColors.surface(context);
  Color get cardBackground => AppColors.cardBackground(context);
  
  // Text colors
  Color get textPrimary => AppColors.textPrimary(context);
  Color get textSecondary => AppColors.textSecondary(context);
  Color get textLight => AppColors.textLight(context);
  Color get textOnPrimary => AppColors.textOnPrimary(context);
  
  // Status colors
  Color get success => AppColors.success(context);
  Color get warning => AppColors.warning(context);
  Color get error => AppColors.error(context);
  Color get info => AppColors.info(context);
  
  // Border and divider colors
  Color get border => AppColors.border(context);
  Color get divider => AppColors.divider(context);
  
  // Transparent colors
  Color get overlay => AppColors.overlay(context);
  Color get primaryOverlay => AppColors.primaryOverlay(context);
  Color get transparent => AppColors.transparent;
}