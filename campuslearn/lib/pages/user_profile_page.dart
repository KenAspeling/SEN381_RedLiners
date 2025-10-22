import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/message_service.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/models/message.dart';
import 'package:campuslearn/pages/message_page.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final String? userName; // Optional - will be loaded if not provided
  final String? userEmail; // Optional - will be loaded if not provided

  const UserProfilePage({
    super.key,
    required this.userId,
    this.userName,
    this.userEmail,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _userData;
  List<Topic> _userTopics = [];
  bool _isLoading = true;
  bool _isLoadingTopics = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserTopics();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await AuthService.getUserById(widget.userId);

      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserTopics() async {
    try {
      setState(() {
        _isLoadingTopics = true;
      });

      final email = _userData?['email'] ?? widget.userEmail ?? '';
      if (email.isNotEmpty) {
        final topics = await TopicService.getTopicsByUser(email);

        if (mounted) {
          setState(() {
            _userTopics = topics;
            _isLoadingTopics = false;
          });
        }
      } else {
        setState(() {
          _isLoadingTopics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTopics = false;
        });
      }
    }
  }

  Future<void> _startConversation() async {
    try {
      final userName = _userData?['name'] ?? widget.userName ?? 'User';
      final surname = _userData?['surname'] ?? '';
      final email = _userData?['email'] ?? widget.userEmail ?? '';

      final conversation = Conversation(
        userId: widget.userId,
        userName: '$userName $surname'.trim(),
        userEmail: email,
        unreadCount: 0,
      );

      // Navigate to message page with this conversation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(
              conversation: conversation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start conversation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _userData?['email'] ?? widget.userEmail ?? '';
    final accessLevel = _userData?['accessLevel'] ?? 1;
    String roleName = 'Student';
    if (accessLevel >= 3) {
      roleName = 'Admin';
    } else if (accessLevel >= 2) {
      roleName = 'Tutor';
    }

    final displayName = _userData != null
        ? '${_userData!['name'] ?? ''} ${_userData!['surname'] ?? ''}'.trim()
        : widget.userName ?? 'User';
    final displayNameWithRole = '$displayName ($roleName)';

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(displayName),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: context.appColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'User not found',
                        style: TextStyle(
                          fontSize: 18,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: context.appColors.primary,
                              radius: 50,
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              displayNameWithRole,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 16,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.appColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.appColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                roleName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Message Button
                            ElevatedButton.icon(
                              onPressed: _startConversation,
                              icon: Icon(Icons.message),
                              label: Text('Send Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.appColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // User Info
                      if (_userData!['degree'] != null || _userData!['yearOfStudy'] != null) ...[
                        Text(
                          'Academic Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12),
                        if (_userData!['degree'] != null)
                          _buildInfoRow(Icons.school, 'Degree', _userData!['degree']),
                        if (_userData!['yearOfStudy'] != null)
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Year of Study',
                            'Year ${_userData!['yearOfStudy']}',
                          ),
                        SizedBox(height: 24),
                      ],

                      // Topics/Posts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Topics & Posts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_userTopics.length} posts',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      if (_isLoadingTopics)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_userTopics.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No posts yet',
                              style: TextStyle(color: context.appColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _userTopics.length,
                          itemBuilder: (context, index) {
                            final topic = _userTopics[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  topic.title,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  topic.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite, size: 16, color: Colors.red),
                                    Text(
                                      topic.likeCount.toString(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.appColors.textSecondary),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
