import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/pages/profile_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final email = await AuthService.getUserEmail();
      final userData = await AuthService.getUserDataFromToken();
      
      if (mounted) {
        setState(() {
          _userEmail = email ?? 'user@campus.edu';
          _userName = userData?['email']?.split('@')[0] ?? 'Student';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Student';
          _userEmail = 'user@campus.edu';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: context.appColors.surface,
      child: Column(
        children: [
          // Profile Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.primary,
            ),
            child: widget.hideProfileButton 
              ? SizedBox(height: 80) // Empty space to maintain layout
              : Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: context.appColors.background,
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _userEmail,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'View Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
          
          SizedBox(height: 16),
          
          // Navigation Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.create, 'Create'),
                _buildNavItem(2, Icons.message, 'Messages'),
                _buildNavItem(3, Icons.notifications, 'Notifications'),
                _buildNavItem(4, Icons.help_outline, 'Help'),
                
                SizedBox(height: 24),
                
                // Campus Stats Section
                _buildSectionHeader('Campus Stats'),
                _buildStatsCard(),
                
                SizedBox(height: 24),
                
                // Recent Activity Section
                _buildSectionHeader('Recent Activity'),
                _buildActivityCard(),
                
                SizedBox(height: 24),
                
                // Study Groups Section
                _buildSectionHeader('Study Groups'),
                _buildStudyGroupsCard(),
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
      margin: EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => widget.onNavigationTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.appColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
              ? Border.all(color: context.appColors.primary.withOpacity(0.3))
              : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? context.appColors.primary : context.appColors.textSecondary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? context.appColors.primary : context.appColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
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

  Widget _buildStatsCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Online Users', style: TextStyle(fontSize: 12, color: context.appColors.textSecondary)),
                Text('2,847', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.appColors.primary)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Topics', style: TextStyle(fontSize: 12, color: context.appColors.textSecondary)),
                Text('156', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.appColors.primary)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Study Groups', style: TextStyle(fontSize: 12, color: context.appColors.textSecondary)),
                Text('89', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.appColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sarah posted in CS 101',
                    style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mike joined Study Group',
                    style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'New assignment posted',
                    style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyGroupsCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CS Finals Prep',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.appColors.textPrimary),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '12 members',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Math Study Group',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.appColors.textPrimary),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '8 members',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Study groups feature coming soon!')),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 14, color: context.appColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Join More Groups',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}