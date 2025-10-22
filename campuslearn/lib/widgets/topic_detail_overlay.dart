import 'package:flutter/material.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/models/comment.dart';
import 'package:campuslearn/services/comment_service.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/subscription_service.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/pages/user_profile_page.dart';

class TopicDetailOverlay extends StatefulWidget {
  final Topic topic;
  final VoidCallback? onTopicUpdated;

  const TopicDetailOverlay({
    super.key,
    required this.topic,
    this.onTopicUpdated,
  });

  @override
  State<TopicDetailOverlay> createState() => _TopicDetailOverlayState();
}

class _TopicDetailOverlayState extends State<TopicDetailOverlay> {
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;
  bool _isCurrentUserTutor = false;
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  // Local state for topic like status
  late bool _isLiked;
  late int _likeCount;

  // Local state for subscription status
  bool _isSubscribed = false;
  bool _isLoadingSubscription = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.topic.isLiked;
    _likeCount = widget.topic.likeCount;
    _loadComments();
    _checkTutorStatus();
    _checkSubscriptionStatus();
  }

  Future<void> _checkTutorStatus() async {
    final isTutor = await AuthService.isTutor();
    if (mounted) {
      setState(() {
        _isCurrentUserTutor = isTutor;
      });
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final isSubscribed = await SubscriptionService.isSubscribed(
        subscribableType: 1, // 1 = Topic
        subscribableId: widget.topic.id,
      );

      if (mounted) {
        setState(() {
          _isSubscribed = isSubscribed;
        });
      }
    } catch (e) {
      print('Error checking subscription status: $e');
    }
  }

  Future<void> _toggleSubscription() async {
    if (_isLoadingSubscription) return;
    if (!mounted) return;

    print('[TOPIC OVERLAY] Toggle subscription called. Current state: $_isSubscribed');

    if (mounted) {
      setState(() {
        _isLoadingSubscription = true;
      });
    }

    try {
      final newSubscriptionStatus = await SubscriptionService.toggleSubscription(
        subscribableType: 1, // 1 = Topic
        subscribableId: widget.topic.id,
        currentlySubscribed: _isSubscribed,
      );

      print('[TOPIC OVERLAY] New subscription status: $newSubscriptionStatus');

      if (mounted) {
        setState(() {
          _isSubscribed = newSubscriptionStatus;
          _isLoadingSubscription = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _isSubscribed ? Icons.notifications_active : Icons.notifications_off,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(_isSubscribed
                  ? 'Subscribed! You\'ll be notified of new comments'
                  : 'Unsubscribed from notifications'),
              ],
            ),
            backgroundColor: _isSubscribed ? Colors.green : Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('[TOPIC OVERLAY ERROR] Failed to toggle subscription: $e');

      if (mounted) {
        setState(() {
          _isLoadingSubscription = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subscription: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingComments = true;
        });
      }

      final comments = await CommentService.getCommentsByTopic(widget.topic.id);
      
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _comments = [];
          _isLoadingComments = false;
        });
      }

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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmittingComment = true;
      });
    }

    try {
      final userEmail = await AuthService.getUserEmail() ?? 'user@campus.edu';
      final userData = await AuthService.getUserDataFromToken();
      final userName = userData?['email']?.split('@')[0] ?? 'Student';

      final newComment = await CommentService.createComment(
        topicId: widget.topic.id,
        content: _commentController.text,
        authorName: userName,
        authorEmail: userEmail,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Comment added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      widget.onTopicUpdated?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Failed to add comment: ${e.toString()}')),
              ],
            ),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> _toggleTopicLike() async {
    // Optimistically update UI
    final wasLiked = _isLiked;
    final previousCount = _likeCount;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);
    });

    try {
      await TopicService.toggleLike(widget.topic.id);

      if (mounted) {
        // Notify parent to refresh the topic list
        widget.onTopicUpdated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? 'Added to likes' : 'Removed from likes'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = previousCount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    try {
      final isLiked = await CommentService.toggleLike(comment.id);

      if (mounted) {
        setState(() {
          final index = _comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            // Update the comment with new like status
            final oldComment = _comments[index];
            _comments[index] = oldComment.copyWith(
              isLiked: isLiked,
              likeCount: isLiked
                ? oldComment.likeCount + 1
                : (oldComment.likeCount > 0 ? oldComment.likeCount - 1 : 0),
            );
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

  Future<void> _deleteComment(Comment comment) async {
    if (!_isCurrentUserTutor) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment? This action cannot be undone.'),
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
        await CommentService.deleteComment(comment.id);
        
        // Remove from local list
        if (mounted) {
          setState(() {
            _comments.removeWhere((c) => c.id == comment.id);
          });
        }
        
        widget.onTopicUpdated?.call(); // Refresh parent
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete comment: $e'),
              backgroundColor: context.appColors.error,
            ),
          );
        }
      }
    }
  }

  double _getOverlayWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth;
    } else if (screenWidth < 900) {
      return 600;
    } else {
      return 700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobile ? EdgeInsets.zero : EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getOverlayWidth(context),
            maxHeight: MediaQuery.of(context).size.height * (isMobile ? 1.0 : 0.9),
          ),
          child: Material(
            borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.background,
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Topic Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.appColors.textSecondary),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  Divider(height: 1, color: context.appColors.border),
                  
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic content
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Author info
                                GestureDetector(
                                  onTap: widget.topic.authorId != null && !widget.topic.isAnonymous
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserProfilePage(
                                                userId: widget.topic.authorId!,
                                                userName: widget.topic.authorDisplayName,
                                                userEmail: widget.topic.authorEmail,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: context.appColors.primary,
                                        child: Text(
                                          widget.topic.authorDisplayName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                                                Flexible(
                                                  child: Text(
                                                    widget.topic.authorDisplayName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: widget.topic.isAnonymous
                                                          ? context.appColors.textPrimary
                                                          : context.appColors.primary,
                                                      fontSize: 16,
                                                      decoration: widget.topic.isAnonymous
                                                          ? TextDecoration.none
                                                          : TextDecoration.underline,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (widget.topic.authorEmail == 'tutor@campus.edu') ...[
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
                                              widget.topic.timeAgo,
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
                                
                                SizedBox(height: 16),
                                
                                // Topic title
                                Text(
                                  widget.topic.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                
                                // Topic content (full content, not preview)
                                Text(
                                  widget.topic.content,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.appColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                
                                SizedBox(height: 16),

                                // Topic stats and actions
                                Row(
                                  children: [
                                    // Like button
                                    GestureDetector(
                                      onTap: _toggleTopicLike,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 18,
                                            color: _isLiked ? Colors.red : context.appColors.textLight,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _likeCount.toString(),
                                            style: TextStyle(
                                              color: _isLiked ? Colors.red : context.appColors.textLight,
                                              fontWeight: _isLiked ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.comment_outlined, size: 18, color: context.appColors.textLight),
                                    SizedBox(width: 4),
                                    Text('${_comments.length}', style: TextStyle(color: context.appColors.textLight)),
                                    SizedBox(width: 16),
                                    Spacer(),
                                    // Subscribe button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _isLoadingSubscription ? null : _toggleSubscription,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _isSubscribed
                                                ? context.appColors.primary.withOpacity(0.1)
                                                : context.appColors.surface,
                                            border: Border.all(
                                              color: _isSubscribed
                                                  ? context.appColors.primary
                                                  : context.appColors.border,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isLoadingSubscription)
                                                SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      context.appColors.primary,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  _isSubscribed
                                                      ? Icons.notifications_active
                                                      : Icons.notifications_none,
                                                  size: 16,
                                                  color: _isSubscribed
                                                      ? context.appColors.primary
                                                      : context.appColors.textSecondary,
                                                ),
                                              SizedBox(width: 6),
                                              Text(
                                                _isSubscribed ? 'Subscribed' : 'Subscribe',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: _isSubscribed
                                                      ? context.appColors.primary
                                                      : context.appColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Divider(color: context.appColors.border),
                          
                          // Comments section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Comments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '(${_comments.length})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (_isLoadingComments)
                            Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
                                ),
                              ),
                            )
                          else if (_comments.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 48,
                                      color: context.appColors.textLight,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.appColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Be the first to share your thoughts!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.appColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: context.appColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.appColors.border,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Comment header
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: context.appColors.primary,
                                            child: Text(
                                              comment.authorDisplayName[0].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        comment.authorDisplayName,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: context.appColors.textPrimary,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (comment.authorEmail == 'tutor@campus.edu') ...[
                                                      SizedBox(width: 6),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          'Tutor',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 8,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                Text(
                                                  comment.timeAgo,
                                                  style: TextStyle(
                                                    color: context.appColors.textLight,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      
                                      // Comment content
                                      Text(
                                        comment.content,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: context.appColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      // Comment actions
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _toggleCommentLike(comment),
                                            child: Row(
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
                                                    fontSize: 12,
                                                    fontWeight: comment.isLiked ? FontWeight.w500 : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_isCurrentUserTutor) ...[
                                            SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () => _deleteComment(comment),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    size: 16,
                                                    color: Colors.red.withOpacity(0.7),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red.withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  
                  Divider(height: 1, color: context.appColors.border),
                  
                  // Comment input
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.appColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.appColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.appColors.primary, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: context.appColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: _isSubmittingComment
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(Icons.send, color: Colors.white),
                            onPressed: _isSubmittingComment ? null : _submitComment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}