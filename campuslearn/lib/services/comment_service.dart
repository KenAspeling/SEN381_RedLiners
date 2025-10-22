import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/models/comment.dart';
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';

class CommentService {
  /// Get all comments for a specific topic from backend API
  static Future<List<Comment>> getCommentsByTopic(int topicId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.postsUrl}/$topicId/comments'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => _convertToComment(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  /// Create a new comment via backend API
  static Future<Comment> createComment({
    required int topicId,
    required String content,
    required String authorName,
    required String authorEmail,
  }) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }

      if (content.trim().length < 3) {
        throw Exception('Comment must be at least 3 characters long');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.postsUrl),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'parentPostId': topicId,
          'content': content.trim(),
          'type': 1, // 1 = Comment type (PostTypes.Comment)
          'isAnonymous': false,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return _convertToComment(jsonData);
      } else {
        throw Exception('Failed to create comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating comment: $e');
      rethrow;
    }
  }

  /// Toggle like status for a comment
  /// Returns true if liked, false if unliked
  static Future<bool> toggleLike(int commentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.postsUrl}/$commentId/like'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        // Backend returns { "liked": true/false }
        final jsonResponse = json.decode(response.body);
        return jsonResponse['liked'] as bool? ?? false;
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  /// Convert backend post JSON to Comment model
  static Comment _convertToComment(Map<String, dynamic> json) {
    return Comment(
      id: json['postId'] ?? 0,
      topicId: json['parentPostId'] ?? 0,
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? 'Unknown',
      authorEmail: json['authorEmail'] ?? 'unknown@campuslearn.com',
      createdAt: json['timeCreated'] != null
          ? DateTime.parse(json['timeCreated'])
          : DateTime.now(),
      updatedAt: json['timeCreated'] != null
          ? DateTime.parse(json['timeCreated'])
          : DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLikedByCurrentUser'] ?? false,
    );
  }

  /// Delete a comment (admin only)
  static Future<void> deleteComment(int commentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.postsUrl}/$commentId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Update a comment (only comment author can update)
  static Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }

      if (content.trim().length < 3) {
        throw Exception('Comment must be at least 3 characters long');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.postsUrl}/$commentId'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'content': content.trim(),
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _convertToComment(jsonData);
      } else {
        throw Exception('Failed to update comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating comment: $e');
      rethrow;
    }
  }

  /// Get comments by user
  static Future<List<Comment>> getCommentsByUser(String userEmail) async {
    try {
      // Get user ID from email
      final userIdString = await AuthService.getUserId();
      final userId = int.tryParse(userIdString ?? '0');

      if (userId == null || userId == 0) {
        print('[CommentService] No valid user ID found');
        return [];
      }

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.postsUrl}/user/$userId/comments'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => _convertToComment(json)).toList();
      } else {
        print('[CommentService] Failed to load user comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[CommentService] Error fetching user comments: $e');
      return [];
    }
  }
}