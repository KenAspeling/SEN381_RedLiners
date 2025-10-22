import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.appColors.primary, context.appColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions and learn how to use CampusLearn',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Getting Started
            _buildSectionTitle(context, 'Getting Started'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'How do I create an account?',
              'Click the "Register" button on the login page and fill in your details. Make sure to use your @belgiumcampus.ac.za email address.',
              Icons.person_add,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'How do I update my profile?',
              'Navigate to your profile page and click the edit icon next to your name. You can update your personal information, degree, and year of study.',
              Icons.edit,
            ),
            SizedBox(height: 24),

            // Using Forums
            _buildSectionTitle(context, 'Discussion Forums'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'How do I create a new topic?',
              'Navigate to the "Create" tab in the main menu. Fill in the title, select your module, and write your question or discussion point.',
              Icons.add_circle,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'How do I comment on a topic?',
              'Click on any topic to open its detail view. Scroll to the bottom and use the comment box to add your response.',
              Icons.comment,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'Can I filter topics by module?',
              'Yes! On the home page, use the filter chips at the top to select specific modules or filter between topics and posts.',
              Icons.filter_list,
            ),
            SizedBox(height: 24),

            // Help Tickets
            _buildSectionTitle(context, 'Help Tickets'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'What is a help ticket?',
              'Help tickets allow you to submit specific questions to tutors. Your question will be assigned to a qualified tutor who will provide personalized assistance.',
              Icons.help_center,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'How do I submit a help ticket?',
              'Go to the "Query" tab, click the "+" button, select your module, and describe your question in detail. Tutors will be notified and can claim your ticket.',
              Icons.assignment,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'How long does it take to get a response?',
              'Response times vary depending on tutor availability, but most tickets are answered within 24 hours. Urgent tickets are prioritized.',
              Icons.schedule,
            ),
            SizedBox(height: 24),

            // Messaging
            _buildSectionTitle(context, 'Messaging'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'How do I message someone?',
              'Click on a user\'s name anywhere in the app to view their profile, then click the message icon to start a conversation.',
              Icons.message,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'Are my messages private?',
              'Yes, all direct messages are private and can only be seen by you and the recipient.',
              Icons.lock,
            ),
            SizedBox(height: 24),

            // Notifications
            _buildSectionTitle(context, 'Notifications'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'What notifications will I receive?',
              'You\'ll be notified when someone likes or comments on your posts, responds to your help tickets, or sends you a direct message.',
              Icons.notifications_active,
            ),
            SizedBox(height: 12),
            _buildHelpItem(
              context,
              'How do I view my notifications?',
              'Click the bell icon in the navigation bar to see all your notifications. Unread notifications are highlighted.',
              Icons.notifications,
            ),
            SizedBox(height: 24),

            // Search
            _buildSectionTitle(context, 'Search'),
            SizedBox(height: 16),
            _buildHelpItem(
              context,
              'How does search work?',
              'Use the search icon to find topics, posts, and users. You can filter results by type using the filter chips.',
              Icons.search,
            ),
            SizedBox(height: 24),

            // Need More Help
            _buildSectionTitle(context, 'Still Need Help?'),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: context.appColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you couldn\'t find the answer you\'re looking for, reach out to our support team:',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, size: 18, color: context.appColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'support@campuslearn.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: context.appColors.textPrimary,
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, String question, String answer, IconData icon) {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: context.appColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        question,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: context.appColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      backgroundColor: context.appColors.surface,
      collapsedBackgroundColor: context.appColors.surface,
    );
  }
}