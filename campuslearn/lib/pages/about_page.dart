import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About CampusLearn'),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo/Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 60,
                  color: context.appColors.primary,
                ),
              ),
            ),
            SizedBox(height: 24),

            // App Name and Version
            Center(
              child: Column(
                children: [
                  Text(
                    'CampusLearn',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // What is CampusLearn
            _buildSectionTitle(context, 'What is CampusLearn?'),
            SizedBox(height: 12),
            _buildInfoCard(
              context,
              'CampusLearn is a comprehensive learning platform designed to connect students with tutors and peers. Our platform facilitates seamless communication, knowledge sharing, and academic support within your campus community.',
            ),
            SizedBox(height: 24),

            // Features
            _buildSectionTitle(context, 'Key Features'),
            SizedBox(height: 12),
            _buildFeatureItem(context, Icons.forum, 'Discussion Forums',
              'Engage in topic-based discussions and share knowledge with your peers.'),
            SizedBox(height: 12),
            _buildFeatureItem(context, Icons.help_outline, 'Help Tickets',
              'Submit questions and get personalized help from qualified tutors.'),
            SizedBox(height: 12),
            _buildFeatureItem(context, Icons.message, 'Direct Messaging',
              'Connect directly with tutors and classmates through private messages.'),
            SizedBox(height: 12),
            _buildFeatureItem(context, Icons.notifications, 'Real-time Notifications',
              'Stay updated with instant notifications for replies, likes, and new content.'),
            SizedBox(height: 12),
            _buildFeatureItem(context, Icons.search, 'Smart Search',
              'Quickly find relevant posts, users, and discussions.'),
            SizedBox(height: 24),

            // Mission
            _buildSectionTitle(context, 'Our Mission'),
            SizedBox(height: 12),
            _buildInfoCard(
              context,
              'We believe in fostering a collaborative learning environment where students can thrive. Our mission is to break down barriers to knowledge and create a supportive academic community where every question finds an answer.',
            ),
            SizedBox(height: 24),

            // Contact/Support
            _buildSectionTitle(context, 'Get in Touch'),
            SizedBox(height: 12),
            _buildContactItem(context, Icons.email, 'support@campuslearn.com'),
            SizedBox(height: 8),
            _buildContactItem(context, Icons.language, 'www.campuslearn.com'),
            SizedBox(height: 32),

            // Copyright
            Center(
              child: Text(
                '© 2024 CampusLearn. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
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

  Widget _buildInfoCard(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: context.appColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: context.appColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.appColors.primary,
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}