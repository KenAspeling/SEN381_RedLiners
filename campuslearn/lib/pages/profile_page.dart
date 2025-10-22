import 'package:flutter/material.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/comment_service.dart';
import 'package:campuslearn/services/post_service.dart';
import 'package:campuslearn/theme/app_colors.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/widgets/left_sidebar.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';
import 'package:campuslearn/widgets/edit_profile_dialog.dart';
import 'package:campuslearn/main.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/models/comment.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _roleName = 'Student';
  String _firstName = '';
  String _surname = '';
  String? _phoneNumber;
  String? _degree;
  int? _yearOfStudy;
  List<Topic> _userTopics = [];
  List<Comment> _userComments = [];
  List<Topic> _likedTopics = [];
  List<Comment> _likedComments = [];
  bool _isLoadingTopics = true;
  bool _isLoadingComments = true;
  bool _isLoadingLiked = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _loadUserTopics();
    _loadUserComments();
    _loadLikedContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userIdString = await AuthService.getUserId();
      final userId = int.tryParse(userIdString ?? '0');

      if (userId != null && userId != 0) {
        final userData = await AuthService.getUserById(userId);

        if (userData != null) {
          // Try both camelCase and PascalCase field names
          final name = userData['name'] ?? userData['Name'] ?? '';
          final surname = userData['surname'] ?? userData['Surname'] ?? '';
          final email = userData['email'] ?? userData['Email'] ?? 'user@campus.edu';
          final accessLevelName = userData['accessLevelName'] ?? userData['AccessLevelName'] ?? 'Student';
          final phoneNumber = userData['phoneNumber'] ?? userData['PhoneNumber'];
          final degree = userData['degree'] ?? userData['Degree'];
          final yearOfStudy = userData['yearOfStudy'] ?? userData['YearOfStudy'];

          // Capitalize first letter of role name
          final roleName = accessLevelName.isNotEmpty
              ? accessLevelName[0].toUpperCase() + accessLevelName.substring(1).toLowerCase()
              : 'Student';

          setState(() {
            _userName = '$name $surname'.trim();
            _userEmail = email;
            _roleName = roleName;
            _firstName = name;
            _surname = surname;
            _phoneNumber = phoneNumber;
            _degree = degree;
            _yearOfStudy = yearOfStudy is int ? yearOfStudy : (yearOfStudy != null ? int.tryParse(yearOfStudy.toString()) : null);
          });

          print('Profile loaded - Name: $name, Surname: $surname, Role: $roleName');
        } else {
          // Fallback to basic data
          final email = await AuthService.getUserEmail();
          setState(() {
            _userEmail = email ?? 'user@campus.edu';
            _userName = email?.split('@')[0] ?? 'User';
            _roleName = 'Student';
          });
        }
      } else {
        // Fallback to basic data
        final email = await AuthService.getUserEmail();
        setState(() {
          _userEmail = email ?? 'user@campus.edu';
          _userName = email?.split('@')[0] ?? 'User';
          _roleName = 'Student';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      final email = await AuthService.getUserEmail();
      setState(() {
        _userEmail = email ?? 'user@campus.edu';
        _userName = email?.split('@')[0] ?? 'User';
        _roleName = 'Student';
      });
    }
  }

  Future<void> _loadUserTopics() async {
    try {
      setState(() {
        _isLoadingTopics = true;
      });
      
      final email = await AuthService.getUserEmail() ?? 'user@campus.edu';
      final topics = await TopicService.getTopicsByUser(email);
      
      setState(() {
        _userTopics = topics;
        _isLoadingTopics = false;
      });
    } catch (e) {
      setState(() {
        _userTopics = [];
        _isLoadingTopics = false;
      });
      
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

  Future<void> _loadUserComments() async {
    try {
      setState(() {
        _isLoadingComments = true;
      });
      
      final email = await AuthService.getUserEmail() ?? 'user@campus.edu';
      final comments = await CommentService.getCommentsByUser(email);
      
      setState(() {
        _userComments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _userComments = [];
        _isLoadingComments = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshTopics() async {
    await _loadUserTopics();
  }

  Future<void> _refreshComments() async {
    await _loadUserComments();
  }

  Future<void> _loadLikedContent() async {
    try {
      setState(() {
        _isLoadingLiked = true;
      });

      // Get liked topics and comments from backend
      final likedTopics = await PostService.getLikedTopics();
      final likedComments = await PostService.getLikedComments();

      setState(() {
        _likedTopics = likedTopics;
        _likedComments = likedComments;
        _isLoadingLiked = false;
      });
    } catch (e) {
      setState(() {
        _likedTopics = [];
        _likedComments = [];
        _isLoadingLiked = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load liked content: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshLiked() async {
    await _loadLikedContent();
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

  // Check if screen is desktop size
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  void _openTopicDetail(Topic topic) {
    showDialog(
      context: context,
      builder: (context) => TopicDetailOverlay(
        topic: topic,
        onTopicUpdated: () {
          // Refresh the user's topics, comments and liked content
          _loadUserTopics();
          _loadUserComments();
          _loadLikedContent();
        },
      ),
    );
  }

  Future<void> _openTopicDetailFromComment(int topicId) async {
    try {
      final topic = await TopicService.getTopicById(topicId);
      if (topic != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => TopicDetailOverlay(
            topic: topic,
            onTopicUpdated: () {
              // Refresh the user's topics and comments when comments are added
              _loadUserTopics();
              _loadUserComments();
            },
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Topic not found or may have been deleted'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load topic: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // AppBar styling now comes from theme
      ),
      body: isDesktop
        ? Row(
            children: [
              // Left sidebar with navigation
              LeftSidebar(
                selectedIndex: -1, // No main nav item selected on profile page
                hideProfileButton: true, // Hide "View Profile" button since we're on profile page
                onNavigationTap: (index) {
                  // Navigate back to main screen
                  Navigator.of(context).pop();
                },
              ),
              // Main content
              Expanded(
                child: _buildProfileContent(context),
              ),
            ],
          )
        : _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Column(
      children: [
          // Profile Header
          Container(
            color: context.appColors.primary,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // Profile Picture and Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: context.appColors.background,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$_userName ($_roleName)',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.background,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => EditProfileDialog(
                                        currentName: _firstName,
                                        currentSurname: _surname,
                                        currentPhoneNumber: _phoneNumber,
                                        currentDegree: _degree,
                                        currentYearOfStudy: _yearOfStudy,
                                      ),
                                    );

                                    // Reload user data if profile was updated
                                    if (result == true) {
                                      _loadUserData();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: context.appColors.primaryOverlay,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: context.appColors.background,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Stats Row
                            Row(
                              children: [
                                _buildStatItem('Topics', _userTopics.length.toString()),
                                SizedBox(width: 20),
                                _buildStatItem('Comments', _userComments.length.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Tab Bar
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _getContentWidth(context) - 40, // Account for margin
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 45,
                      decoration: BoxDecoration(
                        color: context.appColors.background,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: context.appColors.primaryDark,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: context.appColors.textOnPrimary,
                        unselectedLabelColor: context.appColors.primaryLight,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                        tabs: [
                          Container(
                            height: 45,
                            alignment: Alignment.center,
                            child: Text('Topics'),
                          ),
                          Container(
                            height: 45,
                            alignment: Alignment.center,
                            child: Text('Comments'),
                          ),
                          Container(
                            height: 45,
                            alignment: Alignment.center,
                            child: Text('Liked'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopicsList(),
                _buildCommentsList(),
                _buildLikedContent(),
              ],
            ),
          ),
        ],
      );
    }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.appColors.background,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.appColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsList() {
    if (_isLoadingTopics) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
          ),
        ),
      );
    }

    if (_userTopics.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.topic,
                size: 64,
                color: context.appColors.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'No topics yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first topic to share with the campus community!',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textLight,
                ),
                textAlign: TextAlign.center,
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
            itemCount: _userTopics.length,
            itemBuilder: (context, index) {
            final topic = _userTopics[index];
            return GestureDetector(
              onTap: () => _openTopicDetail(topic),
              child: Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    SizedBox(height: 12),
                    // Topic stats and actions
                    Row(
                      children: [
                        // Like button with state
                        Icon(
                          topic.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16, 
                          color: topic.isLiked ? Colors.red : context.appColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          topic.formattedLikeCount, 
                          style: TextStyle(color: context.appColors.textLight),
                        ),
                        SizedBox(width: 16),
                        // Comment count
                        Icon(Icons.comment_outlined, size: 16, color: context.appColors.textLight),
                        SizedBox(width: 4),
                        Text(
                          topic.formattedCommentCount, 
                          style: TextStyle(color: context.appColors.textLight),
                        ),
                        SizedBox(width: 16),
                        // View count
                        Icon(Icons.visibility_outlined, size: 16, color: context.appColors.textLight),
                        SizedBox(width: 4),
                        Text(
                          topic.formattedViewCount, 
                          style: TextStyle(color: context.appColors.textLight),
                        ),
                        Spacer(),
                        // Time ago
                        Text(
                          topic.timeAgo,
                          style: TextStyle(fontSize: 12, color: context.appColors.textLight),
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

  Widget _buildCommentsList() {
    if (_isLoadingComments) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
          ),
        ),
      );
    }

    if (_userComments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 64,
                color: context.appColors.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your comments on topics will appear here!',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textLight,
                ),
                textAlign: TextAlign.center,
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
          onRefresh: _refreshComments,
          color: context.appColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _userComments.length,
            itemBuilder: (context, index) {
              final comment = _userComments[index];
              return FutureBuilder<Topic?>(
                future: TopicService.getTopicById(comment.topicId),
                builder: (context, snapshot) {
                  final topicTitle = snapshot.data?.title ?? 'Unknown Topic';
                  
                  return GestureDetector(
                    onTap: () => _openTopicDetailFromComment(comment.topicId),
                    child: Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'On: $topicTitle',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              comment.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.appColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: comment.isLiked ? Colors.red : context.appColors.textLight,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  comment.formattedLikeCount,
                                  style: TextStyle(
                                    color: comment.isLiked ? Colors.red : context.appColors.textLight,
                                    fontWeight: comment.isLiked ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  comment.timeAgo,
                                  style: TextStyle(fontSize: 12, color: context.appColors.textLight),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLikedContent() {
    if (_isLoadingLiked) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
          ),
        ),
      );
    }

    final hasLikedContent = _likedTopics.isNotEmpty || _likedComments.isNotEmpty;

    if (!hasLikedContent) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 64,
                color: context.appColors.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'No liked content yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Topics and comments you like will appear here!',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textLight,
                ),
                textAlign: TextAlign.center,
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
          onRefresh: _refreshLiked,
          color: context.appColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _likedTopics.length + _likedComments.length,
            itemBuilder: (context, index) {
              // Display liked posts first, then liked comments
              if (index < _likedTopics.length) {
                // Build liked topic card
                final topic = _likedTopics[index];
                return GestureDetector(
                  onTap: () => _openTopicDetail(topic),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic type indicator
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryLight.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.article, size: 14, color: context.appColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Topic',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.appColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text(
                                topic.timeAgo,
                                style: TextStyle(fontSize: 12, color: context.appColors.textLight),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Author info
                          Text(
                            'By ${topic.authorDisplayName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Topic title
                          Text(
                            topic.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Topic preview
                          Text(
                            topic.isLongTopic ? topic.contentPreview : topic.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.appColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Stats
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text(topic.formattedLikeCount, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                              SizedBox(width: 16),
                              Icon(Icons.comment_outlined, size: 16, color: context.appColors.textLight),
                              SizedBox(width: 4),
                              Text(topic.formattedCommentCount, style: TextStyle(color: context.appColors.textLight)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Build liked comment card
                final commentIndex = index - _likedTopics.length;
                final comment = _likedComments[commentIndex];
                
                return FutureBuilder<Topic?>(
                  future: TopicService.getTopicById(comment.topicId),
                  builder: (context, snapshot) {
                    final topicTitle = snapshot.data?.title ?? 'Unknown Topic';
                    
                    return GestureDetector(
                      onTap: () => _openTopicDetailFromComment(comment.topicId),
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Comment type indicator
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.appColors.primaryLight.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.comment, size: 14, color: context.appColors.primary),
                                        SizedBox(width: 4),
                                        Text(
                                          'Comment',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.appColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    comment.timeAgo,
                                    style: TextStyle(fontSize: 12, color: context.appColors.textLight),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Topic reference
                              Text(
                                'On: $topicTitle',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Comment content
                              Text(
                                comment.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.appColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 12),
                              // Author and stats
                              Row(
                                children: [
                                  Text(
                                    'By ${comment.authorDisplayName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.appColors.textSecondary,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.favorite, size: 16, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text(
                                    comment.formattedLikeCount,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
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
                );
              }
            },
          ),
        ),
      ),
    );
  }
}