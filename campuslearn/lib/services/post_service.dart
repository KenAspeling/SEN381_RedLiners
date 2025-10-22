import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/models/comment.dart';

class PostService {
  /// Get all liked posts (topics, posts, and comments) for the current user
  static Future<List<dynamic>> getLikedPosts() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/posts/liked'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load liked posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting liked posts: $e');
      rethrow;
    }
  }

  /// Get liked topics only (Type = 3)
  static Future<List<Topic>> getLikedTopics() async {
    try {
      final likedPosts = await getLikedPosts();
      final topics = likedPosts
          .where((post) => post['type'] == 3)
          .map((post) => _convertToTopic(post))
          .toList();
      return topics;
    } catch (e) {
      print('Error getting liked topics: $e');
      rethrow;
    }
  }

  /// Get liked comments only (Type = 1)
  static Future<List<Comment>> getLikedComments() async {
    try {
      final likedPosts = await getLikedPosts();
      final comments = likedPosts
          .where((post) => post['type'] == 1)
          .map((post) => _convertToComment(post))
          .toList();
      return comments;
    } catch (e) {
      print('Error getting liked comments: $e');
      rethrow;
    }
  }

  /// Convert backend post JSON to Topic model
  static Topic _convertToTopic(Map<String, dynamic> post) {
    return Topic(
      id: post['postId'] ?? 0,
      title: post['title'] ?? '',
      content: post['content'] ?? '',
      authorName: post['authorEmail'] ?? 'Unknown',
      authorEmail: post['authorEmail'] ?? 'unknown@campuslearn.com',
      createdAt: post['timeCreated'] != null
          ? DateTime.parse(post['timeCreated'])
          : DateTime.now(),
      updatedAt: post['timeCreated'] != null
          ? DateTime.parse(post['timeCreated'])
          : DateTime.now(),
      likeCount: post['likeCount'] ?? 0,
      commentCount: post['commentCount'] ?? 0,
      viewCount: 0,
      isLiked: post['isLikedByCurrentUser'] ?? false,
      isAnnouncement: false,
    );
  }

  /// Convert backend post JSON to Comment model
  static Comment _convertToComment(Map<String, dynamic> post) {
    return Comment(
      id: post['postId'] ?? 0,
      topicId: post['parentPostId'] ?? 0,
      content: post['content'] ?? '',
      authorName: post['authorEmail'] ?? 'Unknown',
      authorEmail: post['authorEmail'] ?? 'unknown@campuslearn.com',
      createdAt: post['timeCreated'] != null
          ? DateTime.parse(post['timeCreated'])
          : DateTime.now(),
      updatedAt: post['timeCreated'] != null
          ? DateTime.parse(post['timeCreated'])
          : DateTime.now(),
      likeCount: post['likeCount'] ?? 0,
      isLiked: post['isLikedByCurrentUser'] ?? false,
    );
  }
}
