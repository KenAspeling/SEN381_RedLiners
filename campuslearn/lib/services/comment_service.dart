import 'package:campuslearn/models/comment.dart';
import 'package:campuslearn/services/topic_service.dart';

class CommentService {
  static List<Comment> _mockComments = [
    Comment(
      id: 1,
      topicId: 1,
      content: 'Great explanation! This really helped me understand neural networks better.',
      authorName: 'Sarah Chen',
      authorEmail: 'sarah.chen@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(Duration(hours: 1)),
      likeCount: 5,
      isLiked: false,
    ),
    Comment(
      id: 2,
      topicId: 1,
      content: 'I had the same questions! Thanks for sharing this resource.',
      authorName: 'Mike Rodriguez',
      authorEmail: 'mike.rodriguez@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(Duration(hours: 3)),
      likeCount: 2,
      isLiked: true,
    ),
    Comment(
      id: 3,
      topicId: 2,
      content: 'I\'ll be there! Looking forward to the AI workshop.',
      authorName: 'Alex Kim',
      authorEmail: 'alex.kim@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 4)),
      updatedAt: DateTime.now().subtract(Duration(hours: 4)),
      likeCount: 8,
      isLiked: false,
    ),
    Comment(
      id: 4,
      topicId: 2,
      content: 'Same here! Anyone know if we need to register in advance?',
      authorName: 'Emma Johnson',
      authorEmail: 'emma.johnson@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(Duration(hours: 6)),
      likeCount: 3,
      isLiked: false,
    ),
    Comment(
      id: 5,
      topicId: 3,
      content: 'Have you considered using foreign keys for better data integrity?',
      authorName: 'David Wilson',
      authorEmail: 'david.wilson@campus.edu',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      likeCount: 12,
      isLiked: true,
    ),
    Comment(
      id: 6,
      topicId: 1,
      content: 'This is really helpful! I was struggling with recursion.',
      authorName: 'Student User',
      authorEmail: 'user@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(Duration(hours: 5)),
      likeCount: 3,
      isLiked: false,
    ),
    Comment(
      id: 7,
      topicId: 2,
      content: 'Count me in for the study group! I need help with algorithms.',
      authorName: 'Student User',
      authorEmail: 'user@campus.edu',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      likeCount: 1,
      isLiked: false,
    ),
    Comment(
      id: 8,
      topicId: 2,
      content: 'Great initiative! I recommend focusing on dynamic programming and graph algorithms. These are crucial for the exam.',
      authorName: 'Prof. Dr. Smith',
      authorEmail: 'tutor@campus.edu',
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(Duration(hours: 12)),
      likeCount: 15,
      isLiked: false,
    ),
  ];

  static int _nextCommentId = 9;

  static Future<List<Comment>> getCommentsByTopic(int topicId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final topicComments = _mockComments.where((comment) => comment.topicId == topicId).toList();
    topicComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return topicComments;
  }

  static Future<Comment> createComment({
    required int topicId,
    required String content,
    required String authorName,
    required String authorEmail,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    if (content.trim().isEmpty) {
      throw Exception('Comment content cannot be empty');
    }

    if (content.trim().length < 3) {
      throw Exception('Comment must be at least 3 characters long');
    }

    final now = DateTime.now();
    final newComment = Comment(
      id: _nextCommentId++,
      topicId: topicId,
      content: content.trim(),
      authorName: authorName,
      authorEmail: authorEmail,
      createdAt: now,
      updatedAt: now,
      likeCount: 0,
      isLiked: false,
    );

    _mockComments.add(newComment);
    
    // Update the topic's comment count
    await TopicService.incrementCommentCount(topicId);
    
    return newComment;
  }

  static Future<Comment> toggleLike(int commentId) async {
    await Future.delayed(Duration(milliseconds: 200));

    final commentIndex = _mockComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex == -1) {
      throw Exception('Comment not found');
    }

    final comment = _mockComments[commentIndex];
    final updatedComment = comment.copyWith(
      isLiked: !comment.isLiked,
      likeCount: comment.isLiked ? comment.likeCount - 1 : comment.likeCount + 1,
      updatedAt: DateTime.now(),
    );

    _mockComments[commentIndex] = updatedComment;
    return updatedComment;
  }

  static Future<Comment> getCommentById(int commentId) async {
    await Future.delayed(Duration(milliseconds: 200));

    final comment = _mockComments.firstWhere(
      (comment) => comment.id == commentId,
      orElse: () => throw Exception('Comment not found'),
    );

    return comment;
  }

  static Future<List<Comment>> getCommentsByUser(String userEmail) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final userComments = _mockComments.where((comment) => comment.authorEmail == userEmail).toList();
    userComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return userComments;
  }

  static Future<void> deleteComment(int commentId) async {
    await Future.delayed(Duration(milliseconds: 300));

    final commentIndex = _mockComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex == -1) {
      throw Exception('Comment not found');
    }

    final comment = _mockComments[commentIndex];
    final topicId = comment.topicId;
    
    _mockComments.removeAt(commentIndex);
    
    // Update the topic's comment count
    await TopicService.decrementCommentCount(topicId);
  }

  /// Delete a comment as tutor (moderator privilege)
  static Future<void> deleteCommentAsTutor(int commentId, String tutorEmail) async {
    await Future.delayed(Duration(milliseconds: 300));

    final commentIndex = _mockComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex == -1) {
      throw Exception('Comment not found');
    }

    final comment = _mockComments[commentIndex];
    final topicId = comment.topicId;
    
    _mockComments.removeAt(commentIndex);
    
    // Update the topic's comment count
    await TopicService.decrementCommentCount(topicId);
  }

  static Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));

    if (content.trim().isEmpty) {
      throw Exception('Comment content cannot be empty');
    }

    if (content.trim().length < 3) {
      throw Exception('Comment must be at least 3 characters long');
    }

    final commentIndex = _mockComments.indexWhere((comment) => comment.id == commentId);
    if (commentIndex == -1) {
      throw Exception('Comment not found');
    }

    final comment = _mockComments[commentIndex];
    final updatedComment = comment.copyWith(
      content: content.trim(),
      updatedAt: DateTime.now(),
    );

    _mockComments[commentIndex] = updatedComment;
    return updatedComment;
  }

  static int getCommentCountForTopic(int topicId) {
    return _mockComments.where((comment) => comment.topicId == topicId).length;
  }

  static List<Comment> getAllComments() {
    return List.from(_mockComments);
  }

  static void clearAllComments() {
    _mockComments.clear();
    _nextCommentId = 1;
  }

  static Future<List<Comment>> searchComments(String query) async {
    await Future.delayed(Duration(milliseconds: 400));

    if (query.trim().isEmpty) {
      return [];
    }

    final searchQuery = query.toLowerCase().trim();
    final matchingComments = _mockComments.where((comment) {
      return comment.content.toLowerCase().contains(searchQuery) ||
             comment.authorName.toLowerCase().contains(searchQuery);
    }).toList();

    matchingComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matchingComments;
  }
}