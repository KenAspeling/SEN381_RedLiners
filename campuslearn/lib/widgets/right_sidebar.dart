import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/pages/create_page.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: context.appColors.surface,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Quick Actions Section
          _buildSectionHeader(context, 'Quick Actions'),
          _buildQuickActionsCard(context),
          
          SizedBox(height: 24),
          
          // Trending Topics Section
          _buildSectionHeader(context, 'Trending Topics'),
          _buildTrendingTopicsCard(context),
          
          SizedBox(height: 24),
          
          // Notifications Preview Section
          _buildSectionHeader(context, 'Recent Notifications'),
          _buildNotificationsCard(context),
          
          SizedBox(height: 24),
          
          // Campus News Section
          _buildSectionHeader(context, 'Campus News'),
          _buildCampusNewsCard(context),
          
          SizedBox(height: 24),
          
          // Quick Links Section
          _buildSectionHeader(context, 'Quick Links'),
          _buildQuickLinksCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
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

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionButton(
              context,
              Icons.create,
              'Create Topic',
              context.appColors.primary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePage()),
                );
              },
            ),
            SizedBox(height: 12),
            _buildActionButton(
              context,
              Icons.group_add,
              'Join Study Group',
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Study groups feature coming soon!')),
                );
              },
            ),
            SizedBox(height: 12),
            _buildActionButton(
              context,
              Icons.message,
              'Send Message',
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Messaging feature coming soon!')),
                );
              },
            ),
            SizedBox(height: 12),
            _buildActionButton(
              context,
              Icons.event,
              'Create Event',
              Colors.orange,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Events feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTopicsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTrendingItem(context, '#FinalExams', '234 posts'),
            SizedBox(height: 8),
            _buildTrendingItem(context, '#DataStructures', '156 posts'),
            SizedBox(height: 8),
            _buildTrendingItem(context, '#StudyTips', '89 posts'),
            SizedBox(height: 8),
            _buildTrendingItem(context, '#CampusLife', '67 posts'),
            SizedBox(height: 8),
            _buildTrendingItem(context, '#TechInternships', '45 posts'),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trending topics feature coming soon!')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Trending',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: context.appColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(BuildContext context, String hashtag, String postCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hashtag,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.appColors.primary,
          ),
        ),
        Text(
          postCount,
          style: TextStyle(
            fontSize: 10,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildNotificationItem(
              context,
              Icons.favorite,
              'Sarah liked your post',
              '2m ago',
              Colors.red,
            ),
            SizedBox(height: 8),
            _buildNotificationItem(
              context,
              Icons.comment,
              'New comment on "Study Tips"',
              '5m ago',
              Colors.blue,
            ),
            SizedBox(height: 8),
            _buildNotificationItem(
              context,
              Icons.group,
              'Mike joined your study group',
              '1h ago',
              Colors.green,
            ),
            SizedBox(height: 8),
            _buildNotificationItem(
              context,
              Icons.assignment,
              'New assignment posted',
              '2h ago',
              Colors.orange,
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications page coming soon!')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Notifications',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: context.appColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, IconData icon, String message, String time, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: iconColor),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 9,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampusNewsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewsItem(
              context,
              'Spring Break Schedule Released',
              'Check the academic calendar for updated dates.',
            ),
            SizedBox(height: 12),
            _buildNewsItem(
              context,
              'New Library Hours',
              'Extended hours during finals week starting Monday.',
            ),
            SizedBox(height: 12),
            _buildNewsItem(
              context,
              'Tech Career Fair',
              'Register now for the upcoming career fair on April 15th.',
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Campus news feature coming soon!')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Read More News',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: context.appColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 10,
            color: context.appColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinksCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildQuickLink(context, Icons.help, 'Help & Support'),
            SizedBox(height: 8),
            _buildQuickLink(context, Icons.info, 'About Campus Learn'),
            SizedBox(height: 8),
            _buildQuickLink(context, Icons.settings, 'Settings'),
            SizedBox(height: 8),
            _buildQuickLink(context, Icons.feedback, 'Send Feedback'),
            SizedBox(height: 8),
            _buildQuickLink(context, Icons.privacy_tip, 'Privacy Policy'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label coming soon!')),
        );
      },
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.appColors.textSecondary),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}