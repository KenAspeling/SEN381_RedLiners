import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';
import 'package:campuslearn/pages/user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Topic> _topics = [];
  bool _isLoading = true;
  bool _isCurrentUserAdmin = false;
  String _selectedFilter = 'All'; // All, Topics, Posts
  String? _selectedModule; // Filter by specific module

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AuthService.isAdmin();
    if (mounted) {
      setState(() {
        _isCurrentUserAdmin = isAdmin;
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

  List<Topic> _getFilteredTopics() {
    var filtered = _topics;

    // Filter by type (Topics vs Posts)
    if (_selectedFilter == 'Topics') {
      filtered = filtered.where((topic) => topic.type == 3).toList(); // Type 3 = Topic
    } else if (_selectedFilter == 'Posts') {
      filtered = filtered.where((topic) => topic.type == 2).toList(); // Type 2 = Post
    }

    // Filter by module if selected
    if (_selectedModule != null && _selectedModule!.isNotEmpty) {
      filtered = filtered.where((topic) => topic.moduleName == _selectedModule).toList();
    }

    return filtered;
  }

  Set<String> _getAvailableModules() {
    return _topics
        .where((topic) => topic.moduleName != null)
        .map((topic) => topic.moduleName!)
        .toSet();
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
    if (!_isCurrentUserAdmin) return;

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

    final filteredTopics = _getFilteredTopics();
    final availableModules = _getAvailableModules();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getContentWidth(context),
        ),
        child: Column(
          children: [
            // Filter chips
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                border: Border(
                  bottom: BorderSide(color: context.appColors.border, width: 1),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildFilterChip('All', _topics.length),
                  SizedBox(width: 8),
                  _buildFilterChip('Topics', _topics.where((t) => t.type == 3).length),
                  SizedBox(width: 8),
                  _buildFilterChip('Posts', _topics.where((t) => t.type == 2).length),
                  if (availableModules.isNotEmpty) ...[
                    SizedBox(width: 16),
                    Container(
                      width: 1,
                      color: context.appColors.border,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    SizedBox(width: 16),
                    ...availableModules.map((module) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _buildModuleChip(module),
                    )),
                  ],
                ],
              ),
            ),
            // Topics list
            Expanded(
              child: filteredTopics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: context.appColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No $_selectedFilter found',
                            style: TextStyle(
                              fontSize: 16,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTopics,
                      color: context.appColors.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredTopics.length,
                        itemBuilder: (context, index) {
                          final topic = filteredTopics[index];
              return GestureDetector(
                onTap: () => _openTopicDetail(topic),
                child: Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: topic.isAnnouncement ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: topic.isAnnouncement
                        ? BorderSide(color: context.appColors.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topic badge for announcements
                      if (topic.isAnnouncement)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [context.appColors.primary, context.appColors.primaryDark],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.appColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.campaign,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'TOPIC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [context.appColors.primary, context.appColors.primaryDark],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.appColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        topic.moduleName ?? "General",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Topic header with author info
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: topic.authorId != null && !topic.isAnonymous
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfilePage(
                                            userId: topic.authorId!,
                                            userName: topic.authorDisplayName,
                                            userEmail: topic.authorEmail,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Row(
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
                                                decoration: topic.isAnonymous
                                                    ? TextDecoration.none
                                                    : TextDecoration.underline,
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
                                ],
                              ),
                            ),
                          ),
                          // Admin action buttons
                          if (_isCurrentUserAdmin) ...[
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () => _deleteTopic(topic),
                              tooltip: 'Delete topic',
                            ),
                          ]
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
            ],
          ),
        ),
      );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : context.appColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.appColors.primary : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
          _selectedModule = null; // Clear module filter when changing type filter
        });
      },
      selectedColor: context.appColors.primary.withOpacity(0.2),
      checkmarkColor: context.appColors.primary,
    );
  }

  Widget _buildModuleChip(String module) {
    final isSelected = _selectedModule == module;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book, size: 14, color: isSelected ? Colors.white : context.appColors.primary),
          SizedBox(width: 4),
          Text(module),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedModule = module;
          } else {
            _selectedModule = null;
          }
        });
      },
      selectedColor: context.appColors.primary,
      backgroundColor: context.appColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.appColors.textPrimary,
      ),
      checkmarkColor: Colors.white,
    );
  }
}