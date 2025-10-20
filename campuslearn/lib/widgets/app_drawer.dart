import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:campuslearn/pages/settings_page.dart';
import 'package:campuslearn/pages/help_page.dart';
import 'package:campuslearn/pages/about_page.dart';
import 'package:campuslearn/pages/login_page.dart';
import 'package:campuslearn/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.appColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.appColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: context.appColors.background,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: context.appColors.primaryDark,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Campus Learn',
                  style: TextStyle(
                    color: context.appColors.textOnPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Welcome, Student',
                  style: TextStyle(
                    color: context.appColors.textOnPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: context.appColors.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: context.appColors.error),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Get navigator reference before async operations
                final navigator = Navigator.of(context);
                
                // Close dialog first
                navigator.pop();
                
                try {
                  // Clear all auth data
                  await AuthService.logout();
                  
                  // Navigate back to login page and clear all previous routes
                  // Use pushNamedAndRemoveUntil if possible, or check if context is still mounted
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  print('Error during logout: $e');
                  // Fallback navigation
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: context.appColors.error),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'No',
                style: TextStyle(color: context.appColors.textLight),
              ),
            ),
          ],
        );
      },
    );
  }
}