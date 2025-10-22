import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:campuslearn/pages/settings_page.dart';
import 'package:campuslearn/pages/help_page.dart';
import 'package:campuslearn/pages/about_page.dart';
import 'package:campuslearn/pages/login_page.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/module_service.dart';
import 'package:campuslearn/services/subscription_service.dart';
import 'package:campuslearn/models/module.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<Module> _userModules = [];
  bool _loadingModules = true;
  Map<int, bool> _moduleSubscriptions = {}; // Track subscription status

  @override
  void initState() {
    super.initState();
    _loadUserModules();
  }

  Future<void> _loadUserModules() async {
    try {
      final modules = await ModuleService.getUserModules();

      // Load subscription status for each module
      final subscriptions = <int, bool>{};
      for (var module in modules) {
        try {
          final isSubscribed = await SubscriptionService.isSubscribed(
            subscribableType: 2, // 2 = Module
            subscribableId: module.moduleId,
          );
          subscriptions[module.moduleId] = isSubscribed;
        } catch (e) {
          subscriptions[module.moduleId] = false;
        }
      }

      if (mounted) {
        setState(() {
          _userModules = modules;
          _moduleSubscriptions = subscriptions;
          _loadingModules = false;
        });
      }
    } catch (e) {
      print('Error loading user modules: $e');
      if (mounted) {
        setState(() {
          _userModules = [];
          _loadingModules = false;
        });
      }
    }
  }

  Future<void> _toggleModuleSubscription(Module module) async {
    try {
      final currentStatus = _moduleSubscriptions[module.moduleId] ?? false;
      final newStatus = await SubscriptionService.toggleSubscription(
        subscribableType: 2, // 2 = Module
        subscribableId: module.moduleId,
        currentlySubscribed: currentStatus,
      );

      if (mounted) {
        setState(() {
          _moduleSubscriptions[module.moduleId] = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                ? 'Subscribed to ${module.tag ?? module.name}'
                : 'Unsubscribed from ${module.tag ?? module.name}'
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                  'Welcome',
                  style: TextStyle(
                    color: context.appColors.textOnPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // My Modules Section
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'MY MODULES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (_loadingModules)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_userModules.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: context.appColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No modules enrolled',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._userModules.map((module) {
              final isSubscribed = _moduleSubscriptions[module.moduleId] ?? false;
              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.book,
                    size: 20,
                    color: context.appColors.primary,
                  ),
                ),
                title: Text(
                  module.tag ?? module.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: module.tag != null
                    ? Text(
                        module.name,
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    isSubscribed ? Icons.notifications : Icons.notifications_off,
                    size: 20,
                    color: isSubscribed ? context.appColors.primary : context.appColors.textLight,
                  ),
                  onPressed: () => _toggleModuleSubscription(module),
                  tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Module: ${module.name}')),
                  );
                },
              );
            }),

          Divider(),

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