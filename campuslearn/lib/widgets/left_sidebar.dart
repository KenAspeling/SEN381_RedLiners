import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/module_service.dart';
import 'package:campuslearn/services/subscription_service.dart';
import 'package:campuslearn/models/module.dart';
import 'package:campuslearn/pages/profile_page.dart';
import 'package:campuslearn/pages/settings_page.dart';
import 'package:campuslearn/pages/help_page.dart';
import 'package:campuslearn/pages/about_page.dart';
import 'package:campuslearn/pages/login_page.dart';

class LeftSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onNavigationTap;
  final bool hideProfileButton;

  const LeftSidebar({
    super.key,
    required this.selectedIndex,
    required this.onNavigationTap,
    this.hideProfileButton = false,
  });

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  String _userName = 'Student';
  String _userEmail = 'user@campus.edu';
  List<Module> _userModules = [];
  bool _loadingModules = true;
  Map<int, bool> _moduleSubscriptions = {}; // Track subscription status

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserModules();
  }

  Future<void> _loadUserData() async {
    try {
      final userIdString = await AuthService.getUserId();
      final userId = int.tryParse(userIdString ?? '0');

      if (userId != null && userId != 0) {
        final userData = await AuthService.getUserById(userId);

        if (userData != null) {
          final name = userData['name'] ?? userData['Name'] ?? '';
          final surname = userData['surname'] ?? userData['Surname'] ?? '';
          final email = userData['email'] ?? userData['Email'] ?? 'user@campus.edu';

          if (mounted) {
            setState(() {
              _userName = '$name $surname'.trim().isNotEmpty
                  ? '$name $surname'.trim()
                  : 'Student';
              _userEmail = email;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop(); // Close dialog

                try {
                  await AuthService.logout();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  print('Error during logout: $e');
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(color: context.appColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: context.appColors.surface,
      child: Column(
        children: [
          // Profile Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.primary,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.appColors.background,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: context.appColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!widget.hideProfileButton) ...[
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'View Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              children: [
                // Main Navigation
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(3, Icons.live_help, 'Tickets'),
                _buildNavItem(1, Icons.add_box, 'Create'),
                _buildNavItem(2, Icons.message, 'Messages'),

                SizedBox(height: 20),
                Divider(height: 1),
                SizedBox(height: 20),

                // My Modules Section
                _buildSectionHeader('My Modules'),
                SizedBox(height: 8),
                _buildModulesCard(),

                SizedBox(height: 24),
                Divider(height: 1),
                SizedBox(height: 12),

                // App Menu Items
                _buildMenuTile(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),

                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),

                // Logout
                _buildMenuTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: _showLogoutDialog,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () => widget.onNavigationTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? context.appColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : context.appColors.textSecondary,
                size: 22,
              ),
              SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : context.appColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? context.appColors.error : context.appColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? context.appColors.error : context.appColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.appColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModulesCard() {
    if (_loadingModules) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_userModules.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.school_outlined,
                size: 32,
                color: context.appColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 8),
              Text(
                'No modules enrolled',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._userModules.map((module) {
              final isSubscribed = _moduleSubscriptions[module.moduleId] ?? false;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.book,
                        size: 16,
                        color: context.appColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (module.tag != null)
                            Text(
                              module.tag!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.appColors.primary,
                              ),
                            ),
                          Text(
                            module.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSubscribed ? Icons.notifications : Icons.notifications_off,
                        size: 18,
                        color: isSubscribed ? context.appColors.primary : context.appColors.textLight,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => _toggleModuleSubscription(module),
                      tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
