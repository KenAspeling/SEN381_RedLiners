import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campuslearn/providers/theme_provider.dart';

/// Dynamic color definitions that adapt to theme provider
class AppColors {
  // Static colors that don't change
  static const Color secondary = Color.fromARGB(255, 243, 33, 103);
  static const Color secondaryLight = Color.fromARGB(255, 255, 105, 135);
  static const Color shadow = Color.fromARGB(25, 0, 0, 0);
  static const Color transparent = Colors.transparent;
  
  // Static method to get theme provider colors
  static ThemeProvider _getProvider(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true);
  }
  
  // Dynamic colors based on theme provider
  static Color primary(BuildContext context) => _getProvider(context).primaryColor;
  static Color primaryDark(BuildContext context) => _getProvider(context).primaryDark;
  static Color primaryLight(BuildContext context) => _getProvider(context).primaryLight;
  
  static Color background(BuildContext context) => _getProvider(context).backgroundColor;
  static Color surface(BuildContext context) => _getProvider(context).surfaceColor;
  static Color cardBackground(BuildContext context) => _getProvider(context).cardBackground;
  
  static Color textPrimary(BuildContext context) => _getProvider(context).textPrimary;
  static Color textSecondary(BuildContext context) => _getProvider(context).textSecondary;
  static Color textLight(BuildContext context) => _getProvider(context).textLight;
  static Color textOnPrimary(BuildContext context) => _getProvider(context).textOnPrimary;
  
  static Color success(BuildContext context) => _getProvider(context).success;
  static Color warning(BuildContext context) => _getProvider(context).warning;
  static Color error(BuildContext context) => _getProvider(context).error;
  static Color info(BuildContext context) => _getProvider(context).info;
  
  static Color border(BuildContext context) => _getProvider(context).border;
  static Color divider(BuildContext context) => _getProvider(context).divider;
  static Color overlay(BuildContext context) => _getProvider(context).overlay;
  static Color primaryOverlay(BuildContext context) => _getProvider(context).primaryOverlay;
}