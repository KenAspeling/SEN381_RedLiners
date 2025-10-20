import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Topic> _topics = [];
  bool _isLoading = true;
  bool _isCurrentUserTutor = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _checkTutorStatus();
  }

  Future<void> _checkTutorStatus() async {
    final isTutor = await AuthService.isTutor();
    if (mounted) {
      setState(() {
        _isCurrentUserTutor = isTutor;
      });
    }
  }

  Future<void> _loadTopics() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      
      final topics = await TopicService.getAllTopics();
      
      if (mounted) {
        setState(() {
          _topics = topics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _topics = [];
          _isLoading = false;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load topics: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshTopics() async {
    await _loadTopics();
  }

  Future<void> _toggleLike(Topic topic) async {
    try {
      final updatedTopic = await TopicService.toggleLike(topic.id);
      
      // Update the post in the list
      if (mounted) {
        setState(() {
          final index = _topics.indexWhere((t) => t.id == topic.id);
          if (index != -1) {
            _topics[index] = updatedTopic;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  // Calculate responsive content width
  double _getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth; // Full width on mobile
    } else if (screenWidth < 900) {
      return 600; // Tablet size
    } else {
      return 700; // Desktop max
    }
  }

  void _openTopicDetail(Topic topic) {
    showDialog(
      context: context,
      builder: (context) => TopicDetailOverlay(
        topic: topic,
        onTopicUpdated: () {
          // Refresh the topics when comments are added
          _loadTopics();
        },
      ),
    );
  }

  Future<void> _deleteTopic(Topic topic) async {
    if (!_isCurrentUserTutor) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Topic'),
        content: Text('Are you sure you want to delete this topic? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final tutorEmail = await AuthService.getUserEmail() ?? '';
        await TopicService.deleteTopicAsTutor(topic.id, tutorEmail);
        _loadTopics(); // Refresh the list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Topic deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete topic: $e'),
              backgroundColor: context.appColors.error,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Loading topics...',
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_topics.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 80,
                color: context.appColors.textLight,
              ),
              SizedBox(height: 24),
              Text(
                'Welcome to Campus Learn!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'No topics yet. Be the first to share something with the campus community!',
                style: TextStyle(
                  fontSize: 16,
                  color: context.appColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // This will switch to Create tab (index 1)
                  // You might want to add callback to parent widget to handle this
                },
                icon: Icon(Icons.add),
                label: Text('Create First Topic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getContentWidth(context),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshTopics,
          color: context.appColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              return GestureDetector(
                onTap: () => _openTopicDetail(topic),
                child: Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: topic.isAnnouncement 
                        ? BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topic header with author info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: context.appColors.primary,
                            child: Text(
                              topic.authorDisplayName[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      topic.authorDisplayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: context.appColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (topic.authorEmail == 'tutor@campus.edu') ...[
                                      SizedBox(width: 6),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Tutor',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  topic.timeAgo,
                                  style: TextStyle(
                                    color: context.appColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tutor action buttons
                          if (_isCurrentUserTutor) ...[
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () => _deleteTopic(topic),
                              tooltip: 'Delete topic',
                            ),
                          ] else ...[
                            IconButton(
                              icon: Icon(Icons.more_vert, color: context.appColors.textLight),
                              onPressed: () {
                                // TODO: Show post menu (report, share, etc.)
                              },
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Topic title
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Topic content (with preview for long topics)
                      Text(
                        topic.isLongTopic ? topic.contentPreview : topic.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (topic.isLongTopic)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: GestureDetector(
                            onTap: () => _openTopicDetail(topic),
                            child: Text(
                              'Read more...',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      
                      SizedBox(height: 16),
                      
                      // Topic stats and actions
                      Row(
                        children: [
                          // Like button
                          GestureDetector(
                            onTap: () => _toggleLike(topic),
                            child: Row(
                              children: [
                                Icon(
                                  topic.isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 20, 
                                  color: topic.isLiked ? Colors.red : context.appColors.textLight,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  topic.formattedLikeCount, 
                                  style: TextStyle(
                                    color: topic.isLiked ? Colors.red : context.appColors.textLight,
                                    fontWeight: topic.isLiked ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: 24),
                          
                          // Comment button
                          GestureDetector(
                            onTap: () => _openTopicDetail(topic),
                            child: Row(
                              children: [
                                Icon(Icons.comment_outlined, size: 20, color: context.appColors.textLight),
                                SizedBox(width: 4),
                                Text(
                                  topic.formattedCommentCount, 
                                  style: TextStyle(color: context.appColors.textLight),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: 24),
                          
                          // Share button
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement share functionality
                            },
                            child: Row(
                              children: [
                                Icon(Icons.share_outlined, size: 20, color: context.appColors.textLight),
                                SizedBox(width: 4),
                                Text(
                                  'Share', 
                                  style: TextStyle(color: context.appColors.textLight),
                                ),
                              ],
                            ),
                          ),
                          
                          Spacer(),
                          
                          // View count
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 16, color: context.appColors.textLight),
                              SizedBox(width: 4),
                              Text(
                                topic.formattedViewCount, 
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: context.appColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ),
    );
  }
}