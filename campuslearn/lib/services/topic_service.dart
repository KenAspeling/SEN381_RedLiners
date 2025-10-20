import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';

class TopicService {
  /// Get all topics from the backend API
  static Future<List<Topic>> getAllTopics() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.topicsUrl),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Topic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching topics: $e');
      // Fallback to mock data if API fails
      return _getMockTopics();
    }
  }

  /// Get topics by specific user
  static Future<List<Topic>> getTopicsByUser(String userEmail) async {
    try {
      // For now, get all topics and filter by user email
      // TODO: Update backend to accept email parameter
      final allTopics = await getAllTopics();
      return allTopics.where((topic) => topic.authorEmail == userEmail).toList();
    } catch (e) {
      print('Error fetching user topics: $e');
      return [];
    }
  }

  /// Create a new topic
  static Future<Topic> createTopic({
    required String title,
    required String content,
    required String authorName,
    required String authorEmail,
    bool isAnnouncement = false,
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty) {
        throw Exception('Topic title cannot be empty');
      }
      if (content.trim().isEmpty) {
        throw Exception('Topic content cannot be empty');
      }
      if (title.length > 100) {
        throw Exception('Topic title cannot exceed 100 characters');
      }
      if (content.length > 2000) {
        throw Exception('Topic content cannot exceed 2000 characters');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.topicsUrl),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'title': title.trim(),
          'content': content.trim(),
          'isAnnouncement': isAnnouncement,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Topic.fromJson(jsonData);
      } else {
        throw Exception('Failed to create topic: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating topic: $e');
      rethrow;
    }
  }

  /// Toggle like status for a topic
  static Future<Topic> toggleLike(int topicId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.topicsUrl}/$topicId/like'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        // Get updated topic data
        final updatedTopic = await getTopicById(topicId);
        if (updatedTopic == null) {
          throw Exception('Topic not found after like toggle');
        }
        return updatedTopic;
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  /// Get a single topic by ID
  static Future<Topic?> getTopicById(int topicId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.topicsUrl}/$topicId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Topic.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load topic: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching topic by ID: $e');
      return null;
    }
  }

  /// Delete a topic
  static Future<void> deleteTopic(int topicId, String userEmail) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.topicsUrl}/$topicId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete topic: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting topic: $e');
      rethrow;
    }
  }

  /// Increment view count for a topic
  static Future<void> incrementViewCount(int topicId) async {
    try {
      // Note: The backend automatically increments view count when getting a topic
      // So we just call getTopicById which will increment the view count
      await getTopicById(topicId);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// Increment comment count (handled by backend when comments are added)
  static Future<void> incrementCommentCount(int topicId) async {
    // This is handled automatically by the backend when comments are created
    // No action needed from frontend
  }

  /// Decrement comment count (handled by backend when comments are deleted)
  static Future<void> decrementCommentCount(int topicId) async {
    // This is handled automatically by the backend when comments are deleted
    // No action needed from frontend
  }

  /// Delete a topic as tutor (moderator privilege)
  static Future<void> deleteTopicAsTutor(int topicId, String tutorEmail) async {
    // Same as deleteTopic for now - backend will check permissions
    await deleteTopic(topicId, tutorEmail);
  }

  /// Update topic content as tutor (moderation privilege)
  static Future<Topic> updateTopicAsTutor({
    required int topicId,
    required String tutorEmail,
    String? title,
    String? content,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title.trim();
      if (content != null) updateData['content'] = content.trim();

      final response = await http.put(
        Uri.parse('${ApiConfig.topicsUrl}/$topicId'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode(updateData),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Topic.fromJson(jsonData);
      } else {
        throw Exception('Failed to update topic: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating topic: $e');
      rethrow;
    }
  }

  /// Create an announcement (tutor privilege)
  static Future<Topic> createAnnouncement({
    required String title,
    required String content,
    required String tutorName,
    required String tutorEmail,
  }) async {
    return await createTopic(
      title: title,
      content: content,
      authorName: tutorName,
      authorEmail: tutorEmail,
      isAnnouncement: true,
    );
  }

  /// Search topics by title or content
  static Future<List<Topic>> searchTopics(String query) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('${ApiConfig.topicsUrl}/search').replace(
        queryParameters: {'query': query},
      );

      final response = await http.get(
        uri,
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Topic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search topics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching topics: $e');
      return [];
    }
  }

  /// Get trending topics (most liked/commented in last 7 days)
  static Future<List<Topic>> getTrendingTopics() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.topicsUrl}/trending'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Topic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending topics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trending topics: $e');
      return [];
    }
  }

  /// Clear all topics (for testing purposes)
  static void clearAllTopics() {
    // Not applicable for API version
    print('clearAllTopics not supported with API backend');
  }

  /// Get topic statistics
  static Map<String, int> getTopicStats() {
    // For now, return empty stats - would need backend endpoint
    return {
      'totalTopics': 0,
      'totalLikes': 0,
      'totalComments': 0,
      'totalViews': 0,
    };
  }

  /// Fallback mock data for when API is unavailable
  static List<Topic> _getMockTopics() {
    return [
      Topic(
        id: 1,
        title: 'Welcome to Campus Learn',
        content: 'This is a sample topic. The backend API is not available, so you\'re seeing mock data. Please ensure the backend server is running.',
        authorName: 'System',
        authorEmail: 'system@campus.edu',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        likeCount: 0,
        commentCount: 0,
        viewCount: 1,
        isLiked: false,
        isAnnouncement: true,
      ),
    ];
  }
}