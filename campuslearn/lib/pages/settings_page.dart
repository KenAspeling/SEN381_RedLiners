import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campuslearn/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Theme Section
              _buildSectionHeader(context, 'Theme'),
              Card(
                child: Column(
                  children: [
                    _buildColorPickerTile(context, themeProvider),
                    Divider(height: 1),
                    _buildDarkModeTile(context, themeProvider),
                    Divider(height: 1),
                    _buildFontSizeTile(context, themeProvider),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Reset Section
              Card(
                child: ListTile(
                  leading: Icon(Icons.refresh, color: context.appColors.warning),
                  title: Text('Reset to Defaults'),
                  subtitle: Text('Reset all theme settings to default'),
                  onTap: () => _showResetDialog(context, themeProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: context.appColors.primary,
        ),
      ),
    );
  }

  Widget _buildColorPickerTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: themeProvider.primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.appColors.border, width: 2),
        ),
      ),
      title: Text('Primary Color'),
      subtitle: Text('Customize your app\'s main color'),
      onTap: () => _showColorPicker(context, themeProvider),
    );
  }

  Widget _buildDarkModeTile(BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: context.appColors.textSecondary,
      ),
      title: Text('Dark Mode'),
      subtitle: Text('Switch between light and dark themes'),
      value: themeProvider.isDarkMode,
      onChanged: (value) => themeProvider.setDarkMode(value),
    );
  }

  Widget _buildFontSizeTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(Icons.text_fields, color: context.appColors.textSecondary),
      title: Text('Font Size'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjust text size throughout the app'),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Small', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: themeProvider.fontSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  onChanged: (value) => themeProvider.setFontSize(value),
                ),
              ),
              Text('Large', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(Icons.notifications, color: context.appColors.textSecondary),
      title: Text('Notifications'),
      subtitle: Text('Receive push notifications'),
      value: true, // TODO: Add notification state management
      onChanged: (value) {
        // TODO: Implement notification toggle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification settings coming soon!')),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.language, color: context.appColors.textSecondary),
      title: Text('Language'),
      subtitle: Text('English (US)'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language selection coming soon!')),
        );
      },
    );
  }

  Widget _buildChangePasswordTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.lock, color: context.appColors.textSecondary),
      title: Text('Change Password'),
      subtitle: Text('Update your account password'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password change coming soon!')),
        );
      },
    );
  }

  Widget _buildPrivacyTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.privacy_tip, color: context.appColors.textSecondary),
      title: Text('Privacy & Data'),
      subtitle: Text('Manage your privacy settings'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Privacy settings coming soon!')),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    final predefinedColors = [
      Color.fromARGB(255, 172, 30, 73),  // Original pink
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Primary Color'),
        content: Container(
          width: 280,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: predefinedColors.length,
            itemBuilder: (context, index) {
              final color = predefinedColors[index];
              final isSelected = color.value == themeProvider.primaryColor.value;
              
              return GestureDetector(
                onTap: () {
                  themeProvider.setPrimaryColor(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected 
                      ? Border.all(color: context.appColors.textPrimary, width: 3)
                      : Border.all(color: context.appColors.border, width: 1),
                  ),
                  child: isSelected 
                    ? Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Theme Settings'),
        content: Text('This will reset all theme settings to their default values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme settings reset to defaults')),
              );
            },
            child: Text('Reset', style: TextStyle(color: context.appColors.error)),
          ),
        ],
      ),
    );
  }
}